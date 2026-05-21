import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';

import '../data/models/cached_attachment.dart';
import '../data/models/sync_enums.dart';
import '../data/models/sync_queue_item.dart';
import '../data/repositories/attachment_cache_repository.dart';
import '../data/repositories/incident_cache_repository.dart';
import '../data/repositories/mission_cache_repository.dart';
import '../data/repositories/sync_queue_repository.dart';
import '../network/network_monitor.dart';
import 'conflict_resolver.dart';
import 'id_remap_service.dart';

/// Drains the offline sync queue, talks to the backend, and updates local
/// caches accordingly. The manager is single-flighted: only one drain pass
/// runs at a time, guaranteed by [_drainLock].
///
/// Lifecycle:
///   * [start] is called once during bootstrap. It hooks into [NetworkMonitor]
///     so a reconnect automatically triggers [syncNow].
///   * [syncNow] is safe to call at any time — from a foreground BLoC, a
///     pull-to-refresh, or a background WorkManager task.
///   * Items that fail with retryable errors stay in the queue; non-retryable
///     errors (validation, 4xx other than 401/409) flip the item to `failed`
///     and surface to the UI.
class SyncManager {
  SyncManager({
    required this.queue,
    required this.attachments,
    required this.incidents,
    required this.missions,
    required this.networkMonitor,
    required this.conflictResolver,
    required this.idRemapService,
    required Dio Function() dioBuilder,
  }) : _dioBuilder = dioBuilder;

  final SyncQueueRepository queue;
  final AttachmentCacheRepository attachments;
  final IncidentCacheRepository incidents;
  final MissionCacheRepository missions;
  final NetworkMonitorService networkMonitor;
  final ConflictResolver conflictResolver;
  final IdRemapService idRemapService;

  final Dio Function() _dioBuilder;

  final Lock _drainLock = Lock();
  bool _isSyncing = false;
  Timer? _periodicTimer;
  StreamSubscription<bool>? _onlineSub;

  final StreamController<SyncStatusEvent> _events =
      StreamController<SyncStatusEvent>.broadcast();

  /// Stream of sync lifecycle events for UI consumption.
  Stream<SyncStatusEvent> get events => _events.stream;

  bool get isSyncing => _isSyncing;

  /// Wire into NetworkMonitor and schedule the foreground periodic sweep.
  /// Background sync is handled separately by [BackgroundSyncService].
  ///
  /// We use two redundant triggers so a missed event never leaves the queue
  /// stranded:
  ///   1. Direct subscription to [NetworkMonitorService.onlineStream] — fires
  ///      on every emission, so even if the reconnect-callback path missed
  ///      one (e.g. listener race during bootstrap), this catches it.
  ///   2. A short periodic sweep (every 20 seconds) that retries the queue
  ///      while we're online — covers any edge case where the stream is
  ///      paused or the listener is gone.
  Future<void> start() async {
    // 0. Recover items left in `syncing` state from a previous app run.
    await queue.resetStuckSyncing();

    // 1. Reconnect listener (legacy entry point, still useful for tests).
    networkMonitor.addReconnectListener(syncNow);

    // 2. PRIMARY trigger: every emission of `true` on the online stream runs
    //    syncNow. This is what guarantees pending writes flush the moment
    //    connectivity comes back, regardless of which path detected it
    //    (OS event, periodic probe, or manual Retry).
    _onlineSub?.cancel();
    _onlineSub = networkMonitor.onlineStream.listen((online) {
      if (online) {
        unawaited(syncNow());
      }
    });

    // 3. Safety-net foreground sweep.
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (networkMonitor.isOnline) {
        unawaited(syncNow());
      }
    });

    // 4. Immediately drain anything left over from a previous session.
    if (networkMonitor.isOnline) {
      unawaited(syncNow());
    }
  }

  Future<void> stop() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _onlineSub?.cancel();
    _onlineSub = null;
    networkMonitor.removeReconnectListener(syncNow);
  }

  /// Drain whatever is pending right now. Safe to call from anywhere; calls
  /// while a previous drain is in flight are coalesced by [_drainLock].
  Future<void> syncNow() async {
    if (!networkMonitor.isOnline) return;
    await _drainLock.synchronized(_drainOnce);
  }

  Future<void> _drainOnce() async {
    _isSyncing = true;
    _events.add(const SyncStatusEvent.started());

    try {
      // 1. Drain regular write queue (FIFO).
      var items = queue.pending();
      while (items.isNotEmpty) {
        for (final item in items) {
          if (!networkMonitor.isOnline) {
            _events.add(const SyncStatusEvent.pausedOffline());
            return;
          }
          await _processItem(item);
        }
        items = queue.pending();
      }

      // 2. Drain pending attachment uploads.
      final pendingAttachments = attachments.pendingUploads();
      for (final att in pendingAttachments) {
        if (!networkMonitor.isOnline) {
          _events.add(const SyncStatusEvent.pausedOffline());
          return;
        }
        await _uploadAttachment(att);
      }

      _events.add(SyncStatusEvent.completed(
        pendingLeft: queue.countPending(),
        conflicts: queue.countConflicts(),
      ));
    } finally {
      _isSyncing = false;
    }
  }

  // ── single item processing ─────────────────────────────────────────────────

  Future<void> _processItem(SyncQueueItem item) async {
    await queue.markSyncing(item.id);
    _events.add(SyncStatusEvent.itemStarted(item.id, item.endpoint));

    try {
      final dio = _dioBuilder();
      final response = await dio.request<dynamic>(
        item.endpoint,
        data: item.payloadJson,
        queryParameters: item.queryParams,
        options: Options(
          method: _methodFor(item.operation),
          contentType: Headers.jsonContentType,
          headers: {
            // Mark this request so the offline interceptor lets it through
            // even if connectivity drops mid-flight.
            'X-Offline-Replay': 'true',
            ...?item.headers,
          },
          // Treat all <500 as resolvable so we can branch on status code.
          validateStatus: (code) => code != null && code < 500,
        ),
      );

      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) {
        await _onItemSuccess(item, response.data);
      } else if (status == 409) {
        final fakeError = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
        final decision = conflictResolver.inspect(fakeError);
        await conflictResolver.apply(item: item, decision: decision);
        _events.add(SyncStatusEvent.itemConflict(item.id, decision.detail));
      } else {
        // 4xx other than 409: don't retry — the server is rejecting the data.
        await queue.markConflict(item.id, 'HTTP $status: ${response.data}');
        _events.add(SyncStatusEvent.itemFailed(item.id, 'HTTP $status'));
      }
    } on DioException catch (e) {
      // Retryable transport errors → re-queue with exponential backoff.
      final transient = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.error is SocketException);

      if (transient) {
        await queue.markFailed(item.id, e.message ?? 'Transient error');
        _events.add(SyncStatusEvent.itemFailed(item.id, 'Transient'));
      } else if (e.response?.statusCode == 409) {
        final decision = conflictResolver.inspect(e);
        await conflictResolver.apply(item: item, decision: decision);
        _events.add(SyncStatusEvent.itemConflict(item.id, decision.detail));
      } else {
        await queue.markConflict(
            item.id, e.response?.data?.toString() ?? e.message ?? 'Unknown');
        _events.add(SyncStatusEvent.itemFailed(item.id, 'Permanent'));
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('Unexpected sync error: $e\n$st');
      await queue.markFailed(item.id, e.toString());
      _events.add(SyncStatusEvent.itemFailed(item.id, 'Unexpected'));
    }
  }

  Future<void> _onItemSuccess(SyncQueueItem item, dynamic responseData) async {
    // 1. If this item created an entity with a temp id, remap to server id.
    if (item.tempLocalId != null) {
      final tempId = int.tryParse(item.tempLocalId!);
      if (tempId != null && responseData is Map<String, dynamic>) {
        final serverId = _extractServerIdFromResponse(responseData, item);
        if (serverId != null) {
          if (item.entityRef?.startsWith('incident:') ?? false) {
            await idRemapService.remapIncidentId(
              tempId: tempId,
              serverId: serverId,
              mergeServerJson: responseData,
            );
          } else if (item.entityRef?.startsWith('mission:') ?? false) {
            await idRemapService.remapMissionId(
              tempId: tempId,
              serverId: serverId,
              mergeServerJson: responseData,
            );
          }
        }
      }
    }

    // 2. Flip the cached entity to clean.
    final ref = item.entityRef;
    if (ref != null && ref.startsWith('incident:')) {
      final id = int.tryParse(ref.split(':')[1]);
      if (id != null) {
        await incidents.markPending(id, false);
        await incidents.markConflict(id, false);
      }
    }

    // 3. Drop the queue item.
    await queue.markSynced(item.id);
    _events.add(SyncStatusEvent.itemSynced(item.id));
  }

  /// Best-effort extraction of the server's new id from a create response.
  /// Falls back to a few common field names used across the API.
  int? _extractServerIdFromResponse(
    Map<String, dynamic> response,
    SyncQueueItem item,
  ) {
    for (final key in const [
      'current_incident_id',
      'id',
      'mission_id',
      'incident_id',
    ]) {
      final v = response[key];
      if (v is int && v > 0) return v;
      if (v is String) {
        final parsed = int.tryParse(v);
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    // Nested envelopes: { "data": { "id": 123 } }
    final nested = response['data'];
    if (nested is Map<String, dynamic>) {
      return _extractServerIdFromResponse(nested, item);
    }
    return null;
  }

  // ── attachment uploads ─────────────────────────────────────────────────────

  Future<void> _uploadAttachment(CachedAttachment att) async {
    final incidentId = att.incidentIdOrTempId;
    // Don't try to upload attachments tied to an incident that hasn't synced
    // yet — wait for the parent's remap to land first.
    if (incidentId < 0) return;

    final file = File(att.localFilePath);
    if (!await file.exists()) {
      await attachments.recordFailure(att.localId, 'File missing on disk');
      return;
    }

    try {
      final dio = _dioBuilder();
      final formData = FormData.fromMap({
        'description': att.description,
        'x_axis': att.xAxis.toString(),
        'y_axis': att.yAxis.toString(),
        'photo': await MultipartFile.fromFile(
          att.localFilePath,
          filename: att.fileName,
        ),
      });

      final response = await dio.post(
        '/upload-incident-photo/$incidentId',
        data: formData,
        options: Options(
          headers: const {'X-Offline-Replay': 'true'},
        ),
      );

      if (response.statusCode == 200) {
        int serverId = 0;
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final v = data['id'] ?? data['photo_id'];
          if (v is int) serverId = v;
        }
        await attachments.markUploaded(localId: att.localId, serverId: serverId);
        _events.add(SyncStatusEvent.attachmentSynced(att.localId));
      } else {
        await attachments.recordFailure(att.localId, 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      await attachments.recordFailure(att.localId, e.toString());
    }
  }

  String _methodFor(SyncOperation op) {
    switch (op) {
      case SyncOperation.post:
      case SyncOperation.upload:
        return 'POST';
      case SyncOperation.put:
        return 'PUT';
      case SyncOperation.patch:
        return 'PATCH';
      case SyncOperation.delete:
        return 'DELETE';
    }
  }

  void dispose() {
    _periodicTimer?.cancel();
    _events.close();
  }
}

/// Lightweight discriminated union for sync lifecycle events.
class SyncStatusEvent {
  final SyncStatusKind kind;
  final String? itemId;
  final String? message;
  final int? pendingLeft;
  final int? conflicts;

  const SyncStatusEvent._({
    required this.kind,
    this.itemId,
    this.message,
    this.pendingLeft,
    this.conflicts,
  });

  const SyncStatusEvent.started() : this._(kind: SyncStatusKind.started);
  const SyncStatusEvent.pausedOffline()
      : this._(kind: SyncStatusKind.pausedOffline);
  const SyncStatusEvent.completed({int? pendingLeft, int? conflicts})
      : this._(
          kind: SyncStatusKind.completed,
          pendingLeft: pendingLeft,
          conflicts: conflicts,
        );
  const SyncStatusEvent.itemStarted(String id, String endpoint)
      : this._(kind: SyncStatusKind.itemStarted, itemId: id, message: endpoint);
  const SyncStatusEvent.itemSynced(String id)
      : this._(kind: SyncStatusKind.itemSynced, itemId: id);
  const SyncStatusEvent.itemFailed(String id, String detail)
      : this._(kind: SyncStatusKind.itemFailed, itemId: id, message: detail);
  const SyncStatusEvent.itemConflict(String id, String detail)
      : this._(kind: SyncStatusKind.itemConflict, itemId: id, message: detail);
  const SyncStatusEvent.attachmentSynced(String id)
      : this._(kind: SyncStatusKind.attachmentSynced, itemId: id);
}

enum SyncStatusKind {
  started,
  pausedOffline,
  completed,
  itemStarted,
  itemSynced,
  itemFailed,
  itemConflict,
  attachmentSynced,
}
