import 'package:latlong2/latlong.dart';

class MapState {
  final LatLng selectedLocation;
  final double zoom;

  const MapState({required this.selectedLocation, required this.zoom});

  MapState copyWith({LatLng? selectedLocation, double? zoom}) {
    return MapState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      zoom: zoom ?? this.zoom,
    );
  }
}
