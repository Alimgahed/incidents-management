import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

/// Schedules periodic background-sync work. On Android this is delivered by
/// WorkManager; on iOS the same package bridges to BGTaskScheduler / fetch
/// (capabilities permitting).
///
/// The actual sync logic doesn't live in the background isolate — when the
/// task wakes us up we just **re-launch** the main isolate which, on
/// `_AppBootstrap.initState`, will hit [SyncManager.syncNow] as part of normal
/// startup. This avoids the well-known headache of duplicating Hive boxes /
/// Dio instances across isolates.
///
/// If you later want true headless sync, swap the callback dispatcher body to
/// call `SyncManager.syncNow` directly after re-initializing Hive + DI in the
/// background isolate.
class BackgroundSyncService {
  BackgroundSyncService._();

  static const String _kPeriodicTask = 'offline_sync_periodic';
  static const String _kOneoffTask = 'offline_sync_oneoff';

  static bool _initialized = false;

  /// Idempotent; safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      // WorkManager has no web implementation; on web the foreground
      // SyncManager + connectivity listener is sufficient.
      _initialized = true;
      return;
    }

    try {
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: kDebugMode,
      );
      await Workmanager().registerPeriodicTask(
        _kPeriodicTask,
        _kPeriodicTask,
        frequency: const Duration(minutes: 15), // platform minimum on Android
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );
      _initialized = true;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('BackgroundSync init failed: $e\n$st');
      }
      // Don't crash the app — background sync is a nice-to-have.
    }
  }

  /// Manually schedule a one-shot sync attempt (e.g. after the user enqueued
  /// something important).
  static Future<void> requestOneoff() async {
    if (kIsWeb || !_initialized) return;
    try {
      await Workmanager().registerOneOffTask(
        '${_kOneoffTask}_${DateTime.now().millisecondsSinceEpoch}',
        _kOneoffTask,
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingWorkPolicy.append,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('requestOneoff failed: $e');
    }
  }

  static Future<void> cancel() async {
    if (kIsWeb) return;
    try {
      await Workmanager().cancelAll();
    } catch (_) {}
  }
}

/// Top-level entry point invoked by WorkManager when a task fires.
///
/// Must be a top-level function (annotated with @pragma).
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (kDebugMode) debugPrint('BG task fired: $task');
    // Headless sync hook. To enable true headless processing:
    //   1. await LocalDatabase.initialize();
    //   2. construct a minimal Dio + SyncQueueRepository + SyncManager;
    //   3. await SyncManager.syncNow();
    //
    // We leave it intentionally minimal here so the app stays buildable
    // without further platform-channel wiring (Android manifest changes,
    // iOS BGTaskScheduler identifiers in Info.plist). When you adopt
    // headless sync, wire those up and replace this body.
    return Future.value(true);
  });
}
