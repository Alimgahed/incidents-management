import 'package:hive/hive.dart';

/// A photo / file attachment that the user picked while offline (or before the
/// server upload succeeded). Holds enough information to:
///   1. show a preview in the UI immediately (via [localFilePath]),
///   2. defer upload until connectivity returns (via [SyncManager]),
///   3. replace the local placeholder with the real server attachment once
///      upload completes (via [serverId]).
class CachedAttachment extends HiveObject {
  /// Stable local id (uuid). Used as the Hive key.
  String localId;

  /// Incident this attachment belongs to. May be a server id (positive) or a
  /// temp id (negative) created offline.
  int incidentIdOrTempId;

  /// Absolute path to the picked file on the local filesystem.
  String localFilePath;

  /// Original filename the user picked / camera captured.
  String fileName;

  /// Mime-type guess, e.g. `image/jpeg`. Optional.
  String? mimeType;

  /// Free-text description the user typed.
  String description;

  /// Geo at time of capture.
  double xAxis;
  double yAxis;

  /// `true` once the file has been uploaded and we have a [serverId].
  bool isUploaded;

  /// Server-side attachment id assigned after the upload completes.
  int? serverId;

  /// UTC ms when the user picked the file.
  int createdAtMs;

  /// UTC ms when the file was successfully uploaded (null if not yet).
  int? uploadedAtMs;

  /// Number of retry attempts so far.
  int retryCount;

  /// Last error message, for the UI.
  String? lastError;

  CachedAttachment({
    required this.localId,
    required this.incidentIdOrTempId,
    required this.localFilePath,
    required this.fileName,
    required this.description,
    required this.xAxis,
    required this.yAxis,
    required this.createdAtMs,
    this.mimeType,
    this.isUploaded = false,
    this.serverId,
    this.uploadedAtMs,
    this.retryCount = 0,
    this.lastError,
  });
}

class CachedAttachmentAdapter extends TypeAdapter<CachedAttachment> {
  @override
  final int typeId = 103;

  @override
  CachedAttachment read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return CachedAttachment(
      localId: fields[0] as String,
      incidentIdOrTempId: fields[1] as int,
      localFilePath: fields[2] as String,
      fileName: fields[3] as String,
      mimeType: fields[4] as String?,
      description: fields[5] as String,
      xAxis: (fields[6] as num).toDouble(),
      yAxis: (fields[7] as num).toDouble(),
      isUploaded: fields[8] as bool? ?? false,
      serverId: fields[9] as int?,
      createdAtMs: fields[10] as int,
      uploadedAtMs: fields[11] as int?,
      retryCount: fields[12] as int? ?? 0,
      lastError: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedAttachment obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.localId)
      ..writeByte(1)
      ..write(obj.incidentIdOrTempId)
      ..writeByte(2)
      ..write(obj.localFilePath)
      ..writeByte(3)
      ..write(obj.fileName)
      ..writeByte(4)
      ..write(obj.mimeType)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.xAxis)
      ..writeByte(7)
      ..write(obj.yAxis)
      ..writeByte(8)
      ..write(obj.isUploaded)
      ..writeByte(9)
      ..write(obj.serverId)
      ..writeByte(10)
      ..write(obj.createdAtMs)
      ..writeByte(11)
      ..write(obj.uploadedAtMs)
      ..writeByte(12)
      ..write(obj.retryCount)
      ..writeByte(13)
      ..write(obj.lastError);
  }
}
