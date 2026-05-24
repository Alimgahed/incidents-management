import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:incidents_managment/core/helpers/startup_service.dart';
import 'package:incidents_managment/core/network/fcm_service.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/incidents.dart';

// Global key for showing SnackBars from anywhere in the app.
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Entry point.
///
/// [runApp] is called **immediately** after the binding is initialized so the
/// Flutter engine can hand off from the native launch screen to Flutter as fast
/// as possible. All heavy async work (Firebase, DI, token read) runs inside
/// [_AppBootstrapState] behind a lightweight splash frame.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupErrorHandlers();
  runApp(const _AppBootstrap());
}

// ── Error handlers ────────────────────────────────────────────────────────────

/// Suppresses harmless hot-restart errors produced by flutter_map when the
/// EngineFlutterView is disposed before the map widget finishes painting.
void _setupErrorHandlers() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details
        .exceptionAsString()
        .contains('Trying to render a disposed EngineFlutterView')) {
      return;
    }
    originalOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error
        .toString()
        .contains('Trying to render a disposed EngineFlutterView')) {
      return true;
    }
    return false;
  };
}

// ── Bootstrap widget ──────────────────────────────────────────────────────────

/// Drives the startup sequence. Shows [_AppSplash] while
/// [StartupService.initialize] runs, then replaces it with [Incidents].
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  AppStartupResult? _result;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final stopwatch = Stopwatch()..start();

    // Start a 2-second minimum delay timer
    final minDelay = Future.delayed(const Duration(seconds: 2));

    final result = await StartupService.initialize();

    // Wait until at least 2 seconds have passed
    await minDelay;

    if (kDebugMode) {
      stopwatch.stop();
      debugPrint('⏱ Initialization took ${stopwatch.elapsedMilliseconds}ms');
    }

    if (!mounted) return;

    setState(() => _result = result);

    // Defer FCM init to the first frame of the real app — token retrieval is
    // not needed for the initial UI render and would slow the first paint.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmService.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result == null) return const _AppSplash();
    return Incidents(appRouter: AppRouter(), isLoggedIn: result.isLoggedIn);
  }
}

// ── Splash screen ─────────────────────────────────────────────────────────────

/// Shown between the native launch screen and the first real screen.
/// Keeps the user oriented while Firebase + DI + token initialise in the
/// background. Intentionally minimal — no heavy assets, no animations.
class _AppSplash extends StatelessWidget {
  const _AppSplash();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              const Text(
                'إدارة الأزمات',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
