import 'dart:async';

import 'package:hive/hive.dart';

import '../local_database.dart';
import '../models/cached_incident.dart';

/// Read/write access to the cached incident store.
///
/// Stores incidents keyed by their numeric id (positive for server ids,
/// negative for offline-created temp ids). Supports cheap pagination and
/// in-memory search/filter — sufficient for the typical incident volume of
/// a single user (hundreds, not millions).
class IncidentCacheRepository {
  Box<CachedIncident> get _box => LocalDatabase.incidents;

  Stream<BoxEvent> watch() => _box.watch();

  /// Insert or replace.
  Future<void> upsert(CachedIncident incident) async {
    await _box.put(_keyFor(incident.idOrTempId), incident);
  }

  Future<void> upsertAll(Iterable<CachedIncident> items) async {
    final map = {for (final i in items) _keyFor(i.idOrTempId): i};
    await _box.putAll(map);
  }

  CachedIncident? get(int idOrTempId) => _box.get(_keyFor(idOrTempId));

  Future<void> remove(int idOrTempId) =>
      _box.delete(_keyFor(idOrTempId));

  /// Newest first, optional pagination and free-text filter.
  List<CachedIncident> list({
    int offset = 0,
    int limit = 100,
    String? search,
    bool Function(CachedIncident)? where,
  }) {
    final values = _box.values.toList();
    values.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));

    Iterable<CachedIncident> filtered = values;
    if (where != null) filtered = filtered.where(where);

    if (search != null && search.trim().isNotEmpty) {
      final needle = search.trim().toLowerCase();
      filtered = filtered.where((i) {
        final map = i.toMap();
        final desc =
            (map['current_incident_description'] ?? '').toString().toLowerCase();
        final notes =
            (map['current_incident_notes'] ?? '').toString().toLowerCase();
        final type = (map['incident_type_name'] ?? '').toString().toLowerCase();
        final branch = (map['branch_name'] ?? '').toString().toLowerCase();
        return desc.contains(needle) ||
            notes.contains(needle) ||
            type.contains(needle) ||
            branch.contains(needle);
      });
    }

    return filtered.skip(offset).take(limit).toList();
  }

  int count() => _box.length;

  /// After a temp incident is committed to the server, swap its key from the
  /// negative temp id to the real server id without losing fields.
  Future<void> remapTempIdToServerId({
    required int tempId,
    required int serverId,
    Map<String, dynamic>? mergeWithServerJson,
  }) async {
    final existing = get(tempId);
    if (existing == null) return;

    final base = existing.toMap();
    if (mergeWithServerJson != null) {
      base.addAll(mergeWithServerJson);
    }
    base['current_incident_id'] = serverId;

    final renamed = CachedIncident.fromMap(
      base,
      idOrTempId: serverId,
      hasPendingChanges: false,
    );
    await _box.delete(_keyFor(tempId));
    await upsert(renamed);
  }

  Future<void> markConflict(int id, bool hasConflict) async {
    final existing = get(id);
    if (existing == null) return;
    existing.hasConflict = hasConflict;
    await upsert(existing);
  }

  Future<void> markPending(int id, bool hasPending) async {
    final existing = get(id);
    if (existing == null) return;
    existing.hasPendingChanges = hasPending;
    await upsert(existing);
  }

  /// Stable, sortable string key for any int id (positive or negative).
  /// Prefix lets the key namespace tolerate adjacent integer ranges in future.
  String _keyFor(int id) => 'inc_$id';
}
