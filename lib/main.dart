import 'package:flutter/material.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/incidents.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setup();

  runApp(Incidents(appRouter: AppRouter()));
}
