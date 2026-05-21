import 'dart:async';

import 'package:hive/hive.dart';

import '../local_database.dart';
import '../models/cached_mission.dart';

/// Symmetric counterpart to [IncidentCacheRepository] for mission rows.
class MissionCacheRepository {
  Box<CachedMission> get _box => LocalDatabase.missions;

  Stream<BoxEvent> watch() => _box.watch();

  Future<void> upsert(CachedMission item) =>
      _box.put(_keyFor(item.idOrTempId), item);

  Future<void> upsertAll(Iterable<CachedMission> items) =>
      _box.putAll({for (final i in items) _keyFor(i.idOrTempId): i});

  CachedMission? get(int idOrTempId) => _box.get(_keyFor(idOrTempId));

  Future<void> remove(int idOrTempId) => _box.delete(_keyFor(idOrTempId));

  List<CachedMission> list({
    int offset = 0,
    int limit = 200,
    String? search,
    bool Function(CachedMission)? where,
  }) {
    final values = _box.values.toList()
      ..sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));

    Iterable<CachedMission> filtered = values;
    if (where != null) filtered = filtered.where(where);

    if (search != null && search.trim().isNotEmpty) {
      final needle = search.trim().toLowerCase();
      filtered = filtered.where((m) {
        final json = m.toMap();
        final name = (json['mission_name'] ?? '').toString().toLowerCase();
        return name.contains(needle);
      });
    }

    return filtered.skip(offset).take(limit).toList();
  }

  Future<void> remapTempIdToServerId({
    required int tempId,
    required int serverId,
    Map<String, dynamic>? mergeWithServerJson,
  }) async {
    final existing = get(tempId);
    if (existing == null) return;
    final base = existing.toMap();
    if (mergeWithServerJson != null) base.addAll(mergeWithServerJson);
    base['id'] = serverId;

    final renamed = CachedMission.fromMap(base, idOrTempId: serverId);
    await _box.delete(_keyFor(tempId));
    await upsert(renamed);
  }

  String _keyFor(int id) => 'mis_$id';
}
