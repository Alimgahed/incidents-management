import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../valves_map/models/etit_vehicle_model.dart';
import '../../core/error/fleet_failure.dart';
import '../../domain/entities/fleet_filter_params.dart';
import '../../domain/entities/fleet_statistics.dart';
import '../../domain/repositories/fleet_repository.dart';
import 'fleet_state.dart';

class FleetCubit extends Cubit<FleetState> {
  final FleetRepository _repository;
  final Duration pollInterval;
  final Duration searchDebounceDuration;

  Timer? _pollTimer;
  Timer? _searchDebounce;
  bool _isPollInFlight = false;
  bool _isPollingPaused = false;

  FleetCubit({
    required FleetRepository repository,
    this.pollInterval = const Duration(seconds: 30),
    this.searchDebounceDuration = const Duration(milliseconds: 250),
  }) : _repository = repository,
       super(const FleetState());

  /// Initializes the Cubit:
  /// 1. Hydrates immediately from warm repository cache if available.
  /// 2. Triggers a fresh sync in the background.
  /// 3. Starts the non-overlapping live polling timer.
  Future<void> initialize({
    EtitVehicleModel? targetVehicle,
    bool enableLivePolling = true,
  }) async {
    final cached = _repository.getCachedSnapshot();
    if (cached != null && cached.vehicles.isNotEmpty) {
      _emitVehiclesUpdate(
        allVehicles: cached.vehicles,
        syncedAt: cached.syncedAt,
        targetVehicle: targetVehicle,
        status: FleetStatus.refreshing,
      );
      await refresh(forceFullRefresh: false, silent: true);
    } else {
      if (targetVehicle != null) {
        emit(state.copyWith(selectedVehicle: targetVehicle));
      }
      await refresh(forceFullRefresh: true, silent: false);
    }

    if (enableLivePolling) {
      startLivePolling();
    }
  }

  /// Fetches fresh data from the repository.
  Future<void> refresh({
    bool forceFullRefresh = true,
    bool silent = false,
  }) async {
    if (_isPollInFlight && silent) return;
    _isPollInFlight = true;

    try {
      if (!isClosed) {
        if (state.allVehicles.isEmpty && !silent) {
          emit(state.copyWith(status: FleetStatus.loading, clearFailure: true));
        } else {
          emit(
            state.copyWith(status: FleetStatus.refreshing, clearFailure: true),
          );
        }
      }

      final snapshot = await _repository.fetchFleetWithLiveTracking(
        forceFullRefresh: forceFullRefresh,
      );

      if (isClosed) return;

      if (snapshot.vehicles.isEmpty) {
        emit(
          state.copyWith(
            status: FleetStatus.empty,
            allVehicles: const [],
            filteredVehicles: const [],
            paginatedVehicles: const [],
            statistics: const FleetStatistics(),
            lastSyncedAt: snapshot.syncedAt,
            clearFailure: true,
          ),
        );
        return;
      }

      _emitVehiclesUpdate(
        allVehicles: snapshot.vehicles,
        syncedAt: snapshot.syncedAt,
        status: FleetStatus.loaded,
      );
    } catch (e) {
      if (isClosed) return;
      final failure = FleetFailure.fromException(e);
      emit(
        state.copyWith(
          status: state.allVehicles.isNotEmpty
              ? FleetStatus.loaded
              : FleetStatus.error,
          failure: failure,
        ),
      );
    } finally {
      _isPollInFlight = false;
    }
  }

  void _emitVehiclesUpdate({
    required List<EtitVehicleModel> allVehicles,
    required DateTime syncedAt,
    required FleetStatus status,
    EtitVehicleModel? targetVehicle,
  }) {
    final filtered = state.filters.applyTo(allVehicles);
    final paginated = FleetState.computePaginatedSlice(filtered, state.filters);
    final stats = FleetStatistics.fromVehicles(
      allVehicles: allVehicles,
      filteredVehicles: filtered,
    );

    EtitVehicleModel? updatedSelected = targetVehicle ?? state.selectedVehicle;
    if (updatedSelected != null) {
      for (final v in allVehicles) {
        if (v.id == updatedSelected!.id) {
          updatedSelected = v;
          break;
        }
      }
    }

    emit(
      state.copyWith(
        status: status,
        allVehicles: allVehicles,
        filteredVehicles: filtered,
        paginatedVehicles: paginated,
        statistics: stats,
        selectedVehicle: updatedSelected,
        lastSyncedAt: syncedAt,
        clearFailure: true,
      ),
    );
  }

  void startLivePolling() {
    _pollTimer?.cancel();
    _isPollingPaused = false;
    _pollTimer = Timer.periodic(pollInterval, (_) {
      if (!_isPollingPaused && !_isPollInFlight && !isClosed) {
        refresh(forceFullRefresh: false, silent: true);
      }
    });
  }

  void pausePolling() {
    _isPollingPaused = true;
  }

  void resumePolling() {
    _isPollingPaused = false;
  }

  // ── Filter & Search Actions ─────────────────────────────────────────────────

  void updateSearchQuery(String query, {bool immediate = false}) {
    _searchDebounce?.cancel();
    if (immediate || searchDebounceDuration == Duration.zero) {
      _applyFilterParams(
        state.filters.copyWith(searchQuery: query, currentPage: 1),
      );
      return;
    }
    _searchDebounce = Timer(searchDebounceDuration, () {
      if (!isClosed) {
        _applyFilterParams(
          state.filters.copyWith(searchQuery: query, currentPage: 1),
        );
      }
    });
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    _applyFilterParams(
      state.filters.copyWith(searchQuery: '', currentPage: 1),
    );
  }

  void setStatusFilter(String statusFilter) {
    _applyFilterParams(
      state.filters.copyWith(statusFilter: statusFilter, currentPage: 1),
    );
  }

  void toggleStatusFilter(String statusFilter) {
    final next = state.filters.statusFilter == statusFilter
        ? 'الكل'
        : statusFilter;
    setStatusFilter(next);
  }

  void setBranchFilter(String branch) {
    _applyFilterParams(
      state.filters.copyWith(branchFilter: branch, currentPage: 1),
    );
  }

  void setVehicleTypeFilter(String vehicleType) {
    _applyFilterParams(
      state.filters.copyWith(vehicleTypeFilter: vehicleType, currentPage: 1),
    );
  }

  void setVendorFilter(String vendor) {
    _applyFilterParams(
      state.filters.copyWith(vendorFilter: vendor, currentPage: 1),
    );
  }

  void setProviderFilter(String provider) {
    _applyFilterParams(
      state.filters.copyWith(providerFilter: provider, currentPage: 1),
    );
  }

  void removeFilterChip(String key) {
    switch (key) {
      case 'search':
        clearSearch();
        break;
      case 'status':
        setStatusFilter('الكل');
        break;
      case 'branch':
        setBranchFilter('الكل');
        break;
      case 'type':
        setVehicleTypeFilter('الكل');
        break;
      case 'vendor':
        setVendorFilter('الكل');
        break;
      case 'provider':
        setProviderFilter('الكل');
        break;
    }
  }

  void clearAllFilters() {
    _searchDebounce?.cancel();
    _applyFilterParams(
      FleetFilterParams(
        pageSize: state.filters.pageSize,
        sortField: state.filters.sortField,
        sortAscending: state.filters.sortAscending,
      ),
    );
  }

  void toggleSort(FleetSortField field) {
    final isSameField = state.filters.sortField == field;
    final nextAsc = isSameField ? !state.filters.sortAscending : true;
    _applyFilterParams(
      state.filters.copyWith(
        sortField: field,
        sortAscending: nextAsc,
        currentPage: 1,
      ),
    );
  }

  void setPage(int page) {
    final clamped = page.clamp(1, state.totalPages);
    if (clamped == state.filters.currentPage) return;
    final nextFilters = state.filters.copyWith(currentPage: clamped);
    final paginated = FleetState.computePaginatedSlice(
      state.filteredVehicles,
      nextFilters,
    );
    emit(state.copyWith(filters: nextFilters, paginatedVehicles: paginated));
  }

  void setPageSize(int pageSize) {
    if (pageSize == state.filters.pageSize) return;
    final nextFilters = state.filters.copyWith(
      pageSize: pageSize,
      currentPage: 1,
    );
    final paginated = FleetState.computePaginatedSlice(
      state.filteredVehicles,
      nextFilters,
    );
    emit(state.copyWith(filters: nextFilters, paginatedVehicles: paginated));
  }

  void _applyFilterParams(FleetFilterParams nextFilters) {
    final filtered = nextFilters.applyTo(state.allVehicles);
    final paginated = FleetState.computePaginatedSlice(filtered, nextFilters);
    final mapVisible = filtered.where((v) => v.hasValidLocation).length;

    emit(
      state.copyWith(
        filters: nextFilters,
        filteredVehicles: filtered,
        paginatedVehicles: paginated,
        statistics: state.statistics.copyWithMapVisibleCount(mapVisible),
      ),
    );
  }

  // ── Map & Selection Actions ─────────────────────────────────────────────────

  void selectVehicle(
    EtitVehicleModel? vehicle, {
    bool collapseMapList = false,
  }) {
    if (vehicle == null) {
      emit(
        state.copyWith(
          clearSelectedVehicle: true,
          isFollowingSelected: false,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        selectedVehicle: vehicle,
        isMapListExpanded: collapseMapList ? false : state.isMapListExpanded,
      ),
    );
  }

  void toggleFollowSelected() {
    if (state.selectedVehicle == null) return;
    emit(state.copyWith(isFollowingSelected: !state.isFollowingSelected));
  }

  void toggleMapListExpanded() {
    emit(state.copyWith(isMapListExpanded: !state.isMapListExpanded));
  }

  void setMapListExpanded(bool expanded) {
    if (state.isMapListExpanded == expanded) return;
    emit(state.copyWith(isMapListExpanded: expanded));
  }

  void setMapLayer(String layerKey) {
    if (state.mapLayerKey == layerKey) return;
    emit(state.copyWith(mapLayerKey: layerKey));
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _searchDebounce?.cancel();
    return super.close();
  }
}
