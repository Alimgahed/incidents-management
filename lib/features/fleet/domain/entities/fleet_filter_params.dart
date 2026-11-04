import 'package:equatable/equatable.dart';
import '../../../valves_map/models/etit_vehicle_model.dart';
import '../../core/theme/fleet_design_system.dart';

enum FleetSortField {
  none,
  plateNumber,
  code,
  branch,
  vehicleType,
  speed,
  lastUpdate,
}

class ActiveFilterChipItem extends Equatable {
  final String key;
  final String label;

  const ActiveFilterChipItem({required this.key, required this.label});

  @override
  List<Object?> get props => [key, label];
}

/// Immutable filter, sort, and pagination parameters for the Fleet feature.
class FleetFilterParams extends Equatable {
  final String searchQuery;
  final String statusFilter; // الكل | متحركة | متوقفة | غير متصل
  final String branchFilter;
  final String vehicleTypeFilter;
  final String vendorFilter;
  final String providerFilter;
  final FleetSortField sortField;
  final bool sortAscending;
  final int currentPage;
  final int pageSize;

  const FleetFilterParams({
    this.searchQuery = '',
    this.statusFilter = 'الكل',
    this.branchFilter = 'الكل',
    this.vehicleTypeFilter = 'الكل',
    this.vendorFilter = 'الكل',
    this.providerFilter = 'الكل',
    this.sortField = FleetSortField.none,
    this.sortAscending = true,
    this.currentPage = 1,
    this.pageSize = 20,
  });

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      statusFilter != 'الكل' ||
      branchFilter != 'الكل' ||
      vehicleTypeFilter != 'الكل' ||
      vendorFilter != 'الكل' ||
      providerFilter != 'الكل';

  List<ActiveFilterChipItem> get activeChips {
    final chips = <ActiveFilterChipItem>[];
    if (searchQuery.trim().isNotEmpty) {
      chips.add(
        ActiveFilterChipItem(key: 'search', label: 'بحث: ${searchQuery.trim()}'),
      );
    }
    if (statusFilter != 'الكل') {
      chips.add(
        ActiveFilterChipItem(key: 'status', label: 'الحالة: $statusFilter'),
      );
    }
    if (branchFilter != 'الكل') {
      chips.add(
        ActiveFilterChipItem(key: 'branch', label: 'الفرع: $branchFilter'),
      );
    }
    if (vehicleTypeFilter != 'الكل') {
      chips.add(
        ActiveFilterChipItem(key: 'type', label: 'النوع: $vehicleTypeFilter'),
      );
    }
    if (vendorFilter != 'الكل') {
      chips.add(
        ActiveFilterChipItem(key: 'vendor', label: 'الجهاز: $vendorFilter'),
      );
    }
    if (providerFilter != 'الكل') {
      chips.add(
        ActiveFilterChipItem(
          key: 'provider',
          label: 'الشريحة: $providerFilter',
        ),
      );
    }
    return chips;
  }

  bool matches(EtitVehicleModel v) {
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      final matchesSearch =
          v.plateNumber.toLowerCase().contains(q) ||
          v.code.toLowerCase().contains(q) ||
          (v.codePlateNumber ?? '').toLowerCase().contains(q) ||
          (v.deviceCode ?? '').toLowerCase().contains(q) ||
          (v.allocation ?? '').toLowerCase().contains(q) ||
          (v.chassisNumber ?? '').toLowerCase().contains(q) ||
          (v.vendorName ?? '').toLowerCase().contains(q) ||
          (v.providerName ?? '').toLowerCase().contains(q) ||
          v.arabicVehicleType.toLowerCase().contains(q);
      if (!matchesSearch) return false;
    }

    if (statusFilter != 'الكل') {
      if (statusFilter == 'متحركة' && !v.isMoving) return false;
      if (statusFilter == 'متوقفة' && !v.isStopped) return false;
      if ((statusFilter == 'غير متصل' || statusFilter == 'GPS غير متصل') &&
          !v.isOffline) {
        return false;
      }
    }

    if (branchFilter != 'الكل') {
      final vBranch = (v.allocation ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.allocation!.trim();
      if (vBranch != branchFilter) return false;
    }

    if (vehicleTypeFilter != 'الكل') {
      final vType = (v.vehicleType ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.vehicleType!.trim();
      if (vType != vehicleTypeFilter) return false;
    }

    if (vendorFilter != 'الكل') {
      final vVendor = (v.vendorName ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.vendorName!.trim();
      if (vVendor != vendorFilter) return false;
    }

    if (providerFilter != 'الكل') {
      final vProvider = (v.providerName ?? '').trim().isEmpty
          ? 'غير محدد'
          : v.providerName!.trim();
      if (vProvider != providerFilter) return false;
    }

    return true;
  }

  List<EtitVehicleModel> applyTo(List<EtitVehicleModel> all) {
    final filtered = all.where(matches).toList();
    if (sortField != FleetSortField.none) {
      filtered.sort((a, b) {
        int cmp = 0;
        switch (sortField) {
          case FleetSortField.plateNumber:
            cmp = a.plateNumber.compareTo(b.plateNumber);
            break;
          case FleetSortField.code:
            final aNum = int.tryParse(a.code);
            final bNum = int.tryParse(b.code);
            cmp = (aNum != null && bNum != null)
                ? aNum.compareTo(bNum)
                : a.code.compareTo(b.code);
            break;
          case FleetSortField.branch:
            cmp = (a.allocation ?? '').compareTo(b.allocation ?? '');
            break;
          case FleetSortField.vehicleType:
            cmp = (a.vehicleType ?? '').compareTo(b.vehicleType ?? '');
            break;
          case FleetSortField.speed:
            cmp = (a.speed ?? 0).compareTo(b.speed ?? 0);
            break;
          case FleetSortField.lastUpdate:
            final dtA = FleetDateFormatter.parseEtitDate(a.lastUpdate);
            final dtB = FleetDateFormatter.parseEtitDate(b.lastUpdate);
            if (dtA == null && dtB == null) {
              cmp = 0;
            } else if (dtA == null) {
              cmp = -1;
            } else if (dtB == null) {
              cmp = 1;
            } else {
              cmp = dtA.compareTo(dtB);
            }
            break;
          case FleetSortField.none:
            cmp = 0;
            break;
        }
        return sortAscending ? cmp : -cmp;
      });
    }
    return filtered;
  }

  FleetFilterParams copyWith({
    String? searchQuery,
    String? statusFilter,
    String? branchFilter,
    String? vehicleTypeFilter,
    String? vendorFilter,
    String? providerFilter,
    FleetSortField? sortField,
    bool? sortAscending,
    int? currentPage,
    int? pageSize,
  }) {
    return FleetFilterParams(
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      branchFilter: branchFilter ?? this.branchFilter,
      vehicleTypeFilter: vehicleTypeFilter ?? this.vehicleTypeFilter,
      vendorFilter: vendorFilter ?? this.vendorFilter,
      providerFilter: providerFilter ?? this.providerFilter,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
    searchQuery,
    statusFilter,
    branchFilter,
    vehicleTypeFilter,
    vendorFilter,
    providerFilter,
    sortField,
    sortAscending,
    currentPage,
    pageSize,
  ];
}
