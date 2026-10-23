import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_filter_bottom_sheet.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_home_empty_state.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_home_filter_chips.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_home_header.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_home_search_bar.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_home_shimmer.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_home_stats.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/home/widgets/mobile_incident_card.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/gloable/gloable.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';

class MobileIncidentsListScreen extends StatefulWidget {
  const MobileIncidentsListScreen({super.key});

  @override
  State<MobileIncidentsListScreen> createState() =>
      _MobileIncidentsListScreenState();
}

class _MobileIncidentsListScreenState extends State<MobileIncidentsListScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<IncidentMapCubit>().initialize();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Whenever the user returns to the app, verify and reconnect socket
      context.read<IncidentMapCubit>().reconnectIfDisconnected();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToIncidentDetails(
    BuildContext context,
    CurrentIncidentModel incident,
    DashboardCubit dashboardCubit,
  ) {
    incidentID = incident.currentIncidentId ?? 0;
    dashboardCubit.selectIncident(incident);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: dashboardCubit),
            BlocProvider.value(value: context.read<IncidentMapCubit>()),
          ],
          child: MobileIncidentDetailsScreen(
            incidentId: incident.currentIncidentId,
            initialIncident: incident,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    List<CurrentIncidentModel> incidents,
  ) {
    final dashboardCubit = context.read<DashboardCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: dashboardCubit,
        child: MobileFilterBottomSheet(incidents: incidents),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: MobileSystemBars.standard,
      child: PopScope(
        canPop: _currentBottomNavIndex == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_currentBottomNavIndex != 0) {
            setState(() => _currentBottomNavIndex = 0);
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: BlocBuilder<IncidentMapCubit, IncidentMapState>(
            builder: (context, incidentState) {
              final incidents = context.read<IncidentMapCubit>().incidents;

              return BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, dashboardState) {
                  final dashboardCubit = context.read<DashboardCubit>();
                  final filteredIncidents = dashboardCubit.filterIncidents(
                    incidents,
                  );

                  final isLoadingInitial =
                      incidentState is IncidentMapLoading && incidents.isEmpty;
                  final isErrorInitial =
                      incidentState is IncidentMapError && incidents.isEmpty;
                  final hasActiveFilter =
                      dashboardCubit.hasActiveFilters ||
                      _searchController.text.trim().isNotEmpty;

                  return RefreshIndicator(
                    color: appColor,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await context.read<IncidentMapCubit>().refresh();
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // ================= TOP HEADER BANNER =================
                        SliverToBoxAdapter(
                          child: MobileHomeHeader(incidents: incidents),
                        ),

                        // ================= STATS & SEARCH/FILTERS =================
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 14),
                                MobileHomeStats(
                                  incidents: incidents,
                                  dashboardCubit: dashboardCubit,
                                ),
                                const SizedBox(height: 14),
                                MobileHomeSearchBar(
                                  controller: _searchController,
                                  dashboardCubit: dashboardCubit,
                                  onFilterTap: () => _showFilterBottomSheet(
                                    context,
                                    incidents,
                                  ),
                                ),
                                MobileHomeFilterChips(
                                  dashboardCubit: dashboardCubit,
                                  searchController: _searchController,
                                  incidents: incidents,
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),

                        // ================= INCIDENTS LIST / STATES =================
                        if (isLoadingInitial)
                          const SliverToBoxAdapter(
                            child: MobileHomeShimmerList(),
                          )
                        else if (isErrorInitial)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: MobileHomeEmptyState(
                              type: EmptyStateType.error,
                              errorMessage: incidentState.message,
                              onAction: () {
                                context.read<IncidentMapCubit>().refresh();
                              },
                            ),
                          )
                        else if (filteredIncidents.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: MobileHomeEmptyState(
                              type: hasActiveFilter
                                  ? EmptyStateType.noSearchResults
                                  : EmptyStateType.noIncidents,
                              onAction: () {
                                if (hasActiveFilter) {
                                  _searchController.clear();
                                  dashboardCubit.clearAllFilters();
                                } else {
                                  context.read<IncidentMapCubit>().refresh();
                                }
                              },
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final incident = filteredIncidents[index];
                                  return RepaintBoundary(
                                    key: ValueKey(
                                      incident.currentIncidentId ?? index,
                                    ),
                                    child: MobileIncidentCard(
                                      incident: incident,
                                      onTap: () => _navigateToIncidentDetails(
                                        context,
                                        incident,
                                        dashboardCubit,
                                      ),
                                    ),
                                  );
                                },
                                childCount: filteredIncidents.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          bottomNavigationBar: _buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  // --- NATIVE MOBILE BOTTOM NAVIGATION ---
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Tab 1: الرئيسية (Home - Active)
              _buildBottomNavItem(
                index: 0,
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: _currentBottomNavIndex == 0,
                onTap: () {
                  setState(() => _currentBottomNavIndex = 0);
                },
              ),

              // Tab 2: أنواع الأزمات (Incident Types)
              _buildBottomNavItem(
                index: 1,
                icon: Icons.article_outlined,
                label: 'أنواع الأزمات',
                isActive: _currentBottomNavIndex == 1,
                onTap: () {
                  context.pushNamed(Routes.allIncidentType);
                },
              ),

              // Tab Center: إضافة بلاغ (Floating Add Button)
              GestureDetector(
                onTap: () async {
                  await context.pushNamed(Routes.addIncidentMobile);
                  if (context.mounted) {
                    context.read<IncidentMapCubit>().refresh();
                  }
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B64F2),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x551B64F2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'إضافة بلاغ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B64F2),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab 4: المهام (Tasks)
              _buildBottomNavItem(
                index: 2,
                icon: Icons.fact_check_outlined,
                label: 'المهام',
                isActive: _currentBottomNavIndex == 2,
                onTap: () {
                  context.pushNamed(Routes.allMissions);
                },
              ),

              // Tab 5: المزيد (More Services)
              _buildBottomNavItem(
                index: 3,
                icon: Icons.grid_view_rounded,
                label: 'المزيد',
                isActive: false,
                onTap: () {
                  context.pushNamed(Routes.mobileMoreServices);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? const Color(0xFF1B64F2)
                  : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? const Color(0xFF1B64F2)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
