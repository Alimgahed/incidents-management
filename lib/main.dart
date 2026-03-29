import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:incidents_managment/firebase_options.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/incidents.dart';

import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setup();
  
  // Resolve auth status before building widget tree
  final token = await SharedPreferencesHelper.getData<String>(SharedPreferenceKeys.userToken);
  final isLoggedIn = token != null && token.toString().trim().isNotEmpty;

  runApp(Incidents(appRouter: AppRouter(), isLoggedIn: isLoggedIn));
}
