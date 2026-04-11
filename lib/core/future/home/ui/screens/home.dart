import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/all_missions.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/dash_board.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map_widget.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/side_bar.dart';

class CrisisDashboard extends StatelessWidget {
  const CrisisDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: Builder(
        builder: (context) {
          final isMobile = MediaQuery.of(context).size.width <= 600;
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7FA),
            appBar: isMobile
                ? AppBar(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    title: const Text('إدارة الأزمات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    centerTitle: true,
                  )
                : null,
            drawer: isMobile ? Drawer(child: buildSidebar(context)) : null,
            body: SafeArea(
              child: Row(
                children: [
                  if (!isMobile) buildSidebar(context),

                  /// MAIN CONTENT
                  Expanded(
                    child: BlocBuilder<HomeCubit, HomeStates>(
                      buildWhen: (p, c) => c is HomeChanged,
                      builder: (context, state) {
                        final index = context.select(
                          (HomeCubit c) => c.selectedIndex,
                        );

                        // Optimizing memory by not building all screens at once
                        Widget activeScreen;
                        switch (index) {
                          case 0:
                            activeScreen = const DashboardView();
                            break;
                          case 1:
                            activeScreen = const IncidentsMapScreen();
                            break;
                          case 4:
                            activeScreen = const AddIncidentScreen();
                            break;
                          case 5:
                            activeScreen = const AllIncidentType();
                            break;
                          case 6:
                            activeScreen = const AllMissions();
                            break;
                          case 7:
                            activeScreen = const Addincidentmission();
                            break;
                          default:
                            activeScreen = const Center(child: Text("هذه الشاشة غير متوفرة حالياً"));
                        }

                        // Close drawer automatically upon mobile navigation
                        if (isMobile && Scaffold.of(context).isDrawerOpen) {
                          Scaffold.of(context).closeDrawer();
                        }
                        
                        return activeScreen;
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
