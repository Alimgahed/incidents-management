import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/features/fleet/core/error/fleet_failure.dart';
import 'package:incidents_managment/features/fleet/core/theme/fleet_design_system.dart';
import 'package:incidents_managment/features/fleet/data/repositories/fleet_repository_impl.dart';
import 'package:incidents_managment/features/fleet/domain/entities/fleet_filter_params.dart';
import 'package:incidents_managment/features/fleet/domain/entities/fleet_statistics.dart';
import 'package:incidents_managment/features/fleet/domain/repositories/fleet_repository.dart';
import 'package:incidents_managment/features/fleet/presentation/cubit/fleet_cubit.dart';
import 'package:incidents_managment/features/fleet/presentation/cubit/fleet_state.dart';
import 'package:incidents_managment/features/valves_map/models/etit_vehicle_model.dart';
import 'package:incidents_managment/features/valves_map/services/etit_gps_service.dart';

class _FakeEtitGpsService extends EtitGpsService {
  _FakeEtitGpsService() : super.internal();

  int getVehiclesCallCount = 0;
  int getLiveCoordinatesCallCount = 0;
  bool shouldThrow = false;

  List<EtitVehicleModel> stubVehicles = [
    EtitVehicleModel(
      id: 'v-1',
      code: 'cbcnsisa17',
      plateNumber: 'د ن 9143',
      codePlateNumber: 'cbcnsisa17 - د ن 9143',
      allocation: 'فرع مطاي',
      vehicleType: 'Pickup',
      deviceCode: '869606020926386',
      vendorName: 'Queclink',
      providerName: 'Vodafone',
      statusName: 'Available',
    ),
    EtitVehicleModel(
      id: 'v-2',
      code: 'cbcnsisa18',
      plateNumber: 'د ج 8427',
      codePlateNumber: 'cbcnsisa18 - د ج 8427',
      allocation: 'فرع المنيا',
      vehicleType: 'Trailer',
      deviceCode: '869606020902692',
      vendorName: 'Teltonika',
      providerName: 'Orange',
      statusName: 'Available',
    ),
    EtitVehicleModel(
      id: 'v-3',
      code: 'cbcnsisa19',
      plateNumber: 'ن ب أ 6448',
      codePlateNumber: 'cbcnsisa19 - ن ب أ 6448',
      allocation: 'فرع سمالوط',
      vehicleType: 'Truck',
      deviceCode: '869606020893560',
      vendorName: 'Queclink',
      providerName: 'We',
      statusName: 'Available',
    ),
  ];

  Map<String, Map<String, dynamic>> stubLiveCoords = {
    'v-1': {
      'lat': 28.1098,
      'lon': 30.7503,
      'speed': 56.0,
      'status': '1',
      'lastUpdate': '04 November 2026 18:08:00',
      'deviceCode': '869606020926386',
    },
    'v-2': {
      'lat': 28.2000,
      'lon': 30.8000,
      'speed': 0.0,
      'status': '0',
      'lastUpdate': '04 November 2026 18:05:00',
      'deviceCode': '869606020902692',
    },
    // v-3 has no live entry -> offline
  };

  @override
  Future<List<EtitVehicleModel>> getVehicles({
    int pageIndex = 1,
    int pageSize = 100,
    String? searchKeyword,
    bool throwOnError = false,
  }) async {
    getVehiclesCallCount++;
    if (shouldThrow) {
      throw Exception('SocketException: Failed host lookup');
    }
    return stubVehicles;
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getLiveCoordinates({
    bool throwOnError = false,
  }) async {
    getLiveCoordinatesCallCount++;
    if (shouldThrow) {
      throw Exception('SocketException: Failed host lookup');
    }
    return stubLiveCoords;
  }
}

void main() {
  group('FleetRepositoryImpl & Two-Tier Caching', () {
    late _FakeEtitGpsService fakeService;
    late FleetRepositoryImpl repository;

    setUp(() {
      fakeService = _FakeEtitGpsService();
      repository = FleetRepositoryImpl(
        gpsService: fakeService,
        metadataTtl: const Duration(minutes: 5),
      );
    });

    test(
      'fetches both base metadata and live telematics on cold start, then reuses cached metadata on subsequent polls',
      () async {
        expect(repository.getCachedSnapshot(), isNull);

        // 1. Cold fetch
        final first = await repository.fetchFleetWithLiveTracking(
          forceFullRefresh: false,
        );
        expect(first.metadataFromCache, isFalse);
        expect(first.vehicles.length, 3);
        expect(fakeService.getVehiclesCallCount, 1);
        expect(fakeService.getLiveCoordinatesCallCount, 1);

        // Verify live merge on v-1 (moving), v-2 (stopped), v-3 (offline)
        final v1 = first.vehicles.firstWhere((v) => v.id == 'v-1');
        final v2 = first.vehicles.firstWhere((v) => v.id == 'v-2');
        final v3 = first.vehicles.firstWhere((v) => v.id == 'v-3');
        expect(v1.isMoving, isTrue);
        expect(v1.speed, 56.0);
        expect(v2.isStopped, isTrue);
        expect(v3.isOffline, isTrue);

        // 2. Subsequent background poll (forceFullRefresh: false) -> reuses metadata cache, fetches fresh GPS
        fakeService.stubLiveCoords['v-1'] = {
          'lat': 28.1200,
          'lon': 30.7600,
          'speed': 72.0,
          'status': '1',
          'lastUpdate': '04 November 2026 18:09:00',
          'deviceCode': '869606020926386',
        };
        final second = await repository.fetchFleetWithLiveTracking(
          forceFullRefresh: false,
        );
        expect(second.metadataFromCache, isTrue);
        expect(fakeService.getVehiclesCallCount, 1); // Not called again!
        expect(fakeService.getLiveCoordinatesCallCount, 2); // Fresh GPS called!
        expect(
          second.vehicles.firstWhere((v) => v.id == 'v-1').speed,
          72.0,
        );

        // 3. Explicit force refresh -> calls both endpoints
        final third = await repository.fetchFleetWithLiveTracking(
          forceFullRefresh: true,
        );
        expect(third.metadataFromCache, isFalse);
        expect(fakeService.getVehiclesCallCount, 2);
        expect(fakeService.getLiveCoordinatesCallCount, 3);
      },
    );

    test('maps exceptions to sanitized FleetFailure', () async {
      fakeService.shouldThrow = true;
      expect(
        () => repository.fetchFleetWithLiveTracking(forceFullRefresh: true),
        throwsA(isA<FleetFailure>()),
      );
    });
  });

  group('FleetCubit State Management, Filtering, Sorting & Pagination', () {
    late _FakeEtitGpsService fakeService;
    late FleetRepository repository;
    late FleetCubit cubit;

    setUp(() {
      fakeService = _FakeEtitGpsService();
      repository = FleetRepositoryImpl(gpsService: fakeService);
      cubit = FleetCubit(
        repository: repository,
        pollInterval: const Duration(hours: 1),
        searchDebounceDuration: Duration.zero,
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initialize loads vehicles and computes accurate FleetStatistics', () async {
      await cubit.initialize(enableLivePolling: false);

      expect(cubit.state.status, FleetStatus.loaded);
      expect(cubit.state.allVehicles.length, 3);
      expect(cubit.state.statistics.totalCount, 3);
      expect(cubit.state.statistics.movingCount, 1);
      expect(cubit.state.statistics.stoppedCount, 1);
      expect(cubit.state.statistics.offlineCount, 1);
      expect(
        cubit.state.statistics.branches,
        containsAll(['الكل', 'فرع مطاي', 'فرع المنيا', 'فرع سمالوط']),
      );
    });

    test('supports combined search, status, branch, type, vendor, and provider filters', () async {
      await cubit.initialize(enableLivePolling: false);

      // Filter by status = متحركة
      cubit.setStatusFilter('متحركة');
      expect(cubit.state.filteredVehicles.length, 1);
      expect(cubit.state.filteredVehicles.first.id, 'v-1');

      // Reset status and filter by branch
      cubit.setStatusFilter('الكل');
      cubit.setBranchFilter('فرع المنيا');
      expect(cubit.state.filteredVehicles.length, 1);
      expect(cubit.state.filteredVehicles.first.id, 'v-2');

      // Clear all filters
      cubit.clearAllFilters();
      expect(cubit.state.filteredVehicles.length, 3);
      expect(cubit.state.filters.hasActiveFilters, isFalse);

      // Search by IMEI substring
      cubit.updateSearchQuery('869606020893560', immediate: true);
      expect(cubit.state.filteredVehicles.length, 1);
      expect(cubit.state.filteredVehicles.first.id, 'v-3');
      expect(cubit.state.filters.activeChips.length, 1);

      // Remove search chip
      cubit.removeFilterChip('search');
      expect(cubit.state.filteredVehicles.length, 3);
    });

    test('sorts by speed and paginates slices accurately', () async {
      await cubit.initialize(enableLivePolling: false);

      // Sort by speed ascending
      cubit.toggleSort(FleetSortField.speed);
      expect(cubit.state.filters.sortField, FleetSortField.speed);
      expect(cubit.state.filters.sortAscending, isTrue);
      expect(cubit.state.filteredVehicles.last.id, 'v-1'); // 56 km/h highest

      // Toggle again -> speed descending
      cubit.toggleSort(FleetSortField.speed);
      expect(cubit.state.filters.sortAscending, isFalse);
      expect(cubit.state.filteredVehicles.first.id, 'v-1');

      // Pagination with pageSize = 2
      cubit.setPageSize(2);
      expect(cubit.state.totalPages, 2);
      expect(cubit.state.paginatedVehicles.length, 2);

      cubit.setPage(2);
      expect(cubit.state.safeCurrentPage, 2);
      expect(cubit.state.paginatedVehicles.length, 1);
    });

    test('preserves existing vehicle list when background refresh fails', () async {
      await cubit.initialize(enableLivePolling: false);
      expect(cubit.state.allVehicles.length, 3);

      // Simulate transient network failure during refresh
      fakeService.shouldThrow = true;
      await cubit.refresh(forceFullRefresh: true, silent: true);

      expect(cubit.state.status, FleetStatus.loaded);
      expect(cubit.state.allVehicles.length, 3);
      expect(cubit.state.failure, isNotNull);
    });

    test('syncs map selection, follow mode, and map layer key', () async {
      await cubit.initialize(enableLivePolling: false);
      final target = cubit.state.allVehicles.first;

      cubit.setMapListExpanded(true);
      expect(cubit.state.isMapListExpanded, isTrue);

      cubit.selectVehicle(target, collapseMapList: true);
      expect(cubit.state.selectedVehicle?.id, target.id);
      expect(cubit.state.isMapListExpanded, isFalse);

      cubit.toggleFollowSelected();
      expect(cubit.state.isFollowingSelected, isTrue);

      cubit.setMapLayer('satellite');
      expect(cubit.state.mapLayerKey, 'satellite');

      cubit.selectVehicle(null);
      expect(cubit.state.selectedVehicle, isNull);
      expect(cubit.state.isFollowingSelected, isFalse);
    });
  });

  group('FleetDateFormatter & FleetStatistics', () {
    test('parses ETIT English timestamps with memoized cache', () {
      const raw = '04 November 2026 18:15:22';
      final dt1 = FleetDateFormatter.parseEtitDate(raw);
      final dt2 = FleetDateFormatter.parseEtitDate(raw);

      expect(dt1, isNotNull);
      expect(dt1!.year, 2026);
      expect(dt1.month, 11);
      expect(dt1.day, 4);
      expect(dt1.hour, 18);
      expect(dt1.minute, 15);
      expect(identical(dt1, dt2), isTrue);
    });

    test('computes percentages safely when fleet is empty', () {
      final stats = FleetStatistics.fromVehicles(
        allVehicles: const [],
        filteredVehicles: const [],
      );
      expect(stats.totalCount, 0);
      expect(stats.movingPercentageLabel, '0.0 % من الإجمالي');
      expect(stats.stoppedPercentageLabel, '0.0 % من الإجمالي');
      expect(stats.offlinePercentageLabel, '0.0 % من الإجمالي');
    });
  });
}
