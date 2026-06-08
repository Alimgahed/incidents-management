import 'package:latlong2/latlong.dart';

class MapState {
  final LatLng selectedLocation;
  final double zoom;
  final String? address;

  const MapState({
    required this.selectedLocation,
    required this.zoom,
    this.address,
  });

  MapState copyWith({
    LatLng? selectedLocation,
    double? zoom,
    String? address,
  }) {
    return MapState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      zoom: zoom ?? this.zoom,
      // We check if address is passed, otherwise keep the old one. If we want to allow nulling it out, it would need a different pattern, but this is fine.
      // Wait, we need to be able to update address when we pass it explicitly.
      // We will do address: address ?? this.address. But if we want to overwrite with null? Not needed here.
      address: address ?? this.address,
    );
  }
}
