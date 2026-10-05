import 'package:dio/dio.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/network/api_error_model.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/offline/data/models/cached_incident.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/domain/temp_id_generator.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';
import 'package:incidents_managment/core/offline/network/offline_interceptor.dart';

/// Repository for creating a new incident.
///
/// This class is the **reference implementation** for the offline-first
/// integration pattern other repositories should follow:
///   1. Generate a temp id locally if we're about to write while offline.
///   2. Pass `entityRef` + `tempLocalId` through Dio `extra` so the
///      [OfflineInterceptor] can stamp them onto the queued [SyncQueueItem].
///   3. Write to the local cache *before* awaiting the network — the UI
///      reads from the cache and is updated optimistically.
///   4. On success of an online call, refresh the cache with the server's
///      authoritative payload.
///
/// The signature ([addIncdient]) is unchanged so existing callers continue to
/// work without modification.
class AddIncdientRepo {
  final ApiService apiService;
  final IncidentCacheRepository _cache = getIt<IncidentCacheRepository>();
  final NetworkMonitorService _monitor = getIt<NetworkMonitorService>();
  final Dio _dio = getIt<Dio>();

  AddIncdientRepo({required this.apiService});

  Future<ApiResult> addIncdient(CurrentIncidentModel mission) async {
    final isOffline = _monitor.isOffline;

    // ── 1. Generate / reuse a temp id and write to the optimistic cache ─────
    int tempId = mission.currentIncidentId ?? TempIdGenerator.nextNumeric();
    if (tempId == 0) tempId = TempIdGenerator.nextNumeric();

    final payload = mission.toJson();
    // The same identifier is sent for both the first request and a possible
    // offline replay so the optimistic row and replay metadata stay aligned.
    if (isOffline) payload['current_incident_id'] = tempId;

    final optimistic = CachedIncident.fromMap(
      payload,
      idOrTempId: tempId,
      hasPendingChanges: isOffline,
    );
    await _cache.upsert(optimistic);

    // ── 2. Either go through the interceptor (queue) or the real API ────────
    try {
      final response = await _dio.post(
        ApiConstants.addcurrentincdient,
        data: payload,
        options: Options(
          extra: {
            OfflineInterceptor.kEntityRef: 'incident:$tempId',
            OfflineInterceptor.kTempLocalId: tempId.toString(),
          },
        ),
      );
      final queued =
          response.statusCode == 202 ||
          (response.data is Map && response.data['__offline'] == true);
      if (queued) {
        await _cache.markPending(tempId, true);
        return ApiResult.success(response.data);
      }

      // Replace the optimistic temp row with the server's authoritative copy.
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final serverId =
            responseData['current_incident_id'] ?? responseData['id'];
        final parsedServerId = serverId is int
            ? serverId
            : int.tryParse('$serverId');
        if (parsedServerId != null && parsedServerId > 0) {
          await _cache.remove(tempId);
          await _cache.upsert(
            CachedIncident.fromMap(responseData, idOrTempId: parsedServerId),
          );
        }
      }
      return ApiResult.success(responseData);
    } on DioException catch (e) {
      await _cache.remove(tempId);
      // The interceptor already handled the "offline transport failure" case
      // by resolving with a synthetic 202; anything reaching here is a real
      // server error worth surfacing.
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
          ApiErrorModel(error: 'Network error. Please check your connection'),
        );
      }
    } catch (e) {
      await _cache.remove(tempId);
      return ApiResult.error(
        ApiErrorModel(error: 'An unexpected error occurred'),
      );
    }
  }
}
