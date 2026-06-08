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
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _error = null;
      _stackTrace = null;
      _result = null;
    });

    final stopwatch = Stopwatch()..start();

    // Start a 2-second minimum delay timer
    final minDelay = Future.delayed(const Duration(seconds: 2));

    try {
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
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('❌ Startup initialization failed: $e\n$st');
      }
      if (!mounted) return;
      setState(() {
        _error = e;
        _stackTrace = st;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _AppError(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: _start,
      );
    }

    final result = _result;
    if (result == null) return const _AppSplash();
    return Incidents(appRouter: AppRouter(), isLoggedIn: result.isLoggedIn);
  }
}

// ── Startup Error Screen ──────────────────────────────────────────────────────

class _AppError extends StatefulWidget {
  const _AppError({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  @override
  State<_AppError> createState() => _AppErrorState();
}

class _AppErrorState extends State<_AppError> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFD32F2F),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'حدث خطأ أثناء التشغيل',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لم نتمكن من تهيئة التطبيق بنجاح. قد يكون هناك مشكلة في الاتصال بالشبكة.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                    ),
                    child: Text(
                      _showDetails ? 'إخفاء التفاصيل الفنية' : 'عرض التفاصيل الفنية',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_showDetails) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.error.toString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFFC62828),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          if (widget.stackTrace != null) ...[
                            const Divider(height: 16),
                            SizedBox(
                              height: 150,
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.stackTrace.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                    color: Color(0xFF424242),
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
