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

class CrisisDashboard extends StatefulWidget {
  const CrisisDashboard({super.key});

  @override
  State<CrisisDashboard> createState() => _CrisisDashboardState();
}

class _CrisisDashboardState extends State<CrisisDashboard> {
  // To keep track of which tabs have been initialized (built)
  final List<bool> _isBuilt = List.generate(
    8,
    (i) => i == 0 || i == 1,
  ); // Always build dashboard and map initially

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
                    title: const Text(
                      'إدارة الأزمات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: true,
                  )
                : null,
            drawer: isMobile ? Drawer(child: buildSidebar(context)) : null,
            body: SafeArea(
              child: Row(
                children: [
                  if (!isMobile)
                    const RepaintBoundary(child: SidebarWrapper()),

                  /// MAIN CONTENT
                  Expanded(
                    child: BlocBuilder<HomeCubit, HomeStates>(
                      buildWhen: (p, c) => c is HomeChanged,
                      builder: (context, state) {
                        final index = context.select(
                          (HomeCubit c) => c.selectedIndex,
                        );

                        // Mark this index as built
                        if (index < _isBuilt.length) {
                          _isBuilt[index] = true;
                        }

                        // Close drawer automatically on mobile navigation
                        if (isMobile) {
                          WidgetsBinding.instance.addPostFrameCallback((
                            _,
                          ) {
                            if (Scaffold.of(context).isDrawerOpen) {
                              Scaffold.of(context).closeDrawer();
                            }
                          });
                        }

                        return IndexedStack(
                          index: index,
                          children: List.generate(8, (i) {
                            // Lazy load: if not built yet, show empty
                            if (!_isBuilt[i]) return const SizedBox.shrink();

                            switch (i) {
                              case 0:
                                return const DashboardView();
                              case 1:
                                return const IncidentsMapScreen();
                              case 4:
                                return const AddIncidentScreen();
                              case 5:
                                return const AllIncidentType();
                              case 6:
                                return const AllMissions();
                              case 7:
                                return const Addincidentmission();
                              default:
                                return const SizedBox.shrink();
                            }
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SidebarWrapper extends StatelessWidget {
  const SidebarWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return buildSidebar(context);
  }
}
