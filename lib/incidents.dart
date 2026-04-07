import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Incidents extends StatelessWidget {
  const Incidents({
    super.key,
    required this.appRouter,
    required this.isLoggedIn,
  });

  final AppRouter appRouter;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, __) {
        // MediaQuery is now available because ScreenUtilInit provides it
        final isMobile = MediaQuery.of(context).size.width < 600;

        // Choose starting screen correctly based on login status and platform
        final initialRoute = isLoggedIn
            ? (isMobile ? Routes.mobileHome : Routes.crisisDashboardScreen)
            : Routes.login;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Incidents Management',
          theme: AppTheme.lightTheme,
          onGenerateRoute: appRouter.generateRoute,
          initialRoute:initialRoute,
          // Set the app's locale to Arabic
          locale: const Locale('ar', 'AE'), // Arabic (UAE) locale
          supportedLocales: const [Locale('en', 'US'), Locale('ar', 'AE')],
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
                  textScaler: TextScaler.linear(
                    1.0,
                  ), // Prevent system text scaling issues
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
