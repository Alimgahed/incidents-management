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

  
  void _showServerConfigDialog() {
    final cubit = context.read<GisCubit>();
    final currentUrl = cubit.apiService.customBaseUrl ?? cubit.apiService.dio.options.baseUrl;
    final controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                cubit.apiService.isServerAvailable
                    ? Icons.cloud_done_rounded
                    : Icons.cloud_off_rounded,
                color: cubit.apiService.isServerAvailable
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 8),
              const Text(
                'حالة خادم الـ GIS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cubit.apiService.isServerAvailable
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cubit.apiService.isServerAvailable
                      ? 'الخادم متصل وجارٍ جلب الطبقات مباشرة من خادم الـ Geodatabase.'
                      : 'الخادم غير متصل أو لم يُفعّل بعد على هذا الرابط (HTTP 404). لا يتم عرض أي بيانات افتراضية على الخريطة.',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    color: cubit.apiService.isServerAvailable
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'رابط خدمة الـ GIS (Flask Blueprint):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'https://crises.miniawater.com/api أو http://localhost:5000',
                  hintStyle: const TextStyle(fontSize: 11),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3B6C),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                cubit.setCustomBaseUrl(controller.text);
                Navigator.pop(ctx);
              },
              child: const Text('حفظ واختبار', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
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
      final isEnabled = state.enabledLayers.contains(s.name) ||
          s.aliases.any((a) => state.enabledLayers.contains(a));
      return isEnabled && state.currentZoom >= s.minZoom;
    });

    for (final style in activeStyles) {
      GisCollection? col = state.layerData[style.name];
      if (col == null) {
        for (final a in style.aliases) {
          if (state.layerData.containsKey(a)) {
            col = state.layerData[a];
            break;
          }
        }
      }
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
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.miniawater.crises',
            ),
          );
        }

        // 2. Iterate gisLayerStack in bottom-to-top drawing order
        final labelMarkers = <Marker>[];

        for (final style in gisLayerStack) {
          final isEnabled = state.enabledLayers.contains(style.name) ||
              style.aliases.any((a) => state.enabledLayers.contains(a));
          final meetsZoom = state.currentZoom >= style.minZoom;
          if (!isEnabled || !meetsZoom) continue;

          GisCollection? collection = state.layerData[style.name];
          if (collection == null) {
            for (final a in style.aliases) {
              if (state.layerData.containsKey(a)) {
                collection = state.layerData[a];
                break;
              }
            }
          }
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

            // Building Name Labels on Vector Base Map
            if ((style.name == 'buildings' || style.aliases.contains('building')) &&
                state.currentZoom >= 15.0 &&
                feature.center != null) {
              final bName = feature.props['name'] ?? feature.props['NAME'] ?? feature.props['building_name'];
              if (bName != null && bName.toString().trim().isNotEmpty) {
                labelMarkers.add(
                  Marker(
                    point: feature.center!,
                    width: 140,
                    height: 38,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFA1887F), width: 0.7),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1)),
                          ],
                        ),
                        child: Text(
                          bName.toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ),
                    ),
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

            // Street Name Labels on Vector Base Map
            if ((style.name == 'streets' || style.aliases.contains('street')) &&
                state.currentZoom >= 14.0 &&
                feature.center != null) {
              final sName = feature.props['street_name'] ?? feature.props['STREET_NAME'] ?? feature.props['name'];
              if (sName != null && sName.toString().trim().isNotEmpty) {
                labelMarkers.add(
                  Marker(
                    point: feature.center!,
                    width: 150,
                    height: 28,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBDBDBD), width: 0.7),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 2),
                          ],
                        ),
                        child: Text(
                          sName.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                            color: Color(0xFF424242),
                          ),
                        ),
                      ),
                    ),
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

        // Add Base Map Text Labels (Buildings, Streets, Landmarks)
        if (labelMarkers.isNotEmpty) {
          layerWidgets.add(MarkerLayer(markers: labelMarkers));
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
                    initialZoom: 15.5,
                    minZoom: 9.0,
                    maxZoom: 19.0,
                    backgroundColor: const Color(0xFFF3F1EC),
                    onMapReady: () {
                      cubit.onCameraMoved(_mapController.camera);
                    },
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
                              icon: Icon(
                                cubit.apiService.isServerAvailable
                                    ? Icons.cloud_done_rounded
                                    : Icons.cloud_queue_rounded,
                                color: cubit.apiService.isServerAvailable
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFFFBBF24),
                                size: 20,
                              ),
                              tooltip: cubit.apiService.isServerAvailable
                                  ? 'الخادم متصل'
                                  : 'إعدادات ورابط الخادم',
                              onPressed: _showServerConfigDialog,
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

                // Notice if backend is offline/mock
                if (!cubit.apiService.isServerAvailable)
                  Positioned(
                    bottom: 24,
                    left: 70,
                    right: 210,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF38BDF8)),
                            const SizedBox(width: 8),
                            const Flexible(
                              child: Text(
                                'خادم GIS غير متصل · لا توجد طبقات جغرافية للعرض',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showServerConfigDialog,
                              child: const Text(
                                'تغيير الرابط',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF38BDF8),
                                  fontFamily: 'Cairo',
                                  decoration: TextDecoration.underline,
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
