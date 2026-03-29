import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/auth/data/model/registration_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class RegistrationGet {
  final ApiService apiService;
  RegistrationGet({required this.apiService});
  Future<ApiResult<RegistrationModel>> getregister() async {
    try {
      final response = await apiService.getregister();
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
        // No response from server (network issue)
        return ApiResult.error(
          ApiErrorModel(error: 'Network error. Please check your connection'),
        );
      }
    }
  }
}
