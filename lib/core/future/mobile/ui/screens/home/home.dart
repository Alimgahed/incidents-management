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
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';

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
        body: BlocBuilder<IncidentMapCubit, IncidentMapState>(
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
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              children: [
                // Top App Bar
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile / Menu Icon -> Opens More Services Screen
                    GestureDetector(
                      onTap: () => context.pushNamed(Routes.mobileMoreServices),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
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

                    const Spacer(),

                    // Date & Weather badge (Glassmorphic chip)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
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
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatArabicHeaderDate().replaceAll('\n', ' - '),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Center Title & Logo Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
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
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'منظومة إدارة الأزمات',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Text(
                          'شركة مياه الشرب والصرف الصحي بالمنيا',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
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

  // --- HERO ACTIVE INCIDENTS CARD ---
  Widget _buildHeroActiveCard(int totalActive) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E56A0),
            Color(0xFF163E75),
            Color(0xFF0F2B56),
          ],
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
                      Icons.crisis_alert_rounded,
                      color: Colors.white,
                      size: 28,
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
        // 1. Follow-up / Medium (قيد المتابعة)
        Expanded(
          child: _buildSeverityCard(
            label: 'قيد المتابعة',
            count: mediumCount,
            total: totalCount,
            icon: Icons.pending_actions_rounded,
            iconColor: const Color(0xFF2563EB),
            barColor: const Color(0xFF2563EB),
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
            icon: Icons.priority_high_rounded,
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
            icon: Icons.shield_outlined,
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
                    color: count > 0 ? primaryTextColor : const Color(0xFF94A3B8),
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

              // Tab 2: الأزمات (Incidents / Incident Types)
              _buildBottomNavItem(
                index: 1,
                icon: Icons.format_list_bulleted_rounded,
                label: 'الأزمات',
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
                icon: Icons.assignment_outlined,
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
                    // 1. Right in RTL: Severity Icon Badge & Incident #
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: severityBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            severityIconData,
                            color: severityColor,
                            size: 22,
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

                    // 3. Left in RTL: Arrow button pointing to details
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
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

