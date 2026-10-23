import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/auth/data/model/registration_model.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';

class ReportsRepo {
  final Dio _dio;

  ReportsRepo({required Dio dio}) : _dio = dio;

  /// Fetches available branches/sectors dynamically from the authoritative backend `/register` API.
  Future<List<Sector>> getBranches() async {
    try {
      final response = await _dio.get(
        ApiConstants.register,
        options: Options(
          extra: {'noCache': true},
        ),
      );
      if (response.data is Map<String, dynamic>) {
        final reg = RegistrationModel.fromJson(response.data);
        return reg.sectors;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ReportsRepo: error fetching branches: $e');
      }
    }
    return [];
  }

  /// Fetches all current incidents from the `/current-incidents` endpoint.
  /// Falls back to local Hive cache or IncidentMapCubit live stream if network is unavailable.
  Future<ApiResult<List<CurrentIncidentModel>>> getCurrentIncidents() async {
    try {
      final response = await _dio.get(
        ApiConstants.currentIncidents,
        options: Options(
          extra: {'noCache': true},
        ),
      );

      dynamic rawData = response.data;
      List<dynamic> listData = [];

      if (rawData is List) {
        listData = rawData;
      } else if (rawData is Map<String, dynamic>) {
        if (rawData['data'] is List) {
          listData = rawData['data'];
        } else if (rawData['incidents'] is List) {
          listData = rawData['incidents'];
        }
      }

      final incidents = <CurrentIncidentModel>[];
      for (final item in listData) {
        if (item is Map) {
          try {
            incidents.add(
              CurrentIncidentModel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            if (kDebugMode) {
              debugPrint('ReportsRepo: error parsing incident: $e');
            }
          }
        }
      }

      // If network returned valid data, sort descending by creation date and return
      if (incidents.isNotEmpty) {
        _sortIncidents(incidents);
        return ApiResult.success(incidents);
      }

      // If empty from network, try local fallback
      final fallback = _getLocalFallback();
      if (fallback.isNotEmpty) {
        return ApiResult.success(fallback);
      }

      return ApiResult.success(incidents);
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('ReportsRepo: DioException on /current-incidents: $e');
      }

      // Try local cache or live cubit fallback when network error occurs
      final fallback = _getLocalFallback();
      if (fallback.isNotEmpty) {
        return ApiResult.success(fallback);
      }

      final errorMsg = e.response?.data is Map &&
              (e.response!.data as Map).containsKey('message')
          ? (e.response!.data as Map)['message'].toString()
          : 'تعذر تحميل بيانات تقارير الأزمات من الخادم';

      return ApiResult.error(ApiErrorModel(error: errorMsg));
    } catch (e) {
      final fallback = _getLocalFallback();
      if (fallback.isNotEmpty) {
        return ApiResult.success(fallback);
      }

      return ApiResult.error(
        ApiErrorModel(error: 'حدث خطأ غير متوقع أثناء معالجة بيانات التقارير'),
      );
    }
  }

  /// Attempts to read from IncidentCacheRepository (Hive) or IncidentMapCubit
  List<CurrentIncidentModel> _getLocalFallback() {
    try {
      if (getIt.isRegistered<IncidentMapCubit>()) {
        final cubitIncidents = getIt<IncidentMapCubit>().incidentss;
        if (cubitIncidents.isNotEmpty) {
          final copy = List<CurrentIncidentModel>.from(cubitIncidents);
          _sortIncidents(copy);
          return copy;
        }
      }

      if (getIt.isRegistered<IncidentCacheRepository>()) {
        final cached = getIt<IncidentCacheRepository>().list(limit: 1000);
        if (cached.isNotEmpty) {
          final list = <CurrentIncidentModel>[];
          for (final item in cached) {
            try {
              list.add(CurrentIncidentModel.fromJson(item.toMap()));
            } catch (_) {}
          }
          if (list.isNotEmpty) {
            _sortIncidents(list);
            return list;
          }
        }
      }
    } catch (_) {}
    return [];
  }

  void _sortIncidents(List<CurrentIncidentModel> list) {
    list.sort((a, b) {
      final aDate = a.currentIncidentCreatedAt;
      final bDate = b.currentIncidentCreatedAt;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  }
}
