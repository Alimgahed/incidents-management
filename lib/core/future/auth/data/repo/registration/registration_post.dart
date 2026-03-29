import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';


class RegistrationPost {
  final ApiService apiService;
  RegistrationPost({required this.apiService});
  Future<ApiResult<dynamic>> register(ActiveUser user) async {
    try {
      final response = await apiService.register(user);
      return ApiResult.success(response);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          final errorModel = ApiErrorModel.fromJson(e.response!.data);
          return ApiResult.error(errorModel);
        } catch (_) {
          // If the error format is not an object or has a different structure
          return ApiResult.error(ApiErrorModel(error: e.response?.data?.toString() ?? 'خطأ غير معروف من الخادم'));
        }
      }
      return ApiResult.error(ApiErrorModel(error: 'مشكلة في الاتصال بالخادم'));
    } catch (e) {
      return ApiResult.error(ApiErrorModel(error: 'حدث خطأ غير متوقع'));
    }
  }
}