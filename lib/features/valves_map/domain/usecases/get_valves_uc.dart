import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';
import 'package:incidents_managment/features/valves_map/domain/repositories/valves_repository.dart';

class GetValvesUseCase {
  final ValvesRepository repository;

  GetValvesUseCase(this.repository);

  /// Returns cached valves immediately for fast UI rendering,
  /// then fetches fresh data from the server in the background.
  Future<List<ValveEntity>> call({bool forceRefresh = false}) async {
    if (forceRefresh) {
      return await repository.fetchAndCacheValves();
    }
    
    final cached = await repository.getCachedValves();
    if (cached.isNotEmpty) {
      // Trigger background sync but return cached instantly
      repository.fetchAndCacheValves();
      return cached;
    }

    return await repository.fetchAndCacheValves();
  }
}
