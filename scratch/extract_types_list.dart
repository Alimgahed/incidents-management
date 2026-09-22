import 'dart:io';

void main() {
  final mobileFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/all_incident_type_mobile.dart');
  final webFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/screens/incident.dart/all_incident_type_web.dart');
  
  if (!mobileFile.existsSync() || !webFile.existsSync()) {
    print('Files not found');
    return;
  }

  // 1. We will extract _LoadedView, _IncidentTypeCard, etc from mobile.
  // 2. We will extract _buildGridView, _WebIncidentTypeCard, etc from web.
  // We'll put them in a single new file: shared_incident_types_list.dart
  
  final mContent = mobileFile.readAsStringSync();
  final wContent = webFile.readAsStringSync();
  
  final mLoadedViewStart = mContent.indexOf('class _LoadedView extends StatelessWidget {');
  final mLoadedViewContent = mContent.substring(mLoadedViewStart);
  
  final wGridStart = wContent.indexOf('Widget _buildGridView(');
  final wGridContent = wContent.substring(wGridStart);
  
  // Create shared file content
  final sharedFileContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/helpers/routing.dart';

class SharedIncidentTypesList extends StatelessWidget {
  final List<IncidentType> incidentTypes;
  final bool isWeb;
  
  const SharedIncidentTypesList({
    super.key,
    required this.incidentTypes,
    required this.isWeb,
  });

  @override
  Widget build(BuildContext context) {
    if (isWeb) {
      return _buildGridView(incidentTypes);
    } else {
      return _LoadedView(incidentTypes: incidentTypes);
    }
  }

${wGridContent.replaceAll('Widget _buildGridView', 'Widget _buildGridView')}

}

${mLoadedViewContent}
''';

  final sharedFile = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart');
  sharedFile.writeAsStringSync(sharedFileContent);
  
  print('Created shared_incident_types_list.dart');
}
