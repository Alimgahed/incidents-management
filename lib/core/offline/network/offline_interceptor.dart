import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/local_database.dart';
import '../data/models/sync_enums.dart';
import '../data/models/sync_queue_item.dart';
import '../data/repositories/sync_queue_repository.dart';
import 'network_monitor.dart';

/// The single seam that turns every existing repository in the app into
/// an offline-aware one.
///
/// Behaviour:
///   * `X-Offline-Replay: true` header — request originates from the
///     [SyncManager] replay path; do **nothing**, just let it fly.
///   * `noOfflineQueue: true` in `RequestOptions.extra` — caller opts out
///     of queueing (used by login, token refresh, etc.). When offline this
///     short-circuits to an error so the caller can show a "you must be
///     online" message.
///   * GET requests — always attempted; on offline or network failure the
///     last successful response is replayed from [LocalDatabase.getCache].
///   * POST/PUT/PATCH/DELETE while offline — saved as a [SyncQueueItem] and
///     a synthetic 202 Accepted response is returned so the calling repo
///     keeps its happy path. The synthetic body carries the temp id (if any)
///     and a `__offline: true` flag so cubits/blocs can recognise it.
class OfflineInterceptor extends Interceptor {
  OfflineInterceptor({
    required this.queue,
    required this.networkMonitor,
  });

  final SyncQueueRepository queue;
  final NetworkMonitorService networkMonitor;
  static const _uuid = Uuid();

  // ── opt-in / opt-out keys used via RequestOptions.extra ───────────────────
  static const String kSkipOfflineQueue = 'noOfflineQueue';

  /// Caller can pass `extra: { entityRef: 'incident:42' }` to bind the
  /// queued item to a logical entity for conflict UI / id-remap.
  static const String kEntityRef = 'entityRef';

  /// Caller can pass `extra: { tempLocalId: '-42' }` so the SyncManager knows
  /// to remap a temp id once the server responds.
  static const String kTempLocalId = 'tempLocalId';

  /// Caller can pass `extra: { attachmentPath: '/data/...jpg' }` to mark this
  /// queue item as an attachment upload.
  static const String kAttachmentPath = 'attachmentPath';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Replay path → pass through.
    if (options.headers['X-Offline-Replay'] == 'true') {
      return handler.next(options);
    }

    final method = options.method.toUpperCase();
    final isWrite = method == 'POST' ||
        method == 'PUT' ||
        method == 'PATCH' ||
        method == 'DELETE';

    if (networkMonitor.isOnline) {
      // Online → normal path; the response interceptor will cache GETs.
      return handler.next(options);
    }

    // ── Offline branch ────────────────────────────────────────────────────
    if (!isWrite) {
      // GET request offline: try to serve from cache.
      final cached = _readCachedGet(options);
      if (cached != null) {
        if (kDebugMode) {
          debugPrint('OfflineInterceptor: serving cached GET ${options.uri}');
        }
        return handler.resolve(Response(
          requestOptions: options,
          data: cached,
          statusCode: 200,
          headers: Headers.fromMap(const {
            'x-source': ['offline-cache'],
          }),
        ));
      }
      // No cache — fail with a typed error the repos already handle.
      return handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline_no_cache',
        message: 'Offline and no cached data for ${options.path}',
      ));
    }

    // Write while offline.
    if (options.extra[kSkipOfflineQueue] == true) {
      return handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
        error: 'offline_no_queue',
        message: 'This action requires an active internet connection.',
      ));
    }

    final item = _toQueueItem(options);
    await queue.add(item);

    if (kDebugMode) {
      debugPrint('OfflineInterceptor: queued ${item.operation.name.toUpperCase()} ${item.endpoint} (id=${item.id})');
    }

    // Synthetic optimistic response so callers don't break.
    final synthetic = <String, dynamic>{
      '__offline': true,
      '__queue_id': item.id,
      'message': 'Queued for sync',
      if (item.tempLocalId != null) 'temp_id': item.tempLocalId,
      if (item.entityRef != null) 'entity_ref': item.entityRef,
      // Best-effort echo of the request body so cubits can update the UI.
      if (item.payload != null) 'data': item.payload,
    };

    return handler.resolve(Response(
      requestOptions: options,
      data: synthetic,
      statusCode: 202,
      statusMessage: 'Accepted (offline queue)',
      headers: Headers.fromMap(const {
        'x-source': ['offline-queue'],
      }),
    ));
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Cache successful GETs for the offline-read path.
    final method = response.requestOptions.method.toUpperCase();
    if (method == 'GET' && (response.statusCode ?? 0) == 200) {
      _writeCachedGet(response);
    }
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final method = err.requestOptions.method.toUpperCase();
    final isWrite = method == 'POST' ||
        method == 'PUT' ||
        method == 'PATCH' ||
        method == 'DELETE';

    final isTransport = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    // Any transport failure is the earliest possible signal that we've gone
    // offline — much earlier than the OS-level event (which iOS sometimes
    // swallows entirely). Ask the monitor to immediately re-probe.
    if (isTransport && networkMonitor.isOnline) {
      networkMonitor.reportTransportFailure();
    }

    // Network died mid-flight on a write → queue it and pretend it succeeded.
    if (isWrite && isTransport) {
      if (err.requestOptions.headers['X-Offline-Replay'] == 'true' ||
          err.requestOptions.extra[kSkipOfflineQueue] == true) {
        return handler.next(err);
      }
      final item = _toQueueItem(err.requestOptions);
      await queue.add(item);

      final synthetic = <String, dynamic>{
        '__offline': true,
        '__queue_id': item.id,
        '__reason': 'transport_failure',
        'message': 'Queued for sync (network dropped)',
        if (item.tempLocalId != null) 'temp_id': item.tempLocalId,
        if (item.payload != null) 'data': item.payload,
      };
      return handler.resolve(Response(
        requestOptions: err.requestOptions,
        data: synthetic,
        statusCode: 202,
        statusMessage: 'Accepted (offline queue after failure)',
      ));
    }

    // GET that died on transport → try cache.
    if (!isWrite && isTransport) {
      final cached = _readCachedGet(err.requestOptions);
      if (cached != null) {
        return handler.resolve(Response(
          requestOptions: err.requestOptions,
          data: cached,
          statusCode: 200,
          headers: Headers.fromMap(const {
            'x-source': ['offline-cache-after-failure'],
          }),
        ));
      }
    }

    return handler.next(err);
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  SyncQueueItem _toQueueItem(RequestOptions options) {
    final method = options.method.toUpperCase();
    final op = switch (method) {
      'POST' => SyncOperation.post,
      'PUT' => SyncOperation.put,
      'PATCH' => SyncOperation.patch,
      'DELETE' => SyncOperation.delete,
      _ => SyncOperation.post,
    };

    String? payloadJson;
    if (options.data != null) {
      try {
        // Dio may give us a Map, a JSON string, or FormData. We only support
        // JSON-encodable payloads in the queue — FormData has to go through
        // the dedicated attachment flow.
        if (options.data is FormData) {
          payloadJson = null;
        } else if (options.data is String) {
          payloadJson = options.data as String;
        } else {
          payloadJson = jsonEncode(options.data);
        }
      } catch (_) {
        payloadJson = null;
      }
    }

    final queryJson = options.queryParameters.isEmpty
        ? null
        : jsonEncode(options.queryParameters);

    final extra = options.extra;
    final entityRef = extra[kEntityRef] as String?;
    final tempLocalId = extra[kTempLocalId] as String?;
    final attachmentPath = extra[kAttachmentPath] as String?;

    return SyncQueueItem(
      id: _uuid.v4(),
      operation: attachmentPath != null ? SyncOperation.upload : op,
      endpoint: _relativePath(options),
      payloadJson: payloadJson,
      queryParamsJson: queryJson,
      headersJson: null, // intentionally drop — auth header is re-added on replay
      entityRef: entityRef,
      tempLocalId: tempLocalId,
      attachmentPath: attachmentPath,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  String _relativePath(RequestOptions options) {
    final full = options.uri.toString();
    final base = options.baseUrl;
    if (base.isNotEmpty && full.startsWith(base)) {
      return full.substring(base.length);
    }
    return options.path;
  }

  void _writeCachedGet(Response response) {
    try {
      final key = response.requestOptions.uri.toString();
      final payload = jsonEncode({
        'data': response.data,
        'at': DateTime.now().millisecondsSinceEpoch,
      });
      LocalDatabase.getCache.put(key, payload);
    } catch (_) {
      // Cache is best-effort — never let it break the request flow.
    }
  }

  dynamic _readCachedGet(RequestOptions options) {
    try {
      final key = options.uri.toString();
      final raw = LocalDatabase.getCache.get(key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded['data'];
    } catch (_) {
      return null;
    }
  }
}
