import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/gloable_cubit/map/map_states.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapState(zoom: 13));

  void setLocation(LatLng location) {
    emit(state.copyWith(selectedLocation: location, locationError: null));
    _fetchAddress(location);
  }

  void setZoom(double zoom) {
    emit(state.copyWith(zoom: zoom));
  }

  Future<void> locateCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        emit(
          state.copyWith(
            locationError:
                'خدمة الموقع غير مفعلة. يمكنك تحديد الموقع بالنقر على الخريطة.',
          ),
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            locationError:
                'تعذر الوصول للموقع. يمكنك تحديده يدوياً على الخريطة.',
          ),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      setLocation(LatLng(position.latitude, position.longitude));
    } catch (_) {
      emit(
        state.copyWith(
          locationError:
              'تعذر تحديد الموقع الحالي. يمكنك تحديده يدوياً على الخريطة.',
        ),
      );
    }
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
        if (state.selectedLocation == location) {
          emit(state.copyWith(address: response.data['display_name']));
        }
      }
    } catch (e) {
      // Ignore error, keep existing or null address
    }
  }
}
