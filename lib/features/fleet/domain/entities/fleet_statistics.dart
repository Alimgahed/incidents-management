import 'package:equatable/equatable.dart';
import '../../../valves_map/models/etit_vehicle_model.dart';

/// Immutable, pre-computed fleet statistics and filter option sets derived strictly
/// from the backend API response.
class FleetStatistics extends Equatable {
  final int totalCount;
  final int movingCount;
  final int stoppedCount;
  final int offlineCount;
  final int mapVisibleCount;

  // Dynamic dropdown option lists (pre-sorted once per dataset update)
  final List<String> branches;
  final List<String> vehicleTypes;
  final List<String> vendors;
  final List<String> providers;

  const FleetStatistics({
    this.totalCount = 0,
    this.movingCount = 0,
    this.stoppedCount = 0,
    this.offlineCount = 0,
    this.mapVisibleCount = 0,
    this.branches = const ['الكل'],
    this.vehicleTypes = const ['الكل'],
    this.vendors = const ['الكل'],
    this.providers = const ['الكل'],
  });

  factory FleetStatistics.fromVehicles({
    required List<EtitVehicleModel> allVehicles,
    required List<EtitVehicleModel> filteredVehicles,
  }) {
    int moving = 0;
    int stopped = 0;
    int offline = 0;

    final branchSet = <String>{};
    final typeSet = <String>{};
    final vendorSet = <String>{};
    final providerSet = <String>{};

    for (final v in allVehicles) {
      if (v.isMoving) {
        moving++;
      } else if (v.isStopped) {
        stopped++;
      } else {
        offline++;
      }

      final b = (v.allocation ?? '').trim();
      branchSet.add(b.isEmpty ? 'غير محدد' : b);

      final t = (v.vehicleType ?? '').trim();
      typeSet.add(t.isEmpty ? 'غير محدد' : t);

      final vn = (v.vendorName ?? '').trim();
      vendorSet.add(vn.isEmpty ? 'غير محدد' : vn);

      final pr = (v.providerName ?? '').trim();
      providerSet.add(pr.isEmpty ? 'غير محدد' : pr);
    }

    int mapVisible = 0;
    for (final v in filteredVehicles) {
      if (v.hasValidLocation) mapVisible++;
    }

    final sortedBranches = branchSet.toList()..sort();
    final sortedTypes = typeSet.toList()..sort();
    final sortedVendors = vendorSet.toList()..sort();
    final sortedProviders = providerSet.toList()..sort();

    return FleetStatistics(
      totalCount: allVehicles.length,
      movingCount: moving,
      stoppedCount: stopped,
      offlineCount: offline,
      mapVisibleCount: mapVisible,
      branches: ['الكل', ...sortedBranches],
      vehicleTypes: ['الكل', ...sortedTypes],
      vendors: ['الكل', ...sortedVendors],
      providers: ['الكل', ...sortedProviders],
    );
  }

  String percentageOfTotal(int count) {
    if (totalCount <= 0) return '0.0 % من الإجمالي';
    final pct = (count / totalCount) * 100.0;
    return '${pct.toStringAsFixed(1)} % من الإجمالي';
  }

  String get movingPercentageLabel => percentageOfTotal(movingCount);
  String get stoppedPercentageLabel => percentageOfTotal(stoppedCount);
  String get offlinePercentageLabel => percentageOfTotal(offlineCount);

  FleetStatistics copyWithMapVisibleCount(int newMapVisibleCount) {
    return FleetStatistics(
      totalCount: totalCount,
      movingCount: movingCount,
      stoppedCount: stoppedCount,
      offlineCount: offlineCount,
      mapVisibleCount: newMapVisibleCount,
      branches: branches,
      vehicleTypes: vehicleTypes,
      vendors: vendors,
      providers: providers,
    );
  }

  @override
  List<Object?> get props => [
    totalCount,
    movingCount,
    stoppedCount,
    offlineCount,
    mapVisibleCount,
    branches,
    vehicleTypes,
    vendors,
    providers,
  ];
}
