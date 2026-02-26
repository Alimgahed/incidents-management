import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class MissionAssignRepo {
  final ApiService apiService;
  MissionAssignRepo({required this.apiService});
  Future<ApiResult<List<MissionAssgienModel>>> missionUserAssign(
    int currentIncidentMissionId,
  ) async {
    try {
      final response = await apiService.missionUserAssign(
        currentIncidentMissionId,
      );
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.error(
        ApiErrorModel(error: 'An unexpected error occurred'),
      );
    }
  }
}
