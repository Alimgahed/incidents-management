import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../network/api_constants.dart';
import 'background/background_sync.dart';
import 'data/local_database.dart';
import 'data/repositories/attachment_cache_repository.dart';
import 'data/repositories/incident_cache_repository.dart';
import 'data/repositories/mission_cache_repository.dart';
import 'data/repositories/sync_queue_repository.dart';
import 'domain/conflict_resolver.dart';
import 'domain/id_remap_service.dart';
import 'domain/sync_manager.dart';
import 'network/network_monitor.dart';
import 'network/offline_interceptor.dart';
import 'presentation/offline_status_cubit.dart';

/// One-stop initialiser for the offline subsystem.
///
/// Called from [StartupService.initialize] **before** the first
/// frame. The order matters:
///   1. open Hive boxes (synchronous after init),
///   2. register repositories in get_it,
///   3. start NetworkMonitor (kicks off the connectivity_plus stream),
///   4. start SyncManager (subscribes to NetworkMonitor),
///   5. start BackgroundSyncService (no-op on web).
class OfflineBootstrap {
  OfflineBootstrap._();

  static bool _initialized = false;

  static Future<void> initialize({
    required GetIt getIt,
    required Dio Function() dioBuilder,
  }) async {
    if (_initialized) return;

    // 1. Hive
    await LocalDatabase.initialize();

    // 2. Repositories (singletons — single source of truth per process)
    if (!getIt.isRegistered<SyncQueueRepository>()) {
      getIt.registerLazySingleton<SyncQueueRepository>(SyncQueueRepository.new);
    }
    if (!getIt.isRegistered<IncidentCacheRepository>()) {
      getIt.registerLazySingleton<IncidentCacheRepository>(
          IncidentCacheRepository.new);
    }
    if (!getIt.isRegistered<MissionCacheRepository>()) {
      getIt.registerLazySingleton<MissionCacheRepository>(
          MissionCacheRepository.new);
    }
    if (!getIt.isRegistered<AttachmentCacheRepository>()) {
      getIt.registerLazySingleton<AttachmentCacheRepository>(
          AttachmentCacheRepository.new);
    }

    // 3. Network monitor — pass baseUrl so the reachability probe can recover
    //    from iOS connectivity_plus dropping change events after airplane mode.
    if (!getIt.isRegistered<NetworkMonitorService>()) {
      getIt.registerLazySingleton<NetworkMonitorService>(
        () => NetworkMonitorService(baseUrl: ApiConstants.baseUrl),
      );
    }
    final monitor = getIt<NetworkMonitorService>();
    await monitor.initialize();

    // 4. Domain services
    if (!getIt.isRegistered<IdRemapService>()) {
      getIt.registerLazySingleton<IdRemapService>(() => IdRemapService(
            incidents: getIt<IncidentCacheRepository>(),
            missions: getIt<MissionCacheRepository>(),
            attachments: getIt<AttachmentCacheRepository>(),
            queue: getIt<SyncQueueRepository>(),
          ));
    }
    if (!getIt.isRegistered<ConflictResolver>()) {
      getIt.registerLazySingleton<ConflictResolver>(() => ConflictResolver(
            queue: getIt<SyncQueueRepository>(),
            incidents: getIt<IncidentCacheRepository>(),
            missions: getIt<MissionCacheRepository>(),
          ));
    }

    if (!getIt.isRegistered<SyncManager>()) {
      getIt.registerLazySingleton<SyncManager>(() => SyncManager(
            queue: getIt<SyncQueueRepository>(),
            attachments: getIt<AttachmentCacheRepository>(),
            incidents: getIt<IncidentCacheRepository>(),
            missions: getIt<MissionCacheRepository>(),
            networkMonitor: monitor,
            conflictResolver: getIt<ConflictResolver>(),
            idRemapService: getIt<IdRemapService>(),
            dioBuilder: dioBuilder,
          ));
    }
    await getIt<SyncManager>().start();

    // 5. The Dio offline interceptor — install onto the shared Dio.
    final dio = dioBuilder();
    final alreadyInstalled =
        dio.interceptors.any((i) => i is OfflineInterceptor);
    if (!alreadyInstalled) {
      dio.interceptors.insert(
        0,
        OfflineInterceptor(
          queue: getIt<SyncQueueRepository>(),
          networkMonitor: monitor,
        ),
      );
    }

    // 6. Status cubit factory (consumed by widgets via BlocProvider).
    if (!getIt.isRegistered<OfflineStatusCubit>()) {
      getIt.registerFactory<OfflineStatusCubit>(() => OfflineStatusCubit(
            networkMonitor: monitor,
            syncManager: getIt<SyncManager>(),
            queue: getIt<SyncQueueRepository>(),
            attachments: getIt<AttachmentCacheRepository>(),
          ));
    }

    // 7. Background sync (best-effort).
    await BackgroundSyncService.initialize();

    _initialized = true;
    if (kDebugMode) {
      debugPrint('OfflineBootstrap: ready');
    }
  }

  /// Used by Logout to wipe everything cached for the previous user.
  static Future<void> resetOnLogout() async {
    if (!_initialized) return;
    await LocalDatabase.clearAll();
    await BackgroundSyncService.cancel();
  }
}
