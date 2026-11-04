import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/di/dependcy_injection.dart';
import '../../../fleet/core/shimmer/fleet_shimmer_widgets.dart';
import '../../../fleet/core/theme/fleet_design_system.dart';
import '../../../fleet/domain/repositories/fleet_repository.dart';
import '../../../fleet/presentation/cubit/fleet_cubit.dart';
import '../../../fleet/presentation/cubit/fleet_state.dart';
import '../../../fleet/presentation/widgets/fleet_error_banner.dart';
import '../../../fleet/presentation/widgets/fleet_vehicle_details_modal.dart';
import '../../models/etit_vehicle_model.dart';

class EtitFleetMapScreen extends StatefulWidget {
  final EtitVehicleModel? targetVehicle;

  const EtitFleetMapScreen({super.key, this.targetVehicle});

  @override
  State<EtitFleetMapScreen> createState() => _EtitFleetMapScreenState();
}

class _EtitFleetMapScreenState extends State<EtitFleetMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  late final FleetCubit _cubit;
  bool _ownsCubit = false;
  bool _hasCenteredInitialTarget = false;

  static const LatLng _minyaCenter = LatLng(28.10988, 30.75030);

  static const Map<String, Map<String, String>> _mapLayers = {
    'osm': {
      'label': 'خريطة قياسية',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
    'satellite': {
      'label': 'قمر صناعي',
      'url':
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    },
  };

  @override
  void initState() {
    super.initState();
    FleetCubit? existing;
    try {
      existing = context.read<FleetCubit>();
    } catch (_) {
      existing = null;
    }

    if (existing != null) {
      _cubit = existing;
      _ownsCubit = false;
      if (widget.targetVehicle != null) {
        _cubit.selectVehicle(widget.targetVehicle);
      }
      if (_cubit.state.allVehicles.isEmpty) {
        _cubit.initialize(targetVehicle: widget.targetVehicle);
      }
    } else {
      _cubit = getIt.isRegistered<FleetCubit>()
          ? getIt<FleetCubit>()
          : FleetCubit(repository: getIt<FleetRepository>());
      _ownsCubit = true;
      _cubit.initialize(targetVehicle: widget.targetVehicle);
    }

    _searchController.text = _cubit.state.filters.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  void _fitAllMarkers(List<EtitVehicleModel> vehicles) {
    final pts = vehicles
        .where((v) => v.hasValidLocation)
        .map((v) => LatLng(v.latitude!, v.longitude!))
        .toList();
    if (pts.isEmpty) {
      _mapController.move(_minyaCenter, 10.5);
      return;
    }
    if (pts.length == 1) {
      _mapController.move(pts.first, 15.0);
      return;
    }
    final bounds = LatLngBounds.fromPoints(pts);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(80, 120, 360, 120),
      ),
    );
  }

  void _selectAndFocusVehicle(EtitVehicleModel v, {bool fromPanel = false}) {
    _cubit.selectVehicle(v, collapseMapList: fromPanel);
    if (v.hasValidLocation) {
      _mapController.move(LatLng(v.latitude!, v.longitude!), 15.5);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'المركبة (${v.plateNumber.isNotEmpty ? v.plateNumber : v.code}) ليس لها إحداثيات GPS متصلة حالياً — تم عرض كافة بياناتها بالأسفل.',
          ),
          backgroundColor: FleetColors.offlineText,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _statusColor(EtitVehicleModel v) {
    if (v.isMoving) return FleetColors.movingDot;
    if (v.isStopped) return FleetColors.stoppedDot;
    return FleetColors.offlineDot;
  }

  Color _statusBgColor(EtitVehicleModel v) {
    if (v.isMoving) return FleetColors.movingBadgeBg;
    if (v.isStopped) return FleetColors.stoppedBadgeBg;
    return FleetColors.offlineBadgeBg;
  }

  IconData _vehicleIcon(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('trailer')) return Icons.rv_hookup_rounded;
    if (t.contains('truck')) return Icons.local_shipping_rounded;
    if (t.contains('pickup')) return Icons.local_shipping_outlined;
    return Icons.directions_car_filled_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FleetCubit>.value(
      value: _cubit,
      child: BlocConsumer<FleetCubit, FleetState>(
        listenWhen: (prev, curr) =>
            prev.selectedVehicle != curr.selectedVehicle ||
            prev.filters.searchQuery != curr.filters.searchQuery ||
            prev.lastSyncedAt != curr.lastSyncedAt,
        listener: (context, state) {
          if (_searchController.text != state.filters.searchQuery) {
            _searchController.value = TextEditingValue(
              text: state.filters.searchQuery,
              selection: TextSelection.collapsed(
                offset: state.filters.searchQuery.length,
              ),
            );
          }

          if (!_hasCenteredInitialTarget &&
              widget.targetVehicle != null &&
              state.selectedVehicle != null &&
              state.selectedVehicle!.hasValidLocation) {
            _hasCenteredInitialTarget = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _mapController.move(
                  LatLng(
                    state.selectedVehicle!.latitude!,
                    state.selectedVehicle!.longitude!,
                  ),
                  15.5,
                );
              }
            });
          } else if (state.isFollowingSelected &&
              state.selectedVehicle != null &&
              state.selectedVehicle!.hasValidLocation) {
            _mapController.move(
              LatLng(
                state.selectedVehicle!.latitude!,
                state.selectedVehicle!.longitude!,
              ),
              _mapController.camera.zoom,
            );
          }
        },
        buildWhen: (prev, curr) =>
            prev.isInitialLoading != curr.isInitialLoading ||
            prev.status != curr.status ||
            prev.hasData != curr.hasData,
        builder: (context, state) {
          if (state.isInitialLoading) {
            return const Scaffold(
              backgroundColor: FleetColors.pageBackground,
              body: FleetMapShimmer(),
            );
          }

          if (state.status == FleetStatus.error && !state.hasData) {
            return Scaffold(
              backgroundColor: FleetColors.pageBackground,
              body: FleetErrorStateView(
                failure: state.failure!,
                onRetry: () => _cubit.refresh(forceFullRefresh: true),
              ),
            );
          }

          return _buildMapCanvas(context);
        },
      ),
    );
  }

  Widget _buildMapCanvas(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = FleetResponsive.isMobile(screenWidth);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      body: Stack(
        children: [
          // ── 1. Interactive Live Map (Rebuilds only when map markers/layer/selection change)
          BlocBuilder<FleetCubit, FleetState>(
            buildWhen: (prev, curr) =>
                prev.filteredVehicles != curr.filteredVehicles ||
                prev.selectedVehicle != curr.selectedVehicle ||
                prev.mapLayerKey != curr.mapLayerKey,
            builder: (context, state) {
              final mapVehicles = state.filteredVehicles
                  .where((v) => v.hasValidLocation)
                  .toList(growable: false);

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter:
                      widget.targetVehicle?.hasValidLocation == true
                          ? LatLng(
                              widget.targetVehicle!.latitude!,
                              widget.targetVehicle!.longitude!,
                            )
                          : _minyaCenter,
                  initialZoom: widget.targetVehicle?.hasValidLocation == true
                      ? 15.0
                      : 11.0,
                  maxZoom: 19,
                  minZoom: 5,
                  onTap: (_, _) => _cubit.selectVehicle(null),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        (_mapLayers[state.mapLayerKey] ??
                            _mapLayers['osm']!)['url']!,
                    userAgentPackageName: 'incidents_managment',
                  ),
                  MarkerLayer(
                    markers: mapVehicles
                        .map(
                          (v) => _buildVehicleMarker(
                            v,
                            isSelected: state.selectedVehicle?.id == v.id,
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              );
            },
          ),

          // ── 2. Left-Side Map Zoom & Tools Strip ───────────────────────────
          Positioned(
            left: 14,
            top: 135,
            child: _buildLeftMapToolsStrip(),
          ),

          // ── 3. Bottom-Left Status Legend Card (دليل الحالات) ───────────────
          Positioned(
            left: 14,
            bottom: 16,
            child: _buildStatusLegendCard(),
          ),

          // ── 4. Top Floating Filter Row + Right Stacked Controls & List ───
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopFloatingBar(canPop: canPop),
                const SizedBox(height: 10),
                _buildRightStackedControls(),
              ],
            ),
          ),

          // ── 5. Selected Vehicle Floating Details Card ─────────────────────
          BlocBuilder<FleetCubit, FleetState>(
            buildWhen: (prev, curr) =>
                prev.selectedVehicle != curr.selectedVehicle ||
                prev.isFollowingSelected != curr.isFollowingSelected ||
                prev.isMapListExpanded != curr.isMapListExpanded,
            builder: (context, state) {
              final selected = state.selectedVehicle;
              if (selected == null) return const SizedBox.shrink();

              return Positioned(
                bottom: 16,
                left: isMobile ? 14 : 155,
                right: (!isMobile && state.isMapListExpanded) ? 348 : 16,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _buildSelectedVehicleCard(
                      selected,
                      isFollowing: state.isFollowingSelected,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. CUSTOM VEHICLE MARKER ON MAP
  // ═══════════════════════════════════════════════════════════════════════════
  Marker _buildVehicleMarker(EtitVehicleModel v, {required bool isSelected}) {
    final color = _statusColor(v);

    String statusSuffix;
    if (v.isMoving) {
      statusSuffix = '${v.speed?.toStringAsFixed(0) ?? '0'} كم/س';
    } else if (v.isStopped) {
      statusSuffix = 'متوقفة';
    } else {
      statusSuffix = 'غير متصل';
    }

    final displayName = v.plateNumber.isNotEmpty ? v.plateNumber : v.code;

    return Marker(
      point: LatLng(v.latitude!, v.longitude!),
      width: isSelected ? 175 : 155,
      height: isSelected ? 86 : 72,
      child: GestureDetector(
        onTap: () => _selectAndFocusVehicle(v),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating Label Pill Above Marker
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? FleetColors.primaryNavy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white : color.withAlpha(180),
                  width: 1.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF4ADE80) : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '$displayName · $statusSuffix',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? Colors.white
                            : FleetColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            // Circular Vehicle Marker with Halo Ring
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withAlpha(55),
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 1.5),
                    ),
                  ),
                Container(
                  width: isSelected ? 34 : 30,
                  height: isSelected ? 34 : 30,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _vehicleIcon(v.vehicleType),
                    color: Colors.white,
                    size: isSelected ? 18 : 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. TOP FLOATING FILTER & ACTION BAR
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildTopFloatingBar({required bool canPop}) {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) =>
          prev.statistics != curr.statistics ||
          prev.filters != curr.filters ||
          prev.mapLayerKey != curr.mapLayerKey,
      builder: (context, state) {
        final stats = state.statistics;
        final filters = state.filters;

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            // Right Group: Status Pills + Dropdowns
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (canPop)
                  Material(
                    color: FleetColors.primaryNavy,
                    borderRadius: BorderRadius.circular(10),
                    elevation: 3,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pop(),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'عودة للقائمة',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Status Filter Pills Group
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildStatusPill(
                        label: 'الكل',
                        count: stats.totalCount,
                        value: 'الكل',
                        selectedStatus: filters.statusFilter,
                        dotColor: null,
                        activeColor: FleetColors.primaryNavy,
                      ),
                      const SizedBox(width: 4),
                      _buildStatusPill(
                        label: 'متحركة',
                        count: stats.movingCount,
                        value: 'متحركة',
                        selectedStatus: filters.statusFilter,
                        dotColor: FleetColors.movingDot,
                        activeColor: FleetColors.movingDot,
                      ),
                      const SizedBox(width: 4),
                      _buildStatusPill(
                        label: 'متوقفة',
                        count: stats.stoppedCount,
                        value: 'متوقفة',
                        selectedStatus: filters.statusFilter,
                        dotColor: FleetColors.stoppedDot,
                        activeColor: FleetColors.stoppedDot,
                      ),
                      const SizedBox(width: 4),
                      _buildStatusPill(
                        label: 'غير متصل',
                        count: stats.offlineCount,
                        value: 'غير متصل',
                        selectedStatus: filters.statusFilter,
                        dotColor: FleetColors.offlineDot,
                        activeColor: FleetColors.offlineDot,
                      ),
                    ],
                  ),
                ),

                // Branch Dropdown
                _buildTopDropdownPill(
                  prefixLabel: 'الفرع',
                  icon: Icons.apartment_rounded,
                  value: filters.branchFilter,
                  items: stats.branches,
                  onChanged: (val) {
                    if (val != null) _cubit.setBranchFilter(val);
                  },
                ),

                // Vehicle Type Dropdown
                _buildTopDropdownPill(
                  prefixLabel: 'نوع السيارة',
                  icon: Icons.directions_car_outlined,
                  value: filters.vehicleTypeFilter,
                  items: stats.vehicleTypes,
                  onChanged: (val) {
                    if (val != null) _cubit.setVehicleTypeFilter(val);
                  },
                ),

                // Tracker Vendor Dropdown
                _buildTopDropdownPill(
                  prefixLabel: 'الجهاز',
                  icon: Icons.router_outlined,
                  value: filters.vendorFilter,
                  items: stats.vendors,
                  onChanged: (val) {
                    if (val != null) _cubit.setVendorFilter(val);
                  },
                ),

                // SIM Provider Dropdown
                _buildTopDropdownPill(
                  prefixLabel: 'الشريحة',
                  icon: Icons.sim_card_outlined,
                  value: filters.providerFilter,
                  items: stats.providers,
                  onChanged: (val) {
                    if (val != null) _cubit.setProviderFilter(val);
                  },
                ),

                if (filters.hasActiveFilters)
                  Material(
                    color: FleetColors.offlineBadgeBg,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        _searchController.clear();
                        _cubit.clearAllFilters();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: FleetColors.offlineText,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'مسح الفلاتر',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: FleetColors.offlineText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Left Group: Map Style + Live Status Badge (البث المباشر)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Map Layer Selector (خريطة قياسية / قمر صناعي فقط)
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _mapLayers.containsKey(state.mapLayerKey)
                          ? state.mapLayerKey
                          : 'osm',
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: FleetColors.textPrimary,
                      ),
                      items: _mapLayers.entries
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e.key,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.map_outlined,
                                    size: 15,
                                    color: FleetColors.primaryNavy,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(e.value['label']!),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) _cubit.setMapLayer(val);
                      },
                    ),
                  ),
                ),

                // Live Stream Status Pill (البث المباشر فقط)
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: FleetColors.movingBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: FleetColors.movingDot,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'البث المباشر',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: FleetColors.movingText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2B. RIGHT STACKED CONTROLS (تحت بعض: تحديد الكل/تحديث الآن -> بحث -> قائمة المركبات)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRightStackedControls() {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) =>
          prev.filteredVehicles != curr.filteredVehicles ||
          prev.isRefreshing != curr.isRefreshing ||
          prev.isMapListExpanded != curr.isMapListExpanded ||
          prev.filters.searchQuery != curr.filters.searchQuery ||
          prev.filters.statusFilter != curr.filters.statusFilter ||
          prev.selectedVehicle != curr.selectedVehicle ||
          prev.statistics != curr.statistics,
      builder: (context, state) {
        return Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: 322,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. تحديد الكل + تحديث الآن
                Row(
                  children: [
                    Expanded(
                      child: _buildTopActionButton(
                        label: 'تحديد الكل',
                        icon: Icons.fit_screen_outlined,
                        onTap: () => _fitAllMarkers(state.filteredVehicles),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTopActionButton(
                        label: 'تحديث الآن',
                        icon: Icons.refresh_rounded,
                        isSpinning: state.isRefreshing,
                        onTap: () => _cubit.refresh(forceFullRefresh: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // 2. البحث بالرقم
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _cubit.updateSearchQuery(val),
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'ابحث برقم اللوحة، كود السيارة أو IMEI...',
                      hintStyle: const TextStyle(
                        fontSize: 11.5,
                        color: FleetColors.textHint,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: FleetColors.textMuted,
                      ),
                      suffixIcon: state.filters.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 15),
                              onPressed: () {
                                _searchController.clear();
                                _cubit.clearSearch();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 3. زر قائمة المركبات
                Material(
                  color: state.isMapListExpanded
                      ? FleetColors.primaryNavy
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  elevation: 3,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _cubit.toggleMapListExpanded,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: state.isMapListExpanded
                              ? FleetColors.primaryNavy
                              : FleetColors.borderMedium,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_filled_rounded,
                            size: 18,
                            color: state.isMapListExpanded
                                ? Colors.white
                                : FleetColors.primaryNavy,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'قائمة المركبات (${state.filteredVehicles.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: state.isMapListExpanded
                                    ? Colors.white
                                    : FleetColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            state.isMapListExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: state.isMapListExpanded
                                ? Colors.white
                                : FleetColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 4. القائمة المنسدلة للمركبات (تظهر عند الضغط)
                if (state.isMapListExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      height: 360,
                      child: _buildRightVehiclesPanel(state),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusPill({
    required String label,
    required int count,
    required String value,
    required String selectedStatus,
    required Color? dotColor,
    required Color activeColor,
  }) {
    final isSelected = selectedStatus == value;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _cubit.setStatusFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              '$label ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : FleetColors.textSecondary,
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.white
                    : (dotColor ?? FleetColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopDropdownPill({
    required String prefixLabel,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeItems = items.isEmpty ? const ['الكل'] : items;
    final isFiltered = value != 'الكل';
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFiltered ? FleetColors.selectedRowBg : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFiltered ? FleetColors.accentBlue : Colors.transparent,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeItems.contains(value) ? value : 'الكل',
          icon: const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.keyboard_arrow_down_rounded, size: 16),
          ),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: FleetColors.textPrimary,
          ),
          items: safeItems
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: FleetColors.primaryNavy),
                      const SizedBox(width: 6),
                      Text('$prefixLabel: $item'),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTopActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isSpinning = false,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isSpinning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(icon, size: 16, color: FleetColors.primaryNavy),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: FleetColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. LEFT-SIDE MAP CONTROLS STRIP (+ / - / Center / Fit / Layers)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLeftMapToolsStrip() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMapToolIconButton(
            icon: Icons.add_rounded,
            tooltip: 'تكبير الخريطة',
            onTap: () {
              final z = (_mapController.camera.zoom + 1).clamp(5.0, 19.0);
              _mapController.move(_mapController.camera.center, z);
            },
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.remove_rounded,
            tooltip: 'تصغير الخريطة',
            onTap: () {
              final z = (_mapController.camera.zoom - 1).clamp(5.0, 19.0);
              _mapController.move(_mapController.camera.center, z);
            },
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.my_location_rounded,
            tooltip: 'توسيط محافظة المنيا',
            onTap: () => _mapController.move(_minyaCenter, 11.0),
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.fullscreen_rounded,
            tooltip: 'احتواء جميع المركبات المعروضة',
            onTap: () => _fitAllMarkers(_cubit.state.filteredVehicles),
          ),
          const SizedBox(width: 28, child: Divider(height: 1)),
          _buildMapToolIconButton(
            icon: Icons.layers_outlined,
            tooltip: 'تبديل طبقة الخريطة',
            onTap: () {
              final keys = _mapLayers.keys.toList();
              final current = _cubit.state.mapLayerKey;
              final nextIdx = (keys.indexOf(current) + 1) % keys.length;
              _cubit.setMapLayer(keys[nextIdx]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapToolIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 20, color: FleetColors.textSecondary),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. BOTTOM-LEFT STATUS LEGEND CARD (دليل الحالات)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStatusLegendCard() {
    return BlocBuilder<FleetCubit, FleetState>(
      buildWhen: (prev, curr) => prev.statistics != curr.statistics,
      builder: (context, state) {
        final stats = state.statistics;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(245),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'دليل الحالات',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: FleetColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                'متحركة (${stats.movingCount})',
                FleetColors.movingDot,
              ),
              const SizedBox(height: 5),
              _buildLegendItem(
                'متوقفة (${stats.stoppedCount})',
                FleetColors.stoppedDot,
              ),
              const SizedBox(height: 5),
              _buildLegendItem(
                'غير متصل (${stats.offlineCount})',
                FleetColors.offlineDot,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: FleetColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. RIGHT-SIDE COLLAPSIBLE VEHICLES PANEL (قائمة المركبات)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRightVehiclesPanel(FleetState state) {
    final stats = state.statistics;
    final filtered = state.filteredVehicles;

    return Container(
      width: 322,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 4 Mini Status Tabs inside Panel
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Row(
              children: [
                _buildPanelMiniTab(
                  'الكل (${stats.totalCount})',
                  'الكل',
                  state.filters.statusFilter,
                ),
                const SizedBox(width: 4),
                _buildPanelMiniTab(
                  'متحركة (${stats.movingCount})',
                  'متحركة',
                  state.filters.statusFilter,
                ),
                const SizedBox(width: 4),
                _buildPanelMiniTab(
                  'متوقفة (${stats.stoppedCount})',
                  'متوقفة',
                  state.filters.statusFilter,
                ),
                const SizedBox(width: 4),
                _buildPanelMiniTab(
                  'غير متصل (${stats.offlineCount})',
                  'غير متصل',
                  state.filters.statusFilter,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: FleetColors.borderLight),

          // Scrollable Vehicle Cards List
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'لا توجد مركبات مطابقة للفلاتر المحددة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: FleetColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final v = filtered[index];
                      return _buildPanelVehicleItem(
                        v,
                        isSelected: state.selectedVehicle?.id == v.id,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelMiniTab(
    String text,
    String statusValue,
    String currentStatus,
  ) {
    final isSelected = currentStatus == statusValue;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _cubit.setStatusFilter(statusValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? FleetColors.primaryNavy
                : FleetColors.surfaceMuted,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : FleetColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelVehicleItem(
    EtitVehicleModel v, {
    required bool isSelected,
  }) {
    final statusCol = _statusColor(v);
    final relTime = FleetDateFormatter.formatRelativeDuration(
      v.lastUpdate,
      short: true,
    );

    String statusTrailing;
    if (v.isMoving) {
      statusTrailing = '${v.speed?.toStringAsFixed(0) ?? '0'} كم/س';
    } else if (v.isStopped) {
      statusTrailing = relTime.isNotEmpty ? 'متوقفة · $relTime' : 'متوقفة';
    } else {
      statusTrailing = relTime.isNotEmpty ? 'غير متصل · $relTime' : 'غير متصل';
    }

    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _selectAndFocusVehicle(v, fromPanel: true),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? FleetColors.selectedRowBg : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? FleetColors.accentBlue
                  : FleetColors.borderLight,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Vehicle Icon + Colored Status Dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 36,
                    decoration: BoxDecoration(
                      color: FleetColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: FleetColors.borderLight),
                    ),
                    child: Icon(
                      _vehicleIcon(v.vehicleType),
                      color: FleetColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: statusCol,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Plate + Code + Branch + Speed/Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            v.plateNumber.isNotEmpty ? v.plateNumber : v.code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: FleetColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: FleetColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            v.code,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: FleetColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            (v.allocation ?? '').trim().isNotEmpty
                                ? v.allocation!
                                : 'غير محدد',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: FleetColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusTrailing,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusCol,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. SELECTED VEHICLE FLOATING DETAILS CARD (Bottom Overlay)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSelectedVehicleCard(
    EtitVehicleModel v, {
    required bool isFollowing,
  }) {
    final statusCol = _statusColor(v);
    final statusBg = _statusBgColor(v);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Dark Navy Header Bar ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: FleetColors.primaryNavy,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _vehicleIcon(v.vehicleType),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        v.plateNumber.isNotEmpty ? v.plateNumber : v.code,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'كود: ${v.code}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusCol,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        v.arabicStatusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: statusCol,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _cubit.selectVehicle(null),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White Body: All Vehicle Info Cells ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'السرعة الحالية',
                        value: '${v.speed?.toStringAsFixed(0) ?? '0'} كم/س',
                        valueColor: statusCol,
                        icon: Icons.speed_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'الفرع',
                        value: (v.allocation ?? '').trim().isNotEmpty
                            ? v.allocation!
                            : 'غير محدد',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'النوع',
                        value:
                            '${v.vehicleType ?? '-'} · ${v.arabicVehicleType}',
                        icon: Icons.directions_car_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'آخر تحديث',
                        value: FleetDateFormatter.formatArabicTimestamp(
                          v.lastUpdate,
                        ),
                        icon: Icons.access_time_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'جهاز التتبع والشريحة',
                        value:
                            '${(v.vendorName ?? '').isNotEmpty ? v.vendorName : 'غير محدد'} (${(v.providerName ?? '').isNotEmpty ? v.providerName : '-'})',
                        icon: Icons.wifi_tethering_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailMetricCell(
                        label: 'رقم IMEI',
                        value: (v.deviceCode ?? '').trim().isNotEmpty
                            ? v.deviceCode!
                            : 'غير مسجل',
                        icon: Icons.qr_code_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: FleetColors.borderLight),

          // ── Footer Bar: Coordinates + Full Details + Follow Button ─────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                // Coordinates + Copy
                InkWell(
                  onTap: v.hasValidLocation
                      ? () {
                          Clipboard.setData(
                            ClipboardData(
                              text: '${v.latitude}, ${v.longitude}',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم نسخ الإحداثيات'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: FleetColors.primaryNavy,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        v.hasValidLocation
                            ? '${v.latitude!.toStringAsFixed(4)}° N, ${v.longitude!.toStringAsFixed(4)}° E'
                            : 'لا توجد إحداثيات GPS متصلة حالياً',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: FleetColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          showFleetVehicleDetailsModal(context, v),
                      icon: const Icon(Icons.info_outline_rounded, size: 16),
                      label: const Text('كل بيانات المركبة'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: FleetColors.primaryNavy,
                        side: const BorderSide(color: FleetColors.borderMedium),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: v.hasValidLocation
                          ? () {
                              _cubit.toggleFollowSelected();
                              _mapController.move(
                                LatLng(v.latitude!, v.longitude!),
                                16.0,
                              );
                            }
                          : null,
                      icon: Icon(
                        isFollowing
                            ? Icons.gps_fixed_rounded
                            : Icons.navigation_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        isFollowing ? 'جاري التتبع المباشر' : 'تتبع المركبة',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? FleetColors.movingDot
                            : FleetColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailMetricCell({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: FleetColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FleetColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: FleetColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: valueColor ?? FleetColors.primaryNavy,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: valueColor ?? FleetColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
