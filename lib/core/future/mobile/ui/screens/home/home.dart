import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart';
import 'package:incidents_managment/core/gloable/gloable.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
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
      // Whenever the user unlocks the phone or switches back to the app,
      // immediately verify and resurrect the socket if it was killed by OS backgrounding.
      context.read<IncidentMapCubit>().reconnectIfDisconnected();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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

                  final totalActive = incidents
                      .where(
                        (i) =>
                            i.currentIncidentStatus != 6 &&
                            i.currentIncidentStatus != 7,
                      )
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
                                  incidents,
                                ),
                                // Active Filter Chips (if any active filters)
                                _buildActiveFilterChips(
                                  context,
                                  dashboardCubit,
                                  incidents,
                                ),
                                const SizedBox(height: 16),

                                // Recent Incidents Section Header
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
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final incident = filteredIncidents[index];
                                return RepaintBoundary(
                                  child: _MobileIncidentCard(
                                    incident: incident,
                                    onTap: () {
                                      incidentID =
                                          incident.currentIncidentId ?? 0;
                                      dashboardCubit.selectIncident(incident);
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
                              }, childCount: filteredIncidents.length),
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

  // --- REDESIGNED COMPACT PROFESSIONAL MOBILE HEADER ---
  Widget _buildHeaderBanner(
    BuildContext context,
    List<CurrentIncidentModel> incidents,
  ) {
    final urgentAlertsCount = incidents
        .where(
          (i) =>
              (i.currentIncidentSeverity == 4 ||
                  i.currentIncidentSeverity == 3) &&
              i.currentIncidentStatus != 6 &&
              i.currentIncidentStatus != 7,
        )
        .length;

    final currentUser = getIt<SessionManager>().getCurrentUser();
    final rawName = currentUser?.empName?.trim().isNotEmpty == true
        ? currentUser!.empName!.trim()
        : (currentUser?.username?.trim().isNotEmpty == true
              ? currentUser!.username!.trim()
              : null);
    final userGreeting = rawName != null ? 'مرحباً، $rawName' : 'أهلاً بعودتك';
    final userRole = currentUser?.authorityName?.trim().isNotEmpty == true
        ? currentUser!.authorityName!.trim()
        : 'منظومة الطوارئ';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F3B6C),
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
              const Color(0xFF0A2240).withValues(alpha: 0.94),
              const Color(0xFF0F3866).withValues(alpha: 0.88),
              const Color(0xFF164780).withValues(alpha: 0.97),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Company Branding on Right, Actions on Left
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official Company Logo (Circular badge, no square box)
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.water_drop_rounded,
                                color: appColor,
                                size: 24,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'منظومة إدارة الأزمات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'شركة مياه الشرب والصرف الصحي بالمنيا',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Notification Button with Dynamic Alert Badge
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
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.22),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 20,
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Profile / Menu Icon -> Opens More Services Hub
                  ],
                ),

                const SizedBox(height: 14),

                // Bottom Row of Header: Personalized User Greeting on Right, Date & Weather Chip on Left
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User Greeting
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                userRole,
                                style: const TextStyle(
                                  color: Color(0xFF6EE7B7),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userGreeting,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Date & Weather chip (Glassmorphic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            color: Color(0xFFFBBF24),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatArabicHeaderDate().replaceAll('\n', ' - '),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

  // --- HERO ACTIVE INCIDENTS CARD ---
  Widget _buildHeroActiveCard(int totalActive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E56A0), Color(0xFF163E75), Color(0xFF0F2B56)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF163E75).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Soft background circles
            Positioned(
              left: -20,
              bottom: -30,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              right: 80,
              top: -25,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Icon container with pulse effect
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Label and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
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
                              'الحالة التشغيلية الآن',
                              style: TextStyle(
                                color: Color(0xFF6EE7B7),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'إجمالي البلاغات النشطة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Big Count Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$totalActive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
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
        // 1. Low (منخفضة - Right in RTL, matching screenshot)
        Expanded(
          child: _buildSeverityCard(
            label: 'منخفضة',
            count: lowCount,
            total: totalCount,
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFF10B981),
            barColor: const Color(0xFF10B981),
            isSelected: dashboardCubit.selectedSeverity == 1,
            onTap: () {
              final newSeverity = dashboardCubit.selectedSeverity == 1
                  ? null
                  : 1;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 2. Critical (حرجة)
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
              final newSeverity = dashboardCubit.selectedSeverity == 4
                  ? null
                  : 4;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 3. High (عالية)
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
              final newSeverity = dashboardCubit.selectedSeverity == 3
                  ? null
                  : 3;
              dashboardCubit.updateSeverityFilter(newSeverity);
            },
          ),
        ),
        const SizedBox(width: 8),

        // 4. In Follow-up / Medium (قيد المتابعة - Left in RTL, matching screenshot)
        Expanded(
          child: _buildSeverityCard(
            label: 'قيد المتابعة',
            count: mediumCount,
            total: totalCount,
            icon: Icons.article_outlined,
            iconColor: const Color(0xFF2563EB),
            barColor: const Color(0xFF2563EB),
            isSelected: dashboardCubit.selectedSeverity == 2,
            onTap: () {
              final newSeverity = dashboardCubit.selectedSeverity == 2
                  ? null
                  : 2;
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? barColor : const Color(0xFFEAEEF4),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? barColor.withValues(alpha: 0.18)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Row: Icon and Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 15),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: count > 0
                        ? primaryTextColor
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? primaryTextColor : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // Bottom Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 3.5,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFF1F5F9),
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
    List<CurrentIncidentModel> incidents,
  ) {
    final hasActiveFilters = dashboardCubit.hasActiveFilters;

    return Row(
      children: [
        // Filter Action Button (Left in RTL = End)
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context, incidents),
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

  // --- ACTIVE FILTER CHIPS ---
  Widget _buildActiveFilterChips(
    BuildContext context,
    DashboardCubit dashboardCubit,
    List<CurrentIncidentModel> incidents,
  ) {
    final status = dashboardCubit.selectedStatus;
    final severity = dashboardCubit.selectedSeverity;
    final branchId = dashboardCubit.selectedBranchId;
    final typeId = dashboardCubit.selectedIncidentTypeId;
    final hasPhotos = dashboardCubit.selectedHasPhotos;
    final hasSearch = _searchController.text.trim().isNotEmpty;

    final hasAnyFilter =
        status != null ||
        severity != null ||
        branchId != null ||
        typeId != null ||
        hasPhotos != null ||
        hasSearch;
    if (!hasAnyFilter) return const SizedBox.shrink();

    String getStatusLabel(int s) {
      switch (s) {
        case 1:
          return 'تم التبليغ';
        case 2:
          return 'تم الارسال';
        case 3:
          return 'قيد التنفيذ';
        case 4:
          return 'قيد الانتظار';
        case 5:
          return 'قيد المراجعة';
        case 6:
          return 'تم حلها';
        case 7:
          return 'تم الرفض';
        default:
          return 'حالة $s';
      }
    }

    String getSeverityLabel(int sev) {
      switch (sev) {
        case 4:
          return 'حرجة';
        case 3:
          return 'عالية';
        case 2:
          return 'متوسطة';
        case 1:
          return 'منخفضة';
        default:
          return 'درجة $sev';
      }
    }

    String getBranchLabel(int bId) {
      for (final inc in incidents) {
        if (inc.branchId == bId &&
            inc.branchName != null &&
            inc.branchName!.trim().isNotEmpty) {
          return inc.branchName!;
        }
      }
      return 'فرع #$bId';
    }

    String getTypeLabel(int tId) {
      for (final inc in incidents) {
        if (inc.currentIncidentTypeId == tId &&
            inc.currentIncidentTypeName != null &&
            inc.currentIncidentTypeName!.trim().isNotEmpty) {
          return inc.currentIncidentTypeName!;
        }
      }
      return 'نوع #$tId';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL natural scrolling
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clear All Button
            GestureDetector(
              onTap: () {
                _searchController.clear();
                dashboardCubit.clearAllFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Search Query Chip
            if (hasSearch) ...[
              _buildFilterPill(
                label: 'بحث: ${_searchController.text.trim()}',
                icon: Icons.search_rounded,
                color: const Color(0xFF2563EB),
                onClear: () {
                  _searchController.clear();
                  dashboardCubit.updateSearchQuery('');
                },
              ),
              const SizedBox(width: 6),
            ],

            // Status Chip
            if (status != null) ...[
              _buildFilterPill(
                label: 'الحالة: ${getStatusLabel(status)}',
                icon: Icons.sync_alt_rounded,
                color: getStatusColor(status),
                onClear: () => dashboardCubit.updateStatusFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Severity Chip
            if (severity != null) ...[
              _buildFilterPill(
                label: 'الخطورة: ${getSeverityLabel(severity)}',
                icon: Icons.priority_high_rounded,
                color: getSeverityColor(severity),
                onClear: () => dashboardCubit.updateSeverityFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Branch Chip
            if (branchId != null) ...[
              _buildFilterPill(
                label: 'الفرع: ${getBranchLabel(branchId)}',
                icon: Icons.location_city_rounded,
                color: const Color(0xFF0D9488),
                onClear: () => dashboardCubit.updateBranchFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Incident Type Chip
            if (typeId != null) ...[
              _buildFilterPill(
                label: 'النوع: ${getTypeLabel(typeId)}',
                icon: Icons.category_rounded,
                color: const Color(0xFF7C3AED),
                onClear: () => dashboardCubit.updateIncidentTypeFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Has Photos Chip
            if (hasPhotos != null) ...[
              _buildFilterPill(
                label: hasPhotos ? 'يحتوي على صور' : 'بدون صور',
                icon: hasPhotos
                    ? Icons.photo_library_rounded
                    : Icons.no_photography_rounded,
                color: hasPhotos
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF64748B),
                onClear: () => dashboardCubit.updateHasPhotosFilter(null),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTION HEADER (أحدث الأزمات / عرض الكل) ---

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

              // Tab 5: المزيد (More / Menu - Independent Screen)
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
        child: _FilterBottomSheet(incidents: incidents),
      ),
    );
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
    final branch = incident.branchName ?? 'المنيا';
    final typeName = incident.currentIncidentTypeName ?? 'توقف محطة مياه';
    final description =
        (incident.currentIncidentDescription?.isNotEmpty == true)
        ? incident.currentIncidentDescription!
        : (incident.currentIncidentNotes?.isNotEmpty == true
              ? incident.currentIncidentNotes!
              : 'لا توجد تفاصيل إضافية مسجلة لهذه الأزمة');

    final managerName =
        incident.managerName ?? (incident.username ?? 'أحمد محمد');

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
                // Top Row: Details Arrow Button, Branch & Title, Severity Badge (Incident ID removed from UI)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Right in RTL: Severity Icon Badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: severityBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        severityIconData,
                        color: severityColor,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 2. Middle: Branch name & Incident type
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

                    // 3. Left in RTL: Arrow button pointing to details (Right-pointing arrow inside circle)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Description with vertical pipe accent
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Color(0xFF3B82F6), width: 2.5),
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

                // Upper Metadata Badges Area: Status Pill, Severity Pill, Date & Time Pill
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
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

                    // Date & Time Pill (Moved next to Status & Severity)
                    if (incident.currentIncidentCreatedAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              incident.currentIncidentCreatedAt!
                                  .timeAgoArabic(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),

                // Lower Metadata Row: Attachments, Tasks, Responsible Person (Date removed to avoid duplication)
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E56A0).withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF1E56A0).withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.verified_user_outlined,
                  size: 48,
                  color: Color(0xFF1E56A0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد أزمات حالية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'جميع قطاعات ومحطات المياه تعمل بحالة استقرار دون بلاغات طارئة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                context.read<IncidentMapCubit>().refresh();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'تحديث البيانات',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E56A0),
                side: const BorderSide(color: Color(0xFF1E56A0), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final List<CurrentIncidentModel> incidents;

  const _FilterBottomSheet({required this.incidents});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  int? _tempStatus;
  int? _tempSeverity;
  int? _tempBranch;
  int? _tempIncidentType;
  bool? _tempHasPhotos;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    _tempStatus = cubit.selectedStatus;
    _tempSeverity = cubit.selectedSeverity;
    _tempBranch = cubit.selectedBranchId;
    _tempIncidentType = cubit.selectedIncidentTypeId;
    _tempHasPhotos = cubit.selectedHasPhotos;
  }

  /// Extracts dynamic branches from existing incidents data (no hardcoded branches)
  List<Map<String, dynamic>> _getAvailableBranches() {
    final branchMap = <int, String>{};
    for (final inc in widget.incidents) {
      if (inc.branchId != null &&
          inc.branchName != null &&
          inc.branchName!.trim().isNotEmpty) {
        branchMap[inc.branchId!] = inc.branchName!.trim();
      }
    }

    final sortedEntries = branchMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedEntries.map((e) => {'id': e.key, 'label': e.value}).toList();
  }

  /// Extracts dynamic incident types from existing incidents data (no hardcoded types)
  List<Map<String, dynamic>> _getAvailableIncidentTypes() {
    final typeMap = <int, String>{};
    for (final inc in widget.incidents) {
      if (inc.currentIncidentTypeId != null &&
          inc.currentIncidentTypeName != null &&
          inc.currentIncidentTypeName!.trim().isNotEmpty) {
        typeMap[inc.currentIncidentTypeId!] = inc.currentIncidentTypeName!
            .trim();
      }
    }

    final sortedEntries = typeMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sortedEntries.map((e) => {'id': e.key, 'label': e.value}).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();

    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;

    final hasAnyFilterSelection =
        _tempStatus != null ||
        _tempSeverity != null ||
        _tempBranch != null ||
        _tempIncidentType != null ||
        _tempHasPhotos != null;

    final availableBranches = _getAvailableBranches();
    final availableTypes = _getAvailableIncidentTypes();

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + bottomPadding + viewInsetsBottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: appColor, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'تصفية البلاغات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const Spacer(),
                if (hasAnyFilterSelection || cubit.hasActiveFilters)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempSeverity = null;
                        _tempBranch = null;
                        _tempIncidentType = null;
                        _tempHasPhotos = null;
                      });
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 15,
                      color: Color(0xFFDC2626),
                    ),
                    label: const Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: secondaryTextColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),

            // 1. Status Filter Section
            _buildFilterSection(
              title: 'حالة البلاغ',
              icon: Icons.sync_alt_rounded,
              isSelected: _tempStatus != null,
              onClear: () {
                setState(() => _tempStatus = null);
              },
              child: _buildStatusFilter(),
            ),

            const SizedBox(height: 20),

            // 2. Severity Filter Section
            _buildFilterSection(
              title: 'درجة الخطورة',
              icon: Icons.priority_high_rounded,
              isSelected: _tempSeverity != null,
              onClear: () {
                setState(() => _tempSeverity = null);
              },
              child: _buildSeverityFilter(),
            ),

            const SizedBox(height: 20),

            // 3. Branch Filter Section (Dynamically populated)
            _buildFilterSection(
              title: 'الفرع أو المنطقة',
              icon: Icons.location_city_rounded,
              isSelected: _tempBranch != null,
              onClear: () {
                setState(() => _tempBranch = null);
              },
              child: _buildBranchFilter(availableBranches),
            ),

            const SizedBox(height: 20),

            // 4. Incident Type Filter Section (Dynamically populated)
            _buildFilterSection(
              title: 'نوع الأزمة',
              icon: Icons.category_rounded,
              isSelected: _tempIncidentType != null,
              onClear: () {
                setState(() => _tempIncidentType = null);
              },
              child: _buildIncidentTypeFilter(availableTypes),
            ),

            const SizedBox(height: 20),

            // 5. Photos / Attachments Filter Section
            _buildFilterSection(
              title: 'المرفقات والصور',
              icon: Icons.photo_library_rounded,
              isSelected: _tempHasPhotos != null,
              onClear: () {
                setState(() => _tempHasPhotos = null);
              },
              child: _buildPhotosFilter(),
            ),

            const SizedBox(height: 26),

            // Actions: Apply & Clear Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.updateStatusFilter(_tempStatus);
                      cubit.updateSeverityFilter(_tempSeverity);
                      cubit.updateBranchFilter(_tempBranch);
                      cubit.updateIncidentTypeFilter(_tempIncidentType);
                      cubit.updateHasPhotosFilter(_tempHasPhotos);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تطبيق الفلتر',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (hasAnyFilterSelection) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _tempStatus = null;
                          _tempSeverity = null;
                          _tempBranch = null;
                          _tempIncidentType = null;
                          _tempHasPhotos = null;
                        });
                        cubit.clearAllFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        'مسح الكل',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onClear,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: appColor, size: 17),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              GestureDetector(
                onTap: onClear,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'مسح',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
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

        return ChoiceChip(
          selected: isSelected,
          label: Text(label),
          labelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withValues(alpha: 0.08),
          selectedColor: color,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? color : color.withValues(alpha: 0.25),
            ),
          ),
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

        return ChoiceChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSeverityIcon(id),
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 5),
              Text(label),
            ],
          ),
          labelStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withValues(alpha: 0.08),
          selectedColor: color,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isSelected ? color : color.withValues(alpha: 0.25),
            ),
          ),
          onSelected: (selected) {
            setState(() {
              _tempSeverity = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBranchFilter(List<Map<String, dynamic>> availableBranches) {
    if (availableBranches.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'لا توجد فروع مسجلة بالبيانات الحالية',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _tempBranch != null ? appColor : const Color(0xFFE2E8F0),
          width: _tempBranch != null ? 1.5 : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _tempBranch,
          hint: const Text(
            'اختر الفرع (الكل)',
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: secondaryTextColor),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'جميع الفروع',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            ...availableBranches.map((branch) {
              final id = branch['id'] as int;
              final label = branch['label'] as String;
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city_rounded,
                      size: 16,
                      color: _tempBranch == id ? appColor : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _tempBranch == id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _tempBranch == id ? appColor : primaryTextColor,
                      ),
                    ),
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

  Widget _buildIncidentTypeFilter(List<Map<String, dynamic>> availableTypes) {
    if (availableTypes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'لا توجد أنواع أزمات مسجلة بالبيانات الحالية',
          style: TextStyle(fontSize: 12, color: secondaryTextColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _tempIncidentType != null ? appColor : const Color(0xFFE2E8F0),
          width: _tempIncidentType != null ? 1.5 : 1.0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _tempIncidentType,
          hint: const Text(
            'اختر نوع الأزمة (الكل)',
            style: TextStyle(fontSize: 13, color: secondaryTextColor),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: secondaryTextColor),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text(
                'جميع أنواع الأزمات',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            ...availableTypes.map((type) {
              final id = type['id'] as int;
              final label = type['label'] as String;
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 16,
                      color: _tempIncidentType == id
                          ? appColor
                          : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _tempIncidentType == id
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: _tempIncidentType == id
                              ? appColor
                              : primaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _tempIncidentType = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPhotosFilter() {
    return Row(
      children: [
        // Has photos
        Expanded(
          child: ChoiceChip(
            selected: _tempHasPhotos == true,
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library_rounded, size: 14),
                SizedBox(width: 6),
                Text('يحتوي على صور'),
              ],
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _tempHasPhotos == true
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: _tempHasPhotos == true
                  ? Colors.white
                  : const Color(0xFF0284C7),
            ),
            backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.08),
            selectedColor: const Color(0xFF0284C7),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _tempHasPhotos == true
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF0284C7).withValues(alpha: 0.25),
              ),
            ),
            onSelected: (selected) {
              setState(() {
                _tempHasPhotos = selected ? true : null;
              });
            },
          ),
        ),
        const SizedBox(width: 8),

        // No photos
        Expanded(
          child: ChoiceChip(
            selected: _tempHasPhotos == false,
            label: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_photography_rounded, size: 14),
                SizedBox(width: 6),
                Text('بدون صور'),
              ],
            ),
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: _tempHasPhotos == false
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: _tempHasPhotos == false
                  ? Colors.white
                  : const Color(0xFF64748B),
            ),
            backgroundColor: const Color(0xFF64748B).withValues(alpha: 0.08),
            selectedColor: const Color(0xFF64748B),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: _tempHasPhotos == false
                    ? const Color(0xFF64748B)
                    : const Color(0xFF64748B).withValues(alpha: 0.25),
              ),
            ),
            onSelected: (selected) {
              setState(() {
                _tempHasPhotos = selected ? false : null;
              });
            },
          ),
        ),
      ],
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning_amber_rounded;
      case 2:
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }
}
