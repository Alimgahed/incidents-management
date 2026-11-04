# ETIT GPS Fleet Management — Complete Architecture & Performance Analysis

**Date:** November 4, 2026  
**Scope:** ETIT GPS Fleet Management & Live Tracking Module (`etit-fms.etit-eg.com` & `fms-gps.etit-eg.com`)

---

## 1. Current Architecture Overview

### 1.1 Folder Structure (Before Refactoring)
```text
lib/
  features/
    valves_map/
      models/
        etit_vehicle_model.dart
      services/
        etit_gps_service.dart
      presentation/
        screens/
          etit_fleet_map_screen.dart
          etit_vehicles_list_screen.dart
scripts/
  etit_proxy.js
```

### 1.2 Existing ETIT Integration Mechanics (Preserved 100%)
1. **Authentication Handshake (`ASP.NET AJAX Delta PostBack`)**:
   - `GET https://etit-fms.etit-eg.com/` extracts `__VIEWSTATE` and `__VIEWSTATEGENERATOR` and stores the initial `ASP.NET_SessionId`.
   - `POST https://etit-fms.etit-eg.com/` with `X-MicrosoftAjax: Delta=true`, `X-Requested-With: XMLHttpRequest`, and Telerik `RadAjaxManager1` form fields authenticates `water.menia` and yields SSO cookies (`Token`, `SSOCookie`, `Authentication`, `.ASPXAUTH`).
   - `GET https://fms-gps.etit-eg.com/WebPages/Maps.aspx` initializes the secondary IIS session (`ASP.NET_SessionId` for `fms-gps.etit-eg.com`) and extracts `hdn_NAllTransporterCOdes`.
2. **Fleet Vehicles Metadata Endpoint**:
   - `POST https://etit-fms.etit-eg.com/WebPages/Transporters/List.aspx/GetAllTransporterBySearchCriteria`
   - Paginated in batches of `PageSize: 100` (`PageIndex: 1` and `PageIndex: 2`) to respect ASP.NET `maxJsonLength` limits (162 active vehicles).
3. **Real-Time Telematics Endpoint**:
   - `POST https://fms-gps.etit-eg.com/WebPages/GetTransportersSpeedStatus.aspx`
   - Returns `*`-delimited positional arrays (`par[0]` IDs, `par[1]` Speeds, `par[2]` Statuses, `par[3]` Longitudes, `par[4]` Latitudes, `par[5]` LastUpdate timestamps, `par[20]` Device IMEIs).
4. **Web Proxy (`scripts/etit_proxy.js`)**:
   - Local/Server HTTP proxy on port `8089` managing dual per-host cookie jars (`etit-fms.etit-eg.com` + `fms-gps.etit-eg.com`), automatic session renewal, and CORS headers.

---

## 2. Discovered Technical, Architectural & Performance Issues

| # | Issue | Category | Severity | Impact |
|---|---|---|---|---|
| 1 | **Misplaced Feature Module** (`lib/features/valves_map/`) | Architecture | Medium | Fleet management code is coupled inside `valves_map` without Domain, Data, Repository, or Cubit separation. |
| 2 | **`setState` Used for Application & Business State** | State Management | **Critical** | Both screens manage API calls, filters, pagination, and polling inside `StatefulWidget` via `setState`, causing full widget-tree rebuilds on every interaction. |
| 3 | **Redundant Metadata Fetching on Every 10s Poll** | Network / Performance | **Critical** | `getVehiclesWithLiveTracking()` re-fetches 2 pages of `GetAllTransporterBySearchCriteria` (heavy JSON) every 10 seconds alongside live coordinates, instead of caching vehicle metadata (TTL 5 min) and polling only lightweight `GetTransportersSpeedStatus.aspx`. |
| 4 | **Duplicate API Calls Across Dashboard Tabs** | Network / Memory | **High** | `EtitFleetMapScreen` and `EtitVehiclesListScreen` do not share a repository cache or Cubit state, doubling network traffic when switching tabs. |
| 5 | **Unbounded / Overlapping Polling Timer** | Concurrency | **High** | `Timer.periodic` fires every 10s without an in-flight mutex/guard (`_isPolling`), risking overlapping requests on slow connections. |
| 6 | **No Search Debouncing** | UI Performance | **Medium** | Every keystroke synchronously filters 162 vehicles and rebuilds the entire screen/map without a 250ms debounce. |
| 7 | **Full `FlutterMap` Rebuild on Single Vehicle Selection** | Rendering | **High** | Selecting a vehicle or typing in a search box rebuilds the entire `Scaffold` and `FlutterMap` widget tree instead of scoping rebuilds with `BlocSelector` / `BlocBuilder(buildWhen:)`. |
| 8 | **Generic `CircularProgressIndicator` Instead of Field-Aware Shimmer** | UX / Perceived Perf | **High** | Loading states show a basic spinner rather than layout-matched skeleton placeholders (`FleetStatisticsShimmer`, `FleetFiltersShimmer`, `VehicleTableShimmer`, `FleetMapShimmer`, `VehicleDetailsShimmer`), causing layout shifts when data arrives. |
| 9 | **Swallowed Exceptions in `EtitGpsService`** | Error Handling | **High** | `catch (e) { return []; }` hides network/proxy/auth errors and makes it impossible to distinguish between an empty fleet and a failed connection. |
| 10 | **Hardcoded Styling Tokens in Widgets** | Maintainability | **Medium** | Colors, spacing, border radii, and text styles are hardcoded inline across 2,000+ lines of UI code instead of using centralized design tokens. |

---

## 3. Refactoring & Implementation Plan

### Phase 2: Clean Architecture Structure (`lib/features/fleet/`)
Create a clean, modular, feature-first architecture while keeping backward-compatible exports for existing routes:
```text
lib/
  features/
    fleet/
      core/
        theme/
          fleet_tokens.dart
        error/
          fleet_failure.dart
        shimmer/
          fleet_shimmer_widgets.dart
      data/
        datasources/
          etit_remote_datasource.dart
        models/
          fleet_vehicle_Dto.dart (re-using & extending EtitVehicleModel)
        repositories/
          fleet_repository_impl.dart
      domain/
        entities/
          fleet_statistics.dart
          fleet_filter_Params.dart
        repositories/
          fleet_repository.dart
      presentation/
        cubit/
          fleet_cubit.dart
          fleet_state.dart
        pages/
          fleet_vehicles_page.dart
          fleet_live_map_page.dart
        widgets/
          fleet_kpi_cards_bar.dart
          fleet_filters_bar.dart
          fleet_vehicles_table.dart
          fleet_vehicle_details_card.dart
          fleet_map_side_panel.dart
```

### Phase 3–8: State Management, Shimmer, Caching & Performance
1. **`EtitRemoteDataSource`**:
   - Preserves 100% of the working ETIT authentication, dual-host proxy URL routing, `GetAllTransporterBySearchCriteria` pagination (`PageSize: 100`), and `GetTransportersSpeedStatus.aspx` parsing.
   - Adds in-flight request deduplication (`Synchronized` / shared `Future`) so concurrent callers share a single network round-trip.
   - Throws typed `FleetFailure` exceptions (sanitized Arabic messages; never leaks credentials, cookies, or stack traces).
2. **`FleetRepositoryImpl`**:
   - Implements a **Two-Tier Cache Strategy**:
     - **Vehicle Metadata Cache (TTL: 5 minutes)**: Avoids re-downloading the 2-page `GetAllTransporterBySearchCriteria` payload on every 10-second GPS poll unless `forceRefresh: true` is requested.
     - **Live Telematics Fetch (Always Fresh)**: Every live poll hits only `GetTransportersSpeedStatus.aspx` and merges coordinates, speeds, status codes, `lastUpdate`, and `deviceCode` into the cached metadata in $O(N)$ time using a hash map.
     - Never treats cached coordinates as live without displaying the exact `lastUpdate` server timestamp and `lastSuccessfulSync` time.
3. **`FleetCubit` & Immutable `FleetState` (`Equatable`)**:
   - Manages `FleetStatus` (`initial`, `loading`, `loaded`, `refreshing`, `error`, `empty`), full vehicles list, filtered vehicles list, paginated slice, active `FleetFilterParams`, `FleetStatistics` (both global and filtered), selected vehicle, follow-mode toggle, map layer, and non-overlapping 10-second live polling with pause/resume support.
   - Implements 250ms search debounce.
4. **Field-Aware Shimmer System (`shimmer: ^3.0.0`)**:
   - `FleetStatisticsShimmer`, `FleetFiltersShimmer`, `VehicleTableShimmer`, `VehicleRowShimmer`, `FleetMapShimmer`, `VehicleDetailsShimmer`.
5. **Scoped Widget Rebuilds**:
   - Uses `BlocBuilder` with `buildWhen` and `BlocSelector` so map markers, KPI cards, filter bars, and the selected vehicle card rebuild independently.
