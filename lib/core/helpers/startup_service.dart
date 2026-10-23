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
    // ── Step 0: Fast Base URL configuration (no network stall) ───────────────
    _determineBaseUrl();

    // ── Step 1: Firebase, DI + SP warm-up concurrently in parallel ───────────
    final results = await Future.wait<dynamic>([
      _initFirebase(),
      setup(),
      SharedPreferences.getInstance(),
    ]);
    SharedPreferencesHelper.init(results[2] as SharedPreferences);

    // ── Step 2: Offline subsystem & local database ───────────────────────────
    await OfflineBootstrap.initialize(
      getIt: getIt,
      dioBuilder: () => getIt.isRegistered<Dio>()
          ? getIt<Dio>()
          : DioFactory.getDioInstance(),
    );

    // ── Step 3: Token and Session read ───────────────────────────────────────
    final sessionManager = getIt<SessionManager>();
    await sessionManager.initializeSession();
    final token = await getIt<SecureStorageService>().getUserToken();
    final isLoggedIn = token != null && token.trim().isNotEmpty;

    return AppStartupResult(isLoggedIn: isLoggedIn);
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      try {
        await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      } catch (analyticsError) {
        if (kDebugMode) {
          debugPrint(
            '⚠️ Firebase Analytics config failed (expected offline/web): $analyticsError',
          );
        }
      }
    } catch (firebaseError) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Firebase initializeApp failed (expected offline/web): $firebaseError',
        );
      }
    }
  }

  static void _determineBaseUrl() {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == '172.16.0.31' || host == 'localhost' || host == '127.0.0.1') {
        ApiConstants.baseUrl = ApiConstants.internalBaseUrl;
      } else {
        ApiConstants.baseUrl = ApiConstants.externalBaseUrl;
      }
      if (kDebugMode) {
        debugPrint('🌐 Web Base URL detected: ${ApiConstants.baseUrl}');
      }
      return;
    }

    // On Mobile: Directly use externalBaseUrl without any blocking network roundtrip.
    ApiConstants.baseUrl = ApiConstants.externalBaseUrl;
    if (kDebugMode) {
      debugPrint('🌐 Mobile Base URL: ${ApiConstants.baseUrl}');
    }
  }
}
