import 'package:flutter/material.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident_type_mobile.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident_type_web.dart';

class AddIncidentType extends StatelessWidget {
  const AddIncidentType({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || MediaQuery.sizeOf(context).width > 800;

    if (isDesktop) {
      return const AddIncidentTypeWeb();
    } else {
      return const AddIncidentTypeMobile();
    }
  }
}
