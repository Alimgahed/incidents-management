import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/mission_assgien_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class MissionAssignRepo {
  final ApiService apiService;

  MissionAssignRepo({required this.apiService});

  Future<ApiResult<dynamic>> missionUserAssign(
    int currentIncidentMissionId,
    List<MissionAssgienModel> data,
  ) async {
    try {
      final response = await apiService.missionUserAssign(
        currentIncidentMissionId,
        data,
      );
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
        return ApiResult.error(
          ApiErrorModel(error: e.message ?? 'Unknown Dio error'),
        );
      }
    } catch (e) {
      return ApiResult.error(ApiErrorModel(error: e.toString()));
    }
  }
}
