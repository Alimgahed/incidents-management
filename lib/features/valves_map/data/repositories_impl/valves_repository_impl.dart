import 'package:incidents_managment/features/valves_map/data/models/valve_model.dart';
import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';
import 'package:incidents_managment/features/valves_map/domain/repositories/valves_repository.dart';

// Note: In a real app, inject LocalDataSource and RemoteDataSource via GetIt.
class ValvesRepositoryImpl implements ValvesRepository {
  // Mocking a local cache for offline capabilities
  final List<ValveModel> _cachedValves = [
    ValveModel(id: 1, name: 'محبس رئيسي 1', latitude: 24.7136, longitude: 46.6753, status: 1, zone: 'الرياض', lastUpdated: DateTime.now()),
    ValveModel(id: 2, name: 'محبس فرعي A', latitude: 24.7236, longitude: 46.6853, status: 1, zone: 'الرياض', lastUpdated: DateTime.now()),
    ValveModel(id: 3, name: 'محبس الطوارئ', latitude: 24.7036, longitude: 46.6653, status: 2, zone: 'الرياض', lastUpdated: DateTime.now()),
    ValveModel(id: 4, name: 'محبس الخط الغربي', latitude: 24.7100, longitude: 46.6500, status: 1, zone: 'الرياض', lastUpdated: DateTime.now()),
    // Adding a few more for testing clustering
    ValveModel(id: 5, name: 'محبس مياه الشرب 1', latitude: 24.7150, longitude: 46.6800, status: 1, zone: 'الرياض', lastUpdated: DateTime.now()),
    ValveModel(id: 6, name: 'محبس مياه الشرب 2', latitude: 24.7160, longitude: 46.6810, status: 1, zone: 'الرياض', lastUpdated: DateTime.now()),
  ];

  @override
  Future<List<ValveEntity>> fetchAndCacheValves() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Here we would normally fetch from API, then save to Hive.
    // For now, we return mock data.
    return _cachedValves;
  }

  @override
  Future<List<ValveEntity>> getCachedValves() async {
    // Return cached items (e.g. from Hive)
    return _cachedValves;
  }

  @override
  Stream<List<ValveEntity>> getValvesStream() async* {
    // Initial emission
    yield _cachedValves;
    
    // Simulate socket/stream updates occasionally
    await Future.delayed(const Duration(seconds: 10));
    final updatedList = List<ValveModel>.from(_cachedValves);
    updatedList[0] = ValveModel(
      id: 1, 
      name: 'محبس رئيسي 1', 
      latitude: 24.7136, 
      longitude: 46.6753, 
      status: 3, // Status changed!
      zone: 'الرياض', 
      lastUpdated: DateTime.now()
    );
    yield updatedList;
  }
}
