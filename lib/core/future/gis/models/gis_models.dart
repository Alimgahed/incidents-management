import 'dart:convert';
import 'package:latlong2/latlong.dart';

class GisFeature {
  final int? id;
  final Map<String, dynamic> props;
  final List<LatLng> points; // Point / MultiPoint
  final List<List<LatLng>> lines; // LineString / MultiLineString
  final List<List<List<LatLng>>> polygons; // Polygon / MultiPolygon [outer, hole1, ...]

  const GisFeature(
    this.id,
    this.props, {
    this.points = const [],
    this.lines = const [],
    this.polygons = const [],
  });

  /// Approximate center or representative location for camera focusing or tapping
  LatLng? get center {
    if (points.isNotEmpty) return points.first;
    if (lines.isNotEmpty && lines.first.isNotEmpty) {
      final line = lines.first;
      return line[line.length ~/ 2];
    }
    if (polygons.isNotEmpty &&
        polygons.first.isNotEmpty &&
        polygons.first.first.isNotEmpty) {
      final ring = polygons.first.first;
      double sumLat = 0;
      double sumLng = 0;
      for (final p in ring) {
        sumLat += p.latitude;
        sumLng += p.longitude;
      }
      return LatLng(sumLat / ring.length, sumLng / ring.length);
    }
    return null;
  }
}

class GisCollection {
  final String layer;
  final bool truncated;
  final int count;
  final List<GisFeature> features;

  const GisCollection(
    this.layer,
    this.truncated,
    this.features, {
    this.count = 0,
  });

  static const empty = GisCollection('', false, []);
}

class GisLayerInfo {
  final String name;
  final List<String> aliases;
  final String geometryType; // point | line | polygon
  final String category; // basemap | water_network | wastewater_network | operations
  final String titleAr;
  final int minZoom;
  final bool defaultEnabled;
  final bool versionedView;

  const GisLayerInfo({
    required this.name,
    this.aliases = const [],
    required this.geometryType,
    this.category = 'basemap',
    this.titleAr = '',
    this.minZoom = 12,
    this.defaultEnabled = false,
    this.versionedView = false,
  });

  factory GisLayerInfo.fromJson(Map<String, dynamic> json) {
    return GisLayerInfo(
      name: (json['name'] ?? '').toString().toLowerCase(),
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      geometryType: (json['geometry_type'] ?? '').toString().toLowerCase(),
      category: (json['category'] ?? 'basemap').toString().toLowerCase(),
      titleAr: (json['title_ar'] ?? json['name'] ?? '').toString(),
      minZoom: (json['min_zoom'] as num?)?.toInt() ?? 12,
      defaultEnabled: json['default_enabled'] == true,
      versionedView: json['versioned_view'] == true,
    );
  }
}

LatLng _ll(List c) =>
    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()); // GeoJSON is [lon, lat]
List<LatLng> _line(List l) => [for (final c in l) _ll(c as List)];

/// Top-level parser suitable for compute(parseCollection, responseBody)
GisCollection parseCollection(String body) {
  final j = jsonDecode(body) as Map<String, dynamic>;
  final features = <GisFeature>[];
  final rawFeatures = j['features'] as List? ?? const [];

  for (final f in rawFeatures) {
    if (f is! Map) continue;
    final g = f['geometry'] as Map<String, dynamic>?;
    if (g == null) continue;
    final c = g['coordinates'] as List?;
    if (c == null) continue;

    final id = (f['id'] as num?)?.toInt() ??
        (f['properties'] is Map ? (f['properties']['OBJECTID'] as num?)?.toInt() : null);
    final props = f['properties'] is Map
        ? Map<String, dynamic>.from(f['properties'] as Map)
        : <String, dynamic>{};

    switch (g['type']) {
      case 'Point':
        features.add(GisFeature(id, props, points: [_ll(c)]));
        break;
      case 'MultiPoint':
        features.add(
            GisFeature(id, props, points: [for (final p in c) _ll(p as List)]));
        break;
      case 'LineString':
        features.add(GisFeature(id, props, lines: [_line(c)]));
        break;
      case 'MultiLineString':
        features.add(GisFeature(id, props,
            lines: [for (final l in c) _line(l as List)]));
        break;
      case 'Polygon':
        features.add(GisFeature(id, props,
            polygons: [[for (final r in c) _line(r as List)]]));
        break;
      case 'MultiPolygon':
        features.add(GisFeature(id, props, polygons: [
          for (final p in c) [for (final r in p as List) _line(r as List)]
        ]));
        break;
    }
  }

  return GisCollection(
    j['layer']?.toString() ?? '',
    j['truncated'] == true,
    features,
    count: (j['count'] as num?)?.toInt() ?? features.length,
  );
}
