import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';
import 'package:incidents_managment/core/network/dio_factory.dart';
import 'package:incidents_managment/core/offline/offline_bootstrap.dart';
import 'package:incidents_managment/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Result of [StartupService.initialize], consumed by [_AppBootstrapState]
/// to decide which initial route the app should navigate to.
class AppStartupResult {
  const AppStartupResult({required this.isLoggedIn});

  final bool isLoggedIn;
}

/// Encapsulates every async operation that must complete before the first real
/// screen renders. Separating this from [main] keeps startup logic testable
/// and makes the dependency ordering explicit.
///
/// Startup sequence
/// ────────────────
/// 1. [Firebase.initializeApp] — must run first; DI depends on it.
/// 2. [setup] + [SharedPreferences.getInstance] — run **concurrently**.
///    The resolved [SharedPreferences] instance is passed to
///    [SharedPreferencesHelper.init] so every subsequent storage access is
///    synchronous (no async getInstance() overhead after this point).
/// 3. Token read — fully synchronous; hits the in-memory singleton directly.
class StartupService {
  const StartupService._();

  static Future<AppStartupResult> initialize() async {
    // ── Step 1: Firebase (blocking — DI needs it) ────────────────────────────
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Fire-and-forget; analytics collection doesn't need to await.
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // ── Step 2: DI + SP warm-up in parallel ─────────────────────────────────
    // [setup] registers all GetIt singletons/factories.
    // [SharedPreferences.getInstance] loads all SP keys into memory.
    // We capture the resolved instance and hand it to [SharedPreferencesHelper]
    // so every subsequent SP access is synchronous (no async getInstance()
    // overhead after this point).
    final results = await Future.wait<dynamic>([
      setup(),
      SharedPreferences.getInstance(),
    ]);
    SharedPreferencesHelper.init(results[1] as SharedPreferences);

    // ── Step 2b: Offline subsystem ───────────────────────────────────────────
    // Opens Hive boxes, starts NetworkMonitor + SyncManager, installs the
    // OfflineInterceptor onto the shared Dio. Safe to call after [setup]
    // because it depends on the singletons just registered.
    await OfflineBootstrap.initialize(
      getIt: getIt,
      dioBuilder: () => getIt.isRegistered<Dio>()
          ? getIt<Dio>()
          : DioFactory.getDioInstance(),
    );

    // ── Step 3: Token read — now fully synchronous (SP instance cached) ──────
    final token = await SharedPreferencesHelper.getData<String>(
      SharedPreferenceKeys.userToken,
    );
    final isLoggedIn = token != null && token.toString().trim().isNotEmpty;

    return AppStartupResult(isLoggedIn: isLoggedIn);
  }
}
