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
    
    // Remove _severityColor block
    final colorRegex = RegExp(r'// Severity color helpers\s*Color _severityColor.*?\}\n', dotAll: true);
    content = content.replaceAll(colorRegex, '');
    
    // Remove _severityLabel block
    final labelRegex = RegExp(r'String _severityLabel.*?\}\n', dotAll: true);
    content = content.replaceAll(labelRegex, '');
    
    // Remove _SeverityBadge class block
    final badgeRegex = RegExp(r'class _SeverityBadge extends StatelessWidget \{.*?\}\n\}\n', dotAll: true);
    content = content.replaceAll(badgeRegex, '');
    
    // Replace usages
    content = content.replaceAll('_SeverityBadge', 'SeverityBadge');
    
    // Add import
    final importStmt = "import '../widgets/severity_badge.dart';";
    if (!content.contains(importStmt)) {
      content = content.replaceFirst(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\nimport '../widgets/severity_badge.dart';"
      );
    }
    
    file.writeAsStringSync(content);
  }
  print('Done');
}
