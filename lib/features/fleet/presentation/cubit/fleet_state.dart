import 'dart:math' as math;
import 'package:equatable/equatable.dart';
import '../../../valves_map/models/etit_vehicle_model.dart';
import '../../core/error/fleet_failure.dart';
import '../../domain/entities/fleet_filter_params.dart';
import '../../domain/entities/fleet_statistics.dart';

enum FleetStatus {
  initial,
  loading,
  loaded,
  refreshing,
  empty,
  error,
}

class FleetState extends Equatable {
  final FleetStatus status;
  final List<EtitVehicleModel> allVehicles;
  final List<EtitVehicleModel> filteredVehicles;
  final List<EtitVehicleModel> paginatedVehicles;
  final FleetStatistics statistics;
  final FleetFilterParams filters;
  final EtitVehicleModel? selectedVehicle;
  final bool isFollowingSelected;
  final bool isMapListExpanded;
  final String mapLayerKey;
  final DateTime? lastSyncedAt;
  final FleetFailure? failure;

  const FleetState({
    this.status = FleetStatus.initial,
    this.allVehicles = const [],
    this.filteredVehicles = const [],
    this.paginatedVehicles = const [],
    this.statistics = const FleetStatistics(),
    this.filters = const FleetFilterParams(),
    this.selectedVehicle,
    this.isFollowingSelected = false,
    this.isMapListExpanded = false,
    this.mapLayerKey = 'osm',
    this.lastSyncedAt,
    this.failure,
  });

  bool get isInitialLoading =>
      (status == FleetStatus.initial || status == FleetStatus.loading) &&
      allVehicles.isEmpty;

  bool get isRefreshing => status == FleetStatus.refreshing;

  bool get hasData => allVehicles.isNotEmpty;

  int get totalPages => filteredVehicles.isEmpty
      ? 1
      : (filteredVehicles.length / filters.pageSize).ceil();

  int get safeCurrentPage => filters.currentPage.clamp(1, totalPages);

  int get pageStartIndex =>
      filteredVehicles.isEmpty ? 0 : (safeCurrentPage - 1) * filters.pageSize;

  int get pageEndIndex => filteredVehicles.isEmpty
      ? 0
      : math.min(pageStartIndex + filters.pageSize, filteredVehicles.length);

  static List<EtitVehicleModel> computePaginatedSlice(
    List<EtitVehicleModel> filtered,
    FleetFilterParams filters,
  ) {
    if (filtered.isEmpty) return const [];
    final totalPages = (filtered.length / filters.pageSize).ceil();
    final safePage = filters.currentPage.clamp(1, totalPages);
    final start = (safePage - 1) * filters.pageSize;
    final end = math.min(start + filters.pageSize, filtered.length);
    if (start >= filtered.length) return const [];
    return filtered.sublist(start, end);
  }

  FleetState copyWith({
    FleetStatus? status,
    List<EtitVehicleModel>? allVehicles,
    List<EtitVehicleModel>? filteredVehicles,
    List<EtitVehicleModel>? paginatedVehicles,
    FleetStatistics? statistics,
    FleetFilterParams? filters,
    EtitVehicleModel? selectedVehicle,
    bool clearSelectedVehicle = false,
    bool? isFollowingSelected,
    bool? isMapListExpanded,
    String? mapLayerKey,
    DateTime? lastSyncedAt,
    FleetFailure? failure,
    bool clearFailure = false,
  }) {
    return FleetState(
      status: status ?? this.status,
      allVehicles: allVehicles ?? this.allVehicles,
      filteredVehicles: filteredVehicles ?? this.filteredVehicles,
      paginatedVehicles: paginatedVehicles ?? this.paginatedVehicles,
      statistics: statistics ?? this.statistics,
      filters: filters ?? this.filters,
      selectedVehicle: clearSelectedVehicle
          ? null
          : (selectedVehicle ?? this.selectedVehicle),
      isFollowingSelected: isFollowingSelected ?? this.isFollowingSelected,
      isMapListExpanded: isMapListExpanded ?? this.isMapListExpanded,
      mapLayerKey: mapLayerKey ?? this.mapLayerKey,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [
    status,
    allVehicles,
    filteredVehicles,
    paginatedVehicles,
    statistics,
    filters,
    selectedVehicle,
    isFollowingSelected,
    isMapListExpanded,
    mapLayerKey,
    lastSyncedAt,
    failure,
  ];
}
