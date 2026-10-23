import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/reports/data/repo/reports_repo.dart';
import 'package:incidents_managment/core/future/reports/data/services/report_export_service.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_cubit.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_branch_bars.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_detailed_table_view.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_filter_bar.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_geo_distribution_map.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_header.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_kpi_cards.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_latest_incidents_table.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_missions_stats.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_severity_donut.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_stale_incidents_table.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_status_donut_chart.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_tab_bar.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_trend_chart.dart';
import 'package:incidents_managment/core/future/reports/ui/widgets/reports_type_bars.dart';

class IncidentReportsScreen extends StatelessWidget {
  const IncidentReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsCubit(
        reportsRepo: getIt<ReportsRepo>(),
      )..loadReports(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // Light modern dashboard background
        body: SafeArea(
          child: BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Filters Bar
                    ReportsFilterBar(
                      onExport: () => _handleExport(context, state),
                    ),

                    const SizedBox(height: 14),

                    // 2. Tabs Navigation & Export Row
                    ReportsTabBar(
                      onExport: () => _handleExport(context, state),
                    ),

                    const SizedBox(height: 14),

                    // 4. Main Body Content
                    if (state is ReportsLoading)
                      Container(
                        height: 500,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: Color(0xFF1B72E8),
                        ),
                      )
                    else if (state is ReportsError)
                      _buildErrorCard(context, state.message)
                    else if (state is ReportsLoaded)
                      _buildActiveTabContent(context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ReportsCubit>().loadReports(),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B72E8),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTabContent(BuildContext context, ReportsLoaded state) {
    switch (state.activeTabIndex) {
      case 1:
        return _buildSummaryAndRegionsTab(context, state);
      case 2:
        return _buildTypesAndSeverityTab(context, state);
      case 3:
        return _buildBranchesAndRegionsTab(context, state);
      case 4:
        return _buildStatusesAndMissionsTab(context, state);
      case 5:
        return _buildTemporalAnalysisTab(context, state);
      case 6:
        return _buildGeographicAnalysisTab(context, state);
      case 7:
        return SizedBox(
          height: 750,
          child: ReportsDetailedTableView(
            incidents: state.filteredIncidents,
          ),
        );
      case 0:
      default:
        return _buildExecutiveSummaryTab(context, state);
    }
  }

  /// Tab 0: الملخص التنفيذي الشامل
  Widget _buildExecutiveSummaryTab(BuildContext context, ReportsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KPI Summary Cards (6 in a row)
        ReportsKpiCards(state: state),

        const SizedBox(height: 14),

        // Row 1: Trend Chart (Left) + Status Donut (Middle) + Geo Map (Right)
        SizedBox(
          height: 330,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 4,
                child: ReportsTrendChartCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: ReportsStatusDonutChartCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 4,
                child: ReportsGeoDistributionMapCard(
                  state: state,
                  onOpenFullMap: () {
                    try {
                      context.read<HomeCubit>().changeState(1);
                    } catch (_) {}
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Row 2: Types (Left) + Branches + Severity + Missions (Right)
        SizedBox(
          height: 330,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ReportsTypeBarsCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: ReportsBranchBarsCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 3,
                child: ReportsSeverityDonutCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: ReportsMissionsStatsCard(state: state),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Row 3: Latest Incidents (Left) + Stale Incidents (Right)
        SizedBox(
          height: 310,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: ReportsLatestIncidentsTableCard(
                  incidents: state.latestIncidents,
                  onViewAll: () => context.read<ReportsCubit>().selectTab(7),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: ReportsStaleIncidentsTableCard(
                  incidents: state.staleIncidents,
                  onViewAll: () => context.read<ReportsCubit>().selectTab(7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab 1: الملخص والمناطق
  Widget _buildSummaryAndRegionsTab(BuildContext context, ReportsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReportsKpiCards(state: state),
        const SizedBox(height: 14),
        SizedBox(
          height: 380,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ReportsBranchBarsCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: ReportsGeoDistributionMapCard(
                  state: state,
                  onOpenFullMap: () {
                    try {
                      context.read<HomeCubit>().changeState(1);
                    } catch (_) {}
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 340,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ReportsStatusDonutChartCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: ReportsLatestIncidentsTableCard(
                  incidents: state.latestIncidents,
                  title: 'أحدث الأزمات المسجلة',
                  onViewAll: () => context.read<ReportsCubit>().selectTab(7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab 2: الأنواع والخطورة
  Widget _buildTypesAndSeverityTab(BuildContext context, ReportsLoaded state) {
    final highSeverityIncidents = state.filteredIncidents
        .where((i) => (i.currentIncidentSeverity ?? 1) >= 3)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 360,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: ReportsTypeBarsCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 5,
                child: ReportsSeverityDonutCard(state: state),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 360,
          child: ReportsLatestIncidentsTableCard(
            incidents: highSeverityIncidents,
            title: 'الأزمات عالية وحرجة الخطورة (${highSeverityIncidents.length})',
            onViewAll: () => context.read<ReportsCubit>().selectTab(7),
          ),
        ),
      ],
    );
  }

  /// Tab 3: الفروع والمناطق
  Widget _buildBranchesAndRegionsTab(BuildContext context, ReportsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 380,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: ReportsBranchBarsCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: ReportsGeoDistributionMapCard(
                  state: state,
                  onOpenFullMap: () {
                    try {
                      context.read<HomeCubit>().changeState(1);
                    } catch (_) {}
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 340,
          child: ReportsLatestIncidentsTableCard(
            incidents: state.latestIncidents,
            title: 'أحدث بلاغات الأزمات بالفروع والمراكز',
            onViewAll: () => context.read<ReportsCubit>().selectTab(7),
          ),
        ),
      ],
    );
  }

  /// Tab 4: الحالات والمهام
  Widget _buildStatusesAndMissionsTab(BuildContext context, ReportsLoaded state) {
    final missionIncidents = state.filteredIncidents
        .where((i) => (i.currentIncidentWithMissions?.isNotEmpty ?? false))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 360,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ReportsStatusDonutChartCard(state: state),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: ReportsMissionsStatsCard(state: state),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 360,
          child: ReportsLatestIncidentsTableCard(
            incidents: missionIncidents,
            title: 'الأزمات المخصص لها فرق ومهام عمل (${missionIncidents.length})',
            onViewAll: () => context.read<ReportsCubit>().selectTab(7),
          ),
        ),
      ],
    );
  }

  /// Tab 5: التحليل الزمني
  Widget _buildTemporalAnalysisTab(BuildContext context, ReportsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 380,
          child: ReportsTrendChartCard(state: state),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 340,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: ReportsLatestIncidentsTableCard(
                  incidents: state.latestIncidents,
                  title: 'أحدث الأزمات المسجلة زمنياً',
                  onViewAll: () => context.read<ReportsCubit>().selectTab(7),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 6,
                child: ReportsStaleIncidentsTableCard(
                  incidents: state.staleIncidents,
                  onViewAll: () => context.read<ReportsCubit>().selectTab(7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tab 6: التحليل الجغرافي
  Widget _buildGeographicAnalysisTab(BuildContext context, ReportsLoaded state) {
    final geoIncidents = state.filteredIncidents
        .where((i) => i.currentIncidentXAxis != null && i.currentIncidentYAxis != null)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 480,
          child: ReportsGeoDistributionMapCard(
            state: state,
            onOpenFullMap: () {
              try {
                context.read<HomeCubit>().changeState(1);
              } catch (_) {}
            },
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 340,
          child: ReportsLatestIncidentsTableCard(
            incidents: geoIncidents,
            title: 'الأزمات المحددة جغرافياً بإحداثيات (${geoIncidents.length})',
            onViewAll: () => context.read<ReportsCubit>().selectTab(7),
          ),
        ),
      ],
    );
  }

  void _handleExport(BuildContext context, ReportsState state) {
    if (state is! ReportsLoaded) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'خيارات تصدير التقرير',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.table_view_rounded, color: Color(0xFF059669)),
                  title: const Text('تصدير كملف Excel / CSV مع ترميز UTF-8'),
                  subtitle: Text('تصدير ${state.filteredIncidents.length} أزمة بكافة التفاصيل والبيانات'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'جاري تجهيز وتصدير التقرير...',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    try {
                      final resultPath = await getIt<ReportExportService>()
                          .exportIncidentsToCsv(incidents: state.filteredIncidents);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تصدير ${state.filteredIncidents.length} أزمة بنجاح'
                            '${resultPath.isNotEmpty ? ' ($resultPath)' : ''}',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: const Color(0xFF059669),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'حدث خطأ أثناء التصدير: $e',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
                  title: const Text('تصدير تقرير تنفيذي CSV للمؤشرات والملخص'),
                  subtitle: const Text('تصدير فوري مدعوم ومتوافق مع كافة المنصات والأجهزة'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'جاري تصدير التقرير التنفيذي...',
                              style: TextStyle(fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    try {
                      final resultPath = await getIt<ReportExportService>()
                          .exportIncidentsToCsv(
                        incidents: state.filteredIncidents,
                        customFileName: 'تقرير_تنفيذي_${state.activeTabIndex}.csv',
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تصدير التقرير التنفيذي بنجاح ($resultPath)',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: const Color(0xFF1B72E8),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'حدث خطأ: $e',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
