import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/all_missions.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';
import 'package:incidents_managment/core/future/home/ui/screens/user_management_screen.dart';
import 'package:incidents_managment/core/future/home/ui/screens/analytics_overview_screen.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/dash_board.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dashboard_command_palette.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dashboard_live_status.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map_widget.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/side_bar.dart';
import 'package:incidents_managment/core/future/valve/ui/web_valve_map_screen.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';

class CrisisDashboard extends StatefulWidget {
  const CrisisDashboard({super.key});

  @override
  State<CrisisDashboard> createState() => _CrisisDashboardState();
}

class _CrisisDashboardState extends State<CrisisDashboard> {
  final List<Widget?> _tabs = List<Widget?>.filled(9, null);

  static const _titles = <String>[
    'لوحة التحكم',
    'الخريطة',
    'المستخدمين',
    '',
    'إضافة أزمة',
    'أنواع الأزمات',
    'جميع المهام',
    'ربط مهام بالأزمة',
    'خريطة المحابس',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: DashboardCommandPaletteHost(
        child: Builder(
          builder: (context) {
            final width = MediaQuery.sizeOf(context).width;
            final isMobile = width <= 720;
            final drawerWidth = (width * 0.82).clamp(280.0, 340.0);

            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              appBar: isMobile
                  ? AppBar(
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: AppTheme.textOnPrimary,
                      surfaceTintColor: Colors.transparent,
                      actions: [
                        IconButton(
                          tooltip: 'بحث وتنقل سريع (Ctrl+K)',
                          icon: const Icon(Icons.search_rounded),
                          onPressed: () => showDashboardCommandPalette(context),
                        ),
                      ],
                      title: BlocBuilder<HomeCubit, HomeStates>(
                        buildWhen: (p, c) => c is HomeChanged,
                        builder: (context, _) {
                          final idx = context.read<HomeCubit>().selectedIndex;
                          final title = idx >= 0 && idx < _titles.length
                              ? _titles[idx]
                              : 'إدارة الأزمات';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'إدارة الأزمات',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textOnPrimary,
                                ),
                              ),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textOnPrimary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : null,
              drawer: Drawer(
                width: drawerWidth,
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: SafeArea(child: buildSidebar(context, isDrawer: true)),
              ),
              body: SafeArea(
                child: BlocBuilder<HomeCubit, HomeStates>(
                  buildWhen: (p, c) => c is HomeChanged,
                  builder: (context, state) {
                    final index = context.select(
                      (HomeCubit c) => c.selectedIndex,
                    );

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted &&
                          Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                        Scaffold.of(context).closeDrawer();
                      }
                    });

                    if (index >= 0 && index < _tabs.length) {
                      if (_tabs[index] == null || index == 5 || index == 6) {
                        _tabs[index] = switch (index) {
                          0 => const DashboardView(),
                          1 => const IncidentsMapScreen(),
                          2 => const UserManagementScreen(),
                          3 => const AnalyticsOverviewScreen(),
                          4 => const AddIncidentScreen(),
                          5 => AllIncidentType(key: UniqueKey()),
                          6 => AllMissions(key: UniqueKey()),
                          7 => const Addincidentmission(),
                          8 => const WebValveMapScreen(),
                          _ => const SizedBox.shrink(),
                        };
                      }
                    }

                    final children = List<Widget>.generate(_tabs.length, (i) {
                      final content = _tabs[i];
                      if (content == null) return const SizedBox.shrink();
                      if (isMobile) {
                        return ColoredBox(
                          color: AppTheme.backgroundColor,
                          child: content,
                        );
                      }
                      final dashboardTab = i == 0;
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          dashboardTab ? 10 : 16,
                          dashboardTab ? 8 : 14,
                          dashboardTab ? 10 : 20,
                          dashboardTab ? 8 : 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _DesktopSectionHeader(
                              title: i < _titles.length ? _titles[i] : '',
                            ),
                            SizedBox(height: dashboardTab ? 6 : 12),
                            Expanded(
                              child: Material(
                                color: dashboardTab
                                    ? Colors.transparent
                                    : AppTheme.surfaceColor,
                                surfaceTintColor: Colors.transparent,
                                shape: dashboardTab
                                    ? null
                                    : RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: AppTheme.borderColor
                                              .withValues(alpha: 0.65),
                                        ),
                                      ),
                                clipBehavior: dashboardTab
                                    ? Clip.none
                                    : Clip.antiAlias,
                                child: content,
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                    return IndexedStack(
                      index: index.clamp(0, children.length - 1),
                      children: children,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DesktopSectionHeader extends StatelessWidget {
  final String title;

  const _DesktopSectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final user = getIt<SessionManager>().getCurrentUser();
    final userName = user?.empName ?? user?.username ?? 'مستخدم';
    final userRole = user?.authorityName ?? 'غير محدد';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hamburger Menu (First in RTL = Right)
          IconButton(
            tooltip: 'القائمة',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1B4F8A), size: 28),
          ),
          
          const SizedBox(width: 16),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Search Bar
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                height: 44,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () => showDashboardCommandPalette(context),
                  decoration: const InputDecoration(
                    hintText: 'بحث في الأزمات...',
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // Status Badges
          DashboardLiveStatusStrip(),
          
          const SizedBox(width: 16),
          
          // Notification Bell
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF1B4F8A)),
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 20),
          
          // Profile (Last in RTL = Left)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    userRole,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1B4F8A),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
