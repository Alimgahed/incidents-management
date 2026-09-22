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
  
  // Replace the entire return GetMaterialApp block safely using regex or index
  final startIndex = content.indexOf('return GetMaterialApp(');
  final endIndex = content.indexOf('        );', startIndex) + 10; 
  // Wait, looking at the code, GetMaterialApp ends at line 98 `        );`
  // Actually, I can just read it line by line and construct the new file.
  
  final lines = content.split('\n');
  final newLines = <String>[];
  
  bool insideGetMaterialApp = false;
  
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    
    if (line.contains('return GetMaterialApp(')) {
      newLines.add('        return BlocProvider<ThemeCubit>(');
      newLines.add('          create: (_) => ThemeCubit(),');
      newLines.add('          child: BlocBuilder<ThemeCubit, ThemeMode>(');
      newLines.add('            builder: (context, themeMode) {');
      newLines.add('              return GetMaterialApp(');
      insideGetMaterialApp = true;
      continue;
    }
    
    if (insideGetMaterialApp && line.contains('theme: AppTheme.lightTheme,')) {
      newLines.add('                theme: AppTheme.lightTheme,');
      newLines.add('                darkTheme: AppTheme.darkTheme,');
      newLines.add('                themeMode: themeMode,');
      continue;
    }
    
    if (insideGetMaterialApp && line == '        );') {
      newLines.add('              );');
      newLines.add('            },');
      newLines.add('          ),');
      newLines.add('        );');
      insideGetMaterialApp = false;
      continue;
    }
    
    // Indent lines inside GetMaterialApp by 4 spaces (except the builder function lines which we won't touch to avoid breaking things, 
    // actually, let's just leave the indentation as is, Flutter doesn't care).
    if (insideGetMaterialApp) {
      newLines.add('  ' + line);
    } else {
      newLines.add(line);
    }
  }
  
  file.writeAsStringSync(newLines.join('\n'));
  print('Done safe update');
}
