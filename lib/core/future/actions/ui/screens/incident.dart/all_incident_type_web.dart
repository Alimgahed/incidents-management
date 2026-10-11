import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/incident_type_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_type_filter_state.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident_types/incident_type_stats_cards.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident_types/incident_type_filters_panel.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident_types/incident_type_grid.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';

class AllIncidentTypeWebScreen extends StatelessWidget {
  const AllIncidentTypeWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
        ),
        BlocProvider(
          create: (context) => IncidentTypeFilterCubit(),
        ),
      ],
      child: const _AllIncidentTypeWebBody(),
    );
  }
}

class _AllIncidentTypeWebBody extends StatelessWidget {
  const _AllIncidentTypeWebBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Enterprise background
      body: BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: BuildEmptyState(
                title: 'لا توجد أنواع أزمات',
                message: 'ابدأ بإضافة نوع جديد',
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator(color: appColor)),
            loaded: (incidentTypes) {
              if (incidentTypes.isEmpty) {
                return const Center(
                  child: BuildEmptyState(
                    title: 'لا توجد أنواع أزمات مطابقة',
                    message: 'حاول تعديل معايير البحث',
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
                      IncidentTypeStatsCards(incidentTypes: incidentTypes),
                      const SizedBox(height: 24),

                      // Filters Panel
                      IncidentTypeFiltersPanel(rawTypes: incidentTypes),
                      const SizedBox(height: 24),

                      // Action Bar (Add new type)
                      Row(
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              await context.pushNamed(Routes.addIncidentType);
                              if (context.mounted) {
                                context.read<AllIncidentTypeCubit>().getAllIncidentTypes();
                              }
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('إضافة نوع أزمة جديد'),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1B4F8A),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Grid (Reactive to Filter Cubit)
                      BlocBuilder<IncidentTypeFilterCubit, IncidentTypeFilterState>(
                        builder: (context, filterState) {
                          final filterCubit = context.read<IncidentTypeFilterCubit>();
                          final filteredTypes = filterCubit.filterIncidentTypes(incidentTypes);

                          return IncidentTypeGrid(incidentTypes: filteredTypes);
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
                  Text("حدث خطأ: $message", style: const TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AllIncidentTypeCubit>().getAllIncidentTypes(),
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
