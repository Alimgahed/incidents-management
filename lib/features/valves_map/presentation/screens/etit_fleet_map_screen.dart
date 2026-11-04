import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/etit_vehicle_model.dart';
import '../../services/etit_gps_service.dart';

class EtitFleetMapScreen extends StatefulWidget {
  final EtitVehicleModel? targetVehicle;

  const EtitFleetMapScreen({super.key, this.targetVehicle});

  @override
  State<EtitFleetMapScreen> createState() => _EtitFleetMapScreenState();
}

class _EtitFleetMapScreenState extends State<EtitFleetMapScreen> {
  GoogleMapController? _mapController;
  final EtitGpsService _gpsService = EtitGpsService();

  List<EtitVehicleModel> _vehicles = [];
  bool _isLoading = true;
  final String _selectedFilter = 'الكل';
  Timer? _refreshTimer;

  // Minya Center Coords
  final CameraPosition _minyaCenter = const CameraPosition(
    target: LatLng(28.10988, 30.75030),
    zoom: 10.0,
  );

  @override
  void initState() {
    super.initState();
    _loadLiveFleet();
    // Auto polling every 45 seconds (Read-Only)
    _refreshTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      _loadLiveFleet(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadLiveFleet({bool silent = false}) async {
    if (!silent) {
      setState(() => _isLoading = true);
    }

    final data = await _gpsService.getVehiclesWithLiveTracking();

    if (mounted) {
      setState(() {
        _vehicles = data;
        _isLoading = false;
      });

      if (widget.targetVehicle != null && !silent) {
        final match = _vehicles.firstWhere(
          (v) => v.id == widget.targetVehicle!.id,
          orElse: () => widget.targetVehicle!,
        );
        if (match.hasValidLocation && _mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(match.latitude!, match.longitude!),
              15.0,
            ),
          );
        }
      }
    }
  }

  Set<Marker> _buildMarkers() {
    final filtered = _selectedFilter == 'الكل'
        ? _vehicles
        : _selectedFilter == 'متحرك'
            ? _vehicles.where((v) => v.isMoving).toList()
            : _vehicles.where((v) => v.allocation == _selectedFilter).toList();

    return filtered.where((v) => v.hasValidLocation).map((v) {
      final isMoving = v.isMoving;
      return Marker(
        markerId: MarkerId(v.id),
        position: LatLng(v.latitude!, v.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isMoving ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
        ),
        infoWindow: InfoWindow(
          title: '${v.code} - ${v.plateNumber}',
          snippet: '${v.allocation ?? "المنيا"} | السرعة: ${v.speed?.toStringAsFixed(1) ?? 0} كم/س',
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _vehicles.where((v) => v.hasValidLocation).length;
    final movingCount = _vehicles.where((v) => v.isMoving).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التتبع اللحظي للأسطول (ETIT)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث المواقع',
            onPressed: () => _loadLiveFleet(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _minyaCenter,
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),

          // Top Info Banner
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(235),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('إجمالي السيارات', '${_vehicles.length}', Colors.black87),
                  const VerticalDivider(width: 1),
                  _buildStatItem('متصل GPS', '$activeCount', Colors.blue),
                  const VerticalDivider(width: 1),
                  _buildStatItem('متحرك الآن', '$movingCount', Colors.green),
                ],
              ),
            ),
          ),

          if (_isLoading)
            const Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('جاري تحديث إحداثيات GPS...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
