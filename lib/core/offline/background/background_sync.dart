import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../domain/sync_manager.dart';
import '../network/network_monitor.dart';

/// "Background-ish" sync hook.
///
/// We deliberately do **not** use the `workmanager` package — its 0.5.x
/// release still depends on Flutter's removed v1 Android embedding APIs
/// (`ShimPluginRegistry`, `PluginRegistrantCallback`) and breaks the Android
/// release build on modern Flutter. True headless sync from a background
/// isolate would need either a fixed version of workmanager or a platform-
/// channel of our own; both are out of scope for the offline-first pass.
///
/// Instead, this service subscribes to the app lifecycle and triggers
/// [SyncManager.syncNow] whenever the app comes back to the foreground.
/// Combined with the immediate sync on startup, the periodic 20-second
/// safety-net inside SyncManager, and the per-emission sync on
/// `NetworkMonitor.onlineStream`, this covers every realistic case where
/// the user expects pending writes to flush:
///
///   * App was backgrounded while offline, then brought to foreground after
///     connectivity returned → resume callback triggers sync.
///   * Phone went to sleep mid-sync → on wake, the OS resumes the app and
///     the lifecycle observer triggers a fresh sync.
///   * Connectivity flips while the app is in the foreground → handled by
///     the stream subscription inside SyncManager.
///
/// All of the above happens with **zero native code** and no permission
/// changes to `AndroidManifest.xml` / `Info.plist`.
class BackgroundSyncService {
  BackgroundSyncService._();

  static _ResumeObserver? _observer;
  static bool _initialized = false;

  /// Idempotent. Safe to call multiple times.
  static Future<void> initialize({
    required SyncManager syncManager,
    required NetworkMonitorService networkMonitor,
  }) async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      // On web there is no real "resume" event; the browser tab visibility
      // change is the equivalent, and connectivity_plus already covers the
      // important transitions.
      return;
    }

    _observer = _ResumeObserver(
      syncManager: syncManager,
      networkMonitor: networkMonitor,
    );
    WidgetsBinding.instance.addObserver(_observer!);
  }

  /// Manually request a sync attempt right now. Cheap — coalesces with any
  /// in-flight drain via the [SyncManager]'s internal lock.
  static Future<void> requestOneoff({
    required SyncManager syncManager,
  }) async {
    await syncManager.syncNow();
  }

  static Future<void> cancel() async {
    if (_observer != null) {
      WidgetsBinding.instance.removeObserver(_observer!);
      _observer = null;
    }
    _initialized = false;
  }
}

class _ResumeObserver with WidgetsBindingObserver {
  _ResumeObserver({
    required this.syncManager,
    required this.networkMonitor,
  });

  final SyncManager syncManager;
  final NetworkMonitorService networkMonitor;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 1. Force a connectivity re-check — iOS often doesn't fire the
      //    connectivity_plus stream after a long suspend / Wi-Fi handoff.
      // 2. Sync — even if isOnline is currently true, this is cheap (the
      //    drain lock prevents duplicate work) and worth doing every resume.
      _trigger();
    }
  }

  Future<void> _trigger() async {
    try {
      await networkMonitor.refresh();
      if (networkMonitor.isOnline) {
        await syncManager.syncNow();
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('Resume sync failed: $e\n$st');
      }
    }
  }
}
