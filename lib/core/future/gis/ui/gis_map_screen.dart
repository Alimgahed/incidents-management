import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_cubit.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_state.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';
import 'package:incidents_managment/core/future/gis/models/gis_style_config.dart';
import 'package:incidents_managment/core/future/gis/ui/widgets/gis_feature_details_sheet.dart';
import 'package:incidents_managment/core/future/gis/ui/widgets/gis_layer_control_drawer.dart';

class GisMapScreen extends StatefulWidget {
  /// Optional callback if the screen is opened as an asset picker
  final ValueChanged<Map<String, dynamic>>? onAssetSelected;

  const GisMapScreen({super.key, this.onAssetSelected});

  @override
  State<GisMapScreen> createState() => _GisMapScreenState();
}

class _GisMapScreenState extends State<GisMapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _minyaCenter = LatLng(28.0871, 30.7501);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GisCubit>().init();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _showFeatureDetails(GisFeature feature, String layerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GisFeatureDetailsSheet(
        feature: feature,
        layerName: layerName,
        onAttachToIncident: widget.onAssetSelected,
      ),
    );
  }

  /// Finds the closest feature to the tap position across visible active layers
  void _handleMapTap(LatLng tapPoint, GisState state) {
    const distanceUtil = Distance();
    GisFeature? nearestFeature;
    String? foundLayer;
    double minDistance = double.infinity;

    // Check points and lines in top-to-bottom priority (valves, pipes, landmarks, etc.)
    final activeStyles = gisLayerStack.reversed.where((s) {
      return state.enabledLayers.contains(s.name) &&
          state.currentZoom >= s.minZoom;
    });

    for (final style in activeStyles) {
      final col = state.layerData[style.name];
      if (col == null) continue;

      for (final f in col.features) {
        // 1. Points
        for (final pt in f.points) {
          final d = distanceUtil.as(LengthUnit.Meter, tapPoint, pt);
          // Scale hit tolerance by zoom (closer when zoomed in, wider when zoomed out)
          final tolerance = (19.0 - state.currentZoom).clamp(8.0, 35.0);
          if (d <= tolerance && d < minDistance) {
            minDistance = d;
            nearestFeature = f;
            foundLayer = style.name;
          }
        }

        // 2. Lines
        for (final line in f.lines) {
          for (int i = 0; i < line.length - 1; i++) {
            final p1 = line[i];
            final p2 = line[i + 1];
            final d = _pointToSegmentDistance(tapPoint, p1, p2, distanceUtil);
            final tolerance = (19.0 - state.currentZoom).clamp(6.0, 25.0);
            if (d <= tolerance && d < minDistance) {
              minDistance = d;
              nearestFeature = f;
              foundLayer = style.name;
            }
          }
        }

        // 3. Polygons (center approximation)
        if (nearestFeature == null && f.polygons.isNotEmpty) {
          final c = f.center;
          if (c != null) {
            final d = distanceUtil.as(LengthUnit.Meter, tapPoint, c);
            if (d < 50.0 && d < minDistance) {
              minDistance = d;
              nearestFeature = f;
              foundLayer = style.name;
            }
          }
        }
      }

      if (nearestFeature != null) break;
    }

    if (nearestFeature != null && foundLayer != null) {
      _showFeatureDetails(nearestFeature, foundLayer);
    }
  }

  double _pointToSegmentDistance(
    LatLng p,
    LatLng a,
    LatLng b,
    Distance distUtil,
  ) {
    final l2 = distUtil.as(LengthUnit.Meter, a, b);
    if (l2 == 0) return distUtil.as(LengthUnit.Meter, p, a);

    // Approximate projection
    final latDelta = b.latitude - a.latitude;
    final lngDelta = b.longitude - a.longitude;
    final t = (((p.latitude - a.latitude) * latDelta +
                (p.longitude - a.longitude) * lngDelta) /
            (latDelta * latDelta + lngDelta * lngDelta))
        .clamp(0.0, 1.0);

    final projection = LatLng(
      a.latitude + t * latDelta,
      a.longitude + t * lngDelta,
    );
    return distUtil.as(LengthUnit.Meter, p, projection);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GisCubit, GisState>(
      builder: (context, state) {
        final cubit = context.read<GisCubit>();

        // Build vector layer widgets strictly in official stack draw order
        final layerWidgets = <Widget>[];

        // 1. Optional OpenStreetMap base underlay
        if (state.useOsm) {
          layerWidgets.add(
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'incidents_managment',
            ),
          );
        }

        // 2. Iterate gisLayerStack in bottom-to-top drawing order
        for (final style in gisLayerStack) {
          final isEnabled = state.enabledLayers.contains(style.name);
          final meetsZoom = state.currentZoom >= style.minZoom;
          if (!isEnabled || !meetsZoom) continue;

          final collection = state.layerData[style.name];
          if (collection == null || collection.features.isEmpty) continue;

          final polygons = <Polygon>[];
          final polylines = <Polyline>[];
          final markers = <Marker>[];

          for (final feature in collection.features) {
            // Polygons
            for (final poly in feature.polygons) {
              if (poly.isNotEmpty) {
                final outerRing = poly.first;
                final holes = poly.length > 1 ? poly.sublist(1) : null;
                polygons.add(
                  Polygon(
                    points: outerRing,
                    holePointsList: holes,
                    color: style.fill ?? style.color.withValues(alpha: 0.25),
                    borderColor: style.border ?? style.color,
                    borderStrokeWidth: style.width,
                  ),
                );
              }
            }

            // Lines
            for (final line in feature.lines) {
              if (line.isNotEmpty) {
                polylines.add(
                  Polyline(
                    points: line,
                    color: style.color,
                    strokeWidth: style.width,
                    pattern: style.dashed
                        ? StrokePattern.dashed(segments: const [8, 5])
                        : const StrokePattern.solid(),
                    borderColor: style.border ?? Colors.transparent,
                    borderStrokeWidth: style.border != null ? 1.0 : 0.0,
                  ),
                );
              }
            }

            // Points
            for (final pt in feature.points) {
              markers.add(
                Marker(
                  point: pt,
                  width: style.radius * 4,
                  height: style.radius * 4,
                  child: GestureDetector(
                    onTap: () => _showFeatureDetails(feature, style.name),
                    child: Container(
                      decoration: BoxDecoration(
                        color: style.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: style.radius,
                          height: style.radius,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          }

          if (polygons.isNotEmpty) {
            layerWidgets.add(PolygonLayer(polygons: polygons));
          }
          if (polylines.isNotEmpty) {
            layerWidgets.add(PolylineLayer(polylines: polylines));
          }
          if (markers.isNotEmpty) {
            layerWidgets.add(MarkerLayer(markers: markers));
          }
        }

        final isStandalone =
            Navigator.of(context).canPop() || widget.onAssetSelected != null;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            key: _scaffoldKey,
            endDrawer: const GisLayerControlDrawer(),
            backgroundColor: const Color(0xFFF3F1EC),
            appBar: isStandalone
                ? AppBar(
                    automaticallyImplyLeading: false,
                    leading: Navigator.of(context).canPop()
                        ? IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'رجوع',
                            onPressed: () => Navigator.of(context).maybePop(),
                          )
                        : null,
                    title: const Text(
                      'خريطة شبكات ونظم المعلومات (GIS)',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Colors.white,
                      ),
                    ),
                    centerTitle: true,
                    backgroundColor: const Color(0xFF0F3B6C),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    actions: [
                      // Quick OSM Toggle
                      IconButton(
                        icon: Icon(
                          state.useOsm
                              ? Icons.layers_clear
                              : Icons.map_outlined,
                          color: Colors.white,
                        ),
                        tooltip: state.useOsm
                            ? 'إخفاء خريطة الأساس'
                            : 'إظهار خريطة الأساس (OSM)',
                        onPressed: () => cubit.toggleOsm(),
                      ),
                      // Layer drawer toggle
                      IconButton(
                        icon: const Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'إدارة الطبقات',
                        onPressed: () {
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                      // Refresh
                      IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'تحديث البيانات',
                        onPressed: () => cubit.reload(),
                      ),
                    ],
                  )
                : null,
            body: Stack(
              children: [
                // 1. The Interactive GIS Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _minyaCenter,
                    initialZoom: 15.0,
                    minZoom: 9.0,
                    maxZoom: 19.0,
                    backgroundColor: const Color(0xFFF3F1EC),
                    onTap: (_, point) => _handleMapTap(point, state),
                    onPositionChanged: (camera, hasGesture) {
                      cubit.onCameraMoved(camera);
                    },
                  ),
                  children: layerWidgets,
                ),

                // Floating GIS Toolbar when embedded inside CrisisDashboard
                if (!isStandalone)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Material(
                      color: const Color(0xFF0F3B6C).withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(14),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                state.useOsm
                                    ? Icons.layers_clear
                                    : Icons.map_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: state.useOsm
                                  ? 'إخفاء خريطة الأساس'
                                  : 'إظهار خريطة الأساس (OSM)',
                              onPressed: () => cubit.toggleOsm(),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.layers_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'إدارة الطبقات الجغرافية',
                              onPressed: () {
                                _scaffoldKey.currentState?.openEndDrawer();
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              tooltip: 'تحديث البيانات',
                              onPressed: () => cubit.reload(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 2. Truncated data warning badge (Per documentation specification)
                if (state.truncatedLayers.isNotEmpty)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'بعض البيانات لم تظهر بالكامل لكبر الحجم، قرّب الخريطة لرؤية المزيد (${state.truncatedLayers.join(", ")})',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 3. Subtle loading indicator during viewport fetch
                if (state.isLayersLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF0284C7),
                      ),
                      minHeight: 3.5,
                    ),
                  ),

                // 4. Map Action Controls (Zoom in/out, Minya focus)
                Positioned(
                  left: 16,
                  bottom: 24,
                  child: Column(
                    children: [
                      _buildMapButton(
                        icon: Icons.add,
                        tooltip: 'تكبير',
                        onPressed: () {
                          final newZoom = (_mapController.camera.zoom + 1.0)
                              .clamp(9.0, 19.0);
                          _mapController.move(
                            _mapController.camera.center,
                            newZoom,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildMapButton(
                        icon: Icons.remove,
                        tooltip: 'تصغير',
                        onPressed: () {
                          final newZoom = (_mapController.camera.zoom - 1.0)
                              .clamp(9.0, 19.0);
                          _mapController.move(
                            _mapController.camera.center,
                            newZoom,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildMapButton(
                        icon: Icons.my_location_rounded,
                        tooltip: 'العودة لمركز المنيا',
                        color: const Color(0xFF0F3B6C),
                        iconColor: Colors.white,
                        onPressed: () {
                          _mapController.move(_minyaCenter, 15.5);
                        },
                      ),
                    ],
                  ),
                ),

                // 5. Current Zoom & Layer Count Badge
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Text(
                      'مستوى الزووم: ${state.currentZoom.toStringAsFixed(1)} | الطبقات: ${state.enabledLayers.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color color = Colors.white,
    Color iconColor = const Color(0xFF1E293B),
  }) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}
