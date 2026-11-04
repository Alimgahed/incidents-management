# 03 — Screen-by-Screen UI/UX Findings & Actionable Recommendations

Every finding below is documented using the mandatory audit schema:
**Feature · Screen · Route · Source File · Current Problem · Exact Location · Why It Is a Problem · Recommended Improvement · Expected Result · Priority · Effort**.

---

## 1. Web Application Shell & Global Navigation (`CrisisDashboard` & `AppDrawer`)

### Finding 1.1 — Double-Stacked Headers & Redundant Card Wrapping Inside Web Shell
- **Feature**: Web Application Shell
- **Screen**: `CrisisDashboard`
- **Route**: `Routes.crisisDashboardScreen` (`/crisis_dashboard`)
- **Source File**: [`lib/core/future/home/ui/screens/home.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/home.dart)
- **Current Problem**: `CrisisDashboard` renders `_DesktopSectionHeader(title: _titles[i])` for every tab (`0..10`) and wraps tabs `1..10` inside a padded `Material(borderRadius: 16)` container. However, child tabs (`IncidentReportsScreen`, `AllIncidentTypeWebScreen`, `AllMissionsWeb`, `Addincidentmission`, `GisMapScreen`, `EtitFleetMapScreen`) render their own full-width top bars, `Scaffold`s, or dark blue hero banners inside that card.
- **Exact Location**: [`home.dart` lines 163–254](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/home.dart#L163-L254) (`_buildTabChild` and `_DesktopSectionHeader`).
- **Why It Is a Problem**: Creates visual clutter ("box-inside-a-box"), wastes `68px–140px` of vertical viewport height on laptops, and makes tabs look like separate websites embedded in an iframe rather than a cohesive product.
- **Recommended Improvement**:
  1. Unify the top bar architecture: Either let `_DesktopSectionHeader` serve as the single compact global bar (integrating breadcrumbs, live status indicator, and contextual action slot) OR suppress `_DesktopSectionHeader` on tabs that already provide a rich contextual header (`Tab 3`, `Tab 4`, `Tab 5`, `Tab 6`, `Tab 7`, `Tab 9`, `Tab 10`, `Tab 11`).
  2. Remove the mobile `header_banner.jpg` hero banner from `Addincidentmission` when rendered on Web (`width >= 900`) and remove the inner `AppBar` from `GisMapScreen` when embedded in `CrisisDashboard`.
- **Expected Result**: Reclaims `70px–130px` of vertical workspace across all Web tabs and establishes a single, unmistakable page title hierarchy.
- **Priority**: `CRITICAL`
- **Effort**: `Medium`

---

### Finding 1.2 — Collapsible Rail Mode Missing on Desktop Sidebar (`AppDrawer`)
- **Feature**: Global Navigation Sidebar
- **Screen**: `AppDrawer` (embedded in `CrisisDashboard`)
- **Route**: `Routes.crisisDashboardScreen` (`/crisis_dashboard`)
- **Source File**: [`lib/core/future/home/ui/widgets/app_drawer.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/app_drawer.dart)
- **Current Problem**: On screens `>= 900px`, `AppDrawer` is permanently fixed at `width: 260` (`home.dart` line 264) with no collapse-to-icon-rail toggle (`72px`). Additionally, `إدارة المستخدمين` (Tab `2`) is grouped under `المتابعة والتحكم` (Live Monitoring) instead of an administrative group.
- **Exact Location**: [`home.dart` lines 257–273](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/home.dart#L257-L273) and [`app_drawer.dart` lines 95–218](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/app_drawer.dart#L95-L218).
- **Why It Is a Problem**: On `1024px–1366px` control-room laptops, a non-collapsible `260px` sidebar consumes `20%–25%` of the horizontal width, cramping data-dense screens like `DashboardView` (split view), `IncidentReportsScreen`, and `FleetDashboardScreen`.
- **Recommended Improvement**:
  1. Add a collapse/expand toggle button to `AppDrawer` on desktop (`260px` expanded <-> `72px` icon-only rail with tooltips).
  2. Reorganize sidebar groups into 4 clear operational domains:
     - `غرفة العمليات والمتابعة` (Live Operations: Incidents Dashboard, Incidents Map, Reports & Analytics)
     - `الخرائط الميدانية والأسطول` (GIS & Fleet: GIS Map, Valve Map, Live Fleet Map, Fleet Vehicles)
     - `إدارة البلاغات والمهام` (Workflows: Report Incident, Incident Types, Standard Missions, Link Missions)
     - `إدارة النظام` (Administration: User Management)
- **Expected Result**: Gives operators `+188px` of horizontal screen real estate on demand and improves navigation scannability.
- **Priority**: `HIGH`
- **Effort**: `Medium`

---

## 2. Authentication (`LoginScreen`)

### Finding 2.1 — Static Post-Login Platform Routing & Missing Institutional Context
- **Feature**: Authentication
- **Screen**: `LoginScreen`
- **Route**: `Routes.login` (`/login`)
- **Source File**: [`lib/core/future/auth/ui/screens/login.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/auth/ui/screens/login.dart)
- **Current Problem**:
  1. Upon login success (`lines 46–52`), `LoginScreen` checks `MediaQuery.sizeOf(context).width < 600` to push either `Routes.mobileHome` or `Routes.crisisDashboardScreen`. If a user logs in on a narrow browser window (`<600px`) and maximizes it (or rotates a tablet), they are stuck on `MobileIncidentsListScreen` with no desktop sidebar.
  2. Pressing `Enter` inside username/password fields does not advance focus (`textInputAction: TextInputAction.next` / `onFieldSubmitted: (_) => _submitForm()`).
- **Exact Location**: [`login.dart` lines 46–53](file:///Users/alimegahed/incidents-management/lib/core/future/auth/ui/screens/login.dart#L46-L53) and [`lines 188–202`](file:///Users/alimegahed/incidents-management/lib/core/future/auth/ui/screens/login.dart#L188-L202).
- **Why It Is a Problem**: Web operators who log in with a split browser window get trapped in the mobile UI, and keyboard-first desktop users cannot submit the login form with the `Enter` key.
- **Recommended Improvement**:
  1. Route authenticated sessions through a responsive shell wrapper (or always route `kIsWeb` to `CrisisDashboard`, which already adapts `<900px` with a slide-out `Drawer`).
  2. Add `textInputAction: TextInputAction.next` on Username and `textInputAction: TextInputAction.done` + `onFieldSubmitted` on Password.
  3. Add company subtitle (`شركة مياه الشرب والصرف الصحي بالمنيا — منظومة إدارة الأزمات والطوارئ`) under the main title for institutional clarity.
- **Expected Result**: Seamless keyboard submission and zero risk of desktop users getting stranded in the mobile shell.
- **Priority**: `HIGH`
- **Effort**: `Small`

---

## 3. Incident Command Dashboard (`DashboardView`, `IncidentsList`, `IncidentDetailsPanel`)

### Finding 3.1 — Cramped `28:72` Split-View Ratio & Truncated 4-Column Row in `IncidentCard`
- **Feature**: Incident Command Center (Tab `0`)
- **Screen**: `DashboardView` & `IncidentsList` (`IncidentCard`)
- **Route**: `CrisisDashboard` Tab `0` (`DashboardRoutes.list`)
- **Source File**: [`lib/core/future/home/ui/widgets/dash_board/dash_board.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/dash_board.dart) & [`lib/core/future/home/ui/widgets/dash_board/incient_list.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/incient_list.dart)
- **Current Problem**:
  1. In `dash_board.dart` (`lines 368–396`), the split view allocates `Expanded(flex: 28)` to `IncidentsList` and `Expanded(flex: 72)` to `IncidentDetailsPanel`. On a `1280px` laptop (`1020px` content area), `28%` is only `285px` wide.
  2. Inside `IncidentCard` (`incient_list.dart` `lines 202–294`), when `useWebTileLayout` is true, Row 2 forces 4 `Expanded` columns (`الفرع`, `التاريخ والوقت`, `خطورة الأزمة`, `حالة الأزمة`) into a single horizontal line (`~60px` per column in split mode), truncating branch names and dates into unreadable `...` at `10px` font size.
- **Exact Location**: [`dash_board.dart` lines 368–396](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/dash_board.dart#L368-L396) and [`incient_list.dart` lines 202–294](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/incient_list.dart#L202-L294).
- **Why It Is a Problem**: Operators triaging live crises cannot read the branch name or timestamp in the master list while inspecting an incident in split view.
- **Recommended Improvement**:
  1. Adjust the split-view proportion from `28:72` to `35:65` (with a `ConstrainedBox(minWidth: 340, maxWidth: 440)` on the master list pane).
  2. Redesign compact `IncidentCard` into a clean 2-row card:
     - **Row 1**: Incident Headline/Type (`Expanded`, `13.5px` bold) + Severity Badge + Status Badge.
     - **Row 2**: Branch Icon + Full Branch Name (`12px`) + Spacer + Relative/Formatted Timestamp (`11.5px`) + Incident ID (`#124`).
- **Expected Result**: 100% readable branch names, timestamps, and status badges in both full-grid and split-view modes.
- **Priority**: `CRITICAL`
- **Effort**: `Medium`

---

### Finding 3.2 — Overcrowded `IncidentHeader` Filter & KPI Bar on Standard Desktops
- **Feature**: Incident Command Center (Tab `0`)
- **Screen**: `IncidentHeader`
- **Route**: `CrisisDashboard` Tab `0`
- **Source File**: [`lib/core/future/home/ui/widgets/dash_board/list_header.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/list_header.dart)
- **Current Problem**: When `DashboardView` switches to split mode (`_isSplitView = true`), `IncidentHeader` is rendered inside the narrow left pane (`28%` width), causing KPI pills, search field, and filter dropdowns to stack awkwardly and push the incident cards far down the pane.
- **Exact Location**: [`dash_board.dart` lines 368–377](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/dash_board.dart#L368-L377) and [`list_header.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/list_header.dart).
- **Why It Is a Problem**: Consumes over `40%` of the left master pane's vertical height, showing only 3–4 incident cards at a time.
- **Recommended Improvement**: Keep the top KPI & global filter toolbar spanning the **full width** of `DashboardView` above the split-view `Row(MasterList | DetailPane)`, or collapse the master list header into a single compact Search + Filter Funnel bar when split view is active.
- **Expected Result**: Doubles the number of visible incident cards in the split-view master list (`7–9` visible cards instead of `3–4`).
- **Priority**: `HIGH`
- **Effort**: `Medium`

---

### Finding 3.3 — Fragile `_MeasureSize` Height Coupling in `IncidentDetailsPanel`
- **Feature**: Incident Command Center (Tab `0`)
- **Screen**: `IncidentDetailsPanel`
- **Route**: `CrisisDashboard` Tab `0` (`DashboardRoutes.details`)
- **Source File**: [`lib/core/future/home/ui/widgets/dash_board/incident_details.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/incident_details.dart)
- **Current Problem**: `_IncidentDetailContentState` uses a custom `RenderProxyBox` (`_MeasureSize`, `lines 62–133`) to measure the right column's `mapAndAddressWidgets` height on every layout frame and call `setState` (`lines 126–133`) to force `_MissionsCard` on the left column to match that exact pixel height.
- **Exact Location**: [`incident_details.dart` lines 62–230](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/dash_board/incident_details.dart#L62-L230).
- **Why It Is a Problem**: Triggers post-frame `setState` layout passes on window resize and creates an artificial inner scrollbar inside `_MissionsCard` even when the page itself is already inside a `SingleChildScrollView` (`line 251`).
- **Recommended Improvement**: Replace the `_MeasureSize` post-frame `setState` hack with a clean, balanced 2-column layout where Row 1 uses `IntrinsicHeight` (or fixed `380px` matched cards for Map & Active Missions) and Row 2 displays Description, Photos, Notes, and Timeline without nested scrollbars.
- **Expected Result**: Eliminates layout jitter on resize and removes nested scroll friction inside `_MissionsCard`.
- **Priority**: `MEDIUM`
- **Effort**: `Medium`

---

## 4. User Management & Registration (`UserManagementScreen` & `RegistrationScreen`)

### Finding 4.1 — Missing "Add New User" CTA in `UserManagementScreen` (Broken Admin Flow)
- **Feature**: User Management & Registration
- **Screen**: `UserManagementScreen` & `RegistrationScreen`
- **Route**: `CrisisDashboard` Tab `2` & `Routes.registration` (`/registration`)
- **Source File**: [`lib/core/future/home/ui/screens/user_management_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/user_management_screen.dart) & [`lib/core/future/home/ui/widgets/user_management/user_header.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/widgets/user_management/user_header.dart)
- **Current Problem**: `UserManagementScreen` displays active users, KPI stats, and filters, and has a refresh callback (`onRefresh`), but **has no primary button to register a new user (`Routes.registration`)**. Meanwhile, `AppDrawer` on Web routes `إدارة المستخدمين` to Tab `2`, making `RegistrationScreen` completely unreachable on Web!
- **Exact Location**: [`user_management_screen.dart` lines 57–70](file:///Users/alimegahed/incidents-management/lib/core/future/home/ui/screens/user_management_screen.dart#L57-L70) (`UserHeader`).
- **Why It Is a Problem**: A core administrative capability (`RegistrationScreen`) exists in the codebase and router but cannot be accessed by Web administrators.
- **Recommended Improvement**:
  1. Add a primary `+ تسجيل مستخدم جديد` (`ElevatedButton.icon`) CTA to `UserHeader` in `UserManagementScreen` that navigates to `Routes.registration` (or opens `RegistrationScreen` as a responsive modal dialog on Web) and refreshes `AllActiveUserCubit` upon return.
  2. In `RegistrationScreen` (`registration.dart`), wrap the form in a clean elevated white surface card (`AppRadius.lg`, `1px` border) to match `AddIncidentTypeWeb` and `AddMissionsWeb`, and enable password visibility toggle (`enableTogglePassword: true`) on line 147.
- **Expected Result**: Restores the end-to-end user creation workflow on Web and automatically refreshes the user table after registration.
- **Priority**: `CRITICAL`
- **Effort**: `Small`

---

## 5. Executive Analytics & Reports (`IncidentReportsScreen`)

### Finding 5.1 — Excessive Above-the-Fold Vertical Chrome & Nested Table Scroll Trap
- **Feature**: Reports & Analytics (Tab `3`)
- **Screen**: `IncidentReportsScreen` & `ReportsDetailedTableView`
- **Route**: `CrisisDashboard` Tab `3` / `Routes.reports` (`/reports`)
- **Source File**: [`lib/core/future/reports/ui/incident_reports_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/reports/ui/incident_reports_screen.dart)
- **Current Problem**:
  1. Above the scrollable report body (`lines 82–100`), `IncidentReportsScreen` stacks `_buildHeader` (`~64px`) + `ReportsFilterBar` (`~110px`) + `ReportsTabBar` (`~52px`) — plus `_DesktopSectionHeader` (`52px`) from `CrisisDashboard` — totaling **`~280px` of fixed chrome**. On a `768px` laptop screen, less than `450px` remains for `ReportsKpiCards` and charts.
  2. In Tab `7` (`ReportsDetailedTableView`, `line 346`), the table is wrapped in a fixed `SizedBox(height: 750)` inside a `SingleChildScrollView` (`line 116`), creating a double vertical scrollbar on desktop.
- **Exact Location**: [`incident_reports_screen.dart` lines 80–131](file:///Users/alimegahed/incidents-management/lib/core/future/reports/ui/incident_reports_screen.dart#L80-L131) and [`lines 344–356`](file:///Users/alimegahed/incidents-management/lib/core/future/reports/ui/incident_reports_screen.dart#L344-L356).
- **Why It Is a Problem**: Analysts must constantly scroll through a small viewport window to see charts, and scrolling the detailed table fights with the outer `SingleChildScrollView`.
- **Recommended Improvement**:
  1. Merge `_buildHeader` and `ReportsTabBar` into a single compact header row, and make `ReportsFilterBar` collapsible (showing active filter chips inline with an `تصفية متقدمة` toggle).
  2. When Tab `7` (`ReportsDetailedTableView`) is active, let the table occupy `Expanded` height directly (or size dynamically to viewport height) without wrapping it in a outer `SingleChildScrollView` + `SizedBox(height: 750)`.
- **Expected Result**: Reclaims `~120px` of vertical chart viewport and eliminates double vertical scrollbars on the Detailed Table tab.
- **Priority**: `HIGH`
- **Effort**: `Medium`

---

## 6. Incident Reporting Forms (`AddIncidentScreen`, `AddIncidentMobileScreen`, `SharedIncidentForm`)

### Finding 6.1 — Generic SnackBar Validation Instead of Inline Field-Level Errors
- **Feature**: Report New Incident
- **Screen**: `AddIncidentScreen` (Web) & `AddIncidentMobileScreen` (Mobile)
- **Route**: `CrisisDashboard` Tab `4` / `Routes.addIncident` / `Routes.addIncidentMobile`
- **Source File**: [`lib/core/future/actions/ui/widgets/incident/shared_incident_form.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/widgets/incident/shared_incident_form.dart)
- **Current Problem**: When an operator clicks submit without selecting `نوع الأزمة`, `درجة الخطورة`, `الفرع`, or entering a description, `SharedIncidentForm` (`lines 211–226`) checks manual conditions and shows a bottom `SnackBar` (`يرجى تعبئة جميع الحقول المطلوبة`) without highlighting the specific missing dropdowns/fields in red.
- **Exact Location**: [`shared_incident_form.dart` lines 205–260](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/widgets/incident/shared_incident_form.dart#L205-L260).
- **Why It Is a Problem**: Under emergency conditions, operators waste seconds hunting through 6+ fields and dynamic sub-fields to figure out which required input was missed.
- **Recommended Improvement**:
  1. Attach `validator:` callbacks to every required `CustomDropdownFormField` and `TextFormField` inside `SharedIncidentForm` so `_formKey.currentState!.validate()` highlights each missing field inline with a specific error message (`اختر نوع الأزمة`, `اختر درجة الخطورة`, `اختر الفرع`).
  2. Add a clear coordinate status pill (`تم تحديد الموقع: 28.0871, 30.7618`) with a 1-click "تحديد موقعي الحالي" button on both Web and Mobile map cards.
- **Expected Result**: Instant, unmistakable inline field validation and faster emergency incident logging.
- **Priority**: `HIGH`
- **Effort**: `Small`

---

## 7. Incident Types & Standard Missions (`AllIncidentType`, `AddIncidentType`, `AllMissions`, `AddMissions`, `EditMissions`)

### Finding 7.1 — Missing Top Back Button on `AddIncidentTypeWeb` and `AddMissionsWeb`
- **Feature**: Crisis Classifications & Missions Configuration
- **Screen**: `AddIncidentTypeWeb` & `AddMissionsWeb`
- **Route**: `Routes.addIncidentType` (`/add_incident_type`) & `Routes.addMissions` (`/add_missions`)
- **Source File**: [`lib/core/future/actions/ui/screens/incident.dart/add_incident_type_web.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/incident.dart/add_incident_type_web.dart) & [`lib/core/future/actions/ui/screens/missions/add_missions_web.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/add_missions_web.dart)
- **Current Problem**: Both screens are pushed via `Navigator.pushNamed` on top of `CrisisDashboard` (covering the sidebar), yet their top header bars (`_buildTopBar`, `lines 65–123` in `add_incident_type_web.dart` and `lines 70–131` in `add_missions_web.dart`) only render static text breadcrumbs (`إدارة الأزمات > أنواع الأزمات > إضافة نوع جديد`) with **no clickable Back button** in the top bar.
- **Exact Location**: [`add_incident_type_web.dart` lines 65–123](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/incident.dart/add_incident_type_web.dart#L65-L123) and [`add_missions_web.dart` lines 70–131](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/add_missions_web.dart#L70-L131).
- **Why It Is a Problem**: Violates Fitts's Law and user expectations when a full-screen route covers the main navigation shell; users look to the top-right (in RTL) to go back.
- **Recommended Improvement**: Add an explicit `IconButton` / outlined button (`Icons.arrow_forward_rounded` / `العودة للقائمة`) in `_buildTopBar` and make parent breadcrumb segments clickable (`Navigator.pop(context)`).
- **Expected Result**: Consistent, intuitive top-bar back navigation across all Web sub-routes.
- **Priority**: `MEDIUM`
- **Effort**: `Small`

---

### Finding 7.2 — `EditMissions` Lacks Web Layout Constraint & Has a Double-Pop Navigation Bug
- **Feature**: Standard Missions Management
- **Screen**: `EditMissions`
- **Route**: `Routes.editMissions` (`/edit_missions`)
- **Source File**: [`lib/core/future/actions/ui/screens/missions/edit_missions.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/edit_missions.dart)
- **Current Problem**:
  1. Unlike `AddMissions` (which has `AddMissionsWeb` and `AddMissionsMobile`), `EditMissions` only has a single mobile layout (`_buildHeaderBanner` + unconstrained `Container`) that stretches `100%` wide across `1920px` desktop monitors when opened from `AllMissionsWeb`!
  2. On save success (`lines 40–48`), `SuccessDialog.show` is passed `onPressed: () { context.pop(); Navigator.pop(context, true); }`. Because `SuccessDialog` (`gloable_widget.dart` line 231) *already* calls `Navigator.of(dialogContext).pop()` before invoking `onPressed`, calling both `context.pop()` and `Navigator.pop(context, true)` pops **three** times — closing the dialog, closing `EditMissions`, AND popping `CrisisDashboard`!
  3. The save button (`lines 162–194`) does not show a loading indicator during submission.
- **Exact Location**: [`edit_missions.dart` lines 40–48](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/edit_missions.dart#L40-L48) and [`lines 68–198`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/edit_missions.dart#L68-L198).
- **Why It Is a Problem**: Editing a mission on Web looks broken (full-bleed mobile banner on desktop) and clicking "موافق" after saving can accidentally pop the user out of the entire dashboard!
- **Recommended Improvement**:
  1. Fix the `SuccessDialog` callback to only call `Navigator.pop(context, true)` once (since `SuccessDialog` already pops itself).
  2. Add responsive Web styling to `EditMissions` matching `AddMissionsWeb` (centered `ConstrainedBox(maxWidth: 720)` or 8:4 split card with top breadcrumb bar on `width >= 900`, and inline button loading state).
- **Expected Result**: Prevents accidental root route popping and delivers a cohesive desktop/mobile editing experience.
- **Priority**: `CRITICAL`
- **Effort**: `Small`

---

## 8. Link Missions to Incident Type (`Addincidentmission`)

### Finding 8.1 — Triple Stacked Headers on Web & Unclosed Raw Loading Dialog on Error
- **Feature**: Link Missions to Incident Type (Tab `7`)
- **Screen**: `Addincidentmission`
- **Route**: `CrisisDashboard` Tab `7` / `Routes.addIncidentMission` (`/add_incident_mission`)
- **Source File**: [`lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart)
- **Current Problem**:
  1. When opened as Tab `7` inside `CrisisDashboard`, the user sees: (1) `_DesktopSectionHeader` (`ربط المهام بالأزمات`), (2) `_buildTopBanner` (`header_banner.jpg` dark navy mobile banner with a non-functional back arrow that pops `CrisisDashboard` if clicked!), and (3) `LinkMissionsHeader` (`ربط المهام بالأزمة`) — **three headers stacked on top of each other**!
  2. In the `BlocConsumer` listener (`lines 123–149`), `loading:` opens a blocking `showDialog(builder: (_) => const Center(child: CircularProgressIndicator()))`, and `success:` calls `Navigator.of(context, rootNavigator: true).pop()`, **but `error:` (`lines 142–148`) does NOT pop the loading dialog before showing `ErrorDialog.show`**, leaving a stuck spinner dialog behind the error modal!
- **Exact Location**: [`relation_incident_mission.dart` lines 123–149](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart#L123-L149) and [`lines 172–275`](file:///Users/alimegahed/incidents-management/lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart#L172-L275).
- **Why It Is a Problem**: Clicking the back button inside `_buildTopBanner` while in Tab `7` pops the root route; if an API error occurs during mission linking, the loading spinner remains stuck on screen; and the triple header wastes `260px` of vertical height.
- **Recommended Improvement**:
  1. Hide `_buildTopBanner` when `Addincidentmission` is embedded inside `CrisisDashboard` (or when `width >= 900` and `!Navigator.canPop(context)`), relying cleanly on `LinkMissionsHeader`.
  2. Remove the raw `showDialog` spinner in `loading:` and pass `isSubmitting: state is AddIncidentMissionLoading` directly to `SaveConfigurationBar` so the submit button renders an inline spinner cleanly.
- **Expected Result**: Eliminates the stuck modal bug, prevents accidental root route pops from Tab `7`, and reclaims `140px` of vertical height for the dual-pane mission configurator.
- **Priority**: `CRITICAL`
- **Effort**: `Small`

---

## 9. GIS, Valve & Fleet Maps (`GisMapScreen`, `WebValveMapScreen`, `MapScreen`, `EtitFleetMapScreen`, `FleetDashboardScreen`)

### Finding 9.1 — `GisMapScreen` Missing Back Button on Mobile & Double Header on Web
- **Feature**: GIS Network Layers Map
- **Screen**: `GisMapScreen`
- **Route**: `CrisisDashboard` Tab `9` / `Routes.gisMap` (`/gis_map`)
- **Source File**: [`lib/core/future/gis/ui/gis_map_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/gis/ui/gis_map_screen.dart)
- **Current Problem**:
  1. `GisMapScreen` uses `endDrawer: const GisLayerControlDrawer()` (`line 271`) AND `actions: [...]` (`lines 287–313`). In Flutter, when a `Scaffold` has an `endDrawer`, it automatically injects a trailing drawer icon unless `actions` overrides it, and when pushed from `MobileMoreServicesScreen` (`Routes.gisMap`), the `AppBar` has no explicit consistent back button matching `MapScreen` (`lines 145–160`).
  2. When rendered inside `CrisisDashboard` Tab `9`, `GisMapScreen` renders its dark blue `AppBar` (`height: 56`) directly below `_DesktopSectionHeader`, creating a double header.
  3. On Web, opening the layer list requires clicking a small icon in the top bar to slide out a temporary `endDrawer` instead of offering a dockable floating layer card like `WebValveControlPanel`.
- **Exact Location**: [`gis_map_screen.dart` lines 269–315](file:///Users/alimegahed/incidents-management/lib/core/future/gis/ui/gis_map_screen.dart#L269-L315).
- **Why It Is a Problem**: Inconsistent header chrome on Web and less discoverable layer controls for GIS operators.
- **Recommended Improvement**:
  1. When `GisMapScreen` is embedded in `CrisisDashboard` (`!Navigator.of(context).canPop()` and `onAssetSelected == null`), replace the dark blue `AppBar` with a floating glassmorphic map HUD toolbar (OSM underlay toggle, active layer count pill, Layer Panel toggle, Refresh button).
  2. When pushed as a standalone route (`Navigator.of(context).canPop()` or `onAssetSelected != null`), display a clear back/close button in the header and a prominent floating banner (`اضغط على أي عنصر في الخريطة لإرفاقه بالبلاغ`) when in asset-picker mode.
- **Expected Result**: Full-bleed GIS canvas on Web and crystal-clear asset picking UX when launched from `SharedIncidentForm`.
- **Priority**: `HIGH`
- **Effort**: `Medium`

---

### Finding 9.2 — `FleetDashboardScreen` & `FleetMapScreen` Redundant Top Bar Inside `CrisisDashboard`
- **Feature**: ETIT GPS Fleet Management (Tabs `10` & `11`)
- **Screen**: `FleetDashboardScreen` & `FleetMapScreen`
- **Route**: `CrisisDashboard` Tabs `10` & `11` / `Routes.etitFleetMap` / `Routes.etitVehicles`
- **Source File**: [`lib/features/fleet/presentation/screens/fleet_dashboard_screen.dart`](file:///Users/alimegahed/incidents-management/lib/features/fleet/presentation/screens/fleet_dashboard_screen.dart) & [`lib/features/fleet/presentation/screens/fleet_map_screen.dart`](file:///Users/alimegahed/incidents-management/lib/features/fleet/presentation/screens/fleet_map_screen.dart)
- **Current Problem**: When switching from `FleetDashboardScreen` (Tab `11`) to the live map via the `الخريطة المباشرة` button (`fleet_dashboard_screen.dart` lines 78–92), it pushes `FleetMapScreen` as a new full-screen `MaterialPageRoute` on top of `CrisisDashboard` (hiding the `AppDrawer` sidebar) rather than switching to Tab `10` (or providing a back button in `FleetMapScreen` when pushed as a route!).
- **Exact Location**: [`fleet_dashboard_screen.dart` lines 78–92](file:///Users/alimegahed/incidents-management/lib/features/fleet/presentation/screens/fleet_dashboard_screen.dart#L78-L92) and [`fleet_map_screen.dart` lines 107–148](file:///Users/alimegahed/incidents-management/lib/features/fleet/presentation/screens/fleet_map_screen.dart#L107-L148).
- **Why It Is a Problem**: When a user clicks `الخريطة المباشرة` or `عرض على الخريطة` from `FleetDashboardScreen` (or opens `Routes.etitFleetMap` from `MobileMoreServicesScreen` on Mobile!), `FleetMapScreen` is pushed onto the `Navigator`, **but `FleetMapFilterToolbar` has no Back button (`Navigator.pop`)** — trapping mobile users and desktop route-pushed users on the map unless they use browser/OS back gestures!
- **Recommended Improvement**:
  1. Add a conditional Back button (`if (Navigator.of(context).canPop())`) inside `FleetMapFilterToolbar` (and `FleetTopHeaderBar`) so users who push `FleetMapScreen` or `FleetDashboardScreen` from Mobile (`MobileMoreServicesScreen`) or from "عرض على الخريطة" always have a visible 1-click Back button.
- **Expected Result**: Eliminates navigation dead-ends when entering Fleet Map or Fleet List from Mobile or via "عرض على الخريطة".
- **Priority**: `CRITICAL`
- **Effort**: `Small`

---

## 10. Mobile Experience (`MobileIncidentsListScreen`, `MobileIncidentDetailsScreen`, `MobileMoreServicesScreen`, `FileUploadScreen`)

### Finding 10.1 — Excessive Vertical Scrolling & Monolithic Layout in `MobileIncidentDetailsScreen`
- **Feature**: Mobile Incident Command & Field Updates
- **Screen**: `MobileIncidentDetailsScreen`
- **Route**: Pushed from `MobileIncidentsListScreen`
- **Source File**: [`lib/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart)
- **Current Problem**: `MobileIncidentDetailsScreen` (`3,541` lines) stacks 7 full sections vertically in one continuous scroll: Hero Banner -> Overview Status Card -> 2x3 Details Grid -> Map Card -> Notes Card -> Missions List -> Timeline History -> Photo Gallery. Field technicians must scroll past 5 cards just to reach Missions or upload a field photo.
- **Exact Location**: [`mobile_incident_details_screen.dart` lines 195–310](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart#L195-L310).
- **Why It Is a Problem**: High cognitive load and slow task completion for field crews holding a phone in one hand at an incident site.
- **Recommended Improvement**:
  1. Keep the Hero Header + Sticky Quick-Action Strip (`تحديث الحالة` | `تعيين مهام` | `إضافة صورة`) at the top.
  2. Introduce a clean 3-tab segmented control below the overview card:
     - **Tab 1: `نظرة عامة والموقع`** (Metadata grid, Description, Notes, Interactive Map & Google Maps CTA)
     - **Tab 2: `المهام والتدخل (N)`** (Assigned missions list, 1-tap mission status update, Assign Missions CTA)
     - **Tab 3: `الصور والسجل الزمني`** (Field photo gallery + upload CTA, chronological status timeline)
- **Expected Result**: Reduces vertical scrolling by `65%` and puts Missions and Photos 1 tap away from the top of the screen.
- **Priority**: `HIGH`
- **Effort**: `Medium`

---

### Finding 10.2 — Missing Reports & User Administration Access on `MobileMoreServicesScreen`
- **Feature**: Mobile Navigation & Services Directory
- **Screen**: `MobileMoreServicesScreen` & `MobileIncidentsListScreen`
- **Route**: `Routes.mobileMoreServices` (`/mobile_more_services`)
- **Source File**: [`lib/core/future/mobile/ui/screens/more_services/more_services_screen.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/more_services/more_services_screen.dart)
- **Current Problem**:
  1. `MobileMoreServicesScreen` does not include tiles for `التقارير والإحصائيات` (`Routes.reports`) or `تسجيل مستخدم جديد` (`Routes.registration`), even though both screens support mobile viewports.
  2. In `MobileIncidentsListScreen` (`home.dart` lines 257–360), tapping Bottom Nav items `أنواع الأزمات`, `المهام`, or `المزيد` pushes new full-screen routes via `context.pushNamed(...)` rather than switching tabs or keeping the bottom navigation bar visible, which can confuse users expecting persistent bottom tabs.
- **Exact Location**: [`more_services_screen.dart` lines 103–210](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/more_services/more_services_screen.dart#L103-L210) and [`mobile/ui/screens/home/home.dart` lines 275–365](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/home/home.dart#L275-L365).
- **Why It Is a Problem**: Executives using the mobile app cannot view `IncidentReportsScreen`, and admins on mobile cannot access `RegistrationScreen`.
- **Recommended Improvement**: Add `التقارير والإحصائيات التنفيذية` (`Routes.reports`) and `تسجيل مستخدم جديد` (`Routes.registration`) service tiles to `MobileMoreServicesScreen`.
- **Expected Result**: 100% feature parity between Web and Mobile navigation directories.
- **Priority**: `HIGH`
- **Effort**: `Small`

---

### Finding 10.3 — `FileUploadScreen` Unconstrained Width on Web/Tablet
- **Feature**: Field Photo Upload & Documentation
- **Screen**: `FileUploadScreen`
- **Route**: `Routes.addImageScreen` (`/add_Image_Screen`)
- **Source File**: [`lib/core/future/mobile/ui/screens/add_photo/add_image.dart`](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/add_photo/add_image.dart)
- **Current Problem**: When opened from `IncidentPhotosGrid` on Web (`IncidentDetailsPanel`), `FileUploadScreen` renders a full-bleed mobile banner and stretches its upload cards across the entire desktop monitor without a `ConstrainedBox`.
- **Exact Location**: [`add_image.dart` lines 90–104](file:///Users/alimegahed/incidents-management/lib/core/future/mobile/ui/screens/add_photo/add_image.dart#L90-L104).
- **Why It Is a Problem**: Looks unpolished and disproportionate on desktop screens.
- **Recommended Improvement**: Wrap `_buildMainContent` in `Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), ...))` on wide viewports.
- **Expected Result**: Clean, well-proportioned photo upload layout across Mobile, Tablet, and Web.
- **Priority**: `LOW`
- **Effort**: `Small`
