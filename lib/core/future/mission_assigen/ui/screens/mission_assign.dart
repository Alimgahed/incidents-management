import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/screens/mission_assign_web.dart';
import 'package:incidents_managment/core/future/mission_assigen/ui/screens/mission_assign_mobile.dart';

class MissionAssignScreen extends StatelessWidget {
  final CurrentIncidentModel incident;
  const MissionAssignScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || MediaQuery.sizeOf(context).width > 800;

    if (isDesktop) {
      return MissionAssignWebScreen(incident: incident);
    } else {
      return MissionAssignMobileScreen(incident: incident);
    }
  }
}
