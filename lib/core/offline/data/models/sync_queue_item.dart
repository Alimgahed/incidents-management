import 'dart:convert';

import 'package:hive/hive.dart';

import 'sync_enums.dart';

/// A single unit of work in the offline sync queue.
///
/// Every write that happens while the device is offline is materialised as a
/// [SyncQueueItem] and persisted in Hive. The [SyncManager] later drains the
/// queue in FIFO order, replays each item against the real backend, and updates
/// its [state].
///
/// The class is deliberately schema-light: the request body is stored as a
/// JSON-encoded `String` rather than a typed object. This keeps the queue
/// resilient to evolution of the domain models — adding/removing fields in the
/// API never breaks queued items already on disk.
class SyncQueueItem extends HiveObject {
  /// Stable unique id, generated client-side (`uuid v4`).
  String id;

  /// HTTP method intent.
  SyncOperation operation;

  /// Endpoint path, already templated (e.g. `/edit-current-incident/42`).
  String endpoint;

  /// JSON-encoded body, or `null` for DELETE.
  String? payloadJson;

  /// JSON-encoded query parameters, `null` if none.
  String? queryParamsJson;

  /// Optional headers to merge in (e.g. `If-Match`).
  String? headersJson;

  /// Local entity this item mutates — used for de-duplication and optimistic
  /// UI rollback (e.g. `incident:local_abc`, `mission:42`).
  String? entityRef;

  /// Local (temporary) id this item created, if any. Once the server returns a
  /// real id, [IdRemapService] uses this field to rewrite later queue items
  /// that referenced the temp id.
  String? tempLocalId;

  /// Absolute path to a file on the local filesystem. Used for image uploads
  /// that need to be deferred until connectivity returns. The [SyncManager]
  /// converts this into a `MultipartFile` when it processes the item.
  String? attachmentPath;

  /// Sync state.
  SyncState state;

  /// Number of attempts already made.
  int retryCount;

  /// UTC ms since epoch of last attempt.
  int? lastAttemptAtMs;

  /// UTC ms since epoch of creation.
  int createdAtMs;

  /// Last error message — kept for the UI to display under "failed" items.
  String? lastError;

  /// Next earliest time this item is eligible to be retried (UTC ms).
  int? nextEligibleAtMs;

  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.endpoint,
    required this.createdAtMs,
    this.payloadJson,
    this.queryParamsJson,
    this.headersJson,
    this.entityRef,
    this.tempLocalId,
    this.attachmentPath,
    this.state = SyncState.pending,
    this.retryCount = 0,
    this.lastAttemptAtMs,
    this.lastError,
    this.nextEligibleAtMs,
  });

  Map<String, dynamic>? get payload =>
      payloadJson == null ? null : jsonDecode(payloadJson!) as Map<String, dynamic>;

  Map<String, dynamic>? get queryParams =>
      queryParamsJson == null ? null : jsonDecode(queryParamsJson!) as Map<String, dynamic>;

  Map<String, dynamic>? get headers =>
      headersJson == null ? null : jsonDecode(headersJson!) as Map<String, dynamic>;

  bool get isWriteOperation =>
      operation == SyncOperation.post ||
      operation == SyncOperation.put ||
      operation == SyncOperation.patch ||
      operation == SyncOperation.delete ||
      operation == SyncOperation.upload;

  /// Update payload — also rewrites the encoded JSON.
  set payload(Map<String, dynamic>? value) {
    payloadJson = value == null ? null : jsonEncode(value);
  }
}

/// Manual Hive adapter — avoids `build_runner` so the offline module is
/// independent of code generation in the host app.
class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 100;

  @override
  SyncQueueItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItem(
      id: fields[0] as String,
      operation: fields[1] as SyncOperation,
      endpoint: fields[2] as String,
      payloadJson: fields[3] as String?,
      queryParamsJson: fields[4] as String?,
      headersJson: fields[5] as String?,
      entityRef: fields[6] as String?,
      tempLocalId: fields[7] as String?,
      attachmentPath: fields[8] as String?,
      state: fields[9] as SyncState,
      retryCount: fields[10] as int? ?? 0,
      lastAttemptAtMs: fields[11] as int?,
      createdAtMs: fields[12] as int,
      lastError: fields[13] as String?,
      nextEligibleAtMs: fields[14] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operation)
      ..writeByte(2)
      ..write(obj.endpoint)
      ..writeByte(3)
      ..write(obj.payloadJson)
      ..writeByte(4)
      ..write(obj.queryParamsJson)
      ..writeByte(5)
      ..write(obj.headersJson)
      ..writeByte(6)
      ..write(obj.entityRef)
      ..writeByte(7)
      ..write(obj.tempLocalId)
      ..writeByte(8)
      ..write(obj.attachmentPath)
      ..writeByte(9)
      ..write(obj.state)
      ..writeByte(10)
      ..write(obj.retryCount)
      ..writeByte(11)
      ..write(obj.lastAttemptAtMs)
      ..writeByte(12)
      ..write(obj.createdAtMs)
      ..writeByte(13)
      ..write(obj.lastError)
      ..writeByte(14)
      ..write(obj.nextEligibleAtMs);
  }
}
