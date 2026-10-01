import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_missions/incident_mission.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/future/actions/data/repos/all_incident_type_repo.dart';

class AddIncidentMissionRepo {
  final ApiService apiService;

  AddIncidentMissionRepo({required this.apiService});

  Future<ApiResult> addIncidentMission(IncidentMission incidentMission) async {
    try {
      final response = await apiService.addIncidentMission(incidentMission);
      // Invalidate the local SharedPreferences cache for incident types!
      await AllIncidentTypeRepo.invalidateCache();
      return ApiResult.success(response);
    } on DioException catch (e) {
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
}
