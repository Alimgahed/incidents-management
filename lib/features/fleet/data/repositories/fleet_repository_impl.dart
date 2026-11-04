import '../../../valves_map/models/etit_vehicle_model.dart';
import '../../../valves_map/services/etit_gps_service.dart';
import '../../core/error/fleet_failure.dart';
import '../../domain/repositories/fleet_repository.dart';

class FleetRepositoryImpl implements FleetRepository {
  final EtitGpsService _gpsService;
  final Duration metadataTtl;

  List<EtitVehicleModel>? _cachedBaseMetadata;
  DateTime? _lastMetadataFetchTime;
  FleetSyncSnapshot? _latestSnapshot;

  FleetRepositoryImpl({
    EtitGpsService? gpsService,
    this.metadataTtl = const Duration(minutes: 5),
  }) : _gpsService = gpsService ?? EtitGpsService();

  bool get _hasValidMetadataCache {
    if (_cachedBaseMetadata == null ||
        _cachedBaseMetadata!.isEmpty ||
        _lastMetadataFetchTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastMetadataFetchTime!) < metadataTtl;
  }

  @override
  FleetSyncSnapshot? getCachedSnapshot() => _latestSnapshot;

  @override
  Future<FleetSyncSnapshot> fetchFleetWithLiveTracking({
    bool forceFullRefresh = false,
  }) async {
    try {
      final useCachedMetadata = !forceFullRefresh && _hasValidMetadataCache;

      late final List<EtitVehicleModel> baseVehicles;
      late final Map<String, Map<String, dynamic>> liveCoords;

      if (useCachedMetadata) {
        baseVehicles = _cachedBaseMetadata!;
        liveCoords = await _gpsService.getLiveCoordinates(throwOnError: true);
      } else {
        final results = await Future.wait([
          _gpsService.getVehicles(throwOnError: true),
          _gpsService.getLiveCoordinates(throwOnError: true),
        ]);
        baseVehicles = results[0] as List<EtitVehicleModel>;
        liveCoords = results[1] as Map<String, Map<String, dynamic>>;

        if (baseVehicles.isNotEmpty) {
          _cachedBaseMetadata = baseVehicles;
          _lastMetadataFetchTime = DateTime.now();
        }
      }

      final merged = _gpsService.mergeVehiclesWithLiveMap(
        baseVehicles,
        liveCoords,
      );
      final snapshot = FleetSyncSnapshot(
        vehicles: merged,
        syncedAt: DateTime.now(),
        metadataFromCache: useCachedMetadata,
      );
      _latestSnapshot = snapshot;
      return snapshot;
    } catch (e) {
      throw FleetFailure.fromException(e);
    }
  }

  @override
  void invalidateCache() {
    _cachedBaseMetadata = null;
    _lastMetadataFetchTime = null;
    _latestSnapshot = null;
  }
}
