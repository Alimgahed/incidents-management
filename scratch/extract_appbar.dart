import 'dart:io';

void main() {
  final baseDir = 'c:\\Users\\ali\\incidents_managment\\lib\\core\\future\\mission_assigen';
  final files = [
    File('\$baseDir\\ui\\screens\\mission_assign_mobile.dart'),
    File('\$baseDir\\ui\\screens\\mission_assign_web.dart'),
  ];
  
  for (final file in files) {
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    
    // Remove _PremiumAppBar
    final appbarRegex = RegExp(r'class _PremiumAppBar extends StatelessWidget \{.*?\}\n\}\n', dotAll: true);
    content = content.replaceAll(appbarRegex, '');
    
    // Remove _GlassIconButton
    final glassRegex = RegExp(r'class _GlassIconButton extends StatelessWidget \{.*?\}\n\}\n', dotAll: true);
    content = content.replaceAll(glassRegex, '');
    
    // Remove _AppBarChip
    final chipRegex = RegExp(r'class _AppBarChip extends StatelessWidget \{.*?\}\n\}\n', dotAll: true);
    content = content.replaceAll(chipRegex, '');
    
    // Replace usages
    content = content.replaceAll('_PremiumAppBar', 'PremiumAppBar');
    content = content.replaceAll('_GlassIconButton', 'GlassIconButton');
    content = content.replaceAll('_AppBarChip', 'AppBarChip');
    
    // Add imports
    final importStmt = "import '../widgets/premium_app_bar.dart';";
    if (!content.contains(importStmt)) {
      content = content.replaceFirst(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\nimport '../widgets/premium_app_bar.dart';"
      );
    }
    
    file.writeAsStringSync(content);
  }
  print('Done');
}
