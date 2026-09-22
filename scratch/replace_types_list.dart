import 'dart:io';

void main() {
  final mobileFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/all_incident_type_mobile.dart');
  final webFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/all_incident_type_web.dart');
  
  if (mobileFile.existsSync()) {
    String mContent = mobileFile.readAsStringSync();
    
    // In mobile, we replace _LoadedView(incidentTypes: incidentTypes) with SharedIncidentTypesList(incidentTypes: incidentTypes, isWeb: false)
    mContent = mContent.replaceAll('_LoadedView(incidentTypes: incidentTypes)', 'SharedIncidentTypesList(incidentTypes: incidentTypes, isWeb: false)');
    
    // Remove the definition of _LoadedView and everything after it
    final mLoadedViewStart = mContent.indexOf('class _LoadedView extends StatelessWidget {');
    if (mLoadedViewStart != -1) {
      mContent = mContent.substring(0, mLoadedViewStart);
    }
    
    // Add import
    if (!mContent.contains('shared_incident_types_list.dart')) {
      mContent = mContent.replaceFirst(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart';"
      );
    }
    mobileFile.writeAsStringSync(mContent);
  }

  if (webFile.existsSync()) {
    String wContent = webFile.readAsStringSync();
    
    // In web, replace _buildGridView(filteredList) with SharedIncidentTypesList(incidentTypes: filteredList, isWeb: true)
    wContent = wContent.replaceAll('_buildGridView(filteredList)', 'SharedIncidentTypesList(incidentTypes: filteredList, isWeb: true)');
    
    // Remove the definition of _buildGridView and everything after it
    final wGridStart = wContent.indexOf('Widget _buildGridView(');
    if (wGridStart != -1) {
      wContent = wContent.substring(0, wGridStart);
      // However, we need to make sure we close the _AllIncidentTypeWebScreenState class.
      wContent = wContent + '\n}\n';
    }
    
    // Add import
    if (!wContent.contains('shared_incident_types_list.dart')) {
      wContent = wContent.replaceFirst(
        "import 'package:flutter/material.dart';",
        "import 'package:flutter/material.dart';\nimport 'package:incidents_managment/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart';"
      );
    }
    webFile.writeAsStringSync(wContent);
  }
  print('Done replacing in mobile and web');
}
