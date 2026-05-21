import 'dart:async';

import 'package:hive/hive.dart';

import '../local_database.dart';
import '../models/cached_attachment.dart';

/// Read/write access to the cached attachment store.
///
/// The cache holds every file the user picked from camera/gallery while
/// offline (or while a previous upload was failing) so the UI can render a
/// preview even before the server has accepted the upload.
class AttachmentCacheRepository {
  Box<CachedAttachment> get _box => LocalDatabase.attachments;

  Stream<BoxEvent> watch() => _box.watch();

  Future<void> add(CachedAttachment attachment) =>
      _box.put(attachment.localId, attachment);

  Future<void> update(CachedAttachment attachment) =>
      _box.put(attachment.localId, attachment);

  Future<void> remove(String localId) => _box.delete(localId);

  CachedAttachment? get(String localId) => _box.get(localId);

  List<CachedAttachment> listForIncident(int incidentIdOrTempId) {
    return _box.values
        .where((a) => a.incidentIdOrTempId == incidentIdOrTempId)
        .toList()
      ..sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
  }

  List<CachedAttachment> pendingUploads() {
    return _box.values.where((a) => !a.isUploaded).toList()
      ..sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
  }

  int countPending() => _box.values.where((a) => !a.isUploaded).length;

  Future<void> markUploaded({
    required String localId,
    required int serverId,
  }) async {
    final att = get(localId);
    if (att == null) return;
    att.isUploaded = true;
    att.serverId = serverId;
    att.uploadedAtMs = DateTime.now().millisecondsSinceEpoch;
    att.lastError = null;
    await update(att);
  }

  Future<void> recordFailure(String localId, String error) async {
    final att = get(localId);
    if (att == null) return;
    att.retryCount += 1;
    att.lastError = error;
    await update(att);
  }

  /// When a temp incident gets a real id, attachments need their FK updated
  /// so subsequent uploads target the right URL.
  Future<void> remapIncidentId({
    required int tempIncidentId,
    required int serverIncidentId,
  }) async {
    final affected = _box.values
        .where((a) => a.incidentIdOrTempId == tempIncidentId)
        .toList();
    for (final a in affected) {
      a.incidentIdOrTempId = serverIncidentId;
      await update(a);
    }
  }
}
