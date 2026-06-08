import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:latlong2/latlong.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit()
    : super(
        const MapState(
          selectedLocation: LatLng(28.11, 30.75), // default Egypt
          zoom: 13,
        ),
      );

  void setLocation(LatLng location) {
    emit(state.copyWith(selectedLocation: location));
    _fetchAddress(location);
  }

  void setZoom(double zoom) {
    emit(state.copyWith(zoom: zoom));
  }

  // Example for GPS later
  void setCurrentLocation(LatLng location) {
    emit(state.copyWith(selectedLocation: location));
    _fetchAddress(location);
  }

  Future<void> _fetchAddress(LatLng location) async {
    try {
      final response = await Dio().get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'format': 'json',
          'lat': location.latitude,
          'lon': location.longitude,
          'accept-language': 'ar', // Arabic address
        },
      );
      if (response.data != null && response.data['display_name'] != null) {
        emit(state.copyWith(address: response.data['display_name']));
      }
    } catch (e) {
      // Ignore error, keep existing or null address
    }
  }
}
