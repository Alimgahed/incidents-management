import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide ClusterManager, Cluster;
import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';
import 'package:incidents_managment/features/valves_map/presentation/logic/location_tracking_cubit/location_tracking_cubit.dart';
import 'package:incidents_managment/features/valves_map/presentation/logic/valves_map_cubit/valves_map_cubit.dart';
import 'package:incidents_managment/features/valves_map/presentation/widgets/nearest_valve_card.dart';
import 'package:incidents_managment/features/valves_map/presentation/widgets/proximity_alert_banner.dart';

class ValvesMapScreen extends StatefulWidget {
  const ValvesMapScreen({super.key});

  @override
  State<ValvesMapScreen> createState() => _ValvesMapScreenState();
}

class _ValvesMapScreenState extends State<ValvesMapScreen> {
  GoogleMapController? _mapController;
  late ClusterManager _manager;
  Set<Marker> _markers = {};
  
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(24.7136, 46.6753), // Riyadh as default
    zoom: 10.0,
  );

  @override
  void initState() {
    super.initState();
    // Initialize cluster manager
    _manager = _initClusterManager();
    
    // Load valves
    context.read<ValvesMapCubit>().loadValves();
    // Start tracking GPS
    context.read<LocationTrackingCubit>().startTracking();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<ValveEntity>(
      [], // Items will be updated via bloc listener
      _updateMarkers,
      markerBuilder: _markerBuilder,
      levels: const [1, 4.25, 6.75, 8.25, 11.5, 14.5, 16.0, 16.5, 20.0],
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  Future<Marker> _markerBuilder(dynamic clusterDynamic) async {
    final cluster = clusterDynamic as Cluster<ValveEntity>;
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      onTap: () {
        if (cluster.isMultiple) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(cluster.location, 14),
          );
        } else {
          // Show bottom sheet with valve details
          _showValveDetails(cluster.items.first);
        }
      },
      icon: await _getClusterBitmap(cluster.isMultiple ? 120 : 80,
          text: cluster.isMultiple ? cluster.count.toString() : null),
    );
  }

  Future<BitmapDescriptor> _getClusterBitmap(int size, {String? text}) async {
    // In production, use dart:ui to paint a custom icon with text
    // For this example, we fallback to default
    if (text != null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  void _showValveDetails(ValveEntity valve) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valve.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('المنطقة: ${valve.zone}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx),
              icon: const Icon(Icons.close),
              label: const Text('إغلاق'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة المحابس'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              final locationState = context.read<LocationTrackingCubit>().state;
              if (locationState is LocationTrackingActive) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(locationState.position.latitude, locationState.position.longitude),
                    16,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocListener<ValvesMapCubit, ValvesMapState>(
        listener: (context, state) {
          if (state is ValvesMapLoaded) {
            _manager.setItems(state.valves);
          }
        },
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialPosition,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Custom button used
              compassEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                _manager.setMapId(controller.mapId);
              },
              onCameraMove: _manager.onCameraMove,
              onCameraIdle: _manager.updateMap, // Critical for performance!
            ),
            
            // UI Overlay
            const SafeArea(
              child: Column(
                children: [
                  ProximityAlertBanner(),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: NearestValveCard(),
                  ),
                ],
              ),
            ),

            // Loading indicator
            BlocBuilder<ValvesMapCubit, ValvesMapState>(
              builder: (context, state) {
                if (state is ValvesMapLoading) {
                  return const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
