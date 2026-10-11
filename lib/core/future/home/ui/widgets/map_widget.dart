// ============================================================================
// OPTIMIZED MAP SCREEN - Arabic UI with Cubit & WebSocket Real-time Updates
// NOW WITH MISSION MANAGEMENT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_filters_panel.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_incidents_list_panel.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_incident_details_modal.dart';
import 'package:incidents_managment/core/future/home/logic/map_filter_cubit.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/dashboard_kpi_strip.dart';
import 'package:latlong2/latlong.dart';

class IncidentsMapScreen extends StatefulWidget {
  const IncidentsMapScreen({super.key});

  @override
  State<IncidentsMapScreen> createState() => _IncidentsMapScreenState();
}

class _IncidentsMapScreenState extends State<IncidentsMapScreen> {
  final MapController _mapController = MapController();
  final ValueNotifier<String> _filterNotifier = ValueNotifier<String>('الكل');
  List<CurrentIncidentModel> _cachedIncidents = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final cubit = context.read<IncidentMapCubit>();
        if (!cubit.isConnected) {
          cubit.initialize();
        } else if (cubit.state is IncidentMapInitial || cubit.state is IncidentMapError || cubit.incidents.isEmpty) {
          cubit.refresh();
        }
      }
    });
  }

  @override
  void dispose() {
    _filterNotifier.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapFilterCubit(),
      child: BlocBuilder<IncidentMapCubit, IncidentMapState>(
        builder: (context, state) {
          final currentIncidents = state is IncidentMapLoaded
              ? state.incidents
              : _cachedIncidents;

          if (state is IncidentMapLoaded) {
            _cachedIncidents = state.incidents;
          }

          if (state is IncidentMapError && _cachedIncidents.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'إعادة المحاولة',
                    textColor: Colors.white,
                    onPressed: () => context.read<IncidentMapCubit>().refresh(),
                  ),
                ),
              );
            });
          }

          return Column(
            children: [
              DashboardKpiStrip(
                incidents: currentIncidents,
                connected: state is! IncidentMapError && state is! IncidentMapInitial,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Builder(
                    builder: (context) {
                      return _buildMapContent(state, currentIncidents);
                    }
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapContent(
    IncidentMapState state,
    List<CurrentIncidentModel> incidents,
  ) {
    return BlocConsumer<MapFilterCubit, MapFilterState>(
      listener: (context, filterState) {
        final filteredIncidents = context.read<MapFilterCubit>().filterIncidents(incidents);
        if (filteredIncidents.isNotEmpty) {
          _fitMapToBounds(filteredIncidents);
        }
      },
      builder: (context, filterState) {
        final filteredIncidents = context.read<MapFilterCubit>().filterIncidents(incidents);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MapFiltersPanel(
              rawIncidents: incidents,
              filteredCount: filteredIncidents.length,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildMap(filteredIncidents, state),
              ),
            ),
            const SizedBox(width: 16),
            MapIncidentsListPanel(
              filteredIncidents: filteredIncidents,
              onIncidentTap: (incident) {
                final lat = incident.currentIncidentXAxis;
                final lng = incident.currentIncidentYAxis;
                if (lat != null && lng != null) {
                  _mapController.move(LatLng(lat, lng), 17);
                }
                showDialog(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (_) => MapIncidentDetailsModal(
                    incident: incident,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _fitMapToBounds(List<CurrentIncidentModel> incidents) {
    final validPoints = incidents
        .where((inc) => inc.currentIncidentXAxis != null && inc.currentIncidentYAxis != null)
        .map((inc) => LatLng(inc.currentIncidentXAxis!, inc.currentIncidentYAxis!))
        .toList();

    if (validPoints.isEmpty) return;

    if (validPoints.length == 1) {
      _mapController.move(validPoints.first, 15);
    } else {
      final bounds = LatLngBounds.fromPoints(validPoints);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    }
  }

  Widget _buildInitialState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'جاري الاتصال بالخادم...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'جاري تحميل الخريطة...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<IncidentMapCubit>().refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B6CB0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader(
    int totalIncidents,
    bool isLoading,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.map, color: Color(0xFF1B4F8A), size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خريطة الأزمات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F8A),
                      ),
                    ),
                    Text(
                      'عرض جميع الأزمات على الخريطة',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              _buildIncidentCounter(totalIncidents, isLoading),
              const SizedBox(width: 8),
              _buildConnectionIndicator(context),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<String>(
        valueListenable: _filterNotifier,
        builder: (context, value, child) => _buildFilterChips(),
      ),
        ],
      ),
    );
  }

  Widget _buildConnectionIndicator(BuildContext context) {
    final isConnected = context.read<IncidentMapCubit>().isConnected;

    return Tooltip(
      message: isConnected ? 'متصل' : 'غير متصل',
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isConnected
              ? Colors.green.withAlpha(26)
              : Colors.red.withAlpha(26),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isConnected ? Icons.wifi : Icons.wifi_off,
          color: isConnected ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildIncidentCounter(int count, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2B6CB0).withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2B6CB0).withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF2B6CB0)),
              ),
            )
          else
            const Icon(Icons.location_on, color: Color(0xFF2B6CB0), size: 20),
          const SizedBox(width: 8),
          Text(
            '$count أزمة',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B6CB0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['الكل', 'حرجة', 'عالية', 'متوسطة', 'منخفضة'];

    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        final isSelected = _filterNotifier.value == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) {
            _filterNotifier.value = filter;
          },
          backgroundColor: Colors.grey[200],
          selectedColor: const Color(0xFF2B6CB0),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          avatar: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildMap(List<CurrentIncidentModel> filteredIncidents, IncidentMapState state) {
    final markers = _buildMarkers(filteredIncidents);

    return Stack(
      children: [
        RepaintBoundary(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(28.0871, 30.7618),
              initialZoom: 10,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.crisis_management',
              ),
              if (markers.isNotEmpty) MarkerLayer(markers: markers),
            ],
          ),
        ),
        if (state is IncidentMapInitial || state is IncidentMapLoading)
          Container(
            color: Colors.white.withValues(alpha: 0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (state is IncidentMapError && filteredIncidents.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<IncidentMapCubit>().refresh(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          )
        else if (filteredIncidents.isEmpty)
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list_off,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد أزمات بهذا التصنيف',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        _buildMapControls(),
        _buildLegend(),
      ],
    );
  }

  List<Marker> _buildMarkers(List<CurrentIncidentModel> incidents) {
    return incidents
        .where(
          (incident) =>
              incident.currentIncidentXAxis != null &&
              incident.currentIncidentYAxis != null,
        )
        .map((incident) {
          final lat = incident.currentIncidentXAxis!;
          final lng = incident.currentIncidentYAxis!;
          final severity = incident.currentIncidentSeverity ?? 1;
          final status = incident.currentIncidentStatus ?? 1;

          return Marker(
            point: LatLng(lat, lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () {
                _mapController.move(LatLng(lat, lng), 17);
                showDialog(
                  context: context,
                  barrierColor: Colors.black54,
                  builder: (_) => MapIncidentDetailsModal(
                    incident: incident,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                );
              },
              child: _buildMarkerWidget(severity, status),
            ),
          );
        })
        .toList();
  }

  Widget _buildMarkerWidget(int severity, int status) {
    final color = _getSeverityColor(severity);
    final isResolved = status == 6;

    return Stack(
      children: [
        if (!isResolved)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(77),
            ),
          ),
        Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: color.withAlpha(128),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              size: 32,
              color: isResolved ? Colors.green : color,
            ),
          ),
        ),
        if (isResolved)
          const Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 8,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white, size: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        children: [
          _buildControlButton(
            Icons.add,
            'تكبير',
            () => _mapController.move(
              _mapController.camera.center,
              (_mapController.camera.zoom + 1).clamp(3.0, 18.0),
            ),
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.remove,
            'تصغير',
            () => _mapController.move(
              _mapController.camera.center,
              (_mapController.camera.zoom - 1).clamp(3.0, 18.0),
            ),
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.my_location,
            'موقعي',
            () => _mapController.move(const LatLng(28.0871, 30.7618), 12),
          ),
          const SizedBox(height: 8),
          // _buildControlButton(
          //   Icons.refresh,
          //   'تحديث',
          //     () => context.read<IncidentMapCubit>().refresh(),
          // ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF2B6CB0)),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'درجة الخطورة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _buildLegendItem('حرجة', Colors.red),
            _buildLegendItem('عالية', Colors.orange),
            _buildLegendItem('متوسطة', const Color(0xFFFFC107)),
            _buildLegendItem('منخفضة', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }



  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 4:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 2:
        return const Color(0xFFFFC107);
      case 1:
      default:
        return Colors.green;
    }
  }
}

// ============================================================================
// INCIDENT DETAILS PANEL WITH MISSION MANAGEMENT
