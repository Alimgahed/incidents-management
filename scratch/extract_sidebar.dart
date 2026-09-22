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
    
    // Remove _MissionsSidebar
    final sidebarRegex = RegExp(r'class _MissionsSidebar extends StatelessWidget \{.*?\}\n\}\n', dotAll: true);
    content = content.replaceAll(sidebarRegex, '');
    
    // Replace usages
    content = content.replaceAll('_MissionsSidebar', 'MissionsSidebar');
    
    // Add imports
    final importStmt = "import '../widgets/missions_sidebar.dart';";
    if (!content.contains(importStmt)) {
      content = content.replaceFirst(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\nimport '../widgets/missions_sidebar.dart';"
      );
    }
    
    file.writeAsStringSync(content);
  }
  print('Done');
}
