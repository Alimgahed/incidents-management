import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/incidents.dart');
  String content = file.readAsStringSync();
  
  if (!content.contains('theme_cubit.dart')) {
    content = content.replaceFirst(
      "import 'package:incidents_managment/core/theming/app_theme.dart';",
      "import 'package:incidents_managment/core/theming/app_theme.dart';\nimport 'package:incidents_managment/core/theming/logic/theme_cubit.dart';"
    );
  }
  
  final getMaterialAppStart = content.indexOf('return GetMaterialApp(');
  if (getMaterialAppStart != -1) {
    final getMaterialAppReplacement = '''return BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return GetMaterialApp(
                scaffoldMessengerKey: messengerKey,
                debugShowCheckedModeBanner: false,
                title: 'Risk Management',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                onGenerateRoute: appRouter.generateRoute,''';
                
    final originalStart = content.indexOf('return GetMaterialApp(');
    final originalEnd = content.indexOf('onGenerateRoute: appRouter.generateRoute,', originalStart) + 'onGenerateRoute: appRouter.generateRoute,'.length;
    
    content = content.replaceRange(originalStart, originalEnd, getMaterialAppReplacement);
    
    // We added BlocProvider and BlocBuilder, so we need two more closing braces.
    // The end of GetMaterialApp looks like this:
    /*
          },
        );
      },
    );
    */
    
    // Find the last `);` before `},`
    // Actually it's easier to just find the end of GetMaterialApp, which is exactly before `      },` at the end of ScreenUtilInit builder.
    
    final endOfBuilder = content.lastIndexOf('      },');
    content = content.replaceRange(endOfBuilder, endOfBuilder, '              );\n            },\n          );\n');
  }
  
  file.writeAsStringSync(content);
  print('Done incidents.dart');
}
