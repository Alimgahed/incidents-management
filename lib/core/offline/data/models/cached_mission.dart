import 'dart:convert';

import 'package:hive/hive.dart';

/// On-disk representation of a single mission row. Same JSON-payload design as
/// [CachedIncident] — see that file for the rationale.
class CachedMission extends HiveObject {
  int idOrTempId;
  String dataJson;
  int updatedAtMs;
  bool hasPendingChanges;
  bool hasConflict;

  CachedMission({
    required this.idOrTempId,
    required this.dataJson,
    required this.updatedAtMs,
    this.hasPendingChanges = false,
    this.hasConflict = false,
  });

  Map<String, dynamic> toMap() => jsonDecode(dataJson) as Map<String, dynamic>;

  static CachedMission fromMap(
    Map<String, dynamic> json, {
    required int idOrTempId,
    bool hasPendingChanges = false,
  }) {
    return CachedMission(
      idOrTempId: idOrTempId,
      dataJson: jsonEncode(json),
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      hasPendingChanges: hasPendingChanges,
    );
  }
}

class CachedMissionAdapter extends TypeAdapter<CachedMission> {
  @override
  final int typeId = 102;

  @override
  CachedMission read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return CachedMission(
      idOrTempId: fields[0] as int,
      dataJson: fields[1] as String,
      updatedAtMs: fields[2] as int,
      hasPendingChanges: fields[3] as bool? ?? false,
      hasConflict: fields[4] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, CachedMission obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.idOrTempId)
      ..writeByte(1)
      ..write(obj.dataJson)
      ..writeByte(2)
      ..write(obj.updatedAtMs)
      ..writeByte(3)
      ..write(obj.hasPendingChanges)
      ..writeByte(4)
      ..write(obj.hasConflict);
  }
}
