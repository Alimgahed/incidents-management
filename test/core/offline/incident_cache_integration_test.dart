import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/edit_incident.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';
import 'package:incidents_managment/core/network/api_result.dart';
import 'package:incidents_managment/core/network/api_services.dart';
import 'package:incidents_managment/core/offline/data/models/cached_incident.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';
import 'package:incidents_managment/core/offline/network/offline_interceptor.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';

class _FakeApiService implements ApiService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSecureStorageService implements SecureStorageService {
  @override
  Future<String?> getUserToken() async => null; // Offline/no token on boot

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDirectory;
  late IncidentCacheRepository incidentCache;

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers.global'),
          (MethodCall methodCall) async => null,
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('xyz.luan/audioplayers'),
          (MethodCall methodCall) async => null,
        );

    hiveDirectory = await Directory.systemTemp.createTemp('nsn_incident_cache_test_');
    Hive.init(hiveDirectory.path);
    if (!Hive.isAdapterRegistered(101)) {
      Hive.registerAdapter<CachedIncident>(CachedIncidentAdapter());
    }
    await Hive.openBox<CachedIncident>('cache_incidents');
    incidentCache = IncidentCacheRepository();

    if (getIt.isRegistered<IncidentCacheRepository>()) {
      getIt.unregister<IncidentCacheRepository>();
    }
    getIt.registerSingleton<IncidentCacheRepository>(incidentCache);

    if (getIt.isRegistered<IncidentPickerBridge>()) {
      getIt.unregister<IncidentPickerBridge>();
    }
    getIt.registerSingleton<IncidentPickerBridge>(IncidentPickerBridge());

    if (getIt.isRegistered<SecureStorageService>()) {
      getIt.unregister<SecureStorageService>();
    }
    getIt.registerSingleton<SecureStorageService>(_FakeSecureStorageService());
  });

  tearDown(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
    if (getIt.isRegistered<IncidentCacheRepository>()) {
      getIt.unregister<IncidentCacheRepository>();
    }
    if (getIt.isRegistered<IncidentPickerBridge>()) {
      getIt.unregister<IncidentPickerBridge>();
    }
    if (getIt.isRegistered<SecureStorageService>()) {
      getIt.unregister<SecureStorageService>();
    }
    if (getIt.isRegistered<Dio>()) {
      getIt.unregister<Dio>();
    }
  });

  test('EditIncidentRepo updates IncidentCacheRepository with pending changes', () async {
    // Seed an existing incident in cache
    await incidentCache.upsert(
      CachedIncident.fromMap(
        {'current_incident_id': 100, 'current_incident_description': 'Original description'},
        idOrTempId: 100,
      ),
    );

    // Setup Dio with interceptor returning synthetic 202 (offline behavior)
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 202,
              data: {'__offline': true},
            ),
          );
        },
      ),
    );

    if (getIt.isRegistered<Dio>()) getIt.unregister<Dio>();
    getIt.registerSingleton<Dio>(dio);

    final repo = EditIncidentRepo(apiService: _FakeApiService());
    final updateModel = CurrentIncidentModel(
      currentIncidentId: 100,
      currentIncidentDescription: 'Updated description offline',
    );

    final result = await repo.editIncident(updateModel, 100);

    expect(result.when(success: (d) => true, error: (_) => false), isTrue);

    // Verify cache has the updated data and hasPendingChanges = true
    final cached = incidentCache.get(100);
    expect(cached, isNotNull);
    expect(cached!.hasPendingChanges, isTrue);
    final map = cached.toMap();
    expect(map['current_incident_description'], 'Updated description offline');
  });

  test('IncidentMapCubit pre-loads from cache on startup before network connection', () async {
    // Seed an incident in cache
    await incidentCache.upsert(
      CachedIncident.fromMap(
        {
          'current_incident_id': 200,
          'current_incident_description': 'Cached Incident 200',
          'current_incident_created_at': DateTime.now().toIso8601String(),
        },
        idOrTempId: 200,
      ),
    );

    final cubit = IncidentMapCubit();
    expect(cubit.state, isA<IncidentMapInitial>());

    // Initialize cubit — should read cache even though socket cannot connect (token is null)
    await cubit.initialize();

    expect(cubit.state, isA<IncidentMapLoaded>());
    final loadedState = cubit.state as IncidentMapLoaded;
    expect(loadedState.incidents.length, 1);
    expect(loadedState.incidents.first.currentIncidentId, 200);
    expect(loadedState.incidents.first.currentIncidentDescription, 'Cached Incident 200');

    await cubit.close();
  });
}
