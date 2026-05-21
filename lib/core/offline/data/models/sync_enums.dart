import 'package:hive/hive.dart';

/// Lifecycle state of a queued operation.
///
/// The order of values is part of the on-disk schema — never reorder or remove.
/// New values must be appended to the end.
enum SyncState {
  pending,   // 0 - waiting to be sent
  syncing,   // 1 - currently in flight
  synced,    // 2 - confirmed by server
  failed,    // 3 - retry exhausted, server rejected
  conflict,  // 4 - server returned 409 or version mismatch
}

/// HTTP-level intent of the queued operation.
enum SyncOperation {
  post,
  put,
  patch,
  delete,
  upload, // multipart/form-data upload (image, file)
}

/// Hive adapter for [SyncState]. Manual adapter avoids build_runner.
class SyncStateAdapter extends TypeAdapter<SyncState> {
  @override
  final int typeId = 110;

  @override
  SyncState read(BinaryReader reader) {
    final index = reader.readByte();
    if (index < 0 || index >= SyncState.values.length) {
      return SyncState.pending;
    }
    return SyncState.values[index];
  }

  @override
  void write(BinaryWriter writer, SyncState obj) {
    writer.writeByte(obj.index);
  }
}

/// Hive adapter for [SyncOperation].
class SyncOperationAdapter extends TypeAdapter<SyncOperation> {
  @override
  final int typeId = 111;

  @override
  SyncOperation read(BinaryReader reader) {
    final index = reader.readByte();
    if (index < 0 || index >= SyncOperation.values.length) {
      return SyncOperation.post;
    }
    return SyncOperation.values[index];
  }

  @override
  void write(BinaryWriter writer, SyncOperation obj) {
    writer.writeByte(obj.index);
  }
}
