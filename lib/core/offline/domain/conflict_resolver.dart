import 'package:dio/dio.dart';

import '../data/models/sync_enums.dart';
import '../data/models/sync_queue_item.dart';
import '../data/repositories/incident_cache_repository.dart';
import '../data/repositories/mission_cache_repository.dart';
import '../data/repositories/sync_queue_repository.dart';

/// Strategy used when the server rejects a queued write with HTTP 409.
///
/// The default policy is **server-wins for system fields, client-keeps for
/// user-typed fields** plus marking the item as `conflict` so a future UI
/// can surface it to the user. The policy is centralised here so individual
/// repositories don't have to reason about conflicts.
enum ConflictStrategy {
  /// Keep the local copy as-is, mark the queue item conflict, drop the queue
  /// item from automatic retry. UI surfaces it for manual review.
  preserveLocal,

  /// Discard the local change and accept the server version. Removes the
  /// queue item. Useful for low-stakes writes (e.g. notes).
  overwriteWithServer,

  /// Re-enqueue as a fresh pending item (after delay). Useful for transient
  /// 409s caused by race conditions like ETag mismatch.
  retryLater,
}

/// Lightweight envelope carrying the result of inspecting a server error.
class ConflictDecision {
  final ConflictStrategy strategy;
  final String detail;
  final Map<String, dynamic>? serverPayload;

  const ConflictDecision({
    required this.strategy,
    required this.detail,
    this.serverPayload,
  });
}

class ConflictResolver {
  ConflictResolver({
    required this.queue,
    required this.incidents,
    required this.missions,
  });

  final SyncQueueRepository queue;
  final IncidentCacheRepository incidents;
  final MissionCacheRepository missions;

  /// Examine the [DioException] returned by a failed sync attempt and produce
  /// a decision. Defaults to preserveLocal for any non-409 5xx and
  /// retryLater for 409 with `code = "stale"`.
  ConflictDecision inspect(DioException error) {
    final status = error.response?.statusCode ?? 0;
    final data = error.response?.data;
    final asMap = data is Map<String, dynamic> ? data : null;

    if (status == 409) {
      final code = asMap?['code']?.toString();
      if (code == 'stale' || code == 'version_mismatch') {
        return ConflictDecision(
          strategy: ConflictStrategy.retryLater,
          detail: asMap?['message']?.toString() ?? 'Stale version',
          serverPayload: asMap,
        );
      }
      return ConflictDecision(
        strategy: ConflictStrategy.preserveLocal,
        detail: asMap?['message']?.toString() ?? 'Server reported a conflict',
        serverPayload: asMap,
      );
    }

    // Anything else is a "not a conflict" — caller should treat as failure.
    return ConflictDecision(
      strategy: ConflictStrategy.retryLater,
      detail: error.message ?? 'Transient server error',
    );
  }

  /// Apply the decision: update queue state and flag the affected cached
  /// entity so the UI can render a conflict badge.
  Future<void> apply({
    required SyncQueueItem item,
    required ConflictDecision decision,
  }) async {
    final entity = _parseEntityRef(item.entityRef);

    switch (decision.strategy) {
      case ConflictStrategy.preserveLocal:
        await queue.markConflict(item.id, decision.detail);
        if (entity != null) {
          if (entity.type == 'incident') {
            await incidents.markConflict(entity.id, true);
          }
        }
        break;

      case ConflictStrategy.overwriteWithServer:
        await queue.markSynced(item.id); // drops the queue item
        if (entity != null) {
          if (entity.type == 'incident') {
            await incidents.markPending(entity.id, false);
            await incidents.markConflict(entity.id, false);
          }
        }
        break;

      case ConflictStrategy.retryLater:
        await queue.markFailed(item.id, decision.detail);
        break;
    }
  }

  _EntityRef? _parseEntityRef(String? ref) {
    if (ref == null) return null;
    final parts = ref.split(':');
    if (parts.length != 2) return null;
    final id = int.tryParse(parts[1]);
    if (id == null) return null;
    return _EntityRef(parts[0], id);
  }
}

class _EntityRef {
  final String type;
  final int id;
  _EntityRef(this.type, this.id);
}
