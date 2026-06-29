import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../domain/sync_manager.dart';
import 'network_monitor.dart';

/// Thin reliability layer for socket_io_client.
///
/// Concerns handled here:
///   * automatic reconnect after the socket drops,
///   * application-level heartbeat (a periodic `ping` payload) so dead NAT
///     translations get detected sooner than socket.io's idle timeout,
///   * graceful fallback when the network is offline (we close the socket
///     instead of letting it churn battery),
///   * post-reconnect resync trigger that calls [SyncManager.syncNow] and
///     emits a "rehydrate" event the rest of the app can listen for to
///     reload its data.
///
/// The class is intentionally protocol-agnostic about your events: pass in
/// builder functions for "after connect" and "on incoming event" so the
/// existing socket business logic stays where it already lives.
class ResilientWebSocket {
  ResilientWebSocket({
    required this.url,
    required this.networkMonitor,
    required this.syncManager,
    this.authToken,
    this.heartbeatInterval = const Duration(seconds: 25),
    this.reconnectBackoffMax = const Duration(seconds: 30),
    this.onConnected,
    this.onDisconnected,
    this.onEvent,
    this.onResync,
  });

  final String url;
  final NetworkMonitorService networkMonitor;
  final SyncManager syncManager;
  final String? authToken;
  final Duration heartbeatInterval;
  final Duration reconnectBackoffMax;

  /// Called on every successful connect or reconnect. Use this to re-emit
  /// `join_room`, `subscribe_incident`, etc.
  final FutureOr<void> Function(io.Socket socket)? onConnected;

  /// Called on every disconnect, regardless of cause.
  final FutureOr<void> Function()? onDisconnected;

  /// Catch-all incoming-event sink. Lets you pipe socket events into a Bloc.
  final FutureOr<void> Function(String event, dynamic data)? onEvent;

  /// Called once after a reconnect that immediately follows an offline → online
  /// transition. UI layers should use this to refetch lists so stale data is
  /// replaced with the freshest server state.
  final FutureOr<void> Function()? onResync;

  io.Socket? _socket;
  Timer? _heartbeat;
  StreamSubscription<bool>? _connectivitySub;
  bool _wasOffline = false;
  int _reconnectAttempts = 0;
  bool _stopped = false;

  io.Socket? get rawSocket => _socket;
  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_stopped) return;

    final opts = io.OptionBuilder()
        .setTransports(kIsWeb ? const ['polling', 'websocket'] : const ['polling'])
        .enableReconnection()
        .setReconnectionAttempts(0x7FFFFFFF) // never give up while online
        .setReconnectionDelayMax(reconnectBackoffMax.inMilliseconds)
        .setTimeout(15000)
        .build();

    // Manually inject the upgrade:false flag into the built options map,
    // since OptionBuilder doesn't expose a method for it directly.
    opts['upgrade'] = false;

    if (authToken != null) {
      opts['auth'] = {'token': authToken};
    }

    if (kDebugMode) {
      debugPrint('🔍 Socket opts: $opts');
      debugPrint('🔍 Socket url: $url');
    }

    final s = io.io(url, opts);
    _socket = s;

    s.onConnect((_) async {
      _reconnectAttempts = 0;
      _startHeartbeat();
      if (kDebugMode) debugPrint('WS connected: $url');
      await onConnected?.call(s);
      // If we were offline before this connect, trigger resync.
      if (_wasOffline) {
        _wasOffline = false;
        await syncManager.syncNow();
        await onResync?.call();
      }
    });

    s.onDisconnect((_) async {
      _stopHeartbeat();
      if (kDebugMode) debugPrint('WS disconnected: $url');
      await onDisconnected?.call();
      _scheduleReconnect();
    });

    s.onConnectError((err) {
      if (kDebugMode) debugPrint('WS connect_error: $err');
      _scheduleReconnect();
    });

    s.onError((err) {
      if (kDebugMode) debugPrint('WS error: $err');
    });

    s.onAny((event, data) async {
      await onEvent?.call(event, data);
    });

    // React to connectivity changes — close the socket when offline so it
    // doesn't spin its reconnect timer, re-open on connectivity restoration.
    _connectivitySub?.cancel();
    _connectivitySub = networkMonitor.onlineStream.listen((online) {
      if (online) {
        if (!isConnected && !_stopped) {
          if (kDebugMode) debugPrint('WS: connectivity back, reconnecting');
          try {
            s.connect();
          } catch (_) {}
        }
      } else {
        _wasOffline = true;
        try {
          s.disconnect();
        } catch (_) {}
      }
    });

    s.connect();
  }

  void emit(String event, dynamic data) {
    final s = _socket;
    if (s != null && s.connected) {
      s.emit(event, data);
    }
  }

  Future<void> close() async {
    _stopped = true;
    _stopHeartbeat();
    await _connectivitySub?.cancel();
    try {
      _socket?.dispose();
    } catch (_) {}
    _socket = null;
  }

  // ── internals ──────────────────────────────────────────────────────────────

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeat = Timer.periodic(heartbeatInterval, (_) {
      final s = _socket;
      if (s != null && s.connected) {
        try {
          s.emit('ping_app', {'ts': DateTime.now().millisecondsSinceEpoch});
        } catch (_) {}
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = null;
  }

  void _scheduleReconnect() {
    if (_stopped) return;
    if (!networkMonitor.isOnline) return;
    _reconnectAttempts += 1;
    final delayMs = (500 * (1 << _reconnectAttempts.clamp(0, 6)))
        .clamp(500, reconnectBackoffMax.inMilliseconds);
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (_stopped) return;
      final s = _socket;
      if (s != null && !s.connected) {
        try {
          s.connect();
        } catch (_) {}
      }
    });
  }
}
