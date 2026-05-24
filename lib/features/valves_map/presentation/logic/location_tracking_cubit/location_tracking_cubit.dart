import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rxdart/rxdart.dart';

part 'location_tracking_state.dart';

class LocationTrackingCubit extends Cubit<LocationTrackingState> {
  StreamSubscription<Position>? _positionSubscription;

  LocationTrackingCubit() : super(const LocationTrackingInitial());

  Future<void> startTracking() async {
    emit(const LocationTrackingLoading());

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const LocationTrackingError('Location services are disabled.'));
      return;
    }

    // 2. Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(const LocationTrackingError('Location permissions are denied.'));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(const LocationTrackingError('Location permissions are permanently denied.'));
      return;
    }

    // 3. Start listening to location stream
    // Using a LocationSettings that ignores very small movements (e.g. 5 meters) to save battery
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Only update if device moved 5 meters
    );

    // Get initial position first to avoid delay
    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      emit(LocationTrackingActive(position: initialPosition));
    } catch (e) {
      // Ignore error, stream will catch the next one
    }

    // Subscribe to stream and use RxDart for Throttling/Debouncing
    final positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .throttleTime(const Duration(seconds: 2)); // Ignore jittery rapid updates

    _positionSubscription = positionStream.listen(
      (Position position) {
        emit(LocationTrackingActive(position: position));
      },
      onError: (e) {
        emit(LocationTrackingError(e.toString()));
      },
    );
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    emit(const LocationTrackingInitial());
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
