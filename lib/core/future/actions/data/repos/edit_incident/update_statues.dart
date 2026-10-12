import 'package:dio/dio.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/network/offline_interceptor.dart';

class UpdateStatuesRepo {
  final ApiService apiService;

  UpdateStatuesRepo({required this.apiService});

  Future<ApiResult<dynamic>> updateStatues(
    CurrentIncidentWithMissions incident,
    int id1,
    int id2,
    int id3,
  ) async {
    final cache = getIt.isRegistered<IncidentCacheRepository>()
        ? getIt<IncidentCacheRepository>()
        : null;
    final dio = getIt.isRegistered<Dio>() ? getIt<Dio>() : Dio();

    try {
      final endpoint = ApiConstants.editcurrentmissions
          .replaceAll('{id1}', '$id1')
          .replaceAll('{id2}', '$id2')
          .replaceAll('{id3}', '$id3');

      final response = await dio.post(
        endpoint,
        data: incident.toJson(),
        options: Options(
          extra: {
            OfflineInterceptor.kEntityRef: 'incident:$id1',
          },
        ),
      );

      final queued = response.statusCode == 202 ||
          (response.data is Map && response.data['__offline'] == true);
      if (queued) {
        if (cache != null) await cache.markPending(id1, true);
        return ApiResult.success(response.data);
      }

      if (cache != null) {
        await cache.markPending(id1, false);
      }
      return ApiResult.success(response.data);
    } on DioException catch (e) {
      if (cache != null &&
          e.response?.statusCode != null &&
          e.response!.statusCode! >= 400) {
        await cache.markConflict(id1, true);
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
