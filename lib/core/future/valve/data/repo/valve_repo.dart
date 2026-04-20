import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class ValveRepo {
  final ApiService apiService;
  ValveRepo({required this.apiService});
  Future<ApiResult<List<ValveModel>>> allValves() async {
    try {
      final response = await apiService.allValves();
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.error(
        ApiErrorModel(error: 'An unexpected error occurred'),
      );
    }
  }
}
