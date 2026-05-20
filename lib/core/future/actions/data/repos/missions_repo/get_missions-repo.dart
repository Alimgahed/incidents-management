import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/helpers/lookup_cache.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class AllMissionsRepo {
  final ApiService apiService;

  AllMissionsRepo({required this.apiService});

  /// SharedPreferences key for the missions lookup cache.
  static const String _cacheKey = 'lookup_missions';

  Future<ApiResult<List<AllMissionModel>>> getAllMissions() async {
    // ── 1. Serve from fresh local cache ──
    final cached = await LookupCacheService.read(_cacheKey);
    if (cached != null) {
      return ApiResult.success(
        List<AllMissionModel>.generate(
          cached.length,
          (i) => AllMissionModel.fromJson(cached[i]),
          growable: false,
        ),
      );
    }

    // ── 2. Cache miss or expired → fetch from network ──
    try {
      final response = await apiService.getAllMissions();

      // Persist to local cache (fire-and-forget).
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
          List<AllMissionModel>.generate(
            stale.length,
            (i) => AllMissionModel.fromJson(stale[i]),
            growable: false,
          ),
        );
      }

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

  /// Call after adding/editing/deleting a mission so the next fetch is fresh.
  static Future<void> invalidateCache() =>
      LookupCacheService.invalidate(_cacheKey);
}
