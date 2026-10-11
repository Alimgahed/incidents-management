import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_missions_state.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/missions_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/missions_filter_state.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/missions/missions_stats_cards.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/missions/missions_filters_panel.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/missions/missions_grid.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';

class AllMissionsWeb extends StatelessWidget {
  const AllMissionsWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MissionsFilterCubit(),
        ),
      ],
      child: const _AllMissionsWebBody(),
    );
  }
}

class _AllMissionsWebBody extends StatelessWidget {
  const _AllMissionsWebBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Enterprise background
      body: BlocBuilder<AllMissionsCubit, GetAllMissionState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: BuildEmptyState(
                title: 'لا توجد مهام حالياً',
                message: 'ابدأ بإضافة مهمة جديدة',
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: appColor),
            ),
            loaded: (missions) {
              if (missions.isEmpty) {
                return const Center(
                  child: BuildEmptyState(
                    title: 'لا توجد مهام مطابقة',
                    message: 'حاول تعديل معايير البحث أو أضف مهام جديدة',
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards
                      MissionsStatsCards(missions: missions),
                      const SizedBox(height: 24),

                      // Filters Panel
                      MissionsFiltersPanel(rawMissions: missions),
                      const SizedBox(height: 24),

                      // Action Bar (Add new mission button)
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              await context.pushNamed(Routes.addMissions);
                              if (context.mounted) {
                                context.read<AllMissionsCubit>().getAllMissions();
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('إضافة مهمة جديدة'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4F8A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Reactive Grid based on Filter Cubit
                      BlocBuilder<MissionsFilterCubit, MissionsFilterState>(
                        builder: (context, filterState) {
                          final filterCubit = context.read<MissionsFilterCubit>();
                          final filteredMissions = filterCubit.filterMissions(missions);

                          return MissionsGrid(missions: filteredMissions);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "حدث خطأ: $message",
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AllMissionsCubit>().getAllMissions(),
                    child: const Text('إعادة المحاولة'),
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
