import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incidents_managment/firebase_options.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/incidents.dart';

import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';

import 'package:incidents_managment/core/network/fcm_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';



// Global Key for showing SnackBars from anywhere
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  final Stopwatch stopwatch = Stopwatch()..start();

  WidgetsFlutterBinding.ensureInitialized();

  // Suppress harmless hot-restart EngineFlutterView errors (commonly thrown by flutter_map)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('Trying to render a disposed EngineFlutterView')) {
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (error.toString().contains('Trying to render a disposed EngineFlutterView')) {
      return true;
    }
    return false;
  };

  // Firebase must be initialized before DI (some services depend on it)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Analytics (non-blocking, fire-and-forget)
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  // DI setup + token read can run after Firebase
  await setup();

  // Resolve auth status before building widget tree
  final token = await SharedPreferencesHelper.getData<String>(SharedPreferenceKeys.userToken);
  final isLoggedIn = token != null && token.toString().trim().isNotEmpty;

  if (kDebugMode) {
    stopwatch.stop();
    debugPrint('⏱ Initialization took ${stopwatch.elapsedMilliseconds}ms');
  }

  runApp(Incidents(appRouter: AppRouter(), isLoggedIn: isLoggedIn));

  // Defer FCM initialization to after the first frame to reduce cold-start time.
  // FCM token retrieval is not needed for the initial UI render.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FcmService.initialize();
  });
}
