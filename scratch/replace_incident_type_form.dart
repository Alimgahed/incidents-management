import 'dart:io';

void main() {
  final mobileFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/add_incident_type_mobile.dart');
  final webFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/add_incident_type_web.dart');
  
  if (mobileFile.existsSync()) {
    String mContent = mobileFile.readAsStringSync();
    
    // Find start
    final mStart = mContent.indexOf('BlocBuilder<AllIncidentClasses, GetAllIncidentClassesState>');
    if (mStart != -1) {
      // Find end
      final nameFieldStart = mContent.indexOf('CustomTextFormField(', mStart);
      final mEnd = mContent.indexOf('},', nameFieldStart) + 2;
      final fullEnd = mContent.indexOf('),', mEnd) + 2;
      
      final chunk = mContent.substring(mStart, fullEnd);
      mContent = mContent.replaceFirst(chunk, 'const SharedIncidentTypeForm(isWeb: false),');
      
      if (!mContent.contains('shared_incident_type_form.dart')) {
        mContent = mContent.replaceFirst(
          "import 'package:flutter/material.dart';",
          "import 'package:flutter/material.dart';\nimport 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_type_form.dart';"
        );
      }
      mobileFile.writeAsStringSync(mContent);
    }
  }

  if (webFile.existsSync()) {
    String wContent = webFile.readAsStringSync();
    
    // The Row containing the two Expanded widgets
    final wStart = wContent.indexOf('Row(', wContent.indexOf('const SizedBox(height: 32),'));
    if (wStart != -1) {
      final buttonStart = wContent.indexOf('const SizedBox(height: 40),');
      if (buttonStart != -1) {
        final chunk = wContent.substring(wStart, buttonStart);
        wContent = wContent.replaceFirst(chunk, 'const SharedIncidentTypeForm(isWeb: true),\n          ');
        
        if (!wContent.contains('shared_incident_type_form.dart')) {
          wContent = wContent.replaceFirst(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_type_form.dart';"
          );
        }
        webFile.writeAsStringSync(wContent);
      }
    }
  }
  print('Done replace type form');
}
