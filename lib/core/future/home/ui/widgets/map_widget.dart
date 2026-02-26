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
import 'package:latlong2/latlong.dart';

class IncidentsMapScreen extends StatefulWidget {
  const IncidentsMapScreen({super.key});

  @override
  State<IncidentsMapScreen> createState() => _IncidentsMapScreenState();
}

class _IncidentsMapScreenState extends State<IncidentsMapScreen> {
  final MapController _mapController = MapController();
  String _selectedFilter = 'الكل';
  List<CurrentIncidentModel> _cachedIncidents = [];

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentMapCubit, IncidentMapState>(
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
            _buildMapHeader(
              currentIncidents.length,
              state is IncidentMapLoading,
              context,
            ),
            Expanded(child: _buildMapContent(state, currentIncidents)),
          ],
        );
      },
    );
  }

  Widget _buildMapContent(
    IncidentMapState state,
    List<CurrentIncidentModel> incidents,
  ) {
    if (state is IncidentMapInitial) {
      return _buildInitialState();
    }

    if (state is IncidentMapLoading && incidents.isEmpty) {
      return _buildLoadingState();
    }

    if (state is IncidentMapError && incidents.isEmpty) {
      return _buildErrorState(state.message);
    }

    return _buildMap(incidents);
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
              backgroundColor: const Color(0xFF2C5F8D),
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
              const Icon(Icons.map, color: Color(0xFF1E3A5F), size: 28),
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
                        color: Color(0xFF1E3A5F),
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
          _buildFilterChips(),
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
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
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
        color: const Color(0xFF2C5F8D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2C5F8D).withOpacity(0.3)),
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
                valueColor: AlwaysStoppedAnimation(Color(0xFF2C5F8D)),
              ),
            )
          else
            const Icon(Icons.location_on, color: Color(0xFF2C5F8D), size: 20),
          const SizedBox(width: 8),
          Text(
            '$count أزمة',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C5F8D),
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
        final isSelected = _selectedFilter == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) {
            setState(() => _selectedFilter = filter);
          },
          backgroundColor: Colors.grey[200],
          selectedColor: const Color(0xFF2C5F8D),
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

  Widget _buildMap(List<CurrentIncidentModel> incidents) {
    final filteredIncidents = _getFilteredIncidents(incidents);
    final markers = _buildMarkers(filteredIncidents);

    return Stack(
      children: [
        FlutterMap(
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
        if (filteredIncidents.isEmpty)
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

  List<CurrentIncidentModel> _getFilteredIncidents(
    List<CurrentIncidentModel> incidents,
  ) {
    if (_selectedFilter == 'الكل') {
      return incidents;
    }

    const severityMap = {'حرجة': 4, 'عالية': 3, 'متوسطة': 2, 'منخفضة': 1};
    final targetSeverity = severityMap[_selectedFilter];

    return incidents
        .where((i) => i.currentIncidentSeverity == targetSeverity)
        .toList();
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
                _showEnhancedIncidentDetails(incident);
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
              color: color.withOpacity(0.3),
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
                  color: color.withOpacity(0.5),
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
            child: Icon(icon, color: const Color(0xFF2C5F8D)),
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
            _buildLegendItem('متوسطة', Colors.yellow[700]!),
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

  void _showEnhancedIncidentDetails(CurrentIncidentModel incident) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => _IncidentDetailsPanel(
        incident: incident,
        onZoomToLocation: (lat, lng) {
          Navigator.of(context).pop();
          _mapController.move(LatLng(lat, lng), 18);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('تم الانتقال إلى موقع الحادثة على الخريطة'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
        onMissionStatusChanged: (missionId, newStatus) async {
          // // Send update to backend via Socket.IO
          // context.read<IncidentMapCubit>().updateMissionStatus(
          //   incidentId: incident.currentIncidentId!,
          //   missionId: missionId,
          //   newStatus: newStatus,
          // );
        },
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
        return Colors.yellow[700]!;
      case 1:
      default:
        return Colors.green;
    }
  }
}

// ============================================================================
// INCIDENT DETAILS PANEL WITH MISSION MANAGEMENT
// ============================================================================
class _IncidentDetailsPanel extends StatefulWidget {
  final CurrentIncidentModel incident;
  final Function(double lat, double lng) onZoomToLocation;
  final Function(int missionId, int newStatus) onMissionStatusChanged;

  const _IncidentDetailsPanel({
    required this.incident,
    required this.onZoomToLocation,
    required this.onMissionStatusChanged,
  });

  @override
  State<_IncidentDetailsPanel> createState() => _IncidentDetailsPanelState();
}

class _IncidentDetailsPanelState extends State<_IncidentDetailsPanel> {
  late List<CurrentIncidentWithMissions> _missions;
  final bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _missions = widget.incident.currentIncidentWithMissions ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 450,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(-5, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildIncidentHeader(),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildDetailSection(
                        'الوصف',
                        Icons.description,
                        widget.incident.currentIncidentDescription ??
                            'لا يوجد وصف',
                      ),
                      const SizedBox(height: 16),
                      if (widget.incident.currentIncidentXAxis != null &&
                          widget.incident.currentIncidentYAxis != null) ...[
                        _buildLocationSection(),
                        const SizedBox(height: 16),
                      ],
                      // MISSIONS SECTION - NEW!
                      if (_missions.isNotEmpty) ...[
                        _buildMissionsSection(),
                        const SizedBox(height: 16),
                      ],
                      if (widget.incident.currentIncidentNotes != null) ...[
                        _buildDetailSection(
                          'ملاحظات',
                          Icons.notes,
                          widget.incident.currentIncidentNotes!,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTimestampsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Text(
            'تفاصيل الأزمة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (_isUpdating)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentHeader() {
    final severity = widget.incident.currentIncidentSeverity ?? 1;
    final status = widget.incident.currentIncidentStatus ?? 1;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            color: _getStatusColor(status),
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أزمة #${widget.incident.currentIncidentId}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusArabic(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(severity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getSeverityColor(severity)),
                    ),
                    child: Text(
                      _getSeverityArabic(severity),
                      style: TextStyle(
                        color: _getSeverityColor(severity),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // MISSIONS SECTION - NEW!
  // ============================================================================
  Widget _buildMissionsSection() {
    final sortedMissions = List<CurrentIncidentWithMissions>.from(_missions)
      ..sort(
        (a, b) => (a.currentIncidentMissionOrder ?? 0).compareTo(
          b.currentIncidentMissionOrder ?? 0,
        ),
      );

    final completedCount = sortedMissions
        .where((m) => m.currentIncidentMissionStatus == 2)
        .length;
    final totalCount = sortedMissions.length;
    final progressPercent = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5F8D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المهام',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    Text(
                      'قائمة المهام المطلوب إنجازها',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progressPercent == 1.0 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedCount / $totalCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                progressPercent == 1.0 ? Colors.green : const Color(0xFF2C5F8D),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Mission List
          ...sortedMissions.asMap().entries.map((entry) {
            final index = entry.key;
            final mission = entry.value;
            return _buildMissionItem(mission, index);
          }),
        ],
      ),
    );
  }

  Widget _buildMissionItem(CurrentIncidentWithMissions mission, int index) {
    final isCompleted = mission.currentIncidentMissionStatus == 2;
    final missionId = mission.currentIncidentMissionId ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green[300]! : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          if (isCompleted)
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.white,
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          // Mission Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مهمة #$missionId',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.grey : const Color(0xFF1E3A5F),
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (mission.currentIncidentMissionOrder != null)
                  Text(
                    'الترتيب: ${mission.currentIncidentMissionOrder}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                Text(
                  mission.missionName ?? 'نوع المهمة غير محدد',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  size: 14,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  isCompleted ? 'مكتملة' : 'قيد التنفيذ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2C5F8D), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final lat = widget.incident.currentIncidentXAxis!;
    final lng = widget.incident.currentIncidentYAxis!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF2C5F8D), size: 24),
              const SizedBox(width: 12),
              const Text(
                'الموقع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => widget.onZoomToLocation(lat, lng),
                icon: const Icon(Icons.zoom_in, size: 18),
                label: const Text('تكبير على الخريطة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C5F8D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.my_location, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'خط العرض: ${lat.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_searching, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'خط الطول: ${lng.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 12,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.crisis_management',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF2C5F8D), size: 24),
              SizedBox(width: 12),
              Text(
                'المواعيد الزمنية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTimestampItem(
            'تاريخ الإنشاء',
            widget.incident.currentIncidentCreatedAt,
          ),
          if (widget.incident.currentIncidentSeverityUpdateAt != null)
            _buildTimestampItem(
              'آخر تحديث للخطورة',
              widget.incident.currentIncidentSeverityUpdateAt,
            ),
          if (widget.incident.currentIncidentStatusUpdatedAt != null)
            _buildTimestampItem(
              'آخر تحديث للحالة',
              widget.incident.currentIncidentStatusUpdatedAt,
            ),
        ],
      ),
    );
  }

  Widget _buildTimestampItem(String label, DateTime? dateTime) {
    if (dateTime == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ${_formatDateTime(dateTime)}',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
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
        return Colors.yellow[700]!;
      case 1:
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.teal;
      case 6:
        return Colors.green;
      case 7:
        return Colors.red;
      default:
        return Colors.black45;
    }
  }

  String _getStatusArabic(int status) {
    switch (status) {
      case 1:
        return 'تم التبليغ';
      case 2:
        return 'تم الارسال';
      case 3:
        return 'قيد التنفيذ';
      case 4:
        return 'قيد الانتظار';
      case 5:
        return 'قيد المراجعة';
      case 6:
        return 'تم حلها';
      case 7:
        return 'تم الرفض';
      default:
        return 'غير معروف';
    }
  }

  String _getSeverityArabic(int severity) {
    switch (severity) {
      case 4:
        return 'حرجة';
      case 3:
        return 'عالية';
      case 2:
        return 'متوسطة';
      case 1:
      default:
        return 'منخفضة';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
