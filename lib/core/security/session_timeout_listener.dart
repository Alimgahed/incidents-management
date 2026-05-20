import 'dart:async';
import 'package:flutter/material.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/security/session_manager.dart';

class SessionTimeoutListener extends StatefulWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  State<SessionTimeoutListener> createState() => _SessionTimeoutListenerState();
}

class _SessionTimeoutListenerState extends State<SessionTimeoutListener> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _timer?.cancel();
    
    // Only schedule the timer if the user is currently authenticated
    final sessionManager = getIt<SessionManager>();
    if (sessionManager.getCurrentUser() == null) {
      return;
    }

    _timer = Timer(widget.timeoutDuration, _onTimeout);
  }

  void _onTimeout() {
    // Inactivity timeout reached: trigger secure global logout flow
    getIt<SessionManager>().logout(sessionExpired: true);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      onPointerMove: (_) => _resetTimer(),
      onPointerUp: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
