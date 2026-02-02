import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/order_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_missions_state.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
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

// Cubit for managing mission selection state

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

  @override
  void initState() {
    super.initState();
    // Only reset the states, don't interfere with data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AddIncidentMissionCubit>().resetState();
        context.read<MissionSelectionCubit>().reset();
      }
    });
  }

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
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
        child: BlocConsumer<AddIncidentMissionCubit, AddincidentMissionsstates>(
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
                    builder: (dialogContext) => WillPopScope(
                      onWillPop: () async => false,
                      child: const Center(child: CircularProgressIndicator()),
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

                // Reset both cubits for next save
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
            // ... rest of your UI code stays exactly the same
            // ... rest of your build method stays the same
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Globalheader(
                  icon: Icons.edit_note_rounded,
                  title: 'بيانات المهمة',
                ),
                const SizedBox(height: 24),

                // Incident Type Dropdown
                BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
                  builder: (context, typeState) {
                    return typeState.when(
                      initial: () => const SizedBox.shrink(),
                      loading: () => _buildLoadingField("نوع الأزمة"),
                      error: (e) => _buildErrorState(),
                      loaded: (types) =>
                          BlocBuilder<
                            MissionSelectionCubit,
                            MissionSelectionState
                          >(
                            builder: (context, selectionState) {
                              return CustomDropdownFormField<int>(
                                hintText: 'اختر نوع الأزمة',
                                iconData: Icons.category_outlined,
                                value: selectionState.selectedIncidentTypeId,
                                items: types.map((type) {
                                  return DropdownMenuItem<int>(
                                    value: type.incidentTypeId,
                                    child: Text(type.incidentTypeName),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  context
                                      .read<MissionSelectionCubit>()
                                      .setIncidentType(value);
                                },
                              );
                            },
                          ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Selected Missions Section
                BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                  builder: (context, selectionState) {
                    if (selectionState.selectedMissions.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Globalheader(
                              icon: Icons.check_circle_outline,
                              title: 'المهمات المحددة',
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'العدد: ${selectionState.selectedMissions.length}',
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: selectionState.selectedMissions.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final mission =
                                selectionState.selectedMissions[index];

                            return _SelectedMissionItem(
                              order: mission.order,
                              missionName: mission.missionName,
                              onRemove: () {
                                context
                                    .read<MissionSelectionCubit>()
                                    .removeMission(mission.uniqueId);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),

                // Available Missions Section Header
                const Globalheader(
                  icon: Icons.assignment_outlined,
                  title: 'المهمات المتاحة',
                ),
                const SizedBox(height: 8),
                Text(
                  'اضغط على المهمة لإضافتها (يمكنك إضافة نفس المهمة عدة مرات بترتيبات مختلفة)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // Missions Grid
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
                      error: (e) => _buildErrorState(),
                      loaded: (missions) {
                        if (missions.isEmpty) {
                          return _buildEmptyState();
                        }
                        return BlocBuilder<
                          MissionSelectionCubit,
                          MissionSelectionState
                        >(
                          builder: (context, selectionState) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount;
                                double childAspectRatio;

                                if (constraints.maxWidth < 600) {
                                  crossAxisCount = 2;
                                  childAspectRatio = 1.8;
                                } else if (constraints.maxWidth < 900) {
                                  crossAxisCount = 3;
                                  childAspectRatio = 2.0;
                                } else if (constraints.maxWidth < 1200) {
                                  crossAxisCount = 4;
                                  childAspectRatio = 2.0;
                                } else {
                                  crossAxisCount = 5;
                                  childAspectRatio = 2;
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: childAspectRatio,
                                      ),
                                  itemCount: missions.length,
                                  itemBuilder: (context, index) {
                                    final mission = missions[index];
                                    final selectionCount = context
                                        .read<MissionSelectionCubit>()
                                        .getMissionCount(mission.missionId!);

                                    return _MissionCard(
                                      missionId: mission.missionId!,
                                      missionName: mission.missionName,
                                      selectionCount: selectionCount,
                                      onTap: () {
                                        context
                                            .read<MissionSelectionCubit>()
                                            .addMission(
                                              mission.missionId!,
                                              mission.missionName,
                                            );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                // Save Button
                BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                  builder: (context, selectionState) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomButton(
                        text: "حفظ البيانات",
                        onPressed: () {
                          context
                              .read<AddIncidentMissionCubit>()
                              .saveIncidentMission(
                                selectionState: selectionState,
                                incidentTypeId:
                                    selectionState.selectedIncidentTypeId,
                              );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'لا توجد مهمات متاحة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMissionItem extends StatelessWidget {
  final int order;
  final String missionName;
  final VoidCallback onRemove;

  const _SelectedMissionItem({
    required this.order,
    required this.missionName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Order Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$order',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Mission Name
                Expanded(
                  child: Text(
                    missionName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Remove Icon
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final int missionId;
  final String missionName;
  final int selectionCount;
  final VoidCallback onTap;

  const _MissionCard({
    required this.missionId,
    required this.missionName,
    required this.selectionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectionCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    missionName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.blue.shade900
                          : Colors.grey.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.add_circle,
                    color: isSelected ? Colors.blue : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'محدد: $selectionCount مرة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
