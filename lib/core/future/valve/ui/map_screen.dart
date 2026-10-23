// lib/core/future/valve/ui/map_screen.dart — flutter_map + OpenStreetMap GIS Valve Screen

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/valve_cubit.dart';
import 'package:incidents_managment/core/future/valve/logic/state/valve_state.dart';
import 'package:incidents_managment/core/future/valve/ui/alarm.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/valve_details_bottom_sheet.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/valve_icon_widget.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/valve_nearby_alert_callout.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  static const LatLng _minyaCenter = LatLng(28.0871, 30.7501);

  bool _hasCenteredOnInitialLocation = false;
  bool _isSatelliteMode = false;
  bool _isFollowMode = true; // Auto-follow technician movement by default

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ValveProximityCubit>().initialize();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ValveProximityCubit>().resumeTracking();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncBounds();
      });
    } else if (state == AppLifecycleState.paused) {
      context.read<ValveProximityCubit>().pauseAlarmOnBackground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<ValveProximityCubit>().stopTracking();
    _mapController.dispose();
    super.dispose();
  }

  MapBounds _boundsFromCamera() {
    final bounds = _mapController.camera.visibleBounds;
    return MapBounds(
      latMin: bounds.south,
      latMax: bounds.north,
      longMin: bounds.west,
      longMax: bounds.east,
    );
  }

  void _syncBounds() {
    context.read<ValveProximityCubit>().updateMapBounds(_boundsFromCamera());
  }

  void _centerOnUser({bool enableFollow = true}) {
    if (enableFollow && !_isFollowMode) {
      setState(() {
        _isFollowMode = true;
      });
    }

    final state = context.read<ValveProximityCubit>().state;
    double? lat;
    double? lng;

    if (state is ProximitySafe) {
      lat = state.userLat;
      lng = state.userLng;
    } else if (state is ProximityAlert) {
      lat = state.userLat;
      lng = state.userLng;
    }

    if (lat != null && lng != null) {
      final double targetZoom =
          _mapController.camera.zoom < 16.5 ? 17.0 : _mapController.camera.zoom;
      _mapController.move(LatLng(lat, lng), targetZoom);
    }
  }

  void _toggleFollowMode() {
    setState(() {
      _isFollowMode = !_isFollowMode;
    });
    if (_isFollowMode) {
      _centerOnUser(enableFollow: true);
    }
  }

  void _animateToValve(ValveModel valve) {
    if (valve.lat != null && valve.long != null) {
      _mapController.move(LatLng(valve.lat!, valve.long!), 18.0);
    }
  }

  void _showValveDetailsModal(BuildContext context, ValveModel valve) {
    context.read<ValveProximityCubit>().selectValve(valve);
    ValveDetailsBottomSheet.show(
      context,
      valve: valve,
      onNavigateToValve: () => _animateToValve(valve),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'خريطة المحابس والشبكات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF0F3B6C),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
              ),
              tooltip: 'رجوع',
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
          
          ],
        ),
        body: BlocConsumer<ValveProximityCubit, ProximityState>(
          listener: (context, state) {
            double? userLat;
            double? userLng;
            if (state is ProximitySafe) {
              userLat = state.userLat;
              userLng = state.userLng;
            } else if (state is ProximityAlert) {
              userLat = state.userLat;
              userLng = state.userLng;
            }

            if (userLat != null && userLng != null) {
              final userPos = LatLng(userLat, userLng);
              if (!_hasCenteredOnInitialLocation) {
                _hasCenteredOnInitialLocation = true;
                _mapController.move(userPos, 17.0);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _syncBounds();
                });
              } else if (_isFollowMode) {
                // Smoothly follow technician when in follow mode:
                // Only move if user is noticeably away from map center (> 3m) to avoid micro-jitter snapping
                final currentCenter = _mapController.camera.center;
                final distance = const Distance().as(
                  LengthUnit.Meter,
                  currentCenter,
                  userPos,
                );
                if (distance > 3.0) {
                  _mapController.move(userPos, _mapController.camera.zoom);
                }
              }
            }
          },
          builder: (context, state) {
            final isMuted = state is ProximityAlert
                ? state.isMuted
                : (state is ProximitySafe ? state.isMuted : false);

            final alertNearestValve = state is ProximityAlert
                ? state.nearestValve
                : null;

            final double? technicianAccuracy = state is ProximitySafe
                ? state.userAccuracy
                : (state is ProximityAlert ? state.userAccuracy : null);

            final double? technicianLat = state is ProximitySafe
                ? state.userLat
                : (state is ProximityAlert ? state.userLat : null);

            final double? technicianLng = state is ProximitySafe
                ? state.userLng
                : (state is ProximityAlert ? state.userLng : null);

            return Stack(
              children: [
                // 1. Flutter Map with Viewport/Bounds Loading Reused from Web GIS
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _minyaCenter,
                    initialZoom: 16.5,
                    maxZoom: 19,
                    minZoom: 6,
                    onMapReady: () {
                      _syncBounds();
                    },
                    onPositionChanged: (camera, hasGesture) {
                      if (hasGesture) {
                        // User touched or dragged the map manually -> pause automatic camera following
                        if (_isFollowMode) {
                          setState(() {
                            _isFollowMode = false;
                          });
                        }
                        final bounds = camera.visibleBounds;
                        context.read<ValveProximityCubit>().updateMapBounds(
                          MapBounds(
                            latMin: bounds.south,
                            latMax: bounds.north,
                            longMin: bounds.west,
                            longMax: bounds.east,
                          ),
                        );
                      }
                    },
                  ),
                  children: [
                    // Base Map Tiles (Standard OpenStreetMap or Satellite)
                    TileLayer(
                      urlTemplate: _isSatelliteMode
                          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                          : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: _isSatelliteMode
                          ? const []
                          : const ['a', 'b', 'c'],
                      userAgentPackageName: 'incidents_managment',
                    ),

                    // GPS Accuracy Halo Circle around Technician
                    if (technicianLat != null &&
                        technicianLng != null &&
                        technicianAccuracy != null &&
                        technicianAccuracy > 0)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(technicianLat, technicianLng),
                            radius: technicianAccuracy.clamp(4.0, 50.0),
                            useRadiusInMeter: true,
                            color: const Color(0xFF0284C7).withValues(alpha: 0.09),
                            borderStrokeWidth: 1.0,
                            borderColor: const Color(0xFF0284C7).withValues(alpha: 0.25),
                          ),
                        ],
                      ),

                    // Dashed connection line to nearby valve (from screenshot)
                    if (state is ProximityAlert &&
                        state.nearestValve.lat != null &&
                        state.nearestValve.long != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(state.userLat, state.userLng),
                              LatLng(
                                state.nearestValve.lat!,
                                state.nearestValve.long!,
                              ),
                            ],
                            color: const Color(0xFF0284C7),
                            strokeWidth: 2.8,
                            pattern: StrokePattern.dashed(segments: [6, 6]),
                          ),
                        ],
                      ),

                    // Concentric proximity circle rings around nearby valve (from screenshot)
                    if (alertNearestValve != null &&
                        alertNearestValve.lat != null &&
                        alertNearestValve.long != null)
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: LatLng(
                              alertNearestValve.lat!,
                              alertNearestValve.long!,
                            ),
                            radius: 38,
                            useRadiusInMeter: true,
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.12),
                            borderStrokeWidth: 1.5,
                            borderColor: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.35),
                          ),
                          CircleMarker(
                            point: LatLng(
                              alertNearestValve.lat!,
                              alertNearestValve.long!,
                            ),
                            radius: 18,
                            useRadiusInMeter: true,
                            color: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.22),
                            borderStrokeWidth: 1.8,
                            borderColor: const Color(
                              0xFFEF4444,
                            ).withValues(alpha: 0.65),
                          ),
                        ],
                      ),

                    // Valve Markers & User Location Marker
                    MarkerLayer(markers: _buildMarkers(context, state)),
                  ],
                ),

                // 2. Floating Action Controls on Right Side (matching screenshot)
                Positioned(
                  top: 24,
                  left:
                      16, // In RTL, this aligns to the right side of the screen
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Layer Toggle (OSM / Satellite)
                      _buildFloatingButton(
                        icon: _isSatelliteMode
                            ? Icons.map_rounded
                            : Icons.layers_rounded,
                        tooltip: 'تبديل طبقات الخريطة',
                        onTap: () {
                          setState(() {
                            _isSatelliteMode = !_isSatelliteMode;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Re-center / Follow Mode Toggle
                      _buildFloatingButton(
                        icon: _isFollowMode
                            ? Icons.navigation_rounded
                            : Icons.my_location_rounded,
                        tooltip: _isFollowMode
                            ? 'وضع متابعة موقع الفني مفعل (اضغط للتركيز)'
                            : 'تفعيل متابعة موقع الفني التلقائية',
                        backgroundColor: _isFollowMode
                            ? const Color(0xFF0F3B6C)
                            : Colors.white,
                        iconColor: _isFollowMode
                            ? Colors.white
                            : const Color(0xFF0F3B6C),
                        badge: _isFollowMode
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 1.5),
                                ),
                              )
                            : null,
                        onTap: () {
                          if (_isFollowMode) {
                            _centerOnUser(enableFollow: true);
                          } else {
                            _toggleFollowMode();
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Reset Compass / Heading to North
                      _buildFloatingButton(
                        icon: Icons.explore_rounded,
                        tooltip: 'توجيه الشمال وإعادة الضبط',
                        onTap: () {
                          _mapController.rotate(0);
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),

                      // Mute / Stop Alert Button (Explicit User Requirement)
                      _buildFloatingButton(
                        icon: isMuted
                            ? Icons.notifications_off_rounded
                            : Icons.notifications_active_rounded,
                        tooltip: isMuted
                            ? 'تشغيل التنبيه الصوتي'
                            : 'إيقاف التنبيه الصوتي',
                        iconColor: isMuted
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFFDC2626),
                        onTap: () {
                          context.read<ValveProximityCubit>().toggleMute();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isMuted
                                    ? 'تم تفعيل التنبيه الصوتي للمحابس'
                                    : 'تم إيقاف التنبيه الصوتي (صامت)',
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: isMuted
                                  ? const Color(0xFF0F3B6C)
                                  : const Color(0xFF475569),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // 3. Top Banner Alert (When Alert is Active)
                if (state is ProximityAlert)
                  Positioned(
                    top: 12,
                    right: 0,
                    left: 70, // Leaves room for floating buttons
                    child: AlarmBanner(
                      valve: state.nearestValve,
                      distanceMeters: state.distanceMeters,
                      isCritical: state.isCritical,
                      isMuted: state.isMuted,
                      onDismiss: () =>
                          context.read<ValveProximityCubit>().toggleMute(),
                      onTapDetails: () =>
                          _showValveDetailsModal(context, state.nearestValve),
                    ),
                  ),

                // 4. Loading Indicator Overlay
                if (state is ProximityLoading)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0F3B6C),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'جارٍ تحميل المحابس وتحديد الموقع...',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 5. Error Banner
                if (state is ProximityError)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context
                                .read<ValveProximityCubit>()
                                .initialize(),
                            child: const Text(
                              'إعادة المحاولة',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    Widget? badge,
  }) {
    return Tooltip(
      message: tooltip,
      textStyle: const TextStyle(
        fontFamily: 'Cairo',
        color: Colors.white,
        fontSize: 12,
      ),
      child: Material(
        color: backgroundColor ?? Colors.white,
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: iconColor ?? const Color(0xFF0F3B6C),
                ),
                if (badge != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: badge,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Marker> _buildMarkers(BuildContext context, ProximityState state) {
    final markers = <Marker>[];

    List<ValveModel> valves = [];
    double? userLat;
    double? userLng;
    double? userHeading;
    int? alertValveId;
    double alertDistance = 0.0;
    bool isAlertCritical = false;
    bool isAlertMuted = false;

    if (state is ProximitySafe) {
      valves = state.valves;
      userLat = state.userLat;
      userLng = state.userLng;
      userHeading = state.userHeading;
      isAlertMuted = state.isMuted;
    } else if (state is ProximityAlert) {
      valves = state.valves;
      userLat = state.userLat;
      userLng = state.userLng;
      userHeading = state.userHeading;
      alertValveId = state.nearestValve.id;
      alertDistance = state.distanceMeters;
      isAlertCritical = state.isCritical;
      isAlertMuted = state.isMuted;
    }

    // 1. Valve Markers
    for (final valve in valves) {
      if (valve.lat == null || valve.long == null) continue;

      final isAlertValve = (alertValveId != null && valve.id == alertValveId);

      if (isAlertValve) {
        // Red Selected / Alert Marker with Callout Tooltip (Exact Match to Screenshot!)
        markers.add(
          Marker(
            point: LatLng(valve.lat!, valve.long!),
            width: 220,
            height: 110,
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red Floating Callout Card
                ValveNearbyAlertCallout(
                  distanceMeters: alertDistance,
                  isCritical: isAlertCritical,
                  isMuted: isAlertMuted,
                  onTap: () => _showValveDetailsModal(context, valve),
                  onStopAlert: () =>
                      context.read<ValveProximityCubit>().toggleMute(),
                ),
                const SizedBox(height: 4),

                // Red Valve Circle Marker
                GestureDetector(
                  onTap: () => _showValveDetailsModal(context, valve),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626), // Alert Red
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: ValveIconWidget(size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Normal Valve Marker: Clean Circular Blue Marker with soft outer halo (from Screenshot)
        markers.add(
          Marker(
            point: LatLng(valve.lat!, valve.long!),
            width: 42,
            height: 42,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () => _showValveDetailsModal(context, valve),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft halo
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Inner solid badge
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF0284C7,
                          ).withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: ValveIconWidget(size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    // 2. Persistent Live Technician Location Marker (Real-time Directional Arrow)
    if (userLat != null && userLng != null) {
      final double mapRotation = _mapController.camera.rotation;
      // Heading relative to map screen rotation
      final double? effectiveHeading =
          userHeading != null ? (userHeading - mapRotation) : null;
      final double radians =
          effectiveHeading != null ? (effectiveHeading * (pi / 180.0)) : 0.0;

      markers.add(
        Marker(
          point: LatLng(userLat, userLng),
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer radar aura
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
              ),
              // Inner disc with crisp border and drop shadow
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0284C7), width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 7,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: effectiveHeading != null
                      ? Transform.rotate(
                          angle: radians,
                          child: const Icon(
                            Icons.navigation_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                        )
                      : Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0284C7),
                            shape: BoxShape.circle,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return markers;
  }
}
