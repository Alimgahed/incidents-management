import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/states/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/states/update_statues.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_details.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incient_list.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardCubit _dashboardCubit;
  late final IncidentMapCubit _incidentMapCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _incidentMapCubit = IncidentMapCubit();
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _incidentMapCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider.value(value: _incidentMapCubit),
        BlocProvider(
          create: (context) =>
              EditIncidentCubit(editIncidentRepo: getIt<EditIncidentRepo>()),
        ),
        BlocProvider(
          create: (context) =>
              UpdateStatuesCubit(updateStatuesRepo: getIt<UpdateStatuesRepo>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // ===========
          //====== DASHBOARD SIDE EFFECTS =================
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (_, state) => state.maybeWhen(
              error: (_) => true,
              updateRequested: (_, __, ___) => true,
              missionUpdateRequested: (_, __, ___) => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message)),
                        ],
                      ),
                    ),
                  );
                },

                updateRequested: (incidentId, newStatus, newSeverity) {
                  // context.read<IncidentMapCubit>().updateMissionStatus(
                  //   incidentId: incidentId,
                  //   newStatus: newStatus,
                  //   missionId: 0,
                  // );
                },

                missionUpdateRequested: (incidentId, missionId, newStatus) {
                  // context.read<IncidentMapCubit>().updateMissionStatus(
                  //   incidentId: incidentId,
                  //   missionId: missionId,
                  //   newStatus: newStatus,
                  // );
                },

                orElse: () {},
              );
            },
          ),
          BlocListener<EditIncidentCubit, EditIncidentStates>(
            listenWhen: (previous, current) => current.maybeWhen(
              error: (_) => true,
              success: () => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message.error ?? "")),
                        ],
                      ),
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(child: Text("تم تحديث الأزمة بنجاح")),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<UpdateStatuesCubit, UpdateStatuesStates>(
            listenWhen: (previous, current) => current.maybeWhen(
              error: (_) => true,
              success: () => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message.error ?? "")),
                        ],
                      ),
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(child: Text("تم تحديث المهمة بنجاح")),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),

          // ================= MAP → DASHBOARD SYNC =================
          BlocListener<IncidentMapCubit, IncidentMapState>(
            listenWhen: (_, state) => state is IncidentMapLoaded,
            listener: (context, state) {
              if (state is IncidentMapLoaded) {
                context.read<DashboardCubit>().syncWithIncidents(
                  state.incidents,
                );
              }
            },
          ),
        ],
        child: BlocBuilder<IncidentMapCubit, IncidentMapState>(
          builder: (context, mapState) {
            final allIncidents = mapState is IncidentMapLoaded
                ? mapState.incidents
                : <CurrentIncidentModel>[];

            return  Row(
              children: [
                SizedBox(
                  width: 80.w,
                  child: IncidentsList(allIncidents: allIncidents),
                ),
                Expanded(flex: 4, child: IncidentDetailsPanel()),
              ],
            );
          },
        ),
      ),
    );
  }
}
