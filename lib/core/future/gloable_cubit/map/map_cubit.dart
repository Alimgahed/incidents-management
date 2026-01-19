import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:latlong2/latlong.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit()
    : super(
        MapState(
          selectedLocation: LatLng(28.11, 30.75), // default Egypt
          zoom: 13,
        ),
      );

  void setLocation(LatLng location) {
    emit(state.copyWith(selectedLocation: location));
  }

  void setZoom(double zoom) {
    emit(state.copyWith(zoom: zoom));
  }

  // Example for GPS later
  void setCurrentLocation(LatLng location) {
    emit(state.copyWith(selectedLocation: location));
  }
}
