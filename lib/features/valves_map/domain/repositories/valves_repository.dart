import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';

abstract class ValvesRepository {
  /// Fetches valves from the remote server and caches them locally.
  Future<List<ValveEntity>> fetchAndCacheValves();

  /// Retrieves valves from the local cache. Ideal for offline use or fast initial load.
  Future<List<ValveEntity>> getCachedValves();

  /// Gets a stream of valves for real-time updates if supported by the backend (e.g. Socket).
  Stream<List<ValveEntity>> getValvesStream();
}
