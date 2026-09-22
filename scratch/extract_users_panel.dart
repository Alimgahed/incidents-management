import 'dart:io';

void main() {
  final mobileFile = File('c:/Users/ali/incidents_managment/lib/core/future/mission_assigen/ui/screens/mission_assign_mobile.dart');
  final webFile = File('c:/Users/ali/incidents_managment/lib/core/future/mission_assigen/ui/screens/mission_assign_web.dart');
  final widgetsDir = 'c:/Users/ali/incidents_managment/lib/core/future/mission_assigen/ui/widgets';
  
  if (!mobileFile.existsSync()) print('mobile missing');
  if (!webFile.existsSync()) print('web missing');
  if (!mobileFile.existsSync() || !webFile.existsSync()) return;
  
  final mobileLines = mobileFile.readAsLinesSync();
  final webLines = webFile.readAsLinesSync();
  
  // Find where _MissionHorizontalTabs starts
  int mobileSplitIdx = mobileLines.indexWhere((l) => l.contains('class _MissionHorizontalTabs'));
  int webSplitIdx = webLines.indexWhere((l) => l.contains('class _MissionHorizontalTabs'));
  
  if (mobileSplitIdx == -1 || webSplitIdx == -1) {
    print('Split index not found');
    return;
  }
  
  final componentLines = mobileLines.sublist(mobileSplitIdx);
  final newMobileLines = mobileLines.sublist(0, mobileSplitIdx);
  final newWebLines = webLines.sublist(0, webSplitIdx);
  
  final classesToExtract = [
    '_MissionHorizontalTabs',
    '_UsersPanel', '_UsersList', '_FilterDropdown', '_UserCard',
    '_BottomActionBar', '_EmptyMissionPlaceholder', '_ErrorWidget',
    '_ConfirmDialogDesktop', '_ConfirmBottomSheet'
  ];
  
  String processContent(List<String> lines) {
    String content = lines.join('\n');
    for (final cls in classesToExtract) {
      final publicName = cls.substring(1);
      content = content.replaceAll(cls, publicName);
    }
    return content;
  }
  
  final processedMobile = processContent(newMobileLines);
  final processedWeb = processContent(newWebLines);
  
  final importStmt = "import '../widgets/users_panel.dart';";
  
  String addImport(String content) {
    if (!content.contains(importStmt)) {
      return content.replaceFirst(
        "import 'package:flutter/material.dart';", 
        "import 'package:flutter/material.dart';\n" + importStmt
      );
    }
    return content;
  }
  
  final mobileFinal = addImport(processedMobile);
  final webFinal = addImport(processedWeb);
  
  final imports = '''
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_assign_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/data/models/classes/all_incident_classes.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/all_active_user_state.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_assign_states.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';
import 'package:intl/intl.dart';

''';
  
  final processedComponents = processContent(componentLines);
  final finalComponents = imports + processedComponents;
  
  Directory(widgetsDir).createSync(recursive: true);
  File(widgetsDir + '/users_panel.dart').writeAsStringSync(finalComponents);
  
  mobileFile.writeAsStringSync(mobileFinal);
  webFile.writeAsStringSync(webFinal);
  
  print('Done extracting users panel');
}
