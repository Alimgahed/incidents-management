import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Incidents extends StatelessWidget {
  const Incidents({super.key, required this.appRouter});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final initialRoute = isMobile ? Routes.mobileHome : Routes.crisisDashboardScreen;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return BlocProvider(
          create: (context) =>
              IncidentMapCubit(), // Initialize the IncidentMapCubit here
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Incidents Management',
            theme: AppTheme.lightTheme,
            onGenerateRoute: appRouter.generateRoute,
            initialRoute: initialRoute,

            // Set the app's locale to Arabic
            locale: const Locale('ar', 'AE'), // Arabic (UAE) locale
            // Localization support for different languages
            supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
            // LocalizationsDelegates for support
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Ensure RTL layout when using Arabic locale and responsive design
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaleFactor: 1.0, // Prevent system text scaling issues
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
