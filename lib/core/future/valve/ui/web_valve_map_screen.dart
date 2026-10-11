import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/web_valve_cubit.dart';
import 'package:incidents_managment/core/future/valve/logic/state/web_valve_state.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/valve_filter_cubit.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/map/valve_filters_panel.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/map/valve_list_panel.dart';
import 'package:incidents_managment/core/future/valve/ui/widgets/map/map_valve_details_modal.dart';
import 'package:latlong2/latlong.dart';

class WebValveMapScreen extends StatefulWidget {
  const WebValveMapScreen({super.key});

  @override
  State<WebValveMapScreen> createState() => _WebValveMapScreenState();
}

class _WebValveMapScreenState extends State<WebValveMapScreen> {
  final MapController _mapController = MapController();
  static const LatLng _minyaCenter = LatLng(28.0871, 30.7501);
  List<ValveModel> _cachedValves = [];
  ValveFilterOptions _cachedFilters = const ValveFilterOptions();
  ValvePagination _cachedPagination = const ValvePagination();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  MapBounds _boundsFromCamera() {
    final bounds = _mapController.camera.visibleBounds;
    return MapBounds(
      latMin: bounds.south,
      latMax: bounds.north,
      longMin: bounds.west,
      longMax: bounds.east,
    );
  }

  void _syncMapBounds(BuildContext context) {
    context.read<WebValveMapCubit>().updateMapBounds(_boundsFromCamera());
  }

  void _applyServerFilters(BuildContext context) {
    context.read<WebValveMapCubit>().applyFilters(
          context.read<ValveFilterCubit>().state,
        );
  }

  void _showValveDetails(ValveModel valve) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => MapValveDetailsModal(
        valve: valve,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WebValveMapCubit>(
          create: (_) => getIt<WebValveMapCubit>(),
        ),
        BlocProvider<ValveFilterCubit>(
          create: (_) => ValveFilterCubit(),
        ),
      ],
      child: BlocBuilder<WebValveMapCubit, WebValveMapState>(
        builder: (context, state) {
          final currentValves = state is WebValveMapLoaded
              ? state.valves
              : _cachedValves;
          final filterOptions = state is WebValveMapLoaded
              ? state.filters
              : _cachedFilters;
          final pagination = state is WebValveMapLoaded
              ? state.pagination
              : _cachedPagination;

          if (state is WebValveMapLoaded) {
            _cachedValves = state.valves;
            _cachedFilters = state.filters;
            _cachedPagination = state.pagination;
          }

          if (state is WebValveMapError && _cachedValves.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'إعادة المحاولة',
                    textColor: Colors.white,
                    onPressed: () => _syncMapBounds(context),
                  ),
                ),
              );
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildMapContent(
              state,
              currentValves,
              filterOptions,
              pagination,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapContent(
    WebValveMapState state,
    List<ValveModel> valves,
    ValveFilterOptions filterOptions,
    ValvePagination pagination,
  ) {
    return BlocConsumer<ValveFilterCubit, ValveFilterState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.valveTypeId != current.valveTypeId ||
          previous.diameter != current.diameter ||
          previous.pipeDiameter != current.pipeDiameter ||
          previous.direction != current.direction ||
          previous.inServiceYear != current.inServiceYear,
      listener: (context, filterState) {
        context.read<WebValveMapCubit>().applyFilters(filterState);
      },
      builder: (context, filterState) {
        final filteredValves =
            context.read<ValveFilterCubit>().filterValves(valves);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValveFiltersPanel(
              filterOptions: filterOptions,
              filteredCount: filteredValves.length,
              totalCount: pagination.total,
              onApply: () => _applyServerFilters(context),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildMap(context, filteredValves, state),
              ),
            ),
            const SizedBox(width: 16),
            ValveListPanel(
              filteredValves: filteredValves,
              totalCount: pagination.total,
              onValveTap: (valve) {
                final lat = valve.lat;
                final lng = valve.long;
                if (lat != null && lng != null) {
                  _mapController.move(LatLng(lat, lng), 17);
                }
                _showValveDetails(valve);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(
    BuildContext context,
    List<ValveModel> filteredValves,
    WebValveMapState state,
  ) {
    final isRefreshing = state is WebValveMapLoaded && state.isRefreshing;
    final bounds = state is WebValveMapLoaded ? state.bounds : null;

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _minyaCenter,
            initialZoom: 13,
            maxZoom: 19,
            minZoom: 5,
            onMapReady: () => _syncMapBounds(context),
            onPositionChanged: (camera, hasGesture) {
              if (!hasGesture) return;
              context.read<WebValveMapCubit>().updateMapBounds(
                    MapBounds(
                      latMin: camera.visibleBounds.south,
                      latMax: camera.visibleBounds.north,
                      longMin: camera.visibleBounds.west,
                      longMax: camera.visibleBounds.east,
                    ),
                  );
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'incidents_managment',
            ),
            MarkerLayer(
              markers: filteredValves
                  .where((v) => v.lat != null && v.long != null)
                  .map((valve) => Marker(
                        point: LatLng(valve.lat!, valve.long!),
                        width: 45,
                        height: 45,
                        child: GestureDetector(
                          onTap: () => _showValveDetails(valve),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        if (bounds != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'lat ${bounds.latMin.toStringAsFixed(4)} → ${bounds.latMax.toStringAsFixed(4)}  |  '
                  'lng ${bounds.longMin.toStringAsFixed(4)} → ${bounds.longMax.toStringAsFixed(4)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1B4F8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        if (isRefreshing)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 3),
          ),
        Positioned(
          left: 16,
          bottom: 16,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.add,
                onTap: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _syncMapBounds(context);
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.remove,
                onTap: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _syncMapBounds(context);
                  });
                },
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.my_location,
                onTap: () {
                  _mapController.move(_minyaCenter, 13);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _syncMapBounds(context);
                  });
                },
              ),
            ],
          ),
        ),
        if ((state is WebValveMapLoading || state is WebValveMapInitial) &&
            _cachedValves.isEmpty)
          Container(
            color: Colors.white.withValues(alpha: 0.8),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'جاري تحميل المحابس...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        if (state is WebValveMapError && _cachedValves.isEmpty)
          Container(
            color: Colors.white.withValues(alpha: 0.9),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _syncMapBounds(context),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6CB0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMapControl({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.blue.shade800),
        ),
      ),
    );
  }
}
