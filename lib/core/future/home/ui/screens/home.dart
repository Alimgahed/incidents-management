import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/add_incident.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/incident.dart/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/all_missions.dart';
import 'package:incidents_managment/core/future/actions/ui/screens/missions/relation_incident_mission.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';
import 'package:incidents_managment/core/future/home/ui/screens/active_teams_screen.dart';
import 'package:incidents_managment/core/future/home/ui/screens/analytics_overview_screen.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/dash_board.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dashboard_command_palette.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dashboard_live_status.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map_widget.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/side_bar.dart';
import 'package:incidents_managment/core/future/valve/ui/web_valve_map_screen.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';

class CrisisDashboard extends StatefulWidget {
  const CrisisDashboard({super.key});

  @override
  State<CrisisDashboard> createState() => _CrisisDashboardState();
}

class _CrisisDashboardState extends State<CrisisDashboard> {
  final List<bool> _isBuilt = List.generate(9, (i) => i == 0 || i == 1);

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

                    if (index < _isBuilt.length) {
                      _isBuilt[index] = true;
                    }

                    final isDashboard = index == 0;

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted &&
                          Scaffold.maybeOf(context)?.isDrawerOpen == true) {
                        Scaffold.of(context).closeDrawer();
                      }
                    });

                    final content = IndexedStack(
                      index: index,
                      children: List.generate(9, (i) {
                        if (!_isBuilt[i]) return const SizedBox.shrink();
                        switch (i) {
                          case 0:
                            return const DashboardView();
                          case 1:
                            return const IncidentsMapScreen();
                          case 2:
                            return const ActiveTeamsScreen();
                          case 3:
                            return const AnalyticsOverviewScreen();
                          case 4:
                            return index == 4 ? const AddIncidentScreen() : const SizedBox.shrink();
                          case 5:
                            return const AllIncidentType();
                          case 6:
                            return const AllMissions();
                          case 7:
                            return const Addincidentmission();
                          case 8:
                            return const WebValveMapScreen();
                          default:
                            return const SizedBox.shrink();
                        }
                      }),
                    );

                    if (isMobile) {
                      return ColoredBox(
                        color: AppTheme.backgroundColor,
                        child: content,
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        isDashboard ? 10 : 16,
                        isDashboard ? 8 : 14,
                        isDashboard ? 10 : 20,
                        isDashboard ? 8 : 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _DesktopSectionHeader(
                            title: index >= 0 && index < _titles.length
                                ? _titles[index]
                                : '',
                          ),
                          SizedBox(height: isDashboard ? 6 : 12),
                          Expanded(
                            child: Material(
                              elevation: 0,
                              shadowColor: Colors.black26,
                              color: isDashboard
                                  ? Colors.transparent
                                  : AppTheme.surfaceColor,
                              surfaceTintColor: Colors.transparent,
                              shape: isDashboard
                                  ? null
                                  : RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: AppTheme.borderColor.withValues(
                                          alpha: 0.65,
                                        ),
                                      ),
                                    ),
                              clipBehavior: isDashboard
                                  ? Clip.none
                                  : Clip.antiAlias,
                              child: content,
                            ),
                          ),
                        ],
                      ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'القائمة — لوحة التحكم، الفرق، التحليلات…',
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(Icons.menu_rounded, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 28,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'بحث وتنقل سريع (Ctrl+K)',
          onPressed: () => showDashboardCommandPalette(context),
          icon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
        ),
        Flexible(
          flex: 2,
          child: SizedBox(
            height: 44,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DashboardLiveStatusStrip(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
