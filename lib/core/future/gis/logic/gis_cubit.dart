import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/future/gis/data/gis_api_service.dart';
import 'package:incidents_managment/core/future/gis/logic/gis_state.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';
import 'package:incidents_managment/core/future/gis/models/gis_style_config.dart';

class GisCubit extends Cubit<GisState> {
  final GisApiService apiService;

  Timer? _debounceTimer;
  CancelToken? _cancelToken;

  GisCubit({required this.apiService}) : super(const GisState());

  /// Initialize layer schema and load initial metadata
  Future<void> init() async {
    emit(state.copyWith(isLoading: true, errorMessage: () => null));

    try {
      final layers = await apiService.fetchAvailableLayers();
      final defaultEnabled = <String>{};
      for (final l in layers) {
        defaultEnabled.add(l.name);
      }
      // Also ensure standard stack layers are known
      for (final s in gisLayerStack) {
        defaultEnabled.add(s.name);
      }

      emit(state.copyWith(
        isLoading: false,
        availableLayers: layers,
        enabledLayers: defaultEnabled,
      ));

      if (state.lastBounds != null) {
        _fetchViewportLayers(state.lastBounds!, state.currentZoom);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
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
      _fetchViewportLayers(camera.visibleBounds, camera.zoom);
    });
  }

  /// Fetch active layers for current viewport
  Future<void> _fetchViewportLayers(LatLngBounds bounds, double zoom) async {
    // 1. Cancel previous in-flight requests
    _cancelToken?.cancel('Camera moved');
    _cancelToken = CancelToken();
    final token = _cancelToken;

    emit(state.copyWith(isLayersLoading: true));

    final simplify = GisApiService.getSimplificationForZoom(zoom);
    final activeStack = gisLayerStack.where((style) {
      final isEnabled = state.enabledLayers.contains(style.name);
      final meetsZoom = zoom >= style.minZoom;
      return isEnabled && meetsZoom;
    }).toList();

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
    if (updated.contains(layerName)) {
      updated.remove(layerName);
    } else {
      updated.add(layerName);
    }

    emit(state.copyWith(enabledLayers: updated));

    if (state.lastBounds != null) {
      _fetchViewportLayers(state.lastBounds!, state.currentZoom);
    }
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

  /// Manually force reload
  void reload() {
    if (state.lastBounds != null) {
      _fetchViewportLayers(state.lastBounds!, state.currentZoom);
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _cancelToken?.cancel();
    return super.close();
  }
}
