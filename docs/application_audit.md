# Comprehensive Application-Wide Technical Audit (`incidents_managment`)

## 1. Executive Summary

This document presents the Phase 1 architectural, performance, state management, loading experience, and responsive UI/UX audit of the **Minya Water & Wastewater Company Crisis, GIS, Valve & Fleet Management System** (`incidents_managment`). The application targets **Flutter Mobile (Android/iOS), Tablet, and Flutter Web (CanvasKit/HTML)**.

### Audit Scope
- **175+ Dart source files** across `lib/core/future/` and `lib/features/`
- **26+ screens and adaptive Web/Mobile views**
- **25+ Cubits & State classes**
- **3 Networking stacks**:
  1. REST API (`Dio` + `Retrofit` `ApiService` + `OfflineGetCacheInterceptor` + `OfflineInterceptor` + `AuthInterceptor`)
  2. Real-time WebSocket (`Socket.IO` in `IncidentMapCubit`)
  3. ETIT GPS Fleet Integration (`EtitGpsService` + Node/CORS proxy + `FleetRepositoryImpl` + `FleetCubit`)

---

## 2. Complete Screen & Feature Inventory

| # | Feature Module | Screen / Widget | Platform | State Management | Current Loading Experience | Audit Status / Issues |
|---|---|---|---|---|---|---|
| 1 | **Shell / Navigation** | `CrisisDashboard` (`lib/core/future/home/ui/screens/home.dart`) | Web / Desktop | `HomeCubit`, `IncidentMapCubit` | Top bar + IndexedStack | **CRITICAL BUG**: Recreates tabs 5 (`AllIncidentType`) and 6 (`AllMissions`) with `UniqueKey()` on *every* `HomeCubit` emission, causing full network reloads. |
| 2 | **Operations Dashboard** | `DashboardView` (`lib/core/future/home/ui/widgets/dash_board/dash_board.dart`) | Web / Tablet | `IncidentMapCubit`, `DashboardCubit` | Empty list when socket loading | **HIGH**: Creates duplicate local `DashboardCubit` shadowing root `DashboardCubit`; lacks `DashboardScreenShimmer` when initial snapshot is loading. |
| 3 | **Live Incidents Map** | `IncidentsMapScreen` (`lib/core/future/home/ui/widgets/map_widget.dart`) | Web / Tablet / Mobile | `IncidentMapCubit`, `DashboardCubit` | Raw `CircularProgressIndicator` overlay | **HIGH**: Uses raw spinner; fixed 3-column desktop `Row` overflows or cramps on tablet/mobile widths. |
| 4 | **User Management** | `UserManagementScreen` (`lib/core/future/home/ui/screens/user_management_screen.dart`) | Web / Tablet / Mobile | `AllActiveUserCubit`, `UserManagementFilterCubit` | Raw `CircularProgressIndicator` | **HIGH**: Uses raw spinner; wipes existing table during refresh instead of preserving data. |
| 5 | **Analytics Overview** | `AnalyticsOverviewScreen` (`lib/core/future/home/ui/screens/analytics_overview_screen.dart`) | Web / Mobile | `IncidentMapCubit` | Raw `CircularProgressIndicator` | **MEDIUM**: Uses raw spinner on initial state; needs `AnalyticsOverviewShimmer`. |
| 6 | **Executive Reports** | `IncidentReportsScreen` (`lib/core/future/reports/ui/incident_reports_screen.dart`) | Web / Tablet / Mobile | `ReportsCubit` | Raw `CircularProgressIndicator` in 500px box | **HIGH**: Raw spinner instead of multi-card/chart/table shimmer (`ReportsScreenShimmer`); fixed `Row` chart layouts do not wrap on `< 960px` screens. |
| 7 | **Incident Types (Web)** | `AllIncidentTypeWebScreen` (`lib/core/future/actions/ui/screens/incident.dart/all_incident_type_web.dart`) | Web / Desktop | `AllIncidentTypeCubit`, `IncidentTypeFilterCubit` | Raw `CircularProgressIndicator` | **HIGH**: Raw spinner; wipes grid on refresh; needs `IncidentTypesScreenShimmer`. |
| 8 | **Incident Types (Mobile)** | `AllIncidentTypeMobileScreen` (`lib/core/future/actions/ui/screens/incident.dart/all_incident_type_mobile.dart`) | Mobile / Tablet | `AllIncidentTypeCubit` + local `setState` | `Loadding()` (spinner) | **HIGH**: Uses local `setState` (`_searchQuery`, `_selectedCategory`) instead of `IncidentTypeFilterCubit`; uses raw spinner. |
| 9 | **Missions Catalog (Web)** | `AllMissionsWeb` (`lib/core/future/actions/ui/screens/missions/all_missions_web.dart`) | Web / Desktop | `AllMissionsCubit`, `MissionsFilterCubit` | Raw `CircularProgressIndicator` | **HIGH**: Raw spinner; wipes grid on refresh; needs `MissionsScreenShimmer`. |
| 10 | **Missions Catalog (Mobile)** | `AllMissionsMobile` (`lib/core/future/actions/ui/screens/missions/all_missions_mobile.dart`) | Mobile / Tablet | `AllMissionsCubit` + local `setState` | `Loadding()` (spinner) | **HIGH**: Uses local `setState` (`_selectedClass`) instead of `MissionsFilterCubit`; uses raw spinner. |
| 11 | **Link Missions to Types** | `Addincidentmission` (`lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart`) | Web / Mobile | `AllIncidentTypeCubit`, `AllMissionsCubit`, `RelationIncidentMissionCubit`, `MissionSelectionCubit` | Raw `CircularProgressIndicator` | **MEDIUM**: Uses raw spinners in header dropdown & grid; defines duplicate unused `MissionSelectionState` class at bottom of file. |
| 12 | **Add Incident** | `AddIncidentScreen` / `AddIncidentMobileScreen` / `SharedIncidentForm` | Web / Mobile | `AddIncidentCubit`, `AllIncidentTypeCubit` + local `setState` | Raw `CircularProgressIndicator` in dropdowns | **HIGH**: `SharedIncidentForm` calls `getIt<AddIncdientRepo>().getBranches()` directly in `initState()` using `setState`; needs Cubit-managed lookup & `ShimmerInput` skeletons. |
| 13 | **Add / Edit Mission** | `AddMissionsWeb`, `AddMissionsMobile`, `EditMissions` | Web / Mobile | `AddMissionCubit`, `EditMissionCubit`, `AllIncidentClasses` | `LinearProgressIndicator` / `Loadding()` | **MEDIUM**: Uses raw progress indicator while incident classes load; needs `ShimmerInput` skeleton. |
| 14 | **Add Incident Type** | `AddIncidentTypeWeb`, `AddIncidentTypeMobile` | Web / Mobile | `AddIncidentTypeCubit`, `AllIncidentClasses` | `Loadding()` (spinner) | **MEDIUM**: Uses raw spinner while classes load; needs `ShimmerInput` skeleton. |
| 15 | **Mission Assignment (Web)** | `MissionAssignWebScreen` (`lib/core/future/mission_assigen/ui/screens/mission_assign_web.dart`) | Web / Desktop | `AllActiveUserCubit`, `AllMissionsCubit`, `MissionAssignCubit` + local `setState` | Raw spinner in `UsersPanel` | **HIGH**: Uses local `setState` for 5 user filter fields (`_searchQuery`, `_selectedAuthority`, `_selectedSector`, `_selectedGroup`, `_selectedStatus`) and raw spinners. |
| 16 | **Mission Assignment (Mobile)** | `MissionAssignMobileScreen` (`lib/core/future/mission_assigen/ui/screens/mission_assign_mobile.dart`) | Mobile / Tablet | `AllActiveUserCubit`, `AllMissionsCubit`, `MissionSelectionCubit` | Raw spinner in `UsersPanel` | **MEDIUM**: `UsersPanel` and `MissionsSelectionModal` use raw spinners instead of `MissionAssignScreenShimmer`. |
| 17 | **Valves Map (Web)** | `WebValveMapScreen` (`lib/core/future/valve/ui/web_valve_map_screen.dart`) | Web / Tablet | `ValveCubit` | Small floating spinner | **MEDIUM**: Lacks initial `ValveMapScreenShimmer` skeleton and responsive drawer fallback for narrow tablet/mobile widths. |
| 18 | **Valves Map (Mobile)** | `MapScreen` (`lib/core/future/valve/ui/map_screen.dart`) | Mobile | `ValveCubit` | Small spinner | **MEDIUM**: Needs `ValveMapScreenShimmer` during initial load. |
| 19 | **GIS Network Explorer** | `GisMapScreen` (`lib/core/future/gis/ui/gis_map_screen.dart`) | Web / Mobile | `GisCubit` | Toolbar mini-spinner | **LOW**: Needs initial `GisMapScreenShimmer` overlay when loading layers for the first time. |
| 20 | **ETIT Fleet Vehicles List** | `EtitVehiclesListScreen` (`lib/features/valves_map/presentation/screens/etit_vehicles_list_screen.dart`) | Web / Tablet / Mobile | `FleetCubit` | `FleetDashboardPageShimmer` | **COMPLETED & VERIFIED**: Uses `FleetCubit` + `FleetDashboardPageShimmer` + responsive table/card layout. |
| 21 | **ETIT Live Fleet Map** | `EtitFleetMapScreen` (`lib/features/valves_map/presentation/screens/etit_fleet_map_screen.dart`) | Web / Tablet / Mobile | `FleetCubit` | `FleetMapShimmer` | **COMPLETED & VERIFIED**: Uses `FleetCubit` + `FleetMapShimmer` + marker icon caching + responsive drawer. |
| 22 | **Mobile Home (Incidents)** | `MobileIncidentsListScreen` (`lib/core/future/mobile/ui/screens/home/home.dart`) | Mobile | `IncidentMapCubit`, `MobileIncidentsFilterCubit` | `MobileHomeShimmerList` | **GOOD**: Already uses shimmer list; can be enhanced with unified shimmer primitives. |
| 23 | **Mobile Incident Details** | `MobileIncidentDetailsScreen` (`lib/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart`) | Mobile | `IncidentMapCubit`, `IncidentUpdateCubit`, `MissionUpdateCubit` | Raw `CircularProgressIndicator` when loading by ID | **MEDIUM**: Uses raw `CircularProgressIndicator` when resolving deep-linked incident ID; needs `MobileIncidentDetailsShimmer`. |
| 24 | **Auth — Login** | `Login` (`lib/core/future/auth/ui/screens/login.dart`) | Web / Mobile | `LoginCubit` | Button inline loading | **GOOD**: Clean form submission state. |
| 25 | **Auth — Registration** | `RegistrationScreen` (`lib/core/future/auth/ui/screens/registration.dart`) | Web / Mobile | `RegistrationCubit`, `RegistrationGetCubit` | `Loadding()` full-screen spinner | **HIGH**: Replaces entire registration form with a raw spinner while lookup lists (`sectors`, `groups`, `authLevels`) load; needs `RegistrationFormShimmer`. |

---

## 3. Architectural & Technical Findings

### 3.1 Critical Bug: Tab Destruction in `CrisisDashboard` (`home.dart`)
In `lib/core/future/home/ui/screens/home.dart`:
```dart
Widget _getTab(int index, List<CurrentIncidentModel> incidents) {
  if (_tabs[index] == null || index == 5 || index == 6) {
    switch (index) {
      case 5:
        _tabs[index] = AllIncidentType(key: UniqueKey());
        break;
      case 6:
        _tabs[index] = AllMissions(key: UniqueKey());
        break;
```
Because `_buildMainContent` runs inside `BlocBuilder<HomeCubit, HomeState>`, **every time the user hovers a menu item or switches tabs**, `index == 5 || index == 6` forces `AllIncidentType` and `AllMissions` to be recreated with a brand-new `UniqueKey()`, destroying their widget subtrees and re-triggering `getAllIncidentTypes()` / `getAllMissions()` HTTP calls.
- **Fix**: Cache tabs 5 and 6 in `_tabs` without `UniqueKey()`, and refresh data cleanly via Cubit when needed.

### 3.2 Duplicate `DashboardCubit` Instances
- `IncidentsApp` (`lib/incidents.dart`) provides a root `DashboardCubit()`.
- `DashboardView` (`lib/core/future/home/ui/widgets/dash_board/dash_board.dart`) creates *another* `late final DashboardCubit _dashboardCubit = DashboardCubit();` in `initState()` and provides it via `BlocProvider.value`, shadowing the root instance.
- **Fix**: Reuse the existing `DashboardCubit` from `context` if available (or create & own cleanly if standalone) so state is never split across two instances.

### 3.3 Direct Repository Calls & Business `setState` in UI Widgets
1. **`SharedIncidentForm`** (`lib/core/future/actions/ui/widgets/incident/shared_incident_form.dart`):
   - Calls `getIt<AddIncdientRepo>().getBranches()` directly inside `initState()` and stores `_branches` and `_isLoadingBranches` in `State` via `setState`.
   - **Fix**: Move branch loading into `AddIncidentCubit` (with in-memory caching) and expose branches via `AddIncidentCubit` state/properties.
2. **`AllIncidentTypeMobileScreen`** (`lib/core/future/actions/ui/screens/incident.dart/all_incident_type_mobile.dart`):
   - Uses local `setState` (`_searchQuery`, `_selectedCategory`) while `AllIncidentTypeWebScreen` uses `IncidentTypeFilterCubit`.
   - **Fix**: Standardize both Web and Mobile on `IncidentTypeFilterCubit`.
3. **`AllMissionsMobile`** (`lib/core/future/actions/ui/screens/missions/all_missions_mobile.dart`):
   - Uses local `setState` (`_selectedClass`) while `AllMissionsWeb` uses `MissionsFilterCubit`.
   - **Fix**: Standardize both Web and Mobile on `MissionsFilterCubit`.
4. **`MissionAssignWebScreen`** (`lib/core/future/mission_assigen/ui/screens/mission_assign_web.dart`):
   - Uses local `setState` for 5 user filtering fields (`_searchQuery`, `_selectedAuthority`, `_selectedSector`, `_selectedGroup`, `_selectedStatus`).
   - **Fix**: Use `UserManagementFilterCubit` to manage user filtering reactively without full-screen `setState`.

### 3.4 Data Wipe on Background Refresh
- `AllActiveUserCubit`, `AllIncidentTypeCubit`, and `AllMissionsCubit` emit `loading()` unconditionally even when they already hold loaded items in memory, causing the UI to destroy the current scroll position and flash a loading state during refresh.
- **Fix**: Cache the last loaded list inside each Cubit (`cachedUsers`, `cachedIncidentTypes`, `cachedMissions`) and support preserving existing data during refresh while displaying a subtle top refresh progress bar.

### 3.5 Missing Centralized Design System & Two-Level Shimmer Architecture
- Design tokens are scattered across `AppTheme`, `FleetColors`, and ad-hoc `Color(0xFF...)` literals.
- Only the Fleet screens and Mobile Home list have shimmer skeletons; 18+ screens still use raw `CircularProgressIndicator()` or `Loadding()`.
- **Fix**:
  - Create `lib/core/design_system/app_design_system.dart` with centralized tokens (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppBreakpoints`, `AppDurations`) and reusable state widgets (`AppEmptyState`, `AppErrorState`, `AppInlineRefreshBanner`).
  - Create **Level 1 Shimmer Primitives** (`lib/core/widget/shimmer/shimmer_primitives.dart`) and **Level 2 Screen-Specific Shimmer Compositions** (`lib/core/widget/shimmer/screen_shimmers.dart`) tailored to every screen's exact layout.

---

## 4. Prioritized Refactoring Plan

| Priority | Phase | Scope | Impact |
|---|---|---|---|
| **P0 (Critical)** | Design System & Two-Level Shimmer System | `app_design_system.dart`, `shimmer_primitives.dart`, `screen_shimmers.dart` | Unlocks consistent UI tokens and layout-accurate shimmers across all 25+ screens |
| **P0 (Critical)** | Shell & Cubit Stabilization | `home.dart`, `dash_board.dart`, `AllActiveUserCubit`, `AllIncidentTypeCubit`, `AllMissionsCubit`, `AddIncidentCubit` | Eliminates `UniqueKey()` tab re-fetching, duplicate `DashboardCubit`, direct repo calls in UI, and data wiping on refresh |
| **P1 (High)** | Screen-Specific Shimmer & State Migration | Dashboard, Map, User Management, Reports, Incident Types (Web/Mobile), Missions (Web/Mobile), Link Missions, Mission Assign (Web/Mobile), Registration, Forms, Valves Map, GIS Map, Analytics | Eliminates all raw full-screen `CircularProgressIndicator` spinners and local business `setState` |
| **P1 (High)** | Responsive Layout Optimization | `IncidentsMapScreen`, `IncidentReportsScreen`, `WebValveMapScreen` | Ensures Mobile, Tablet, and Web viewports adapt cleanly without horizontal overflow |
| **P2 (Medium)** | Verification & Documentation | Unit/Cubit/Widget tests + 7 architecture & performance reports | 0 `flutter analyze` issues and 100% passing test suite |
