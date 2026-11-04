import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/add_incident_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/order_mission_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/link_missions_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_missions_state.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/link_missions_header.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/selected_missions_list.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/link_missions/available_missions_grid.dart';
import 'package:incidents_managment/core/widget/fields.dart';
import 'package:incidents_managment/core/widget/shimmer/screen_shimmers.dart';

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
  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: MobileSystemBars.standard,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Builder(
              builder: (context) {
                return BlocConsumer<
                  AddIncidentMissionCubit,
                  AddincidentMissionsstates
                >(
                  listener: (context, state) {
                    state.whenOrNull(
                      success: () {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حفظ ربط المهام بنوع الأزمة بنجاح'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 2),
                          ),
                        );

                        context.read<MissionSelectionCubit>().reset();
                        context.read<AddIncidentMissionCubit>().resetState();
                      },
                      error: (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.error ?? "حدث خطأ غير متوقع"),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                    );
                  },
                  builder: (context, state) {
                    final isSubmitting = state.maybeWhen(
                      loading: () => true,
                      orElse: () => false,
                    );

                    return SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Only show standalone mobile header banner when pushed on navigation stack
                          if (canPop)
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF0F3B6C),
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/header_banner.jpg',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(
                                        0xFF0A2240,
                                      ).withValues(alpha: 0.94),
                                      const Color(
                                        0xFF0F3866,
                                      ).withValues(alpha: 0.88),
                                      const Color(
                                        0xFF164780,
                                      ).withValues(alpha: 0.97),
                                    ],
                                  ),
                                ),
                                child: SafeArea(
                                  bottom: false,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      12,
                                      16,
                                      20,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.25),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Image.asset(
                                                'assets/images/logo.png',
                                                fit: BoxFit.contain,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => const Icon(
                                                      Icons.water_drop_rounded,
                                                      color: appColor,
                                                      size: 28,
                                                    ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => Navigator.of(
                                                context,
                                              ).maybePop(),
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.16),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(
                                                          alpha: 0.25,
                                                        ),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'ربط مهام بنوع الأزمة',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'شركة مياه الشرب والصرف الصحي بالمنيا',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white.withValues(
                                              alpha: 0.88,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header (Incident Type Selection)
                                BlocBuilder<
                                  MissionSelectionCubit,
                                  MissionSelectionState
                                >(
                                  buildWhen: (previous, current) =>
                                      previous.selectedIncidentTypeId !=
                                      current.selectedIncidentTypeId,
                                  builder: (context, selectionState) {
                                    return LinkMissionsHeader(
                                      selectedTypeId:
                                          selectionState.selectedIncidentTypeId,
                                      onTypeSelected: (id) => context
                                          .read<MissionSelectionCubit>()
                                          .setIncidentType(id),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Selected Missions
                                BlocBuilder<
                                  MissionSelectionCubit,
                                  MissionSelectionState
                                >(
                                  builder: (context, selectionState) {
                                    return SelectedMissionsList(
                                      selectedMissions:
                                          selectionState.selectedMissions,
                                      onRemove: (id) => context
                                          .read<MissionSelectionCubit>()
                                          .removeMission(id),
                                    );
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Available Missions Grid
                                BlocBuilder<AllMissionsCubit, GetAllMissionState>(
                                  builder: (context, missionState) {
                                    return missionState.when(
                                      initial: () =>
                                          const LinkMissionsScreenShimmer(),
                                      loading: () =>
                                          const LinkMissionsScreenShimmer(),
                                      error: (e) => AppErrorState(
                                        title: 'تعذر تحميل المهام القياسية',
                                        message: e.isNotEmpty
                                            ? e
                                            : 'حدث خطأ أثناء جلب المهام، يرجى المحاولة مرة أخرى.',
                                        onRetry: () => context
                                            .read<AllMissionsCubit>()
                                            .getAllMissions(forceLoading: true),
                                      ),
                                      loaded: (missions) {
                                        return AvailableMissionsGrid(
                                          allMissions: missions,
                                          onMissionAdd: (id, name) {
                                            context
                                                .read<MissionSelectionCubit>()
                                                .addMission(id, name);
                                          },
                                          getMissionCount: (id) => context
                                              .read<MissionSelectionCubit>()
                                              .getMissionCount(id),
                                        );
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Save Button
                                BlocBuilder<
                                  MissionSelectionCubit,
                                  MissionSelectionState
                                >(
                                  builder: (context, selectionState) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: CustomButton(
                                        text: isSubmitting
                                            ? "جاري الحفظ..."
                                            : "حفظ ربط المهام (${selectionState.selectedMissions.length})",
                                        isLoading: isSubmitting,
                                        onPressed: () {
                                          context
                                              .read<AddIncidentMissionCubit>()
                                              .saveIncidentMission(
                                                selectionState: selectionState,
                                                incidentTypeId: selectionState
                                                    .selectedIncidentTypeId,
                                              );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
