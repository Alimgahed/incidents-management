# Application-Wide Performance Optimization Report

## 1. Executive Summary

This report documents the application-wide performance engineering improvements implemented across **Flutter Mobile, Tablet, and Web**.

---

## 2. Key Performance Optimizations

### 2.1 Eliminated Redundant Network Calls & Widget Tree Re-Creation on Tab Switches
- **Root Cause**: `CrisisDashboard` (`lib/core/future/home/ui/screens/home.dart`) previously checked `if (_tabs[index] == null || index == 5 || index == 6)` and instantiated `AllIncidentType(key: UniqueKey())` and `AllMissions(key: UniqueKey())` inside `BlocBuilder<HomeCubit, HomeStates>`.
- **Impact**: Every tab change destroyed the widget subtree and re-triggered HTTP requests for incident types and missions.
- **Optimization**: Replaced with lazy `_tabs[index] ??= ...` without `UniqueKey()`, preserving state and scroll position across tab switches with zero redundant network requests.

### 2.2 Single-Controller Shimmer Rendering (`AppShimmerScope`)
- **Root Cause**: Independent shimmer widgets that each create their own `AnimationController` cause dozens of concurrent ticker callbacks per frame on complex screens.
- **Optimization**: `AppShimmerScope` (`lib/core/widget/shimmer/shimmer_primitives.dart`) shares a single `AnimationController` and `ShaderMask` across an entire screen's skeleton hierarchy, and automatically halts ticker execution when `MediaQuery.maybeDisableAnimationsOf(context)` is true.

### 2.3 Off-Main-Isolate JSON Parsing (`compute`)
- **Implementation**: `IncidentMapCubit` (`lib/core/future/home/logic/incident_map_cubit/incident_map.dart`) parses large Socket.IO `incident_snapshot` payloads on a background isolate via `compute(_parseIncidentList, ...)`, preventing UI frame drops on initial connection.

### 2.4 Marker Widget & Icon Caching on Map Screens
- **ETIT Fleet Map (`EtitFleetMapScreen`)**:
  - Vehicle marker icons and status colors are memoized, and `RepaintBoundary` isolates the `FlutterMap` canvas from HUD and drawer rebuilds.
- **Live Incidents Map (`IncidentsMapScreen`)**:
  - Wrapped `FlutterMap` in `RepaintBoundary` and scoped filter updates via `MapFilterCubit`.

### 2.5 In-Flight Request Deduplication & Non-Destructive Background Refresh
- **Implementation**: `AllActiveUserCubit`, `AllIncidentTypeCubit`, `AllMissionsCubit`, `IncidentMapCubit`, and `FleetCubit` deduplicate concurrent fetch calls and retain cached lists in memory during refreshes so existing scroll views are not torn down and rebuilt from scratch.
