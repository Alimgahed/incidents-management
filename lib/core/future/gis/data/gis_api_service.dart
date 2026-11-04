import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/future/gis/data/gis_mock_data.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';

class GisApiService {
  final Dio dio;

  /// Custom base URL or prefix if the Flask blueprint is at a sub-path or different host.
  /// Examples:
  /// - null: uses Dio's baseUrl directly
  /// - "https://crises.miniawater.com/gis"
  /// - "http://localhost:5000"
  String? customBaseUrl;

  GisApiService({required this.dio, this.customBaseUrl});

  String _buildUrl(String path) {
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      final base = customBaseUrl!.endsWith('/')
          ? customBaseUrl!.substring(0, customBaseUrl!.length - 1)
          : customBaseUrl!;
      final sub = path.startsWith('/') ? path : '/$path';
      return '$base$sub';
    }
    // Relative to dio.options.baseUrl
    if (path.startsWith('/')) {
      return path.substring(1);
    }
    return path;
  }

  /// Calculates geometry simplification based on map zoom:
  /// - Zoom >= 18: 0 (raw detail)
  /// - Zoom >= 16: 0.5 metres
  /// - Zoom >= 14: 2.0 metres
  /// - Zoom < 14: 8.0 metres
  static double getSimplificationForZoom(double zoom) {
    if (zoom >= 18.0) return 0.0;
    if (zoom >= 16.0) return 0.5;
    if (zoom >= 14.0) return 2.0;
    return 8.0;
  }

  /// Formats LatLngBounds into minLon,minLat,maxLon,maxLat with 20% viewport padding
  static String formatPaddedBbox(LatLngBounds bounds, {double paddingRatio = 0.20}) {
    final latSpan = bounds.north - bounds.south;
    final lngSpan = bounds.east - bounds.west;

    final paddedSouth = (bounds.south - latSpan * paddingRatio).clamp(-90.0, 90.0);
    final paddedNorth = (bounds.north + latSpan * paddingRatio).clamp(-90.0, 90.0);
    final paddedWest = (bounds.west - lngSpan * paddingRatio).clamp(-180.0, 180.0);
    final paddedEast = (bounds.east + lngSpan * paddingRatio).clamp(-180.0, 180.0);

    return '${paddedWest.toStringAsFixed(6)},${paddedSouth.toStringAsFixed(6)},'
        '${paddedEast.toStringAsFixed(6)},${paddedNorth.toStringAsFixed(6)}';
  }

  /// GET /api/layers
  Future<List<GisLayerInfo>> fetchAvailableLayers({CancelToken? cancelToken}) async {
    final candidates = [
      _buildUrl('layers'),
      _buildUrl('api/layers'),
      _buildUrl('gis/layers'),
    ];

    for (final url in candidates) {
      try {
        final response = await dio.get(
          url,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.json,
            headers: {'Accept': 'application/json'},
          ),
        );

        if (response.statusCode == 200 && response.data is List) {
          final list = response.data as List;
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => GisLayerInfo.fromJson(e))
              .toList();
        }
      } catch (e) {
        if (e is DioException && CancelToken.isCancel(e)) rethrow;
        // Continue trying other candidate paths
      }
    }

    // Fallback to default schema layers if backend is not yet accessible
    debugPrint('⚠️ GIS API /layers not responding. Using default schema layers.');
    return GisMockData.defaultLayers;
  }

  /// GET /api/layers/{name}/fields
  Future<List<String>> fetchLayerFields(
    String layerName, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        _buildUrl('layers/$layerName/fields'),
        cancelToken: cancelToken,
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => e.toString()).toList();
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) rethrow;
      debugPrint('GIS API fetchLayerFields error: $e');
    }
    return const [];
  }

  /// GET /api/layers/{name}?bbox=...&limit=...&simplify=...
  Future<GisCollection> fetchLayer({
    required String name,
    required LatLngBounds bounds,
    int limit = 5000,
    double simplify = 0,
    CancelToken? cancelToken,
  }) async {
    final bbox = formatPaddedBbox(bounds);
    final queryParams = {
      'bbox': bbox,
      'limit': limit,
      'simplify': simplify,
    };

    try {
      final response = await dio.get(
        _buildUrl('layers/$name'),
        queryParameters: queryParams,
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.plain, // plain string for off-isolate compute
          headers: {'Accept': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawString = response.data.toString();
        // Offload heavy JSON parsing and coordinate transformation to an isolate
        return await compute(parseCollection, rawString);
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) rethrow;
      debugPrint('GIS API fetchLayer ($name) failed: $e. Returning mock collection.');
    }

    // Graceful fallback to mock data
    return GisMockData.getMockCollection(name);
  }

  /// GET /api/health
  Future<bool> checkHealth({CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        _buildUrl('health'),
        cancelToken: cancelToken,
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
