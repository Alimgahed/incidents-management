# Responsive Design & Multi-Platform UX Report (Mobile, Tablet, Web)

## 1. Responsive Breakpoint System

Centralized in `AppBreakpoints` (`lib/core/design_system/app_design_system.dart`) and `FleetResponsive` (`lib/features/fleet/core/theme/fleet_theme.dart`):

| Viewport Tier | Width Range | Layout Pattern |
|---|---|---|
| **Mobile** | `<= 767px` | Single-column scrollable layout, bottom-sheet filters/lists on map screens, drawer navigation, card-based lists instead of wide tables. |
| **Tablet** | `768px – 1199px` | 2–3 column adaptive grids, collapsible side panels / modal sheets on map screens, stacked chart rows on analytics screens. |
| **Desktop / Web** | `>= 1200px` | Persistent sidebar navigation, 3-column split-view map workspaces (Filters + Map + List), 6-column KPI strips, multi-chart executive rows, and full enterprise data tables. |

---

## 2. Screen-by-Screen Responsive Enhancements

1. **`IncidentsMapScreen` (`lib/core/future/home/ui/widgets/map_widget.dart`)**:
   - **Desktop (`>= 1024px`)**: 3-column split workspace (`MapFiltersPanel` + `FlutterMap` + `MapIncidentsListPanel`).
   - **Mobile / Tablet (`< 1024px`)**: Full-bleed interactive map with floating action buttons (`الفلاتر` and `الأزمات (N)`) that open `MapFiltersPanel` and `MapIncidentsListPanel` inside modal bottom sheets (`FractionallySizedBox(heightFactor: 0.8)`), eliminating horizontal overflow.
2. **`WebValveMapScreen` (`lib/core/future/valve/ui/web_valve_map_screen.dart`)**:
   - **Desktop (`>= 1024px`)**: 3-column split workspace (`ValveFiltersPanel` + `FlutterMap` + `ValveListPanel`).
   - **Mobile / Tablet (`< 1024px`)**: Full-bleed map with floating buttons (`فلاتر المحابس` and `المحابس (N)`) opening modal bottom sheets.
3. **`IncidentReportsScreen` (`lib/core/future/reports/ui/incident_reports_screen.dart`)**:
   - **Desktop (`>= 960px`)**: Multi-card horizontal chart rows (`Row` with `Expanded` flex ratios).
   - **Mobile / Tablet (`< 960px`)**: Automatically stacks chart cards vertically with dedicated heights (`290px–310px`) so charts remain legible without horizontal cramping.
4. **`EtitVehiclesListScreen` & `EtitFleetMapScreen`**:
   - Automatically switches between enterprise data table (`>= 900px`) and mobile vehicle cards (`< 900px`), and adapts the fleet map panel into a slide-over drawer on narrow viewports.
5. **RTL & Arabic Typography Consistency**:
   - All screens enforce `TextDirection.rtl` with consistent `Cairo` typography tokens (`AppTextStyles`) and directional padding (`EdgeInsetsDirectional`).
