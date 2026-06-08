import 'package:flutter/material.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/add_missions_mobile.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/add_missions_web.dart';

class AddMissions extends StatelessWidget {
  const AddMissions({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context) || MediaQuery.sizeOf(context).width > 800;

    if (isDesktop) {
      return const AddMissionsWeb();
    } else {
      return const AddMissionsMobile();
    }
  }
}
