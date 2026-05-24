part of 'proximity_alert_cubit.dart';

abstract class ProximityAlertState extends Equatable {
  const ProximityAlertState();

  @override
  List<Object?> get props => [];
}

class ProximityAlertInitial extends ProximityAlertState {
  const ProximityAlertInitial();
}

class ProximityAlertActive extends ProximityAlertState {
  final ValveEntity nearestValve;
  final double distanceInMeters;
  final GeofenceState geofenceState;

  const ProximityAlertActive({
    required this.nearestValve,
    required this.distanceInMeters,
    required this.geofenceState,
  });

  @override
  List<Object?> get props => [nearestValve, distanceInMeters, geofenceState];
}
