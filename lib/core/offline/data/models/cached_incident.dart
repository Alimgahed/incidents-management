import 'dart:convert';

import 'package:hive/hive.dart';

/// On-disk representation of a single incident. We intentionally keep the
/// payload as JSON rather than mirroring [CurrentIncidentModel] field-by-field:
/// the backend schema evolves more often than the offline storage schema and
/// this de-coupling means the cache survives model changes.
///
/// Use [toMap] / [fromMap] to convert back and forth.
class CachedIncident extends HiveObject {
  /// Server id (positive int) OR a local-only temp id (negative int) created
  /// while offline. Server ids start at 1; temp ids start at -1 and decrement.
  int idOrTempId;

  /// JSON-encoded server payload, identical shape to `CurrentIncidentModel`.
  String dataJson;

  /// UTC ms since epoch of last successful refresh from the server.
  int updatedAtMs;

  /// `true` while there are pending sync items targeting this incident.
  bool hasPendingChanges;

  /// `true` if the server returned a conflict the last time we tried to sync.
  bool hasConflict;

  /// Optional UTC ms — used as a hint for SLA / “stale” coloring in the UI.
  int? createdAtMs;

  CachedIncident({
    required this.idOrTempId,
    required this.dataJson,
    required this.updatedAtMs,
    this.hasPendingChanges = false,
    this.hasConflict = false,
    this.createdAtMs,
  });

  Map<String, dynamic> toMap() => jsonDecode(dataJson) as Map<String, dynamic>;

  static CachedIncident fromMap(
    Map<String, dynamic> json, {
    required int idOrTempId,
    bool hasPendingChanges = false,
    bool hasConflict = false,
  }) {
    return CachedIncident(
      idOrTempId: idOrTempId,
      dataJson: jsonEncode(json),
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      hasPendingChanges: hasPendingChanges,
      hasConflict: hasConflict,
    );
  }
}

class CachedIncidentAdapter extends TypeAdapter<CachedIncident> {
  @override
  final int typeId = 101;

  @override
  CachedIncident read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < n; i++) reader.readByte(): reader.read(),
    };
    return CachedIncident(
      idOrTempId: fields[0] as int,
      dataJson: fields[1] as String,
      updatedAtMs: fields[2] as int,
      hasPendingChanges: fields[3] as bool? ?? false,
      hasConflict: fields[4] as bool? ?? false,
      createdAtMs: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, CachedIncident obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idOrTempId)
      ..writeByte(1)
      ..write(obj.dataJson)
      ..writeByte(2)
      ..write(obj.updatedAtMs)
      ..writeByte(3)
      ..write(obj.hasPendingChanges)
      ..writeByte(4)
      ..write(obj.hasConflict)
      ..writeByte(5)
      ..write(obj.createdAtMs);
  }
}
