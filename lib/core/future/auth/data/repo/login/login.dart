import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_model.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_response_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';

class LoginRepo {
  final ApiService apiService;
  LoginRepo({required this.apiService});
  Future<ApiResult<LoginResponseModel>> login(LoginModel loginModel) async {
    try {
      final response = await apiService.login(loginModel);

      // Cache token
      if (response.token != null) {
        await SharedPreferencesHelper.saveData(
          SharedPreferenceKeys.userToken,
          response.token!,
        );
      }
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
