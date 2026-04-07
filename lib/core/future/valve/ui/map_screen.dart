// lib/screens/map_screen.dart — flutter_map + OpenStreetMap
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/ui/alarm.dart';
import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/valve_cubit.dart';
import 'package:incidents_managment/core/future/valve/logic/state/valve_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  // Map controller for flutter_map
  final MapController _mapController = MapController();

  static const LatLng _minyaCenter = LatLng(28.0871, 30.7501);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ValveProximityCubit>().initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<ValveProximityCubit>().stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خريطة شبكة المياه - المنيا'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'موقعي الحالي',
            onPressed: _centerOnUser,
          ),
        ],
      ),
      body: BlocConsumer<ValveProximityCubit, ProximityState>(
        listener: (context, state) {
          if (state is ProximitySafe) {
            _mapController.move(LatLng(state.userLat, state.userLng), 16);
          } else if (state is ProximityAlert) {
            _mapController.move(LatLng(state.userLat, state.userLng), 16);
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // ── Flutter Map
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _minyaCenter,
                  initialZoom: 16,
                  maxZoom: 19,
                  minZoom: 5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'incidents_managment',
                  ),
                  MarkerLayer(
                    markers: _buildValveMarkers(context, state),
                  ),
                  CircleLayer(
                    circles: _buildProximityCircles(state),
                  ),
                ],
              ),

              // ── Alarm banner
              if (state is ProximityAlert)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AlarmBanner(
                    valve: state.nearestValve,
                    distanceMeters: state.distanceMeters,
                    onDismiss: () =>
                        context.read<ValveProximityCubit>().dismissAlarm(),
                  ),
                ),

              // ── Loading overlay
              if (state is ProximityLoading)
                const Center(
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text('جارٍ تحديد الموقع...'),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Error banner
              if (state is ProximityError)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    color: Colors.orange.shade800,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.read<ValveProximityCubit>().initialize(),
                            child: const Text('إعادة المحاولة',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Status chip
              if (state is ProximitySafe)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _StatusChip(
                    label: 'المنطقة آمنة — لا توجد محابس قريبة',
                    icon: Icons.check_circle,
                    color: Colors.green.shade700,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Marker> _buildValveMarkers(BuildContext context, ProximityState state) {
    double? userLat;
    double? userLng;

    if (state is ProximitySafe) {
      userLat = state.userLat;
      userLng = state.userLng;
    } else if (state is ProximityAlert) {
      userLat = state.userLat;
      userLng = state.userLng;
    }

    final valves = _valvesFromState(state);
    final List<Marker> markers = valves
        .map((valve) => Marker(
              point: LatLng(valve.latitude, valve.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (userLat != null && userLng != null) {
                    final dist = const Distance().distance(
                      LatLng(userLat, userLng),
                      LatLng(valve.latitude, valve.longitude),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${valve.name}\nالمسافة: ${dist.toStringAsFixed(1)} متر'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${valve.name}\nجاري تحديد الموقع...'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
            ))
        .toList();

    if (userLat != null && userLng != null) {
      markers.add(
        Marker(
          point: LatLng(userLat, userLng),
          width: 50,
          height: 50,
          child: const Icon(
            Icons.person_pin_circle,
            color: Colors.green,
            size: 40,
          ),
        ),
      );
    }

    return markers;
  }

  List<CircleMarker> _buildProximityCircles(ProximityState state) {
    final valves = _valvesFromState(state);
    final alertValveId = state is ProximityAlert ? state.nearestValve.id : null;

    return valves
        .map((valve) => CircleMarker(
              point: LatLng(valve.latitude, valve.longitude),
              radius: 100,
              useRadiusInMeter: true,
              color: valve.id == alertValveId
                  ? Colors.red.withOpacity(0.35)
                  : Colors.blue.withOpacity(0.15),
              borderStrokeWidth: 2,
              borderColor:
                  valve.id == alertValveId ? Colors.red : Colors.blue,
            ))
        .toList();
  }

  List<ValveModel> _valvesFromState(ProximityState state) {
    if (state is ProximitySafe) return state.valves;
    if (state is ProximityAlert) return state.valves;
    return [];
  }

  void _centerOnUser() {
    final state = context.read<ValveProximityCubit>().state;
    if (state is ProximitySafe) {
      _mapController.move(LatLng(state.userLat, state.userLng), 16);
    } else if (state is ProximityAlert) {
      _mapController.move(LatLng(state.userLat, state.userLng), 16);
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}