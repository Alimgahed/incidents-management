// ============================================================================
// ENHANCED MAP SCREEN - Arabic UI with Cubit & WebSocket Real-time Updates
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
  final MapController mapController = MapController();
  String selectedFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidentMapCubit, IncidentMapState>(
      builder: (context, state) {
        if (state is IncidentMapLoading) {
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

        if (state is IncidentMapError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<IncidentMapCubit>(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is IncidentMapLoaded) {
          return Column(
            children: [
              _buildMapHeader(state.incidents.length),
              Expanded(child: _buildMap(state.incidents)),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }

  // ============================================================================
  // MAP HEADER
  // ============================================================================
  Widget _buildMapHeader(int totalIncidents) {
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
              const Column(
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
              const Spacer(),
              _buildIncidentCounter(totalIncidents),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildIncidentCounter(int count) {
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
        final isSelected = selectedFilter == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) {
            setState(() => selectedFilter = filter);
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

  // ============================================================================
  // MAP
  // ============================================================================
  Widget _buildMap(List<CurrentIncidentModel> incidents) {
    final filteredIncidents = _getFilteredIncidents(incidents);
    final markers = _buildMarkers(filteredIncidents);

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: const LatLng(28.0871, 30.7618),
            initialZoom: 10,
            minZoom: 3,
            maxZoom: 18,
            onTap: (_, __) {
              // Navigator.of(context).pop();
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.crisis_management',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        _buildMapControls(),
        _buildLegend(),
      ],
    );
  }

  List<CurrentIncidentModel> _getFilteredIncidents(
    List<CurrentIncidentModel> incidents,
  ) {
    if (selectedFilter == 'الكل') {
      return incidents;
    }

    final severityMap = {'حرجة': 4, 'عالية': 3, 'متوسطة': 2, 'منخفضة': 1};

    final targetSeverity = severityMap[selectedFilter];
    return incidents
        .where((i) => i.currentIncidentSeverity == targetSeverity)
        .toList();
  }

  List<Marker> _buildMarkers(List<CurrentIncidentModel> incidents) {
    return incidents
        .map<Marker?>((incident) {
          final lat = incident.currentIncidentXAxis;
          final lng = incident.currentIncidentYAxis;

          if (lat == null || lng == null) return null;

          final severity = incident.currentIncidentSeverity;
          final status = incident.currentIncidentStatus;

          return Marker(
            point: LatLng(lat, lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: () {
                mapController.move(LatLng(lat, lng), 17);
                _showEnhancedIncidentDetails(incident);
              },
              child: _buildMarkerWidget(severity!, status!),
            ),
          );
        })
        .whereType<Marker>()
        .toList();
  }

  Widget _buildMarkerWidget(int severity, int status) {
    final color = _getSeverityColor(severity);
    final isResolved = status == 3; // Assuming 3 = resolved

    return Stack(
      children: [
        // Pulse animation container
        if (!isResolved)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3),
            ),
          ),
        // Main marker
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
        // Status indicator
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

  // ============================================================================
  // MAP CONTROLS
  // ============================================================================
  Widget _buildMapControls() {
    return Positioned(
      left: 16,
      bottom: 16,
      child: Column(
        children: [
          _buildControlButton(
            Icons.add,
            'تكبير',
            () => mapController.move(
              mapController.camera.center,
              mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.remove,
            'تصغير',
            () => mapController.move(
              mapController.camera.center,
              mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            Icons.my_location,
            'موقعي',
            () => mapController.move(const LatLng(28.0871, 30.7618), 12),
          ),
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

  // ============================================================================
  // LEGEND
  // ============================================================================
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

  // ============================================================================
  // ENHANCED INCIDENT DETAILS SIDE PANEL
  // ============================================================================
  void _showEnhancedIncidentDetails(CurrentIncidentModel incident) {
    final incidentId = incident.currentIncidentId;
    final lat = incident.currentIncidentXAxis;
    final lng = incident.currentIncidentYAxis;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => Align(
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
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24),
                    ),
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
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'إغلاق',
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon
                        _buildIncidentHeader(incident),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Description
                        _buildDetailSection(
                          'الوصف',
                          Icons.description,
                          incident.currentIncidentDescription ?? 'لا يوجد وصف',
                        ),

                        const SizedBox(height: 16),

                        // Location with map preview
                        if (lat != null && lng != null) ...[
                          _buildLocationSection(lat, lng),
                          const SizedBox(height: 16),
                        ],

                        // Notes
                        if (incident.currentIncidentNotes != null) ...[
                          _buildDetailSection(
                            'ملاحظات',
                            Icons.notes,
                            incident.currentIncidentNotes ?? 'لا توجد ملاحظات',
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Timestamps
                        _buildTimestampsSection(incident),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // DETAIL SECTIONS
  // ============================================================================
  Widget _buildIncidentHeader(CurrentIncidentModel incident) {
    final severity = incident.currentIncidentSeverity;
    final status = incident.currentIncidentStatus;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(status!).withOpacity(0.1),
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
                'أزمة #${incident.currentIncidentId}',
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
                      color: _getStatusColor(status!),
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
                      color: _getSeverityColor(severity!).withOpacity(0.2),
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

  Widget _buildLocationSection(double lat, double lng) {
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
                onPressed: () => _openInMaps(lat, lng),
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

  Widget _buildTimestampsSection(CurrentIncidentModel incident) {
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
            incident.currentIncidentCreatedAt,
          ),
          if (incident.currentIncidentSeverityUpdateAt != null)
            _buildTimestampItem(
              'آخر تحديث للخطورة',
              incident.currentIncidentSeverityUpdateAt,
            ),
          if (incident.currentIncidentStatusUpdatedAt != null)
            _buildTimestampItem(
              'آخر تحديث للحالة',
              incident.currentIncidentStatusUpdatedAt,
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

  // ============================================================================
  // HELPERS
  // ============================================================================
  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 4:
        return Colors.red; // Critical
      case 3:
        return Colors.orange; // High
      case 2:
        return Colors.yellow[700]!; // Medium
      case 1:
      default:
        return Colors.green; // Low
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange; // تم التبليغ
      case 2:
        return Colors.blue; // تم الارسال
      case 3:
        return Colors.purple; // قيد التنفيذ
      case 4:
        return Colors.grey; // قيد الانتظار
      case 5:
        return Colors.teal; // قيد المراجعة
      case 6:
        return Colors.green; // تم حلها
      case 7:
        return Colors.red; // تم الرفض
      default:
        return Colors.black45; // غير معروف
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

  void _openInMaps(double lat, double lng) {
    // Close bottom sheet
    Navigator.of(context).pop();

    // Zoom to location on main map
    mapController.move(LatLng(lat, lng), 18);

    // Show confirmation snackbar
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
  }
}
