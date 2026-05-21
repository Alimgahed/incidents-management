import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/cached_attachment.dart';
import 'models/cached_incident.dart';
import 'models/cached_mission.dart';
import 'models/sync_enums.dart';
import 'models/sync_queue_item.dart';

/// Single source of truth for every Hive box used by the offline subsystem.
///
/// One‐time initialization happens in [OfflineBootstrap]; afterwards anybody
/// can call the typed getters below to grab a ready-to-use box. All boxes are
/// opened *eagerly* during bootstrap so reads never have to wait on disk I/O
/// from the UI thread.
class LocalDatabase {
  LocalDatabase._();

  static const String _kIncidents = 'cache_incidents';
  static const String _kMissions = 'cache_missions';
  static const String _kAttachments = 'cache_attachments';
  static const String _kSyncQueue = 'sync_queue';
  static const String _kGetCache = 'cache_get_responses';
  static const String _kKeyValue = 'cache_kv'; // small bag for misc state

  static bool _initialized = false;

  /// Idempotent. Safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized) return;
    await Hive.initFlutter();

    // Register adapters BEFORE opening any box.
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(SyncQueueItemAdapter());
    }
    if (!Hive.isAdapterRegistered(101)) {
      Hive.registerAdapter(CachedIncidentAdapter());
    }
    if (!Hive.isAdapterRegistered(102)) {
      Hive.registerAdapter(CachedMissionAdapter());
    }
    if (!Hive.isAdapterRegistered(103)) {
      Hive.registerAdapter(CachedAttachmentAdapter());
    }
    if (!Hive.isAdapterRegistered(110)) {
      Hive.registerAdapter(SyncStateAdapter());
    }
    if (!Hive.isAdapterRegistered(111)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }

    try {
      await Future.wait([
        Hive.openBox<CachedIncident>(_kIncidents),
        Hive.openBox<CachedMission>(_kMissions),
        Hive.openBox<CachedAttachment>(_kAttachments),
        Hive.openBox<SyncQueueItem>(_kSyncQueue),
        Hive.openBox<String>(_kGetCache),
        Hive.openBox(_kKeyValue),
      ]);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('LocalDatabase init error: $e\n$st');
      }
      rethrow;
    }

    _initialized = true;
  }

  /// Whether [initialize] has finished. UI code can short-circuit before
  /// initialization completes by checking this flag.
  static bool get isReady => _initialized;

  static Box<CachedIncident> get incidents =>
      Hive.box<CachedIncident>(_kIncidents);

  static Box<CachedMission> get missions => Hive.box<CachedMission>(_kMissions);

  static Box<CachedAttachment> get attachments =>
      Hive.box<CachedAttachment>(_kAttachments);

  static Box<SyncQueueItem> get syncQueue =>
      Hive.box<SyncQueueItem>(_kSyncQueue);

  static Box<String> get getCache => Hive.box<String>(_kGetCache);

  static Box get keyValue => Hive.box(_kKeyValue);

  /// Wipes everything — used by Logout to prevent data leakage between users.
  static Future<void> clearAll() async {
    await Future.wait([
      incidents.clear(),
      missions.clear(),
      attachments.clear(),
      syncQueue.clear(),
      getCache.clear(),
      keyValue.clear(),
    ]);
  }
}
