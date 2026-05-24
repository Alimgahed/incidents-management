part of 'location_tracking_cubit.dart';

abstract class LocationTrackingState extends Equatable {
  const LocationTrackingState();

  @override
  List<Object?> get props => [];
}

class LocationTrackingInitial extends LocationTrackingState {
  const LocationTrackingInitial();
}

class LocationTrackingLoading extends LocationTrackingState {
  const LocationTrackingLoading();
}

class LocationTrackingActive extends LocationTrackingState {
  final Position position;

  const LocationTrackingActive({required this.position});

  @override
  List<Object?> get props => [position];
}

class LocationTrackingError extends LocationTrackingState {
  final String message;

  const LocationTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}
