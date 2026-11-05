import 'package:flutter_map/flutter_map.dart';
import 'package:incidents_managment/core/future/gis/models/gis_models.dart';

class GisState {
  final bool isLoading;
  final bool isLayersLoading;
  final List<GisLayerInfo> availableLayers;
  final Set<String> enabledLayers;
  final Map<String, GisCollection> layerData;
  final List<String> truncatedLayers;
  final GisFeature? selectedFeature;
  final String? selectedFeatureLayer;
  final bool useOsm;
  final double currentZoom;
  final LatLngBounds? lastBounds;
  final String? errorMessage;
  final String activeCategoryFilter; // all | basemap | water_network | wastewater_network | operations

  const GisState({
    this.isLoading = false,
    this.isLayersLoading = false,
    this.availableLayers = const [],
    this.enabledLayers = const {
      'districts',
      'water_bodies',
      'canals',
      'streets',
      'buildings',
      'landmarks',
      'railways',
      'bridges',
      'water_pipes',
      'water_valves',
      'pipe_breaks',
    },
    this.layerData = const {},
    this.truncatedLayers = const [],
    this.selectedFeature,
    this.selectedFeatureLayer,
    this.useOsm = false, // Base map is built directly from GIS system vector layers instead of OpenStreetMap
    this.currentZoom = 15.5,
    this.lastBounds,
    this.errorMessage,
    this.activeCategoryFilter = 'all',
  });

  GisState copyWith({
    bool? isLoading,
    bool? isLayersLoading,
    List<GisLayerInfo>? availableLayers,
    Set<String>? enabledLayers,
    Map<String, GisCollection>? layerData,
    List<String>? truncatedLayers,
    GisFeature? Function()? selectedFeature,
    String? Function()? selectedFeatureLayer,
    bool? useOsm,
    double? currentZoom,
    LatLngBounds? lastBounds,
    String? Function()? errorMessage,
    String? activeCategoryFilter,
  }) {
    return GisState(
      isLoading: isLoading ?? this.isLoading,
      isLayersLoading: isLayersLoading ?? this.isLayersLoading,
      availableLayers: availableLayers ?? this.availableLayers,
      enabledLayers: enabledLayers ?? this.enabledLayers,
      layerData: layerData ?? this.layerData,
      truncatedLayers: truncatedLayers ?? this.truncatedLayers,
      selectedFeature: selectedFeature != null
          ? selectedFeature()
          : this.selectedFeature,
      selectedFeatureLayer: selectedFeatureLayer != null
          ? selectedFeatureLayer()
          : this.selectedFeatureLayer,
      useOsm: useOsm ?? this.useOsm,
      currentZoom: currentZoom ?? this.currentZoom,
      lastBounds: lastBounds ?? this.lastBounds,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      activeCategoryFilter: activeCategoryFilter ?? this.activeCategoryFilter,
    );
  }
}
