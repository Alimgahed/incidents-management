import 'package:equatable/equatable.dart';
import '../../../valves_map/models/etit_vehicle_model.dart';

class FleetSyncSnapshot extends Equatable {
  final List<EtitVehicleModel> vehicles;
  final DateTime syncedAt;
  final bool metadataFromCache;

  const FleetSyncSnapshot({
    required this.vehicles,
    required this.syncedAt,
    required this.metadataFromCache,
  });

  @override
  List<Object?> get props => [vehicles, syncedAt, metadataFromCache];
}

abstract class FleetRepository {
  /// Returns cached snapshot immediately if available, or null when cold.
  FleetSyncSnapshot? getCachedSnapshot();

  /// Fetches fleet vehicles + live GPS telematics.
  ///
  /// * When [forceFullRefresh] is false and vehicle metadata was fetched within
  ///   [metadataTtl] (5 minutes), reuses the cached vehicle metadata and only
  ///   fetches fresh live GPS coordinates (`GetTransportersSpeedStatus.aspx`).
  /// * Never returns stale GPS coordinates as live without querying the live endpoint.
  Future<FleetSyncSnapshot> fetchFleetWithLiveTracking({
    bool forceFullRefresh = false,
  });

  /// Clears the repository's metadata cache.
  void invalidateCache();
}
