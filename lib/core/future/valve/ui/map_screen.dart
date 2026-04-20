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
              point: LatLng(valve.lat!, valve.long!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  if (userLat != null && userLng != null) {
                    final dist = const Distance().distance(
                      LatLng(userLat, userLng),
                      LatLng(valve.lat!, valve.long!),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${valve.valveType?.nameAr ?? 'محبس'}\nالمسافة: ${dist.toStringAsFixed(1)} متر'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'التفاصيل',
                          onPressed: () => _showValveDetails(context, valve),
                        ),
                      ),
                    );
                  } else {
                    _showValveDetails(context, valve);
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
              point: LatLng(valve.lat ?? 0, valve.long ?? 0),
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

  void _showValveDetails(BuildContext context, ValveModel valve) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.water_drop, color: Colors.blue, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                valve.valveType?.nameAr ?? 'محبس مياه',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (valve.id != null)
                                Text(
                                  'كود المحبس: ${valve.id}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                        if (valve.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (valve.status == 'Good' || valve.status == 'جيد')
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              valve.status!,
                              style: TextStyle(
                                color: (valve.status == 'Good' || valve.status == 'جيد')
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 32),
                    if (valve.position != null) _buildDetailRow(Icons.settings_remote, 'الوضع الحالي', valve.position!),
                    if (valve.diameter != null) _buildDetailRow(Icons.straighten, 'القطر', '${valve.diameter} مم'),
                    if (valve.pipeDiameter != null) _buildDetailRow(Icons.plumbing, 'قطر الماسورة', '${valve.pipeDiameter} مم'),
                    if (valve.depth != null) _buildDetailRow(Icons.layers, 'العمق', '${valve.depth} م'),
                    if (valve.numOfTurns != null) _buildDetailRow(Icons.rotate_right, 'عدد اللفات', '${valve.numOfTurns}'),
                    if (valve.direction != null) _buildDetailRow(Icons.explore, 'الاتجاه', valve.direction!),
                    if (valve.inServiceYear != null) _buildDetailRow(Icons.calendar_today, 'سنة التركيب', '${valve.inServiceYear}'),
                    if (valve.lat != null && valve.long != null)
                      _buildDetailRow(Icons.location_on, 'الإحداثيات', '${valve.lat?.toStringAsFixed(6)}, ${valve.long?.toStringAsFixed(6)}'),
                    if (valve.valveType?.abbreviation != null)
                      _buildDetailRow(Icons.badge, 'الاختصار', valve.valveType!.abbreviation!),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('إغلاق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey[400]),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
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
