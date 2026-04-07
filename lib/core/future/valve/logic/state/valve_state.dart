// lib/cubit/proximity_state.dart

import 'package:equatable/equatable.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';

abstract class ProximityState extends Equatable {
  const ProximityState();

  @override
  List<Object?> get props => [];
}

/// Initial state before anything happens
class ProximityInitial extends ProximityState {
  const ProximityInitial();
}

/// Requesting GPS permission or waiting for first fix
class ProximityLoading extends ProximityState {
  const ProximityLoading();
}

/// GPS working, no nearby valve
class ProximitySafe extends ProximityState {
  final double userLat;
  final double userLng;
  final List<ValveModel> valves;

  const ProximitySafe({
    required this.userLat,
    required this.userLng,
    required this.valves,
  });

  @override
  List<Object?> get props => [userLat, userLng, valves];
}

/// User is within 5 m of a valve — ALARM!
class ProximityAlert extends ProximityState {
  final double userLat;
  final double userLng;
  final ValveModel nearestValve;
  final double distanceMeters;
  final List<ValveModel> valves;

  const ProximityAlert({
    required this.userLat,
    required this.userLng,
    required this.nearestValve,
    required this.distanceMeters,
    required this.valves,
  });

  @override
  List<Object?> get props =>
      [userLat, userLng, nearestValve, distanceMeters, valves];
}

/// Something went wrong (permission denied, GPS off …)
class ProximityError extends ProximityState {
  final String message;

  const ProximityError(this.message);

  @override
  List<Object?> get props => [message];
}