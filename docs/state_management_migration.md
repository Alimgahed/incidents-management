# State Management Migration & Standardization Report

## 1. Overview

All application features have been standardized on **Cubit / BLoC (`flutter_bloc`)** with immutable state classes (`freezed` / `Equatable`), strict rebuild scoping (`buildWhen` / `listenWhen` / `context.select`), and in-memory data preservation during background refreshes.

---

## 2. Key State Management Refactorings Completed

### 2.1 Eliminated `UniqueKey()` Tab Re-Creation in `CrisisDashboard`
- **File**: `lib/core/future/home/ui/screens/home.dart`
- **Before**: Every `HomeCubit` state emission forced `index == 5` (`AllIncidentType`) and `index == 6` (`AllMissions`) to be recreated with `UniqueKey()`, destroying their Cubits and re-fetching from the backend.
- **After**: All tabs are lazily instantiated once in `_tabs[index] ??= ...` and preserved inside the `IndexedStack`.

### 2.2 Consolidated Duplicate `DashboardCubit` Instances
- **File**: `lib/core/future/home/ui/widgets/dash_board/dash_board.dart`
- **Before**: `DashboardView` unconditionally instantiated a new `DashboardCubit()`, shadowing the root `DashboardCubit` provided in `IncidentsApp`.
- **After**: `DashboardView` reuses the existing `DashboardCubit` from `context` when available and only creates/disposes a local instance when mounted standalone in tests.

### 2.3 Migrated Direct Repository Calls in `SharedIncidentForm` to `AddIncidentCubit`
- **Files**:
  - `lib/core/future/actions/logic/cubit/incident/add_incident_cubit.dart`
  - `lib/core/future/actions/ui/widgets/incident/shared_incident_form.dart`
- **Before**: `SharedIncidentForm` called `getIt<AddIncdientRepo>().getBranches()` directly inside `initState()`.
- **After**: `AddIncidentCubit.loadBranches()` manages branch retrieval and caches the branch list across form opens.

### 2.4 Unified Filtering Cubits Across Web and Mobile Screens
1. **Incident Types Mobile (`AllIncidentTypeMobileScreen`)**:
   - Migrated from local `setState` (`_searchQuery`, `_selectedCategory`) to `IncidentTypeFilterCubit` (`IncidentTypeFilterState`), matching `AllIncidentTypeWebScreen`.
2. **Missions Mobile (`AllMissionsMobile`)**:
   - Migrated from local `setState` (`_selectedCategory`, `_isSearchActive`) to `MissionsFilterCubit` (`MissionsFilterState`), matching `AllMissionsWeb`.
3. **Mission Assignment Web (`MissionAssignWebScreen`)**:
   - Migrated from 5 local `setState` fields (`_searchQuery`, `_selectedAuthority`, `_selectedSector`, `_selectedGroup`, `_selectedStatus`) to `UserManagementFilterCubit` (`UserManagementFilterState`) enhanced with Arabic text normalization (`ArabicTextHelper`).

### 2.5 Background Refresh Data Preservation & Request Deduplication
- **Updated Cubits**:
  - `AllActiveUserCubit` (`lib/core/future/mission_assigen/logic/cubit/all_active_user_cubit.dart`)
  - `AllIncidentTypeCubit` (`lib/core/future/actions/logic/cubit/incident/all_incident_type.dart`)
  - `AllMissionsCubit` (`lib/core/future/actions/logic/cubit/missions_cubit/get_all_missions_cubit.dart`)
  - `FleetCubit` (`lib/features/fleet/presentation/cubit/fleet_cubit.dart`)
- **Behavior**:
  - In-flight requests are deduplicated (`_inFlight` / `_loadInFlight`).
  - When cached data already exists, refreshing sets `isRefreshing = true` and keeps the existing loaded list rendered with an `AppInlineRefreshBanner` instead of wiping the UI back to a full-screen loading state.
