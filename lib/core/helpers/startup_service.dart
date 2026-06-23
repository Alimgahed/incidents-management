import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/network/dio_factory.dart';
import 'package:incidents_managment/core/offline/offline_bootstrap.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
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
    // Determine which base URL to use
    await _determineBaseUrl();

    // ── Step 1: Firebase (blocking — DI needs it) ────────────────────────────
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Fire-and-forget; analytics collection doesn't need to await.
      try {
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      } catch (analyticsError) {
        if (kDebugMode) {
          debugPrint('⚠️ Firebase Analytics config failed (expected offline/web): $analyticsError');
        }
      }
    } catch (firebaseError) {
      if (kDebugMode) {
        debugPrint('⚠️ Firebase initializeApp failed (expected offline/web): $firebaseError');
      }
      // On Web or Offline environments, Firebase might fail to load (e.g. DNS block or
      // offline state prevents loading Firebase Web JS SDK from gstatic).
      // We catch this to allow the app to boot up in offline mode.
    }

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

    // ── Step 3: Token and Session read ──────
    final sessionManager = getIt<SessionManager>();
    await sessionManager.initializeSession();
    final token = await getIt<SecureStorageService>().getUserToken();
    final isLoggedIn = token != null && token.trim().isNotEmpty;

    return AppStartupResult(isLoggedIn: isLoggedIn);
  }

  static Future<void> _determineBaseUrl() async {
    // If we are running on the web, we can check the URL we are being served from.
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == '172.16.0.31' || host == 'localhost' || host == '127.0.0.1') {
        ApiConstants.baseUrl = ApiConstants.internalBaseUrl;
        if (kDebugMode) {
          debugPrint('🌐 Using Internal Network Base URL (Detected via Web Host): ${ApiConstants.baseUrl}');
        }
      } else {
        ApiConstants.baseUrl = ApiConstants.externalBaseUrl;
        if (kDebugMode) {
          debugPrint('🌐 Using External Network Base URL (Detected via Web Host): ${ApiConstants.baseUrl}');
        }
      }
      return; // Pinging is completely unnecessary and broken by Mixed Content on Web.
    }

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: 1500),
      receiveTimeout: const Duration(milliseconds: 1500),
    ));
    try {
      await dio.get(ApiConstants.internalBaseUrl);
      ApiConstants.baseUrl = ApiConstants.internalBaseUrl;
      if (kDebugMode) {
        debugPrint('🌐 Using Internal Network Base URL: ${ApiConstants.baseUrl}');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        ApiConstants.baseUrl = ApiConstants.internalBaseUrl;
        if (kDebugMode) {
          debugPrint('🌐 Using Internal Network Base URL (Server Responded): ${ApiConstants.baseUrl}');
        }
      } else {
        ApiConstants.baseUrl = ApiConstants.externalBaseUrl;
        if (kDebugMode) {
          debugPrint('🌐 Using External Network Base URL: ${ApiConstants.baseUrl}');
        }
      }
    }
  }
}
