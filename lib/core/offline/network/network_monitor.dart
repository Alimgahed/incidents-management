import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Centralised connectivity state for the whole app.
///
/// Wraps `connectivity_plus` AND a real HTTP reachability probe — the OS-level
/// connectivity APIs (especially on iOS) are notoriously unreliable: they
/// report "no change" when you toggle airplane mode back off, or they report
/// "wifi" while there's no actual internet. Two pieces guard against this:
///
///   1. A periodic reachability probe (every [_probeInterval]) tries a HEAD
///      request against [baseUrl]; if it succeeds we flip to online even if
///      the connectivity stream never emitted.
///   2. [refresh] is publicly callable so the UI "Retry" button can force a
///      probe right now.
///
/// Trigger semantics:
///   - emits `true` on bootstrap if a real probe succeeds OR the OS reports
///     a usable interface.
///   - emits a new value on every change.
///   - registered reconnect callbacks fire on every offline → online
///     transition. Used by [SyncManager] to start draining the queue.
class NetworkMonitorService {
  NetworkMonitorService({
    Connectivity? connectivity,
    Dio? probeClient,
    this.baseUrl,
    this.probeIntervalOffline = const Duration(seconds: 15),
    this.probeIntervalOnline = const Duration(seconds: 30),
    this.probeTimeout = const Duration(seconds: 4),
  })  : _connectivity = connectivity ?? Connectivity(),
        _probeClient = probeClient;

  final Connectivity _connectivity;
  final Dio? _probeClient;

  /// Base URL we probe. If null, the probe is skipped and we rely solely on
  /// `connectivity_plus`.
  final String? baseUrl;

  /// How often we probe while we believe we're offline (fast recovery).
  final Duration probeIntervalOffline;

  /// How often we probe while we believe we're online (verification).
  /// Slower than the offline cadence because each probe costs a tiny HTTP
  /// request — kept reasonable so we still notice a dropped connection
  /// within ~30s even if `connectivity_plus` doesn't fire its event.
  final Duration probeIntervalOnline;

  final Duration probeTimeout;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  final List<FutureOr<void> Function()> _reconnectListeners = [];

  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _probeTimer;
  bool _isOnline = true;
  bool _initialized = false;
  bool _probeInFlight = false;

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  /// Broadcast stream of online/offline changes. Replays the current value to
  /// new listeners by emitting once on subscribe.
  Stream<bool> get onlineStream async* {
    yield _isOnline;
    yield* _controller.stream;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // 1. Initial OS-level check.
    bool osOnline = true;
    try {
      final initial = await _connectivity.checkConnectivity();
      osOnline = _anyConnected(initial);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('⚠️ NetworkMonitor checkConnectivity failed (normal on Web/offline): $e\n$st');
      }
      // Fallback: assume online to allow app boot to proceed.
      // Active HTTP probes will correct this state if the server is unreachable.
      osOnline = true;
    }
    _updateState(osOnline);

    // 2. Reactive OS-level updates.
    try {
      _sub = _connectivity.onConnectivityChanged.listen((results) async {
        final reportedOnline = _anyConnected(results);
        if (reportedOnline) {
          // OS says we have an interface — verify with a real probe before
          // promising the rest of the app there's internet.
          await _runProbe(triggerReconnect: true);
        } else {
          _updateState(false);
        }
      }, onError: (e, st) {
        if (kDebugMode) {
          debugPrint('NetworkMonitor connectivity error: $e\n$st');
        }
      });
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('⚠️ NetworkMonitor connectivity listener registration failed: $e\n$st');
      }
    }

    // 3. Periodic reachability probe — recovers from missed change events in
    //    BOTH directions:
    //      * online → offline: iOS sometimes doesn't emit the change.
    //      * offline → online: same problem, opposite direction.
    //    We probe slower while online (verification) and faster while
    //    offline (recovery), and we re-arm the timer whenever the state
    //    changes so the cadence always matches reality.
    if (baseUrl != null) {
      _scheduleProbe();
      // Fire one immediately so the initial state corrects fast.
      unawaited(_runProbe(triggerReconnect: true));
    }
  }

  void _scheduleProbe() {
    _probeTimer?.cancel();
    final interval = _isOnline ? probeIntervalOnline : probeIntervalOffline;
    _probeTimer = Timer.periodic(interval, (_) {
      unawaited(_runProbe(triggerReconnect: true));
    });
  }

  /// Register a callback that fires every time we transition from offline to
  /// online. The callback may be async — its result is awaited so errors don't
  /// silently drop.
  void addReconnectListener(FutureOr<void> Function() listener) {
    _reconnectListeners.add(listener);
  }

  void removeReconnectListener(FutureOr<void> Function() listener) {
    _reconnectListeners.remove(listener);
  }

  /// Force a re-check. Used by the "Retry" UI button — runs both the OS
  /// check AND a real reachability probe, so it works around the iOS bug
  /// where `onConnectivityChanged` never re-emits after airplane mode toggle.
  Future<bool> refresh() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final osOnline = _anyConnected(results);
      if (!osOnline) {
        _updateState(false);
        return false;
      }
    } catch (_) {
      // ignore — fall through to probe
    }
    final probed = await _runProbe(triggerReconnect: true);
    return probed;
  }

  Future<void> dispose() async {
    _probeTimer?.cancel();
    await _sub?.cancel();
    await _controller.close();
  }

  // ── internals ──────────────────────────────────────────────────────────────

  bool _anyConnected(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Real HTTP probe. Tries HEAD then falls back to GET on the base URL.
  /// Returns true if the server answered (any status code other than a
  /// transport error counts as "we have internet").
  Future<bool> _runProbe({required bool triggerReconnect}) async {
    if (baseUrl == null) return _isOnline;
    if (_probeInFlight) return _isOnline;
    _probeInFlight = true;
    try {
      final dio = _probeClient ??
          Dio(BaseOptions(
            connectTimeout: probeTimeout,
            receiveTimeout: probeTimeout,
            sendTimeout: kIsWeb ? null : probeTimeout,
            validateStatus: (_) => true, // any response = internet works
          ));
      final url = baseUrl!;
      try {
        await dio.head(url,
            options: Options(receiveTimeout: probeTimeout));
        _updateState(true, triggerReconnect: triggerReconnect);
        return true;
      } catch (_) {
        // HEAD might not be supported — fall back to GET /
        try {
          await dio.get(url,
              options: Options(receiveTimeout: probeTimeout));
          _updateState(true, triggerReconnect: triggerReconnect);
          return true;
        } on DioException catch (e) {
          // A response with any status code (4xx/5xx) means we reached the
          // server — that's still "online".
          if (e.response != null) {
            _updateState(true, triggerReconnect: triggerReconnect);
            return true;
          }
          _updateState(false);
          return false;
        } on SocketException {
          _updateState(false);
          return false;
        } catch (_) {
          _updateState(false);
          return false;
        }
      }
    } finally {
      _probeInFlight = false;
    }
  }

  void _updateState(bool nowOnline, {bool triggerReconnect = true}) {
    final wasOnline = _isOnline;
    if (wasOnline == nowOnline) {
      // Re-emit even when value didn't change so listeners that missed the
      // first event get an explicit "still online" / "still offline" ping.
      // We only fire reconnect listeners on a real transition though.
      _controller.add(nowOnline);
      return;
    }
    _isOnline = nowOnline;
    _controller.add(nowOnline);
    // Cadence changes with state: probe more often while offline.
    if (_initialized && baseUrl != null) {
      _scheduleProbe();
    }

    if (!wasOnline && nowOnline && triggerReconnect) {
      _fireReconnect();
    }
  }

  /// Called by the OfflineInterceptor when a request fails with a transport
  /// error while we currently believe we're online. Triggers an immediate
  /// probe so we flip to offline within ~probeTimeout, much faster than the
  /// periodic timer would catch it.
  void reportTransportFailure() {
    if (!_isOnline) return; // already offline, nothing to update
    unawaited(_runProbe(triggerReconnect: false));
  }

  Future<void> _fireReconnect() async {
    // Snapshot to allow listeners to mutate the list safely.
    final listeners = List<FutureOr<void> Function()>.from(_reconnectListeners);
    for (final l in listeners) {
      try {
        await l();
      } catch (e, st) {
        if (kDebugMode) {
          debugPrint('Reconnect listener failed: $e\n$st');
        }
      }
    }
  }
}
