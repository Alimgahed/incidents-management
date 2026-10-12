import 'package:dio/dio.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/offline/data/models/cached_incident.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/network/offline_interceptor.dart';

class EditIncidentRepo {
  final ApiService apiService;

  EditIncidentRepo({required this.apiService});

  Future<ApiResult<dynamic>> editIncident(CurrentIncidentModel incident, int id) async {
    final cache = getIt.isRegistered<IncidentCacheRepository>()
        ? getIt<IncidentCacheRepository>()
        : null;
    final dio = getIt.isRegistered<Dio>() ? getIt<Dio>() : Dio();

    final payload = incident.toJson();
    final existing = cache?.get(id);

    // 1. Optimistically update local cache
    if (cache != null) {
      final mergedMap = existing != null ? existing.toMap() : <String, dynamic>{};
      mergedMap.addAll(payload);
      mergedMap['current_incident_id'] = id;
      await cache.upsert(
        CachedIncident.fromMap(
          mergedMap,
          idOrTempId: id,
          hasPendingChanges: true,
        ),
      );
    }

    // 2. Dispatch network request through Dio with entityRef
    try {
      final endpoint =
          ApiConstants.editcurrentincdient.replaceAll('{id}', '$id');
      final response = await dio.post(
        endpoint,
        data: payload,
        options: Options(
          extra: {
            OfflineInterceptor.kEntityRef: 'incident:$id',
          },
        ),
      );

      final queued = response.statusCode == 202 ||
          (response.data is Map && response.data['__offline'] == true);
      if (queued) {
        if (cache != null) await cache.markPending(id, true);
        return ApiResult.success(response.data);
      }

      // Online success: clear pending flag and merge authoritative response
      if (cache != null) {
        await cache.markPending(id, false);
        if (response.data is Map<String, dynamic>) {
          final resMap = response.data as Map<String, dynamic>;
          final merged =
              existing != null ? existing.toMap() : <String, dynamic>{};
          merged.addAll(resMap);
          merged['current_incident_id'] = id;
          await cache.upsert(
            CachedIncident.fromMap(merged, idOrTempId: id),
          );
        }
      }
      return ApiResult.success(response.data);
    } on DioException catch (e) {
      if (cache != null &&
          e.response?.statusCode != null &&
          e.response!.statusCode! >= 400) {
        await cache.markConflict(id, true);
      }
      // Backend returned an error response
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
        // No response from server (network issue)
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
}
