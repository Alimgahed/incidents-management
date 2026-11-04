import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/design_system/app_design_system.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/incident_type_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/missions_filter_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/user_management_filter_cubit.dart';
import 'package:incidents_managment/core/widget/shimmer/screen_shimmers.dart';

Widget _wrapWithMaterial(
  Widget child, {
  Size size = const Size(1440, 900),
  bool disableAnimations = false,
}) {
  return MaterialApp(
    builder: (context, _) {
      return MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: disableAnimations),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Scaffold(body: child),
          ),
        ),
      );
    },
    home: const SizedBox.shrink(),
  );
}

void main() {
  group('Global Design System & Breakpoints', () {
    test('AppBreakpoints classifies mobile, tablet, and desktop widths', () {
      expect(AppBreakpoints.isMobileWidth(390), isTrue);
      expect(AppBreakpoints.isTabletWidth(900), isTrue);
      expect(AppBreakpoints.isDesktopWidth(1440), isTrue);
      expect(AppBreakpoints.adaptiveGridColumns(390), 1);
      expect(AppBreakpoints.adaptiveGridColumns(900), 2);
      expect(AppBreakpoints.adaptiveGridColumns(1280), 3);
      expect(AppBreakpoints.adaptiveGridColumns(1600), 4);
    });

    testWidgets('AppEmptyState and AppErrorState render and invoke callbacks', (
      tester,
    ) async {
      var retried = false;
      await tester.pumpWidget(
        _wrapWithMaterial(
          Column(
            children: [
              const Expanded(
                child: AppEmptyState(
                  title: 'لا توجد بيانات',
                  subtitle: 'وصف تجريبي',
                ),
              ),
              Expanded(
                child: AppErrorState(
                  title: 'خطأ في التحميل',
                  message: 'فشل الاتصال بالخادم',
                  onRetry: () => retried = true,
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('لا توجد بيانات'), findsOneWidget);
      expect(find.text('فشل الاتصال بالخادم'), findsOneWidget);

      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, isTrue);
    });

    testWidgets('AppInlineRefreshBanner shows progress only when refreshing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterial(
          const AppInlineRefreshBanner(
            isRefreshing: true,
            label: 'جاري تحديث البيانات...',
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('جاري تحديث البيانات...'), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithMaterial(const AppInlineRefreshBanner(isRefreshing: false)),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });

  group('Level 1 — Shimmer Primitives', () {
    testWidgets('All Level 1 shimmer primitives render cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterial(
          const SingleChildScrollView(
            child: AppShimmerScope(
              child: Column(
                children: [
                  ShimmerBox(width: 120, height: 24),
                  ShimmerCircle(size: 32),
                  ShimmerLine(width: 100, height: 12),
                  ShimmerText(lines: 3),
                  ShimmerAvatar(size: 40),
                  ShimmerButton(width: 110, height: 38),
                  ShimmerInput(width: 200, height: 46, showLabel: true),
                  ShimmerCard(width: 220, height: 110),
                  ShimmerTableRow(columns: 4),
                  ShimmerListItem(),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerBox), findsWidgets);
      expect(find.byType(ShimmerCircle), findsWidgets);
      expect(find.byType(ShimmerText), findsOneWidget);
      expect(find.byType(ShimmerTableRow), findsOneWidget);
      expect(find.byType(ShimmerListItem), findsOneWidget);
    });

    testWidgets('AppShimmerScope respects reduced motion accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapWithMaterial(
          const AppShimmerScope(child: ShimmerBox(width: 100, height: 20)),
          disableAnimations: true,
        ),
      );
      await tester.pump();
      expect(find.byType(ShimmerBox), findsOneWidget);
    });
  });

  group('Level 2 — Screen-Specific Shimmer Compositions', () {
    testWidgets(
      'DashboardScreenShimmer renders on Desktop and Mobile viewports',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrapWithMaterial(
            const DashboardScreenShimmer(),
            size: const Size(1440, 900),
          ),
        );
        expect(find.byType(DashboardKpiStripShimmer), findsOneWidget);
        expect(find.byType(IncidentListSectionShimmer), findsOneWidget);
        expect(find.byType(IncidentDetailsSectionShimmer), findsOneWidget);

        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpWidget(
          _wrapWithMaterial(
            const DashboardScreenShimmer(),
            size: const Size(390, 844),
          ),
        );
        expect(find.byType(DashboardKpiStripShimmer), findsOneWidget);
        expect(find.byType(IncidentListSectionShimmer), findsOneWidget);
      },
    );

    testWidgets(
      'IncidentsMapScreenShimmer and ValveMapScreenShimmer render cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrapWithMaterial(const IncidentsMapScreenShimmer()),
        );
        expect(find.byType(IncidentsMapScreenShimmer), findsOneWidget);

        await tester.pumpWidget(
          _wrapWithMaterial(const ValveMapScreenShimmer()),
        );
        expect(find.byType(ValveMapScreenShimmer), findsOneWidget);
      },
    );

    testWidgets(
      'UserManagementScreenShimmer and ReportsScreenShimmer adapt to viewport',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _wrapWithMaterial(
            const UserManagementScreenShimmer(),
            size: const Size(1440, 900),
          ),
        );
        expect(find.byType(ShimmerTableRow), findsWidgets);

        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpWidget(
          _wrapWithMaterial(
            const UserManagementScreenShimmer(),
            size: const Size(390, 844),
          ),
        );
        expect(find.byType(ShimmerListItem), findsWidgets);

        tester.view.physicalSize = const Size(1440, 900);
        await tester.pumpWidget(
          _wrapWithMaterial(
            const SingleChildScrollView(child: ReportsScreenShimmer()),
            size: const Size(1440, 900),
          ),
        );
        expect(find.byType(ReportsScreenShimmer), findsOneWidget);
      },
    );

    testWidgets(
      'Catalog, Form, MissionAssign, and MobileIncidentDetails shimmers render',
      (tester) async {
        await tester.pumpWidget(
          _wrapWithMaterial(const IncidentTypesScreenShimmer()),
        );
        expect(find.byType(IncidentTypesScreenShimmer), findsOneWidget);

        await tester.pumpWidget(
          _wrapWithMaterial(const MissionsScreenShimmer()),
        );
        expect(find.byType(MissionsScreenShimmer), findsOneWidget);

        await tester.pumpWidget(
          _wrapWithMaterial(const FormScreenShimmer(fieldCount: 5)),
        );
        expect(find.byType(ShimmerInput), findsNWidgets(5));

        await tester.pumpWidget(
          _wrapWithMaterial(const MissionAssignUsersShimmer(count: 4)),
        );
        expect(find.byType(ShimmerListItem), findsNWidgets(4));

        await tester.pumpWidget(
          _wrapWithMaterial(const MobileIncidentDetailsShimmer()),
        );
        expect(find.byType(MobileIncidentDetailsShimmer), findsOneWidget);
      },
    );
  });

  group('Standardized Cubit Filtering & State Transitions', () {
    test('DashboardCubit filters by severity, branch, status, and Arabic search', () {
      final cubit = DashboardCubit();
      final incidents = [
        CurrentIncidentModel(
          currentIncidentId: 101,
          currentIncidentDescription: 'كسر خط مياه رئيسي بفرع المنيا',
          currentIncidentSeverity: 4,
          currentIncidentStatus: 1,
          branchId: 213,
          branchName: 'المنيا',
        ),
        CurrentIncidentModel(
          currentIncidentId: 102,
          currentIncidentDescription: 'انسداد شبكة صرف بفرع سمالوط',
          currentIncidentSeverity: 2,
          currentIncidentStatus: 3,
          branchId: 173,
          branchName: 'سمالوط',
        ),
      ];

      cubit.updateFilter('حرجة');
      expect(cubit.filterIncidents(incidents).length, 1);
      expect(cubit.filterIncidents(incidents).first.currentIncidentId, 101);

      cubit.clearAllFilters();
      cubit.updateSearchQuery('سمالوط');
      expect(cubit.filterIncidents(incidents).length, 1);
      expect(cubit.filterIncidents(incidents).first.currentIncidentId, 102);
      cubit.close();
    });

    test('IncidentTypeFilterCubit filters by search and category', () {
      final cubit = IncidentTypeFilterCubit();
      final types = [
        const IncidentType(
          incidentTypeId: 1,
          incidentTypeName: 'كسر ماسورة مياه',
          classId: 10,
          className: 'شبكات مياه',
        ),
        const IncidentType(
          incidentTypeId: 2,
          incidentTypeName: 'طفح صرف صحي',
          classId: 20,
          className: 'صرف صحي',
        ),
      ];

      cubit.updateFilters(className: 'شبكات مياه');
      expect(cubit.filterIncidentTypes(types).length, 1);
      expect(cubit.filterIncidentTypes(types).first.incidentTypeId, 1);

      cubit.resetFilters();
      cubit.updateFilters(searchName: 'طفح');
      expect(cubit.filterIncidentTypes(types).length, 1);
      expect(cubit.filterIncidentTypes(types).first.incidentTypeId, 2);
      cubit.close();
    });

    test('MissionsFilterCubit filters by search query and className', () {
      final cubit = MissionsFilterCubit();
      final missions = [
        AllMissionModel(
          missionId: 11,
          missionName: 'إرسال سيارة كسح',
          classId: 1,
          className: 'طوارئ الصرف',
        ),
        AllMissionModel(
          missionId: 12,
          missionName: 'غلق المحابس المغذية',
          classId: 2,
          className: 'طوارئ المياه',
        ),
      ];

      cubit.updateFilters(className: 'طوارئ المياه');
      expect(cubit.filterMissions(missions).length, 1);
      expect(cubit.filterMissions(missions).first.missionId, 12);

      cubit.resetFilters();
      cubit.updateFilters(searchName: 'كسح');
      expect(cubit.filterMissions(missions).length, 1);
      expect(cubit.filterMissions(missions).first.missionId, 11);
      cubit.close();
    });

    test('UserManagementFilterCubit filters by Arabic name, authority, sector, and status', () {
      final cubit = UserManagementFilterCubit();
      final users = [
        ActiveUser(
          userId: 1,
          empName: 'أحمد محمد علي',
          empCode: '1001',
          authorityName: 'مهندس تشغيل',
          sectorManagementName: 'قطاع المنيا',
          isActive: true,
        ),
        ActiveUser(
          userId: 2,
          empName: 'محمود حسن',
          empCode: '1002',
          authorityName: 'فني صيانة',
          sectorManagementName: 'قطاع ملوي',
          isActive: false,
        ),
      ];

      // Arabic normalized search ('احمد' without hamza matches 'أحمد')
      cubit.updateFilters(name: 'احمد');
      expect(cubit.filterUsers(users).length, 1);
      expect(cubit.filterUsers(users).first.userId, 1);

      cubit.resetFilters();
      cubit.updateFilters(status: 'متاح');
      expect(cubit.filterUsers(users).length, 1);
      expect(cubit.filterUsers(users).first.userId, 1);

      cubit.updateFilters(status: 'غير متاح');
      expect(cubit.filterUsers(users).length, 1);
      expect(cubit.filterUsers(users).first.userId, 2);
      cubit.close();
    });
  });
}
