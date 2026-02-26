import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class AllActiveUserRepo {
  final ApiService apiService;
  AllActiveUserRepo({required this.apiService});
  Future<ApiResult<List<ActiveUser>>> allActiveUsers() async {
    try {
      final response = await apiService.allActiveUsers();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.error(
        ApiErrorModel(error: 'An unexpected error occurred'),
      );
    }
  }
}
