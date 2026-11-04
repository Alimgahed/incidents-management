# Two-Level Shimmer Loading Inventory

## 1. Architecture of the Shimmer System

The application implements a **Two-Level Shimmer Loading Architecture** that replaces raw full-screen `CircularProgressIndicator` spinners with layout-accurate, geometry-matched skeleton compositions.

### Level 1 — Reusable Shimmer Primitives (`lib/core/widget/shimmer/shimmer_primitives.dart`)
- **`AppShimmerScope`**: Coordinates a single shared `AnimationController` across all descendant shimmer primitives so even complex dashboard screens only tick one animation controller. Automatically respects `MediaQuery.maybeDisableAnimationsOf(context)` for reduced-motion accessibility and deterministic widget tests.
- **`ShimmerBox`**: Base rectangular placeholder with configurable width, height, and border radius.
- **`ShimmerCircle`**: Circular placeholder for icons, status indicators, and donut charts.
- **`ShimmerLine`**: Single-line typographic placeholder.
- **`ShimmerText`**: Multi-line paragraph placeholder with realistic trailing line width.
- **`ShimmerAvatar`**: Circular or rounded-square avatar placeholder.
- **`ShimmerButton`**: Action button placeholder matching standard button height and radius.
- **`ShimmerInput`**: Form input / dropdown field placeholder with optional label bar above.
- **`ShimmerCard`**: Surface card container with subtle border and elevation.
- **`ShimmerTableRow`**: Multi-column enterprise data table row skeleton.
- **`ShimmerListItem`**: Structured list item skeleton with leading avatar, title/subtitle, and status pill.

---

## 2. Level 2 — Screen-Specific Shimmer Inventory (`lib/core/widget/shimmer/screen_shimmers.dart`)

| # | Screen / Module | Shimmer Widget | Skeleton Composition Details |
|---|---|---|---|
| 1 | **Operations Dashboard** (`DashboardView`) | `DashboardScreenShimmer` | Top `DashboardKpiStripShimmer` (5 KPI cards) + Left `IncidentListSectionShimmer` + Right `IncidentDetailsSectionShimmer` on Desktop; KPI strip + Incident List shimmer on Mobile. |
| 2 | **Live Incidents Map** (`IncidentsMapScreen`) | `IncidentsMapScreenShimmer` | Left filter sidebar skeleton + center map canvas with floating HUD shimmer + right incident list panel skeleton on Desktop; adaptive map shimmer on Mobile/Tablet. |
| 3 | **User Management** (`UserManagementScreen`) | `UserManagementScreenShimmer` | Header + 3 KPI stat card skeletons + filter bar skeleton + 7-row `ShimmerTableRow` table on Desktop (or `ShimmerListItem` cards on Mobile). |
| 4 | **Executive Reports** (`IncidentReportsScreen`) | `ReportsScreenShimmer` | 6 KPI cards grid + bar chart card skeleton + donut chart card skeleton + breakdown table cards. |
| 5 | **Analytics Overview** (`AnalyticsOverviewScreen`) | `AnalyticsOverviewShimmer` | Full analytics KPI + chart + breakdown shimmer composition. |
| 6 | **Incident Types Catalog** (`AllIncidentTypeWebScreen` & `AllIncidentTypeMobileScreen`) | `IncidentTypesScreenShimmer` | Category filter pills + adaptive multi-column card grid on Web or `ShimmerListItem` list on Mobile. |
| 7 | **Missions Catalog** (`AllMissionsWeb` & `AllMissionsMobile`) | `MissionsScreenShimmer` | Category filter pills + adaptive 9-card grid on Web or `ShimmerListItem` list on Mobile. |
| 8 | **Link Missions to Types** (`Addincidentmission` & `LinkMissionsHeader`) | `LinkMissionsScreenShimmer` + `ShimmerInput` | Header dropdown `ShimmerInput` + 6-card available missions grid shimmer. |
| 9 | **Add Incident Form** (`SharedIncidentForm` & `IncidentTypeDropdown`) | `ShimmerInput` | Field-level `ShimmerInput(height: 52)` skeletons while incident types and branches load asynchronously. |
| 10 | **Add / Edit Mission & Incident Type Forms** (`AddMissionsWeb`, `AddMissionsMobile`, `SharedIncidentTypeForm`) | `ShimmerInput` | Field-level `ShimmerInput` skeleton while incident classes load. |
| 11 | **User Registration** (`RegistrationScreen`) | `FormScreenShimmer(fieldCount: 7)` | Centered card with form header + 7 labeled input/dropdown skeletons + action buttons while registration lookup lists load. |
| 12 | **Mission Assignment** (`MissionAssignWebScreen` & `UsersPanel`) | `MissionAssignUsersShimmer` | Structured user assignment list/grid skeletons while active users load. |
| 13 | **Valves Map** (`WebValveMapScreen`) | `ValveMapScreenShimmer` | 3-column filter + map canvas + valve list shimmer skeleton. |
| 14 | **Mobile Home** (`MobileIncidentsListScreen`) | `MobileHomeShimmerList` | Mobile incident card skeletons with severity badges and metadata lines. |
| 15 | **Mobile Incident Details** (`MobileIncidentDetailsScreen`) | `MobileIncidentDetailsShimmer` | Header card + 2x3 metadata grid + missions list shimmer when resolving deep-linked incident ID. |
| 16 | **ETIT Fleet Vehicles List** (`EtitVehiclesListScreen`) | `FleetDashboardPageShimmer` | 4 KPI cards + search/filter bar + 8-row vehicle table shimmer (`FleetTableRowShimmer` / `FleetMobileCardShimmer`). |
| 17 | **ETIT Live Fleet Map** (`EtitFleetMapScreen`) | `FleetMapShimmer` | Top HUD bar + map canvas + floating vehicle list drawer shimmer. |
