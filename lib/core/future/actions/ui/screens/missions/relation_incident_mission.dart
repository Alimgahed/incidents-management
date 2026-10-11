import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/order_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/link_missions_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_missions_state.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/link_missions_header.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/selected_missions_list.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/available_missions_grid.dart';
import 'package:incidents_managment/core/widget/fields.dart';

// Model for selected mission with order
class SelectedMission {
  final int missionId;
  final String missionName;
  final int order;
  final String uniqueId; // For tracking multiple instances

  SelectedMission({
    required this.missionId,
    required this.missionName,
    required this.order,
    required this.uniqueId,
  });

  SelectedMission copyWith({
    int? missionId,
    String? missionName,
    int? order,
    String? uniqueId,
  }) {
    return SelectedMission(
      missionId: missionId ?? this.missionId,
      missionName: missionName ?? this.missionName,
      order: order ?? this.order,
      uniqueId: uniqueId ?? this.uniqueId,
    );
  }
}

// State class
class MissionSelectionState {
  final int? selectedIncidentClassId;
  final int? selectedIncidentTypeId;
  final List<SelectedMission> selectedMissions;

  MissionSelectionState({
    this.selectedIncidentClassId,
    this.selectedIncidentTypeId,
    List<SelectedMission>? selectedMissions,
  }) : selectedMissions = selectedMissions ?? [];

  MissionSelectionState copyWith({
    int? selectedIncidentClassId,
    int? selectedIncidentTypeId,
    List<SelectedMission>? selectedMissions,
    bool clearIncidentClassId = false,
    bool clearIncidentTypeId = false,
  }) {
    return MissionSelectionState(
      selectedIncidentClassId: clearIncidentClassId
          ? null
          : selectedIncidentClassId ?? this.selectedIncidentClassId,
      selectedIncidentTypeId: clearIncidentTypeId
          ? null
          : selectedIncidentTypeId ?? this.selectedIncidentTypeId,
      selectedMissions: selectedMissions ?? this.selectedMissions,
    );
  }
}

class Addincidentmission extends StatefulWidget {
  const Addincidentmission({super.key});

  @override
  State<Addincidentmission> createState() => _AddIncidentMissionBodyState();
}

class _AddIncidentMissionBodyState extends State<Addincidentmission> {
  bool _isDialogShowing = false;

  void _closeDialogIfOpen() {
    if (_isDialogShowing && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      _isDialogShowing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MissionSelectionCubit()),
        BlocProvider(
          create: (_) => getIt<AllMissionsCubit>()..getAllMissions(),
        ),
        BlocProvider(create: (_) => getIt<AddIncidentMissionCubit>()),
        BlocProvider(
          create: (_) => getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
        ),
        BlocProvider(create: (_) => LinkMissionsFilterCubit()),
      ],
      child: Scaffold(
        backgroundColor: scaffoldColor,
        body: Builder(builder: (context) {
          return BlocConsumer<AddIncidentMissionCubit, AddincidentMissionsstates>(
            listener: (context, state) {
              state.when(
                initial: () {
                  _closeDialogIfOpen();
                },
                loading: () {
                  if (!_isDialogShowing) {
                    _isDialogShowing = true;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogContext) => const PopScope(
                        canPop: false,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                },
                success: () {
                  _closeDialogIfOpen();
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حفظ البيانات بنجاح'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  context.read<MissionSelectionCubit>().reset();
                  context.read<AddIncidentMissionCubit>().resetState();
                },
                error: (e) {
                  _closeDialogIfOpen();
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.error ?? "حدث خطأ غير متوقع"),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              );
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Incident Type Selection)
                    BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                      buildWhen: (previous, current) => previous.selectedIncidentTypeId != current.selectedIncidentTypeId,
                      builder: (context, selectionState) {
                        return LinkMissionsHeader(
                          selectedTypeId: selectionState.selectedIncidentTypeId,
                          onTypeSelected: (id) => context.read<MissionSelectionCubit>().setIncidentType(id),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Selected Missions
                    BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                      builder: (context, selectionState) {
                        return SelectedMissionsList(
                          selectedMissions: selectionState.selectedMissions,
                          onRemove: (id) => context.read<MissionSelectionCubit>().removeMission(id),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Available Missions Grid
                    BlocBuilder<AllMissionsCubit, GetAllMissionState>(
                      builder: (context, missionState) {
                        return missionState.when(
                          initial: () => const SizedBox.shrink(),
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (e) => const Center(child: Text('حدث خطأ أثناء جلب المهام')),
                          loaded: (missions) {
                            return AvailableMissionsGrid(
                              allMissions: missions,
                              onMissionAdd: (id, name) {
                                context.read<MissionSelectionCubit>().addMission(id, name);
                              },
                              getMissionCount: (id) => context.read<MissionSelectionCubit>().getMissionCount(id),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                      builder: (context, selectionState) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: CustomButton(
                            text: "حفظ البيانات",
                            onPressed: () {
                              context.read<AddIncidentMissionCubit>().saveIncidentMission(
                                    selectionState: selectionState,
                                    incidentTypeId: selectionState.selectedIncidentTypeId,
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
