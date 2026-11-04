import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/map/map_incident_details_modal.dart';
import 'package:incidents_managment/core/future/reports/logic/reports_state.dart';

class ReportsGeoDistributionMapCard extends StatefulWidget {
  final ReportsLoaded state;
  final VoidCallback? onOpenFullMap;

  const ReportsGeoDistributionMapCard({
    super.key,
    required this.state,
    this.onOpenFullMap,
  });

  @override
  State<ReportsGeoDistributionMapCard> createState() =>
      _ReportsGeoDistributionMapCardState();
}

class _ReportsGeoDistributionMapCardState
    extends State<ReportsGeoDistributionMapCard> {
  final MapController _mapController = MapController();
  bool _showHeatmapMode = false;

  static const _palette = [
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFF06B6D4),
    Color(0xFF64748B),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFFEAB308),
  ];

  Color _getBranchColor(String branch) {
    if (branch.isEmpty || branch == 'غير محدد') return const Color(0xFF94A3B8);
    final hash = branch.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
    return _palette[hash.abs() % _palette.length];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitMapToIncidents();
    });
  }

  @override
  void didUpdateWidget(ReportsGeoDistributionMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.filteredIncidents != widget.state.filteredIncidents) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitMapToIncidents();
      });
    }
  }

  void _fitMapToIncidents() {
    if (!mounted) return;
    final points = <LatLng>[];
    for (final inc in widget.state.filteredIncidents) {
      final x = inc.currentIncidentXAxis;
      final y = inc.currentIncidentYAxis;
      if (x != null && y != null && x != 0 && y != 0) {
        double lat = x;
        double lng = y;
        if (x > 29.5 && y < 29.5) {
          lat = y;
          lng = x;
        }
        points.add(LatLng(lat, lng));
      }
    }

    if (points.isEmpty) {
      _mapController.move(const LatLng(28.1099, 30.7503), 9.0);
      return;
    }

    if (points.length == 1) {
      _mapController.move(points.first, 14.0);
    } else {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate real map markers strictly from incidents with valid coordinates
    final markers = <Marker>[];
    final activeBranchColors = <String, Color>{};

    for (final inc in widget.state.filteredIncidents) {
      final x = inc.currentIncidentXAxis;
      final y = inc.currentIncidentYAxis;
      if (x != null && y != null && x != 0 && y != 0) {
        double lat = x;
        double lng = y;
        if (x > 29.5 && y < 29.5) {
          lat = y;
          lng = x;
        }

        final point = LatLng(lat, lng);
        final branch =
            (inc.branchName != null && inc.branchName!.trim().isNotEmpty)
            ? inc.branchName!.trim()
            : 'غير محدد';
        final color = _getBranchColor(branch);
        activeBranchColors[branch] = color;

        if (_showHeatmapMode) {
          // Heatmap marker: Glowing multi-layer halo proportional to severity
          final sev = (inc.currentIncidentSeverity ?? 1).clamp(1, 4);
          final heatColor = sev >= 3
              ? const Color(0xFFEF4444) // Red for high/critical
              : (sev == 2 ? const Color(0xFFF97316) : const Color(0xFFEAB308)); // Orange/Yellow

          final size = 48.0 + (sev * 12.0); // 60 to 96 px radius

          markers.add(
            Marker(
              point: point,
              width: size,
              height: size,
              child: GestureDetector(
                onTap: () {
                  _mapController.move(point, 15);
                  showMapIncidentDetailsModal(context, inc);
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        heatColor.withValues(alpha: 0.85),
                        heatColor.withValues(alpha: 0.45),
                        heatColor.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 0.75, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: heatColor.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: heatColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          markers.add(
            Marker(
              point: point,
              width: 36,
              height: 36,
              child: GestureDetector(
                onTap: () {
                  _mapController.move(point, 15);
                  showMapIncidentDetailsModal(context, inc);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${inc.currentIncidentId ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Action buttons on the left
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: widget.onOpenFullMap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'عرض كامل الخريطة',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B72E8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Toggle Heatmap vs Pin mode
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showHeatmapMode = !_showHeatmapMode;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _showHeatmapMode ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _showHeatmapMode ? const Color(0xFFF87171) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.whatshot_rounded,
                            size: 15,
                            color: _showHeatmapMode ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showHeatmapMode ? 'خريطة حرارية (مفعل)' : 'تفعيل Heatmap',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: _showHeatmapMode ? FontWeight.bold : FontWeight.w600,
                              color: _showHeatmapMode ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Title + Markers count
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${markers.length} أزمة محددة',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B72E8),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'التوزيع الجغرافي للأزمات',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Map & Legend
          Expanded(
            child: Row(
              children: [
                // Map Area
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(
                              28.1099,
                              30.7503,
                            ), // Minya Center
                            initialZoom: 9.0,
                            minZoom: 6.0,
                            maxZoom: 18.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.example.crisis_management',
                            ),
                            MarkerLayer(markers: markers),
                          ],
                        ),

                        // If no coordinates in filtered set, show informative badge
                        if (markers.isEmpty)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 204, 17, 17).withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.location_off_outlined,
                                    size: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'لا توجد إحداثيات جغرافية مسجلة للأزمات المطابقة',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Zoom & Focus Controls on the right of the map
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Column(
                            children: [
                              _buildMapBtn(Icons.add_rounded, () {
                                _mapController.move(
                                  _mapController.camera.center,
                                  _mapController.camera.zoom + 1,
                                );
                              }),
                              const SizedBox(height: 6),
                              _buildMapBtn(Icons.remove_rounded, () {
                                _mapController.move(
                                  _mapController.camera.center,
                                  _mapController.camera.zoom - 1,
                                );
                              }),
                              const SizedBox(height: 6),
                              _buildMapBtn(
                                Icons.crop_free_rounded,
                                _fitMapToIncidents,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_showHeatmapMode) ...[
                  const SizedBox(width: 14),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'تدرج بؤر الخطورة',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildHeatmapLegendRow('خطورة قصوى', const Color(0xFFEF4444)),
                        _buildHeatmapLegendRow('خطورة متوسطة', const Color(0xFFF97316)),
                        _buildHeatmapLegendRow('خطورة منخفضة', const Color(0xFFEAB308)),
                      ],
                    ),
                  ),
                ] else if (activeBranchColors.isNotEmpty) ...[
                  const SizedBox(width: 14),
                  // Legend List on the right
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: activeBranchColors.entries.take(8).map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(255, 0, 81, 195),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapLegendRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF475569)),
      ),
    );
  }
}
