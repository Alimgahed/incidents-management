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
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Row(
            children: [
            if (MediaQuery.of(context).size.width > 600)
             buildSidebar(context),

              /// MAIN CONTENT
              Expanded(
                child: BlocBuilder<HomeCubit, HomeStates>(
                  buildWhen: (p, c) => c is HomeChanged,
                  builder: (context, state) {
                    final index = context.select(
                      (HomeCubit c) => c.selectedIndex,
                    );

                    // Lazy-loaded IndexedStack
                    return IndexedStack(
                      index: index,
                      children: List.generate(8, (i) {
                        switch (i) {
                          case 0:
                            return const DashboardView();
                          case 1:
                            return const IncidentsMapScreen();
                          case 4:
                            return i == index
                                ? const AddIncidentScreen()
                                : const SizedBox.shrink();
                          case 5:
                            return i == index
                                ? const AllIncidentType()
                                : const SizedBox.shrink();
                          case 6:
                            return i == index
                                ? const AllMissions()
                                : const SizedBox.shrink();
                          case 7:
                            return i == index
                                ? const Addincidentmission()
                                : const SizedBox.shrink();
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
      ),
    );
  }
}
