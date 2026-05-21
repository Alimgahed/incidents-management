import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/states/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/states/update_statues.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/dashboard_kpi_strip.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_details.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incient_list.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';

/// Routes inside the home dashboard tab (not the app root navigator).
abstract final class DashboardRoutes {
  static const list = '/';
  static const details = '/details';
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardCubit _dashboardCubit;
  final _navKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      getIt<IncidentPickerBridge>().register(
        onSelect: _dashboardCubit.selectIncident,
        onOpenDetails: _openIncidentDetails,
      );
      context.read<IncidentMapCubit>().initialize();
    });
  }

  @override
  void dispose() {
    getIt<IncidentPickerBridge>().unregister();
    _dashboardCubit.close();
    super.dispose();
  }

  void _openIncidentDetails() {
    final nav = _navKey.currentState;
    if (nav == null) return;
    if (nav.canPop()) return;
    nav.pushNamed(DashboardRoutes.details);
  }

  void _onIncidentTap(CurrentIncidentModel incident) {
    _navKey.currentState?.pushNamed(DashboardRoutes.details);
  }

  void _backToIncidentList() {
    _dashboardCubit.deselectIncident();
    final nav = _navKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _dashboardCubit),
        BlocProvider(
          create: (context) =>
              EditIncidentCubit(editIncidentRepo: getIt<EditIncidentRepo>()),
        ),
        BlocProvider(
          create: (context) =>
              UpdateStatuesCubit(updateStatuesRepo: getIt<UpdateStatuesRepo>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (_, state) =>
                state.maybeWhen(error: (_) => true, orElse: () => false),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message)),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<EditIncidentCubit, EditIncidentStates>(
            listenWhen: (previous, current) => current.maybeWhen(
              error: (_) => true,
              success: () => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message.error ?? '')),
                        ],
                      ),
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(child: Text('تم تحديث الأزمة بنجاح')),
                        ],
                      ),
                    ),
                  );
                  // Refresh incidents list to sync with latest changes
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (context.mounted) {
                      context.read<IncidentMapCubit>().refresh();
                    }
                  });
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<UpdateStatuesCubit, UpdateStatuesStates>(
            listenWhen: (previous, current) => current.maybeWhen(
              error: (_) => true,
              success: () => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message.error ?? '')),
                        ],
                      ),
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(child: Text('تم تحديث المهمة بنجاح')),
                        ],
                      ),
                    ),
                  );
                  // WebSocket will handle the update via mission_updated event
                  // No manual refresh needed
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<IncidentMapCubit, IncidentMapState>(
            listenWhen: (_, state) => state is IncidentMapLoaded,
            listener: (context, state) {
              if (state is IncidentMapLoaded) {
                final dashboardCubit = context.read<DashboardCubit>();
                final selectedIncidentId = dashboardCubit.selectedIncident?.currentIncidentId;

                // Sync all incidents
                dashboardCubit.syncWithIncidents(state.incidents);

                // Auto-select the first incident on desktop when nothing is selected yet
                if (selectedIncidentId == null && state.incidents.isNotEmpty) {
                  final isMobile = MediaQuery.sizeOf(context).width <= 768;
                  if (!isMobile) {
                    dashboardCubit.selectIncident(state.incidents.first);
                  }
                }

                // Also make sure selected incident is updated if it exists
                if (selectedIncidentId != null) {
                  try {
                    final updatedIncident = state.incidents.firstWhere(
                      (i) => i.currentIncidentId == selectedIncidentId,
                    );
                    dashboardCubit.syncSelectedIncident(updatedIncident);
                  } catch (_) {
                    // Incident not found, that's ok
                  }
                }
              }
            },
          ),
        ],
        child: Navigator(
          key: _navKey,
          initialRoute: DashboardRoutes.list,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case DashboardRoutes.details:
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, result) {
                      if (!didPop) _backToIncidentList();
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: IncidentDetailsPanel(
                          showBackToList: true,
                          onBackToList: _backToIncidentList,
                          contentPadding: const EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              case DashboardRoutes.list:
              default:
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (context) => _DashboardIncidentsScreen(
                    onIncidentTap: _onIncidentTap,
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}

/// Incident grid — first screen inside the home dashboard tab.
class _DashboardIncidentsScreen extends StatelessWidget {
  const _DashboardIncidentsScreen({required this.onIncidentTap});

  final void Function(CurrentIncidentModel incident) onIncidentTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentMapCubit, IncidentMapState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is IncidentMapLoaded,
      builder: (context, mapState) {
        final allIncidents = mapState is IncidentMapLoaded
            ? mapState.incidents
            : <CurrentIncidentModel>[];
        final connected = context.read<IncidentMapCubit>().isConnected;
        final isMobile = MediaQuery.sizeOf(context).width <= 768;

        // Mobile: Stack-based navigation
        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: DashboardKpiStrip(
                  incidents: allIncidents,
                  connected: connected,
                  compact: true,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  child: IncidentsList(
                    allIncidents: allIncidents,
                    useWebGrid: false,
                    onIncidentTap: onIncidentTap,
                  ),
                ),
              ),
            ],
          );
        }

        // Desktop: Two-panel layout (List + Details side by side)
        return Row(
          children: [
            // LEFT PANEL: Incident List
            Expanded(
              flex: 35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: DashboardKpiStrip(
                      incidents: allIncidents,
                      connected: connected,
                      compact: true,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: IncidentsList(
                        allIncidents: allIncidents,
                        useWebGrid: false,
                        onIncidentTap: onIncidentTap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // RIGHT PANEL: Incident Details
            Expanded(
              flex: 65,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: IncidentDetailsPanel(
                      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
