import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';

class ValveRepo {
  final ApiService apiService;
  ValveRepo({required this.apiService});

  Future<ApiResult<AllValvesResponse>> allValves({
    int page = 1,
    int pageSize = 1000,
    MapBounds? bounds,
    int? valveTypeId,
    String? status,
    int? diameter,
    int? pipeDiameter,
    String? direction,
    int? inServiceYear,
  }) async {
    try {
      final response = await apiService.allValves(
        page: page,
        pageSize: pageSize,
        latMin: bounds?.latMin,
        latMax: bounds?.latMax,
        longMin: bounds?.longMin,
        longMax: bounds?.longMax,
        valveTypeId: valveTypeId,
        status: status,
        diameter: diameter,
        pipeDiameter: pipeDiameter,
        direction: direction,
        inServiceYear: inServiceYear,
      );
      return ApiResult.success(response);
    } catch (e) {
      return ApiResult.error(
        ApiErrorModel(error: 'An unexpected error occurred'),
      );
    }
  }
}
