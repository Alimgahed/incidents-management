import 'dart:convert';

import '../data/models/sync_enums.dart';
import '../data/repositories/attachment_cache_repository.dart';
import '../data/repositories/incident_cache_repository.dart';
import '../data/repositories/mission_cache_repository.dart';
import '../data/repositories/sync_queue_repository.dart';

/// Rewrites temp ids → real server ids across the local cache and queued
/// follow-up operations.
///
/// Example flow:
///   1. User creates incident offline → temp id `-42` is assigned.
///   2. User adds a mission to that incident → queue item with
///      endpoint `/edit-current-incident/-42`.
///   3. Connectivity returns. SyncManager replays the create. Server returns
///      real id `7891`.
///   4. [remapIncidentId(-42, 7891)] is called. The cached incident gets
///      re-keyed; the pending mission's endpoint and payload are rewritten
///      from `-42` → `7891` so it can succeed when replayed.
class IdRemapService {
  IdRemapService({
    required this.incidents,
    required this.missions,
    required this.attachments,
    required this.queue,
  });

  final IncidentCacheRepository incidents;
  final MissionCacheRepository missions;
  final AttachmentCacheRepository attachments;
  final SyncQueueRepository queue;

  Future<void> remapIncidentId({
    required int tempId,
    required int serverId,
    Map<String, dynamic>? mergeServerJson,
  }) async {
    await incidents.remapTempIdToServerId(
      tempId: tempId,
      serverId: serverId,
      mergeWithServerJson: mergeServerJson,
    );
    await attachments.remapIncidentId(
      tempIncidentId: tempId,
      serverIncidentId: serverId,
    );
    await _rewriteQueue(
      oldNumericId: tempId,
      newNumericId: serverId,
      entityPrefix: 'incident',
    );
  }

  Future<void> remapMissionId({
    required int tempId,
    required int serverId,
    Map<String, dynamic>? mergeServerJson,
  }) async {
    await missions.remapTempIdToServerId(
      tempId: tempId,
      serverId: serverId,
      mergeWithServerJson: mergeServerJson,
    );
    await _rewriteQueue(
      oldNumericId: tempId,
      newNumericId: serverId,
      entityPrefix: 'mission',
    );
  }

  /// Rewrites every queue item whose endpoint, payload, entityRef or
  /// tempLocalId references [oldNumericId] so it now points at
  /// [newNumericId].
  Future<void> _rewriteQueue({
    required int oldNumericId,
    required int newNumericId,
    required String entityPrefix,
  }) async {
    final all = queue.pending() + queue.problematic();
    final oldStr = oldNumericId.toString();
    final newStr = newNumericId.toString();

    for (final item in all) {
      var dirty = false;

      // 1. URL substitution — only replace whole-segment occurrences so we
      //    don't accidentally turn "/12" into something else when ids overlap.
      final endpointAfter = _replaceUrlSegment(item.endpoint, oldStr, newStr);
      if (endpointAfter != item.endpoint) {
        item.endpoint = endpointAfter;
        dirty = true;
      }

      // 2. JSON body substitution — naive but safe because payloads are
      //    machine-generated.
      if (item.payloadJson != null && item.payloadJson!.contains(oldStr)) {
        final decoded = jsonDecode(item.payloadJson!);
        final rewritten = _replaceInJson(decoded, oldNumericId, newNumericId);
        item.payloadJson = jsonEncode(rewritten);
        dirty = true;
      }

      if (item.entityRef == '$entityPrefix:$oldNumericId') {
        item.entityRef = '$entityPrefix:$newNumericId';
        dirty = true;
      }

      if (item.tempLocalId == oldStr) {
        item.tempLocalId = null; // resolved
        dirty = true;
      }

      if (dirty) {
        if (item.state == SyncState.conflict) {
          item.state = SyncState.pending;
        }
        await queue.update(item);
      }
    }
  }

  String _replaceUrlSegment(String url, String oldId, String newId) {
    final segments = url.split('/');
    var changed = false;
    for (var i = 0; i < segments.length; i++) {
      if (segments[i] == oldId) {
        segments[i] = newId;
        changed = true;
      }
    }
    return changed ? segments.join('/') : url;
  }

  dynamic _replaceInJson(dynamic node, int oldId, int newId) {
    if (node is int && node == oldId) return newId;
    if (node is String && node == oldId.toString()) return newId.toString();
    if (node is List) {
      return node.map((e) => _replaceInJson(e, oldId, newId)).toList();
    }
    if (node is Map) {
      return node.map((k, v) => MapEntry(k, _replaceInJson(v, oldId, newId)));
    }
    return node;
  }
}
