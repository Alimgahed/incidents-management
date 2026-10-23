import 'package:flutter/material.dart';

/// Inactivity timeout and session expiration have been permanently disabled per backend specification.
class SessionTimeoutListener extends StatelessWidget {
  final Widget child;
  final Duration timeoutDuration;

  const SessionTimeoutListener({
    super.key,
    required this.child,
    this.timeoutDuration = const Duration(minutes: 15),
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
