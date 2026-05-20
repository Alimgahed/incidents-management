import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/helpers/lookup_cache.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class AllIncidentTypeRepo {
  final ApiService apiService;

  AllIncidentTypeRepo({required this.apiService});

  /// SharedPreferences key for the incident-types lookup cache.
  static const String _cacheKey = 'lookup_incident_types';

  Future<ApiResult<List<IncidentType>>> getAllIncidentTypes() async {
    // ── 1. Serve from fresh local cache (avoids network round-trip on restart) ──
    final cached = await LookupCacheService.read(_cacheKey);
    if (cached != null) {
      return ApiResult.success(
        List<IncidentType>.generate(
          cached.length,
          (i) => IncidentType.fromJson(cached[i]),
          growable: false,
        ),
      );
    }

    // ── 2. Cache miss or expired → fetch from network ──
    try {
      final response = await apiService.getAllIncidentTypes();

      // Persist to local cache for next app start (fire-and-forget).
      LookupCacheService.write(
        _cacheKey,
        response.map((e) => e.toJson()).toList(growable: false),
      );

      return ApiResult.success(response);
    } on DioException catch (e) {
      // ── 3. Network failed → fall back to stale cache if available ──
      final stale = await LookupCacheService.readStale(_cacheKey);
      if (stale != null) {
        return ApiResult.success(
          List<IncidentType>.generate(
            stale.length,
            (i) => IncidentType.fromJson(stale[i]),
            growable: false,
          ),
        );
      }

      // No cache at all — surface the network error to the UI.
      if (e.response?.data != null) {
        try {
          final errorModel = ApiErrorModel.fromJson(e.response!.data);
          return ApiResult.error(errorModel);
        } catch (_) {
          return ApiResult.error(
            ApiErrorModel(error: 'Failed to parse error response'),
          );
        }
      } else {
        return ApiResult.error(
          ApiErrorModel(error: 'Network error. Please check your connection'),
        );
      }
    } catch (e) {
      return ApiResult.error(
        ApiErrorModel(error: 'An unexpected error occurred'),
      );
    }
  }

  /// Call this after a successful add/edit/delete of an incident type so the
  /// next [getAllIncidentTypes] call fetches fresh data from the server.
  static Future<void> invalidateCache() =>
      LookupCacheService.invalidate(_cacheKey);
}
