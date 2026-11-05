import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';

class GisApiService {
  final Dio dio;

  /// Custom base URL or prefix if the Flask blueprint is at a sub-path or different host.
  /// Examples:
  /// - null: uses Dio's baseUrl directly
  /// - "http://localhost:5000"
  /// - "https://crises.miniawater.com/gis"
  String? customBaseUrl;

  /// Flag indicating whether the backend Flask server is reachable
  bool isServerAvailable = false;

  GisApiService({required this.dio, this.customBaseUrl});

  /// Safely builds a fully qualified URL ensuring single slashes between segments
  String _buildUrl(String path) {
    String base;
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      base = customBaseUrl!;
    } else {
      base = dio.options.baseUrl;
    }

    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$base$cleanPath';
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
    final candidates = <String>[];
    if (customBaseUrl != null && customBaseUrl!.isNotEmpty) {
      candidates.add(_buildUrl('layers'));
    } else {
      final rootHost = dio.options.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
      candidates.addAll([
        _buildUrl('layers'), // https://crises.miniawater.com/api/layers
        '$rootHost/gis/api/layers', // https://crises.miniawater.com/gis/api/layers
        _buildUrl('gis/layers'), // https://crises.miniawater.com/api/gis/layers
      ]);
    }

    for (final url in candidates) {
      try {
        final response = await dio.get(
          url,
          cancelToken: cancelToken,
          options: Options(
            responseType: ResponseType.json,
            headers: {'Accept': 'application/json'},
            sendTimeout: kIsWeb ? null : const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 4),
            extra: {'noRetry': true},
          ),
        );

        if (response.statusCode == 200 && response.data is List) {
          isServerAvailable = true;
          final list = response.data as List;
          final rootHost = dio.options.baseUrl.replaceAll(RegExp(r'/api/?$'), '');
          if (url.contains('/gis/api/')) {
            customBaseUrl = '$rootHost/gis/api';
          } else if (url.contains('/api/gis/')) {
            customBaseUrl = '$rootHost/api/gis';
          } else {
            customBaseUrl ??= dio.options.baseUrl;
          }

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

    isServerAvailable = false;
    debugPrint('ℹ️ GIS API: No remote GIS layers available from server.');
    return const [];
  }

  /// GET /api/layers/{name}/fields
  Future<List<String>> fetchLayerFields(
    String layerName, {
    CancelToken? cancelToken,
  }) async {
    if (!isServerAvailable) return const [];

    try {
      final response = await dio.get(
        _buildUrl('layers/$layerName/fields'),
        cancelToken: cancelToken,
        options: Options(
          responseType: ResponseType.json,
          headers: {'Accept': 'application/json'},
          sendTimeout: kIsWeb ? null : const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          extra: {'noRetry': true},
        ),
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
    // If backend was unreachable or returned no schema, do not load mock data
    if (!isServerAvailable) {
      return GisCollection(name, false, const []);
    }

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
          responseType: ResponseType.plain,
          headers: {'Accept': 'application/json'},
          sendTimeout: kIsWeb ? null : const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
          extra: {'noRetry': true},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawString = response.data.toString();
        return await compute(parseCollection, rawString);
      }
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) rethrow;
      debugPrint('GIS API fetchLayer ($name) failed: $e');
    }

    return GisCollection(name, false, const []);
  }

  /// GET /api/health
  Future<bool> checkHealth({CancelToken? cancelToken}) async {
    try {
      final response = await dio.get(
        _buildUrl('health'),
        cancelToken: cancelToken,
        options: Options(
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: kIsWeb ? null : const Duration(seconds: 4),
          headers: {'Accept': 'application/json'},
          extra: {'noRetry': true},
        ),
      );
      final isOk = response.statusCode == 200;
      isServerAvailable = isOk;
      return isOk;
    } catch (_) {
      isServerAvailable = false;
      return false;
    }
  }
}
