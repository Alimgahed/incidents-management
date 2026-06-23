import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/web_valve_cubit.dart';
import 'package:incidents_managment/core/future/valve/logic/state/web_valve_state.dart';
import 'package:latlong2/latlong.dart';

class WebValveMapScreen extends StatefulWidget {
  const WebValveMapScreen({super.key});

  @override
  State<WebValveMapScreen> createState() => _WebValveMapScreenState();
}

class _WebValveMapScreenState extends State<WebValveMapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  static const LatLng _minyaCenter = LatLng(28.0871, 30.7501);
  ValveModel? _selectedValve;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onValveTapped(ValveModel valve) {
    setState(() {
      _selectedValve = valve;
    });
    _animationController.forward();
    if (valve.lat != null && valve.long != null) {
      _mapController.move(LatLng(valve.lat!, valve.long!), 17.0);
    }
  }

  void _closePanel() {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedValve = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WebValveMapCubit>()..fetchValves(),
      child: Scaffold(
        body: Stack(
          children: [
            // ── Flutter Map
            BlocBuilder<WebValveMapCubit, WebValveMapState>(
              builder: (context, state) {
                List<ValveModel> valves = [];
                if (state is WebValveMapLoaded) {
                  valves = state.valves;
                }
                
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _minyaCenter,
                    initialZoom: 13,
                    maxZoom: 19,
                    minZoom: 5,
                    onTap: (_, __) => _closePanel(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'incidents_managment',
                    ),
                    MarkerLayer(
                      markers: valves
                          .where((v) => v.lat != null && v.long != null)
                          .map((valve) => Marker(
                                point: LatLng(valve.lat!, valve.long!),
                                width: 45,
                                height: 45,
                                child: GestureDetector(
                                  onTap: () => _onValveTapped(valve),
                                  child: AnimatedScale(
                                    scale: _selectedValve?.id == valve.id ? 1.2 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _selectedValve?.id == valve.id ? Colors.blue.shade800 : Colors.blue.shade600,
                                            shape: BoxShape.circle,
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                            border: Border.all(color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(
                                            Icons.water_drop,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                );
              },
            ),

            // ── Loading & Error States Overlay
            BlocBuilder<WebValveMapCubit, WebValveMapState>(
              builder: (context, state) {
                if (state is WebValveMapLoading) {
                  return Container(
                    color: Colors.white.withValues(alpha: 0.7),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is WebValveMapError) {
                  return Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.message,
                                style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => context.read<WebValveMapCubit>().fetchValves(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // ── Map Controls
            Positioned(
              left: 24,
              bottom: 24,
              child: Column(
                children: [
                  _buildMapControl(
                    icon: Icons.add,
                    onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
                  ),
                  const SizedBox(height: 8),
                  _buildMapControl(
                    icon: Icons.remove,
                    onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
                  ),
                  const SizedBox(height: 8),
                  _buildMapControl(
                    icon: Icons.my_location,
                    onTap: () => _mapController.move(_minyaCenter, 13),
                  ),
                ],
              ),
            ),

            // ── Valve Details Awesome Panel (Glassmorphism)
            if (_selectedValve != null)
              Positioned(
                top: 24,
                right: 24,
                bottom: 24,
                width: 380,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedValve!.valveType?.nameAr ?? 'محبس',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (_selectedValve!.id != null)
                                          Text(
                                            'كود: ${_selectedValve!.id}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.8),
                                              fontSize: 13,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: _closePanel,
                                    tooltip: 'إغلاق',
                                  ),
                                ],
                              ),
                            ),
                            
                            // Content
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_selectedValve!.status != null) ...[
                                      _buildStatusBadge(_selectedValve!.status!),
                                      const SizedBox(height: 24),
                                    ],
                                    _buildSectionTitle('المعلومات الهندسية'),
                                    const SizedBox(height: 12),
                                    if (_selectedValve!.diameter != null)
                                      _buildInfoRow(Icons.straighten, 'القطر', '${_selectedValve!.diameter} مم'),
                                    if (_selectedValve!.pipeDiameter != null)
                                      _buildInfoRow(Icons.plumbing, 'قطر الماسورة', '${_selectedValve!.pipeDiameter} مم'),
                                    if (_selectedValve!.depth != null)
                                      _buildInfoRow(Icons.layers, 'العمق', '${_selectedValve!.depth} م'),
                                    if (_selectedValve!.numOfTurns != null)
                                      _buildInfoRow(Icons.rotate_right, 'عدد اللفات', '${_selectedValve!.numOfTurns}'),
                                    
                                    const SizedBox(height: 24),
                                    _buildSectionTitle('معلومات الموقع و التركيب'),
                                    const SizedBox(height: 12),
                                    if (_selectedValve!.position != null)
                                      _buildInfoRow(Icons.settings_remote, 'الوضع الحالي', _selectedValve!.position!),
                                    if (_selectedValve!.direction != null)
                                      _buildInfoRow(Icons.explore, 'الاتجاه', _selectedValve!.direction!),
                                    if (_selectedValve!.inServiceYear != null)
                                      _buildInfoRow(Icons.calendar_today, 'سنة التركيب', '${_selectedValve!.inServiceYear}'),
                                    if (_selectedValve!.lat != null && _selectedValve!.long != null)
                                      _buildInfoRow(Icons.location_on, 'الإحداثيات', '${_selectedValve!.lat!.toStringAsFixed(5)}, ${_selectedValve!.long!.toStringAsFixed(5)}'),
                                    
                                    if (_selectedValve!.valveType?.abbreviation != null) ...[
                                      const SizedBox(height: 24),
                                      _buildSectionTitle('معلومات إضافية'),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(Icons.badge, 'الاختصار', _selectedValve!.valveType!.abbreviation!),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControl({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.blue.shade800),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isGood = status == 'Good' || status == 'جيد';
    final color = isGood ? Colors.green : Colors.orange;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isGood ? Icons.check_circle : Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade900,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
