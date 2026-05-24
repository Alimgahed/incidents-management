import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/offline/presentation/offline_banner.dart';
import 'package:incidents_managment/core/offline/presentation/offline_status_cubit.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:incidents_managment/main.dart';

class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

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
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (context, _) {
        // MediaQuery is now available because ScreenUtilInit provides it
        final isMobile = MediaQuery.sizeOf(context).width < 600;

        // Choose starting screen correctly based on login status and platform
        final initialRoute = isLoggedIn
            ? (isMobile ? Routes.mobileHome : Routes.crisisDashboardScreen)
            : Routes.login;

        return GetMaterialApp(
          scaffoldMessengerKey: messengerKey,
          debugShowCheckedModeBanner: false,
          title: 'Risk Management',
          theme: AppTheme.lightTheme,
          onGenerateRoute: appRouter.generateRoute,
          initialRoute: initialRoute,
          scrollBehavior: WebScrollBehavior(),
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
            return BlocProvider<OfflineStatusCubit>(
              // Singleton-ish: factory builds a single cubit per app lifecycle.
              create: (_) => getIt<OfflineStatusCubit>(),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: ResponsiveBreakpoints.builder(
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: const TextScaler.linear(1.0), // Prevent system text scaling issues
                      ),
                      // Wrap the child so OfflineBanner always sits at the top of the visible UI.
                      child: Column(
                        children: [
                          const OfflineBanner(),
                          Expanded(child: child ?? const SizedBox.shrink()),
                        ],
                      ),
                    ),
                    breakpoints: [
                      const Breakpoint(start: 0, end: 599, name: MOBILE),
                      const Breakpoint(start: 600, end: 1023, name: TABLET),
                      const Breakpoint(start: 1024, end: 1439, name: DESKTOP),
                      const Breakpoint(start: 1440, end: double.infinity, name: '4K'),
                    ],
                  ),
                ),
              );
          },
        );
      },
    );
  }
}
