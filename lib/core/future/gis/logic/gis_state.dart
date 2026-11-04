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

  const GisState({
    this.isLoading = false,
    this.isLayersLoading = false,
    this.availableLayers = const [],
    this.enabledLayers = const {
      'districts',
      'canals',
      'street',
      'pipe',
      'w_valve',
      'landmark',
      'building',
      'railway',
    },
    this.layerData = const {},
    this.truncatedLayers = const [],
    this.selectedFeature,
    this.selectedFeatureLayer,
    this.useOsm = false, // Document specifies GIS layers on beige background by default
    this.currentZoom = 15.0,
    this.lastBounds,
    this.errorMessage,
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
    );
  }
}
