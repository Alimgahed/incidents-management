import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/actions/data/models/all_incident_type.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class AllIncidentTypeRepo {
  final ApiService apiService;

  AllIncidentTypeRepo({required this.apiService});

  Future<ApiResult<List<IncidentType>>> getAllIncidentTypes() async {
    try {
      final response = await apiService.getAllIncidentTypes();
      return ApiResult.success(response);
    } on DioException catch (e) {
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
