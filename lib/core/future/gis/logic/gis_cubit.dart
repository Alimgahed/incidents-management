import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:incidents_managment/core/future/gis/data/gis_api_service.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_state.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';
import 'package:incidents_managment/core/future/gis/models/gis_style_config.dart';

class GisCubit extends Cubit<GisState> {
  final GisApiService apiService;

  Timer? _debounceTimer;
  CancelToken? _cancelToken;

  GisCubit({required this.apiService}) : super(const GisState());

  /// Initialize layer schema and load initial metadata and viewport
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final layers = await apiService.fetchAvailableLayers();
      final defaultEnabled = <String>{};

      if (layers.isNotEmpty) {
        for (final l in layers) {
          if (l.defaultEnabled || state.enabledLayers.contains(l.name)) {
            defaultEnabled.add(l.name);
          }
        }
      } else {
        defaultEnabled.addAll(state.enabledLayers);
      }

      final initialBounds = state.lastBounds ??
          LatLngBounds(
            const LatLng(28.0500, 30.7000),
            const LatLng(28.1300, 30.8000),
          );

      emit(state.copyWith(
        isLoading: false,
        availableLayers: layers,
        enabledLayers: defaultEnabled,
        lastBounds: initialBounds,
        layerData: layers.isEmpty ? const {} : state.layerData,
      ));

      if (layers.isNotEmpty) {
        _fetchViewportLayers(initialBounds, state.currentZoom);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        availableLayers: const [],
        enabledLayers: const {},
        layerData: const {},
        errorMessage: () => 'فشل في تحميل قائمة طبقات الخريطة: $e',
      ));
    }
  }

  /// Handle map pan & zoom with 300ms debounce and CancelToken cancellation
  void onCameraMoved(MapCamera camera) {
    emit(state.copyWith(
      currentZoom: camera.zoom,
      lastBounds: camera.visibleBounds,
    ));

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (apiService.isServerAvailable && state.enabledLayers.isNotEmpty) {
        _fetchViewportLayers(camera.visibleBounds, camera.zoom);
      }
    });
  }

  /// Fetch active layers for current viewport
  Future<void> _fetchViewportLayers(LatLngBounds bounds, double zoom) async {
    // If backend is not available or no layers enabled, do not fetch anything
    if (!apiService.isServerAvailable || state.enabledLayers.isEmpty) {
      emit(state.copyWith(isLayersLoading: false, layerData: const {}));
      return;
    }

    // 1. Cancel previous in-flight requests
    _cancelToken?.cancel('Camera moved');
    _cancelToken = CancelToken();
    final token = _cancelToken;

    emit(state.copyWith(isLayersLoading: true));

    final simplify = GisApiService.getSimplificationForZoom(zoom);
    final activeStack = gisLayerStack.where((style) {
      final isEnabled = state.enabledLayers.contains(style.name) ||
          style.aliases.any((a) => state.enabledLayers.contains(a));
      final meetsZoom = zoom >= style.minZoom;
      return isEnabled && meetsZoom;
    }).toList();

    if (activeStack.isEmpty) {
      emit(state.copyWith(isLayersLoading: false));
      return;
    }

    final updatedData = Map<String, GisCollection>.from(state.layerData);
    final truncatedList = <String>[];

    try {
      final futures = activeStack.map((style) async {
        try {
          final col = await apiService.fetchLayer(
            name: style.name,
            bounds: bounds,
            simplify: simplify,
            cancelToken: token,
          );
          return MapEntry(style.name, col);
        } catch (_) {
          return null;
        }
      });

      final results = await Future.wait(futures);

      // Check if token was cancelled during wait
      if (token?.isCancelled == true) return;

      for (final entry in results) {
        if (entry != null) {
          updatedData[entry.key] = entry.value;
          if (entry.value.truncated) {
            truncatedList.add(entry.key);
          }
        }
      }

      emit(state.copyWith(
        isLayersLoading: false,
        layerData: updatedData,
        truncatedLayers: truncatedList,
      ));
    } catch (e) {
      if (token?.isCancelled != true) {
        emit(state.copyWith(isLayersLoading: false));
      }
    }
  }

  /// Toggle visibility of a specific layer
  void toggleLayer(String layerName) {
    final updated = Set<String>.from(state.enabledLayers);
    final clean = layerName.toLowerCase().trim();

    if (updated.contains(clean)) {
      updated.remove(clean);
    } else {
      updated.add(clean);
    }

    emit(state.copyWith(enabledLayers: updated));

    if (state.lastBounds != null && apiService.isServerAvailable) {
      _fetchViewportLayers(state.lastBounds!, state.currentZoom);
    }
  }

  /// Sets the active category filter in the layers drawer (all, basemap, water_network, wastewater_network, operations)
  void setCategoryFilter(String category) {
    emit(state.copyWith(activeCategoryFilter: category));
  }

  /// Toggle OSM tile underlay on/off
  void toggleOsm([bool? value]) {
    emit(state.copyWith(useOsm: value ?? !state.useOsm));
  }

  /// Select a feature to inspect its attributes
  void selectFeature(GisFeature? feature, String? layerName) {
    emit(state.copyWith(
      selectedFeature: () => feature,
      selectedFeatureLayer: () => layerName,
    ));
  }

  /// Clear feature selection
  void clearSelection() {
    emit(state.copyWith(
      selectedFeature: () => null,
      selectedFeatureLayer: () => null,
    ));
  }

  /// Configure custom backend URL for GIS blueprint
  void setCustomBaseUrl(String? url) {
    apiService.customBaseUrl = (url != null && url.trim().isNotEmpty) ? url.trim() : null;
    init();
  }

  /// Manually force reload
  void reload() {
    if (state.lastBounds != null && apiService.isServerAvailable) {
      _fetchViewportLayers(state.lastBounds!, state.currentZoom);
    } else {
      init();
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    return super.close();
  }
}
