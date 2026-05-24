import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:incidents_managment/features/valves_map/domain/entities/valve_entity.dart';
import 'package:incidents_managment/features/valves_map/core/engine/geofence_state_machine.dart';
import 'package:incidents_managment/features/valves_map/core/engine/spatial_engine_isolate.dart';
import 'package:incidents_managment/features/valves_map/presentation/logic/location_tracking_cubit/location_tracking_cubit.dart';
import 'package:incidents_managment/features/valves_map/presentation/logic/valves_map_cubit/valves_map_cubit.dart';

part 'proximity_alert_state.dart';

class ProximityAlertCubit extends Cubit<ProximityAlertState> {
  final LocationTrackingCubit locationCubit;
  final ValvesMapCubit valvesMapCubit;
  final GeofenceStateMachine _geofenceStateMachine;
  
  StreamSubscription? _locationSub;
  bool _isProcessing = false;

  ProximityAlertCubit({
    required this.locationCubit,
    required this.valvesMapCubit,
  })  : _geofenceStateMachine = GeofenceStateMachine(),
        super(const ProximityAlertInitial()) {
    _monitorLocation();
  }

  void _monitorLocation() {
    _locationSub = locationCubit.stream.listen((locationState) async {
      if (locationState is LocationTrackingActive) {
        final valvesState = valvesMapCubit.state;
        if (valvesState is ValvesMapLoaded && !_isProcessing) {
          _isProcessing = true;
          await _processProximity(locationState.position, valvesState);
          _isProcessing = false;
        }
      } else {
        // If location is lost, reset geofence
        _geofenceStateMachine.reset();
        emit(const ProximityAlertInitial());
      }
    });
  }

  Future<void> _processProximity(Position position, ValvesMapLoaded valvesState) async {
    if (valvesState.valves.isEmpty) return;

    // Send data to Isolate for heavy calculation
    final request = SpatialEngineRequest(
      userLat: position.latitude,
      userLng: position.longitude,
      valves: valvesState.valves,
      maxResults: 1, // We only care about the absolute nearest valve for alerts
    );

    final nearestResults = await SpatialEngineIsolate.findNearestValves(request);

    if (nearestResults.isEmpty) return;

    final nearest = nearestResults.first;
    final distance = nearest.distanceInMeters;

    // Update Geofence State Machine
    final newState = _geofenceStateMachine.updateDistance(distance);

    // Emit the new state containing the nearest valve and the geofence state
    emit(ProximityAlertActive(
      nearestValve: nearest.valve,
      distanceInMeters: distance,
      geofenceState: newState,
    ));
  }

  @override
  Future<void> close() {
    _locationSub?.cancel();
    return super.close();
  }
}
