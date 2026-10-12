import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
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
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/add_photo/add_image.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/gloable/gloable.dart';
import 'package:incidents_managment/core/security/authenticated_image.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/theming/styling.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class MobileIncidentsListScreen extends StatefulWidget {
  const MobileIncidentsListScreen({super.key});

  @override
  State<MobileIncidentsListScreen> createState() =>
      _MobileIncidentsListScreenState();
}

class _MobileIncidentsListScreenState extends State<MobileIncidentsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<IncidentMapCubit>().initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatArabicHeaderDate() {
    final now = DateTime.now();
    const arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final dayName = arabicDays[(now.weekday - 1) % 7];
    final monthName = arabicMonths[(now.month - 1) % 12];
    return '$dayName\n${now.day} $monthName ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentBottomNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentBottomNavIndex != 0) {
          setState(() => _currentBottomNavIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        body: _currentBottomNavIndex == 3
            ? _buildMoreServicesView(context)
            : BlocBuilder<IncidentMapCubit, IncidentMapState>(
                builder: (context, incidentState) {
                  final incidents = context.read<IncidentMapCubit>().incidents;

                  return BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, dashboardState) {
                      final dashboardCubit = context.read<DashboardCubit>();
                      final filteredIncidents =
                          dashboardCubit.filterIncidents(incidents);

                      final totalActive = incidents
                          .where((i) =>
                              i.currentIncidentStatus != 6 &&
                              i.currentIncidentStatus != 7)
                          .length;
                      final criticalCount = incidents
                          .where((i) => i.currentIncidentSeverity == 4)
                          .length;
                      final highCount = incidents
                          .where((i) => i.currentIncidentSeverity == 3)
                          .length;
                      final mediumCount = incidents
                          .where((i) => i.currentIncidentSeverity == 2)
                          .length;
                      final lowCount = incidents
                          .where((i) => i.currentIncidentSeverity == 1)
                          .length;
                      final totalCount = incidents.isEmpty ? 1 : incidents.length;

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
                              child: _buildHeaderBanner(context, incidents),
                            ),

                            // ================= STATS & SUMMARY =================
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 14),

                                    // Hero Active Incidents Card
                                    _buildHeroActiveCard(totalActive),

                                    const SizedBox(height: 12),

                                    // 4 Compact Severity Cards Row
                                    _buildSeverityCardsRow(
                                      dashboardCubit: dashboardCubit,
                                      criticalCount: criticalCount,
                                      highCount: highCount,
                                      mediumCount: mediumCount,
                                      lowCount: lowCount,
                                      totalCount: totalCount,
                                    ),

                                    const SizedBox(height: 14),

                                    // Search Bar and Filter Button
                                    _buildSearchAndFilterBar(
                                      context,
                                      dashboardCubit,
                                    ),

                                    const SizedBox(height: 16),

                                    // Recent Incidents Section Header
                                    _buildSectionHeader(
                                      context,
                                      totalCount: filteredIncidents.length,
                                      dashboardCubit: dashboardCubit,
                                    ),

                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),

                            // ================= INCIDENTS LIST =================
                            if (filteredIncidents.isEmpty)
                              SliverFillRemaining(
                                hasScrollBody: false,
                                child: _EmptyStateWidget(),
                              )
                            else
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final incident = filteredIncidents[index];
                                      return RepaintBoundary(
                                        child: _MobileIncidentCard(
                                          incident: incident,
                                          onTap: () {
                                            incidentID =
                                                incident.currentIncidentId ?? 0;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider.value(
                                                      value: dashboardCubit,
                                                    ),
                                                    BlocProvider.value(
                                                      value: context
                                                          .read<IncidentMapCubit>(),
                                                    ),
                                                  ],
                                                  child: MobileIncidentDetailsScreen(
                                                    incidentId:
                                                        incident.currentIncidentId,
                                                    initialIncident: incident,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
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
    );
  }

  // --- HEADER BANNER ---
  Widget _buildHeaderBanner(
    BuildContext context,
    List<CurrentIncidentModel> incidents,
  ) {
    final urgentAlertsCount = incidents
        .where((i) =>
            (i.currentIncidentSeverity == 4 ||
                i.currentIncidentSeverity == 3) &&
            i.currentIncidentStatus != 6 &&
            i.currentIncidentStatus != 7)
        .length;

    return Stack(
      children: [
        // Background Image with dark blue gradient overlay
        Container(
          height: 195,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF15447A),
            image: DecorationImage(
              image: AssetImage('assets/images/header_banner.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF0C2B52).withValues(alpha: 0.88),
                  const Color(0xFF154A85).withValues(alpha: 0.82),
                  const Color(0xFF1D5A9E).withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),

        // Foreground content with Safe Area
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                // Top App Bar Icons & Date/Weather
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile/Menu Icon -> Switches directly to More/Services Hub
                    GestureDetector(
                      onTap: () => setState(() => _currentBottomNavIndex = 3),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Notification Icon with dynamic badge
                    GestureDetector(
                      onTap: () {
                        final cubit = context.read<DashboardCubit>();
                        cubit.updateSeverityFilter(
                          cubit.selectedSeverity == 4 ? null : 4,
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          if (urgentAlertsCount > 0)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  urgentAlertsCount > 99
                                      ? '99+'
                                      : '$urgentAlertsCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Date & Weather widget
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wb_sunny_rounded,
                          color: Color(0xFFFBBF24),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatArabicHeaderDate(),
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Center Logo and Title
                Column(
                  children: [
                    // Circular Logo
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.water_drop_rounded,
                          color: appColor,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'إدارة الأزمات',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'شركة مياه الشرب والصرف الصحي بالمنيا',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- HERO ACTIVE INCIDENTS CARD ---
  Widget _buildHeroActiveCard(int totalActive) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2B6CB0),
            Color(0xFF1E5292),
            Color(0xFF133E72),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4F8A).withValues(alpha: 0.32),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative background waves/circles
            Positioned(
              left: -30,
              bottom: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 60,
              top: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Active Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'نشط',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Center Big Count & Label
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '$totalActive',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'إجمالي الأزمات النشطة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Signal Bars Icon Graphic
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 4.5,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 3.5),
                      Container(
                        width: 4.5,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 3.5),
                      Container(
                        width: 4.5,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4 SEVERITY SUMMARY CARDS ROW ---
  Widget _buildSeverityCardsRow({
    required DashboardCubit dashboardCubit,
    required int criticalCount,
    required int highCount,
    required int mediumCount,
    required int lowCount,
    required int totalCount,
  }) {
    return Row(
      children: [
        // 1. Follow-up / Medium (قيد المتابعة)
        Expanded(
          child: _buildSeverityCard(
            label: 'قيد المتابعة',
            count: mediumCount,
            total: totalCount,
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF3B82F6),
            barColor: const Color(0xFF3B82F6),
            isSelected: dashboardCubit.selectedSeverity == 2,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 2 ? null : 2;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 2. High (عالية)
        Expanded(
          child: _buildSeverityCard(
            label: 'عالية',
            count: highCount,
            total: totalCount,
            icon: Icons.warning_amber_rounded,
            iconColor: const Color(0xFFF59E0B),
            barColor: const Color(0xFFF59E0B),
            isSelected: dashboardCubit.selectedSeverity == 3,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 3 ? null : 3;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. Critical (حرجة)
        Expanded(
          child: _buildSeverityCard(
            label: 'حرجة',
            count: criticalCount,
            total: totalCount,
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFFEF4444),
            barColor: const Color(0xFFEF4444),
            isSelected: dashboardCubit.selectedSeverity == 4,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 4 ? null : 4;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. Low (منخفضة)
        Expanded(
          child: _buildSeverityCard(
            label: 'منخفضة',
            count: lowCount,
            total: totalCount,
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF10B981),
            barColor: const Color(0xFF10B981),
            isSelected: dashboardCubit.selectedSeverity == 1,
            onTap: () {
              final newSeverity =
                  dashboardCubit.selectedSeverity == 1 ? null : 1;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityCard({
    required String label,
    required int count,
    required int total,
    required IconData icon,
    required Color iconColor,
    required Color barColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final progress = total > 0 ? (count / total).clamp(0.08, 1.0) : 0.08;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? barColor : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? barColor.withValues(alpha: 0.16)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Row: Icon Container and Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: secondaryTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Bottom Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFF3F4F6),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- SEARCH AND FILTER TOOLBAR ---
  Widget _buildSearchAndFilterBar(
    BuildContext context,
    DashboardCubit dashboardCubit,
  ) {
    final hasActiveFilters = dashboardCubit.hasActiveFilters;

    return Row(
      children: [
        // Filter Action Button (Left in RTL = End)
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasActiveFilters ? appColor : const Color(0xFFE5E7EB),
                width: hasActiveFilters ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: hasActiveFilters ? appColor : secondaryTextColor,
                  size: 20,
                ),
                if (hasActiveFilters)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Search Input Field
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              onChanged: (val) => dashboardCubit.updateSearchQuery(val),
              style: const TextStyle(fontSize: 13, color: primaryTextColor),
              decoration: InputDecoration(
                hintText: '... ابحث عن أزمة أو فرع أو عنوان',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: disabledTextColor,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: secondaryTextColor,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: disabledTextColor,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          dashboardCubit.updateSearchQuery('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- SECTION HEADER (أحدث الأزمات / عرض الكل) ---
  Widget _buildSectionHeader(
    BuildContext context, {
    required int totalCount,
    required DashboardCubit dashboardCubit,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // "عرض الكل" button on left
        GestureDetector(
          onTap: () {
            dashboardCubit.updateSeverityFilter(null);
            dashboardCubit.updateStatusFilter(null);
            dashboardCubit.updateBranchFilter(null);
            _searchController.clear();
            dashboardCubit.updateSearchQuery('');
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
              Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
        ),

        // "أحدث الأزمات" with clock icon on right
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'أحدث الأزمات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            SizedBox(width: 6),
            Icon(
              Icons.access_time_rounded,
              color: Color(0xFF1E40AF),
              size: 20,
            ),
          ],
        ),
      ],
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

              // Tab 2: الأزمات (Incidents)
              _buildBottomNavItem(
                index: 1,
                icon: Icons.article_outlined,
                label: 'الأزمات',
                isActive: _currentBottomNavIndex == 1,
                onTap: () {
                  setState(() => _currentBottomNavIndex = 1);
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
                icon: Icons.assignment_outlined,
                label: 'المهام',
                isActive: _currentBottomNavIndex == 2,
                onTap: () {
                  context.pushNamed(Routes.allMissions);
                },
              ),

              // Tab 5: المزيد (More / Menu)
              _buildBottomNavItem(
                index: 3,
                icon: Icons.grid_view_rounded,
                label: 'المزيد',
                isActive: _currentBottomNavIndex == 3,
                onTap: () {
                  setState(() => _currentBottomNavIndex = 3);
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
              color: isActive ? const Color(0xFF1B64F2) : const Color(0xFF6B7280),
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

  void _showFilterBottomSheet(BuildContext context) {
    final dashboardCubit = context.read<DashboardCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: dashboardCubit,
        child: _FilterBottomSheet(),
      ),
    );
  }

  // --- MODERN SERVICES & OPERATIONS HUB (Replaces Drawer) ---
  Widget _buildMoreServicesView(BuildContext context) {
    final sessionManager = getIt<SessionManager>();
    final currentUser = sessionManager.getCurrentUser();
    final name = currentUser?.empName ?? currentUser?.username ?? 'المسؤول';
    final role = currentUser?.authorityName ?? 'مشرف النظام';
    final empCode = currentUser?.empCode;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Top Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0C2B52),
                  Color(0xFF154A85),
                  Color(0xFF1D5A9E),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentBottomNavIndex = 0),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'مركز الخدمات والعمليات',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
                const SizedBox(height: 18),

                // User Profile Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF154A85),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFF10B981),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    role,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6EE7B7),
                                    ),
                                  ),
                                ),
                                if (empCode != null &&
                                    empCode.toString().isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'كود: $empCode',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                            .withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Services List Content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // 1. الخرائط والعمليات الميدانية
              _buildSectionTitle('الخرائط والعمليات الميدانية'),
              _buildServiceTile(
                icon: Icons.map_rounded,
                iconColor: const Color(0xFF2563EB),
                title: 'خريطة المحابس والشبكات',
                subtitle: 'استعراض مواقع المحابس والمسافات التشغيلية الميدانية',
                onTap: () => context.pushNamed(Routes.valveMap),
              ),

              const SizedBox(height: 16),

              // 2. إدارة الأزمات والبلاغات
              _buildSectionTitle('إدارة الأزمات والبلاغات'),
              _buildServiceTile(
                icon: Icons.add_circle_outline_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'إضافة بلاغ أزمة جديد',
                subtitle: 'تسجيل بلاغ طوارئ جديد مع الموقع الجغرافي والبيانات',
                onTap: () async {
                  await context.pushNamed(Routes.addIncidentMobile);
                  if (context.mounted) {
                    context.read<IncidentMapCubit>().refresh();
                  }
                },
              ),
              _buildServiceTile(
                icon: Icons.category_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'أنواع وتصنيفات الأزمات',
                subtitle: 'استعراض وتعديل تصنيفات الأزمات ودرجات الحرج',
                onTap: () => context.pushNamed(Routes.allIncidentType),
              ),
              _buildServiceTile(
                icon: Icons.playlist_add_rounded,
                iconColor: const Color(0xFF0D9488),
                title: 'إضافة نوع أزمة جديد',
                subtitle: 'تعريف تصنيف بلاغ جديد في النظام',
                onTap: () => context.pushNamed(Routes.addIncidentType),
              ),

              const SizedBox(height: 16),

              // 3. خطط التدخل والمهام
              _buildSectionTitle('خطط التدخل والمهام'),
              _buildServiceTile(
                icon: Icons.assignment_rounded,
                iconColor: const Color(0xFF7C3AED),
                title: 'سجل جميع المهام',
                subtitle: 'استعراض ومتابعة مهام التدخل السريع وفرق العمل',
                onTap: () => context.pushNamed(Routes.allMissions),
              ),
              _buildServiceTile(
                icon: Icons.hub_outlined,
                iconColor: const Color(0xFFD97706),
                title: 'ربط مهام بنوع الأزمة',
                subtitle: 'تحديد خطوات الاستجابة المعيارية لكل نوع بلاغ',
                onTap: () => context.pushNamed(Routes.addIncidentMission),
              ),
              _buildServiceTile(
                icon: Icons.add_task_rounded,
                iconColor: const Color(0xFF4F46E5),
                title: 'إضافة مهمة جديدة',
                subtitle: 'إنشاء مهمة عمل قياسية جديدة وتوصيفها',
                onTap: () => context.pushNamed(Routes.addMissions),
              ),

              const SizedBox(height: 16),

              // 4. إدارة الحساب والنظام
              _buildSectionTitle('إدارة الحساب والنظام'),
              _buildServiceTile(
                icon: Icons.logout_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'تسجيل الخروج',
                subtitle: 'إنهاء الجلسة الحالية والخروج بأمان من المنظومة',
                isDestructive: true,
                onTap: () => _handleLogout(context),
              ),

              const SizedBox(height: 24),

              // Footer Branding
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 36,
                      height: 36,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.water_drop_rounded,
                        color: appColor,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'شركة مياه الشرب والصرف الصحي بالمنيا',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'منظومة إدارة الأزمات والطوارئ - الإصدار 1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: secondaryTextColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: primaryTextColor,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildServiceTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDestructive
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDestructive
                              ? const Color(0xFFDC2626)
                              : primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: secondaryTextColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من النظام؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await getIt<SessionManager>().logout();
      if (context.mounted) {
        context.pushNamedAndRemoveUntil(
          Routes.login,
          predicate: (route) => false,
        );
      }
    }
  }
}

// ============================================================================
// MOBILE INCIDENT CARD (Matches the target reference image design)
// ============================================================================
class _MobileIncidentCard extends StatelessWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onTap;

  const _MobileIncidentCard({required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final severity = incident.currentIncidentSeverity ?? 1;
    final status = incident.currentIncidentStatus ?? 1;
    final id = incident.currentIncidentId ?? 0;
    final branch = incident.branchName ?? 'المنيا';
    final typeName = incident.currentIncidentTypeName ?? 'توقف محطة مياه';
    final description = (incident.currentIncidentDescription?.isNotEmpty == true)
        ? incident.currentIncidentDescription!
        : (incident.currentIncidentNotes?.isNotEmpty == true
            ? incident.currentIncidentNotes!
            : 'لا توجد تفاصيل إضافية مسجلة لهذه الأزمة');

    final managerName = incident.managerName ??
        (incident.username ?? 'أحمد محمد');

    final photosCount = incident.photos?.length ?? 0;
    final missions = incident.currentIncidentWithMissions ?? [];
    final totalMissions = missions.length;
    final completedMissions = missions
        .where((m) => m.currentIncidentMissionStatus == 6)
        .length;

    // Severity specific visual elements
    final isCritical = severity == 4;
    final isHigh = severity == 3;

    final severityIconData = isCritical
        ? Icons.notifications_active_rounded
        : (isHigh
            ? Icons.warning_amber_rounded
            : (severity == 2
                ? Icons.info_outline_rounded
                : Icons.check_circle_outline_rounded));

    final severityBgColor = isCritical
        ? const Color(0xFFFEE2E2)
        : (isHigh ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE));

    final severityColor = isCritical
        ? const Color(0xFFDC2626)
        : (isHigh ? const Color(0xFFD97706) : const Color(0xFF0284C7));

    final severityLabel = getSeverityArabic(severity);
    final statusLabel = getStatusArabic(status);
    final statusColor = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF2F6), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Details Arrow Button, Branch & Title, Severity Badge & Incident #
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arrow button (Left in RTL = Navigation icon)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF2563EB),
                        size: 16,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Branch name & Incident type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فرع $branch',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            typeName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: secondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Severity Icon Badge & Incident #
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: severityBgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            severityIconData,
                            color: severityColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#$id',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description with vertical pipe accent
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Color(0xFF3B82F6),
                        width: 2.5,
                      ),
                    ),
                  ),
                  child: Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: secondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Badges Row: Status Pill and Severity Pill
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Severity Pill (عالية / حرجة with bar chart icon)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            severityLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: severityColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 14,
                            color: severityColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),

                // Footer Metadata Row: Attachments, Tasks, Responsible Person, Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Attachments count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$photosCount',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const Text(
                              'مرفقات',
                              style: TextStyle(
                                fontSize: 9,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Missions / Tasks count
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              totalMissions > 0
                                  ? '$completedMissions/$totalMissions'
                                  : '0/0',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            const Text(
                              'مهام',
                              style: TextStyle(
                                fontSize: 9,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Responsible Person
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 15,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              managerName,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'المسؤول',
                              style: TextStyle(
                                fontSize: 9,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Time Ago & Full Date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              incident.currentIncidentCreatedAt != null
                                  ? incident.currentIncidentCreatedAt!
                                      .timeAgoArabic()
                                  : 'منذ قليل',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                            Text(
                              incident.currentIncidentCreatedAt != null
                                  ? '${incident.currentIncidentCreatedAt!.day.toString().padLeft(2, '0')}/${incident.currentIncidentCreatedAt!.month.toString().padLeft(2, '0')}/${incident.currentIncidentCreatedAt!.year} ${incident.currentIncidentCreatedAt!.hour.toString().padLeft(2, '0')}:${incident.currentIncidentCreatedAt!.minute.toString().padLeft(2, '0')}'
                                  : '',
                              style: const TextStyle(
                                fontSize: 8.5,
                                color: disabledTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Empty State Widget
class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: appColor.withAlpha(13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 80,
              color: appColor.withAlpha(77),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد أزمات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي أزمات',
            style: TextStyle(fontSize: 14, color: secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  int? _tempStatus;
  int? _tempSeverity;
  int? _tempBranch;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    _tempStatus = cubit.selectedStatus;
    _tempSeverity = cubit.selectedSeverity;
    _tempBranch = cubit.selectedBranchId;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + bottomPadding + viewInsetsBottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'تصفية الأزمات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
                const Spacer(),
                if (cubit.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempSeverity = null;
                        _tempBranch = null;
                      });
                    },
                    child: Text(
                      'مسح الكل',
                      style: TextStyle(
                        color: warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Filter
            _buildFilterSection(
              title: 'الحالة',
              icon: Icons.sync_alt,
              child: _buildStatusFilter(),
            ),

            const SizedBox(height: 20),

            // Severity Filter
            _buildFilterSection(
              title: 'درجة الخطورة',
              icon: Icons.priority_high,
              child: _buildSeverityFilter(),
            ),

            const SizedBox(height: 20),

            // Branch Filter
            _buildFilterSection(
              title: 'الفرع',
              icon: Icons.location_city,
              child: _buildBranchFilter(),
            ),

            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cubit.updateStatusFilter(_tempStatus);
                  cubit.updateSeverityFilter(_tempSeverity);
                  cubit.updateBranchFilter(_tempBranch);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تطبيق الفلتر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: appColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildStatusFilter() {
    const statuses = [
      {'id': 1, 'label': 'تم التبليغ'},
      {'id': 2, 'label': 'تم الارسال'},
      {'id': 3, 'label': 'قيد التنفيذ'},
      {'id': 4, 'label': 'قيد الانتظار'},
      {'id': 5, 'label': 'قيد المراجعة'},
      {'id': 6, 'label': 'تم حلها'},
      {'id': 7, 'label': 'تم الرفض'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final id = status['id'] as int;
        final label = status['label'] as String;
        final isSelected = _tempStatus == id;
        final color = getStatusColor(id);

        return FilterChip(
          selected: isSelected,
          label: Text(label),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withAlpha(26),
          selectedColor: color,
          checkmarkColor: Colors.white,
          onSelected: (selected) {
            setState(() {
              _tempStatus = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeverityFilter() {
    const severities = [
      {'id': 1, 'label': 'منخفضة'},
      {'id': 2, 'label': 'متوسطة'},
      {'id': 3, 'label': 'عالية'},
      {'id': 4, 'label': 'حرجة'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: severities.map((severity) {
        final id = severity['id'] as int;
        final label = severity['label'] as String;
        final isSelected = _tempSeverity == id;
        final color = getSeverityColor(id);

        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSeverityIcon(id),
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withAlpha(26),
          selectedColor: color,
          checkmarkColor: Colors.white,
          onSelected: (selected) {
            setState(() {
              _tempSeverity = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBranchFilter() {
    const branches = [
      {'id': 213, 'label': 'المنيا'},
      {'id': 373, 'label': 'المنيا الجديدة'},
      {'id': 173, 'label': 'سمالوط'},
      {'id': 133, 'label': 'مطاي'},
      {'id': 93, 'label': 'بني مزار'},
      {'id': 53, 'label': 'مغاغة'},
      {'id': 13, 'label': 'العدوة'},
      {'id': 253, 'label': 'أبو قرقاص'},
      {'id': 293, 'label': 'ملاوي'},
      {'id': 333, 'label': 'ديرمواس'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _tempBranch,
          hint: const Text('اختر الفرع'),
          icon: Icon(Icons.arrow_drop_down, color: accentColor),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('جميع الفروع'),
            ),
            ...branches.map((branch) {
              final id = branch['id'] as int;
              final label = branch['label'] as String;
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: _tempBranch == id ? appColor : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _tempBranch = value;
            });
          },
        ),
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}

// ============================================================================
// SCREEN 2: MOBILE INCIDENT DETAILS
// ============================================================================

class MobileIncidentDetailsScreen extends StatelessWidget {
  final int? incidentId;
  final CurrentIncidentModel? initialIncident;

  const MobileIncidentDetailsScreen({
    super.key,
    this.incidentId,
    this.initialIncident,
  });
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Creating the cubits here in the MultiBlocProvider
        BlocProvider<EditIncidentCubit>(
          create: (context) =>
              EditIncidentCubit(editIncidentRepo: getIt<EditIncidentRepo>()),
        ),
        BlocProvider<UpdateStatuesCubit>(
          create: (context) =>
              UpdateStatuesCubit(updateStatuesRepo: getIt<UpdateStatuesRepo>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Bloc listeners for state changes
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (_, state) => state.maybeWhen(
              error: (_) => true,
              updateRequested: (_, _, _) => true,
              missionUpdateRequested: (_, _, _) => true,
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
                  // You can add your logic here for updateRequested
                },
                missionUpdateRequested: (incidentId, missionId, newStatus) {
                  // You can add your logic here for missionUpdateRequested
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
        ],
        child: BlocBuilder<IncidentMapCubit, IncidentMapState>(
          builder: (context, state) {
            final targetId = incidentId ?? incidentID;
            final incidents = context.read<IncidentMapCubit>().incidents;
            final incident = incidents.firstWhere(
              (i) => i.currentIncidentId == targetId,
              orElse: () => initialIncident ?? CurrentIncidentModel(),
            );

            return Scaffold(
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  final currentUserId =
                      getIt<SessionManager>().getCurrentUser()?.userId ?? 1;
                  // Navigate to FileUploadScreen with incident ID and dynamic user ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileUploadScreen(
                        incidentId: incident.currentIncidentId ?? 0,
                        userId: currentUserId,
                      ),
                    ),
                  );
                },
                backgroundColor: appColor,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'إضافة صور الأزمة',
                  style: TextStyles.size16(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: const Color(0xFFF8F9FA),
              body: CustomScrollView(
                slivers: [
                  // Collapsible App Bar
                  _MobileSliverAppBar(incident: incident),

                  // Content
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // Quick Actions Row
                        _QuickActionsRow(incident: incident),

                        const SizedBox(height: 16),

                        // Stats Cards
                        _MobileStatsRow(incident: incident),

                        const SizedBox(height: 16),

                        // Description Section
                        _MobileSection(
                          title: 'وصف الأزمة',
                          icon: Icons.description_outlined,
                          child: IncidentDescriptionPresentation(
                            description: incident.currentIncidentDescription,
                            textColor: primaryTextColor,
                            secondaryColor: secondaryTextColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Address Section
                        if (incident.address != null &&
                            incident.address!.isNotEmpty)
                          _MobileSection(
                            title: 'العنوان',
                            icon: Icons.location_on_outlined,
                            child: Text(
                              incident.address!,
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryTextColor,
                                height: 1.5,
                              ),
                            ),
                          ),

                        if (incident.address != null &&
                            incident.address!.isNotEmpty)
                          const SizedBox(height: 16),

                        // Missions Section
                        _MobileMissionsSection(incident: incident),

                        const SizedBox(height: 16),

                        // Metadata Section
                        _MobileMetadataSection(incident: incident),

                        const SizedBox(height: 16),

                        // Timeline Section
                        _MobileTimelineSection(incident: incident),

                        const SizedBox(height: 16),

                        // Photos Section
                        _MobilePhotosSection(incident: incident),

                        const SizedBox(height: 16),

                        // Location Section
                        if (incident.currentIncidentXAxis != null &&
                            incident.currentIncidentYAxis != null)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AppMapSection(
                              lat: incident.currentIncidentXAxis!,
                              lng: incident.currentIncidentYAxis!,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Notes Section
                        if (incident.currentIncidentNotes != null &&
                            incident.currentIncidentNotes!.trim().isNotEmpty)
                          _MobileSection(
                            title: 'ملاحظات',
                            icon: Icons.sticky_note_2_outlined,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: warningColor.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: warningColor.withAlpha(77),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: warningColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      incident.currentIncidentNotes!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: primaryTextColor,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Mobile Sliver App Bar
class _MobileSliverAppBar extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileSliverAppBar({required this.incident});

  @override
  Widget build(BuildContext context) {
    final status = incident.currentIncidentStatus ?? 1;
    final severity = incident.currentIncidentSeverity ?? 1;
    final headline = incidentDescriptionHeadline(
      incident.currentIncidentDescription,
    );

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: appColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => showEditDialog(
              context,
              incident,
              context.read<EditIncidentCubit>(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(
              Icons.person_add_alt_outlined,
              color: Colors.white,
            ),
            onPressed: () =>
                context.pushNamed(Routes.missionAssign, arguments: incident),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appColor, appColor.withAlpha(204)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              headline,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (incident.branchName != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    incident.branchName!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MobileStatusChip(
                        text: getStatusArabic(status),
                        color: getStatusColor(status),
                      ),
                      const SizedBox(width: 8),
                      _MobileSeverityChip(
                        text: getSeverityArabic(severity),
                        severity: severity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileStatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _MobileStatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSeverityChip extends StatelessWidget {
  final String text;
  final int severity;

  const _MobileSeverityChip({required this.text, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = getSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(severity), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}

// Quick Actions Row
class _QuickActionsRow extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _QuickActionsRow({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.edit,
              label: 'تعديل',
              color: accentColor,
              onTap: () => showEditDialog(
                context,
                incident,
                context.read<EditIncidentCubit>(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.location_on,
              label: 'الموقع',
              color: const Color(0xFF10B981),
              onTap: () {
                final lat = incident.currentIncidentXAxis;
                final lng = incident.currentIncidentYAxis;
                if (lat != null && lng != null) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF10B981)),
                          SizedBox(width: 8),
                          Text('موقع الأزمة',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('خط العرض: $lat',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('خط الطول: $lng',
                              style: const TextStyle(fontSize: 14)),
                          if (incident.address?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            Text('العنوان: ${incident.address}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 180,
                              width: double.infinity,
                              child: AppMapSection(lat: lat, lng: lng),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('إغلاق'),
                        ),
                      ],
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لا توجد إحداثيات موقع مسجلة لهذه الأزمة'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.message,
              label: 'تعليق',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                final notes = incident.currentIncidentNotes;
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Row(
                      children: [
                        Icon(Icons.notes, color: Color(0xFF8B5CF6)),
                        SizedBox(width: 8),
                        Text('ملاحظات الأزمة',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    content: Text(
                      notes != null && notes.trim().isNotEmpty
                          ? notes
                          : 'لا توجد ملاحظات مسجلة على هذه الأزمة حالياً.',
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          showEditDialog(
                            context,
                            incident,
                            context.read<EditIncidentCubit>(),
                          );
                        },
                        child: const Text('تعديل الملاحظات'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mobile Stats Row
class _MobileStatsRow extends StatefulWidget {
  final CurrentIncidentModel incident;

  const _MobileStatsRow({required this.incident});

  @override
  State<_MobileStatsRow> createState() => _MobileStatsRowState();
}

class _MobileStatsRowState extends State<_MobileStatsRow> {
  late Duration _elapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initElapsed();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _MobileStatsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.incident.currentIncidentCreatedAt !=
            widget.incident.currentIncidentCreatedAt ||
        oldWidget.incident.currentIncidentStatus !=
            widget.incident.currentIncidentStatus) {
      _timer?.cancel();
      _timer = null;
      _initElapsed();
      _startTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _initElapsed() {
    final createdAt = widget.incident.currentIncidentCreatedAt;
    if (createdAt == null) {
      _elapsed = Duration.zero;
      return;
    }
    _elapsed = DateTime.now().difference(createdAt);
  }

  void _startTimerIfNeeded() {
    if (widget.incident.currentIncidentStatus == 7) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final missions = widget.incident.currentIncidentWithMissions ?? [];
    final completedMissions = missions
        .where((m) => m.currentIncidentMissionStatus == 6)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _MobileStatCard(
              icon: Icons.assignment_outlined,
              title: 'المهام',
              value: '${missions.length}',
              subtitle: '$completedMissions مكتملة',
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MobileStatCard(
              icon: Icons.access_time,
              title: 'الوقت',
              value: _elapsed.format(),
              subtitle: widget.incident.currentIncidentStatus == 7
                  ? 'موقوف'
                  : 'نشط',
              color: const Color(0xFFEC4899),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _MobileStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: secondaryTextColor),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: disabledTextColor),
          ),
        ],
      ),
    );
  }
}

// Mobile Section Widget
class _MobileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  const _MobileSection({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// Mobile Missions Section
class _MobileMissionsSection extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileMissionsSection({required this.incident});

  @override
  Widget build(BuildContext context) {
    final missions = [...(incident.currentIncidentWithMissions ?? [])]
      ..sort(
        (a, b) => (a.currentIncidentMissionOrder ?? 0).compareTo(
          b.currentIncidentMissionOrder ?? 0,
        ),
      );

    return _MobileSection(
      title: 'المهام',
      icon: Icons.task_alt,
      badge: '${missions.length}',
      child: Column(
        children: missions.map((mission) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MobileMissionItem(
              mission: mission,
              incidentId: incident.currentIncidentId!,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MobileMissionItem extends StatelessWidget {
  final CurrentIncidentWithMissions mission;
  final int incidentId;

  const _MobileMissionItem({required this.mission, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final status = mission.currentIncidentMissionStatus ?? 1;
    final order = mission.currentIncidentMissionOrder ?? 0;
    final statusColor = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Order Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: appColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$order',
                style: const TextStyle(
                  color: appColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Mission Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.missionName ??
                      'مهمة #${mission.currentIncidentMissionId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    getStatusArabicLabel(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: accentColor,
            onPressed: mission.currentIncidentMissionId == null
                ? null
                : () => showStatusSelector(
                    context,
                    mission,
                    incidentId,
                    context.read<UpdateStatuesCubit>(),
                  ),
          ),
        ],
      ),
    );
  }
}

// Mobile Metadata Section
class _MobileMetadataSection extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileMetadataSection({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _MobileSection(
      title: 'معلومات النظام',
      icon: Icons.info_outlined,
      child: Column(
        children: [
          _MobileMetadataRow(
            icon: Icons.category,
            label: 'نوع الأزمة',
            value: '#${incident.currentIncidentTypeName ?? '-'}',
          ),
          const Divider(height: 24),
          _MobileMetadataRow(
            icon: Icons.apartment,
            label: 'الفرع',
            value: incident.branchName ?? '#${incident.branchId ?? '-'}',
          ),
          const Divider(height: 24),
          _MobileMetadataRow(
            icon: Icons.person_add,
            label: 'تم الإنشاء بواسطة',
            value: '#${incident.username ?? '-'}',
          ),
        ],
      ),
    );
  }
}

class _MobileMetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MobileMetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }
}

// Mobile Timeline Section
class _MobileTimelineSection extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileTimelineSection({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _MobileSection(
      title: 'الخط الزمني',
      icon: Icons.timeline,
      child: Column(
        children: [
          if (incident.currentIncidentCreatedAt != null)
            _MobileTimelineItem(
              icon: Icons.add_circle_outline,
              title: 'تم الإنشاء',
              time: incident.currentIncidentCreatedAt!,
              userId: incident.currentIncidentCreatedBy,
              isFirst: true,
            ),
          if (incident.currentIncidentStatusUpdatedAt != null)
            _MobileTimelineItem(
              icon: Icons.update,
              title: 'آخر تحديث للحالة',
              time: incident.currentIncidentStatusUpdatedAt!,
              userId: incident.currentIncidentStatusUpdatedBy, 
              username: incident.statusUpdatedByUserName,
            ),
          if (incident.currentIncidentSeverityUpdateAt != null)
            _MobileTimelineItem(
              icon: Icons.priority_high,
              title: 'آخر تحديث للخطورة',
              time: incident.currentIncidentSeverityUpdateAt!,
              userId: incident.currentIncidentSeverityUpdateBy,
              username: incident.severityUpdatedByUserName,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _MobileTimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? username;

  final DateTime time;
  final int? userId;
  final bool isFirst;
  final bool isLast;

  const _MobileTimelineItem({
    required this.icon,
    required this.title,
    required this.time,
    this.username,
    this.userId,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withAlpha(26),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time.timeAgoArabic(),
                    style: TextStyle(fontSize: 12, color: secondaryTextColor),
                  ),
                  if (userId != null)
                    Text(
                      'بواسطة: ${username ?? '#$userId'}',
                      style: TextStyle(fontSize: 11, color: disabledTextColor),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobilePhotosSection extends StatefulWidget {
  final CurrentIncidentModel incident;

  const _MobilePhotosSection({required this.incident});

  @override
  State<_MobilePhotosSection> createState() => _MobilePhotosSectionState();
}

class _MobilePhotosSectionState extends State<_MobilePhotosSection> {
  late final Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = getIt<SecureStorageService>().getUserToken();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.incident.photos == null || widget.incident.photos!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _MobileSection(
      title: 'صور الأزمة',
      icon: Icons.photo_library_outlined,
      child: FutureBuilder<String?>(
        future: _tokenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError || snapshot.data?.trim().isNotEmpty != true) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'تعذر التحقق من الجلسة لعرض الصور. سجل الدخول مجدداً.',
              ),
            );
          }
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: widget.incident.photos!.length,
            itemBuilder: (context, index) {
              final photo = widget.incident.photos![index];
              if (photo.id == null) return const SizedBox.shrink();

              final imageUrl = ApiConstants.viewIncidentPhotoUrl(photo.id!);

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AuthenticatedImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                          errorWidget: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(16),
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text('تعذر تحميل الصورة'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: AuthenticatedImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: const Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
