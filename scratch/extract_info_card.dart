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
    
    // Remove _IncidentInfoCard
    final infoRegex = RegExp(r'class _IncidentInfoCard extends StatelessWidget \{.*?\}\n\}\n', dotAll: true);
    content = content.replaceAll(infoRegex, '');
    
    // Replace usages
    content = content.replaceAll('_IncidentInfoCard', 'IncidentInfoCard');
    
    // Add imports
    final importStmt = "import '../widgets/incident_info_card.dart';";
    if (!content.contains(importStmt)) {
      content = content.replaceFirst(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\nimport '../widgets/incident_info_card.dart';"
      );
    }
    
    file.writeAsStringSync(content);
  }
  print('Done');
}
