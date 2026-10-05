import 'package:dio/dio.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_model.dart';
import 'package:incidents_managment/core/future/auth/data/model/login_response_model.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/core/offline/domain/sync_manager.dart';
import 'package:incidents_managment/core/helpers/shared_preference.dart';
import 'package:incidents_managment/core/helpers/shared_prefrence_constant.dart';

class LoginRepo {
  final ApiService apiService;
  LoginRepo({required this.apiService});
  Future<ApiResult<LoginResponseModel>> login(LoginModel loginModel) async {
    try {
      final response = await apiService.login(loginModel);

      // Securely cache token and current user profile
      if (response.token != null && response.currentUser != null) {
        final pendingOwnerId = await SharedPreferencesHelper.getData<int>(
          SharedPreferenceKeys.pendingOfflineOwnerId,
        );
        if (pendingOwnerId != null &&
            response.currentUser!.userId != pendingOwnerId) {
          return ApiResult.error(
            ApiErrorModel(
              error:
                  'توجد أعمال غير متزامنة مرتبطة بحساب آخر. سجل الدخول بالحساب الأصلي لمزامنتها أولاً.',
            ),
          );
        }
        if (pendingOwnerId != null) {
          await SharedPreferencesHelper.removeData(
            SharedPreferenceKeys.pendingOfflineOwnerId,
          );
        }
        await getIt<SecureStorageService>().saveUserToken(response.token!);
        await getIt<SessionManager>().setCurrentUser(response.currentUser!);
        if (getIt.isRegistered<SyncManager>()) {
          await getIt<SyncManager>().start();
        }
        return ApiResult.success(response);
      } else {
        return ApiResult.error(
          ApiErrorModel(error: 'بيانات الدخول غير صحيحة أو غير مكتملة'),
        );
      }
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
    } catch (e) {
      return ApiResult.error(
        ApiErrorModel(error: 'حدث خطأ أثناء معالجة الاستجابة'),
      );
    }
  }
}
