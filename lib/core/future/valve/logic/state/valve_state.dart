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
  final double? userHeading;
  final double? userSpeed;
  final double? userAccuracy;
  final List<ValveModel> valves;
  final bool isMuted;
  final ValveModel? selectedValve;

  const ProximitySafe({
    required this.userLat,
    required this.userLng,
    this.userHeading,
    this.userSpeed,
    this.userAccuracy,
    required this.valves,
    this.isMuted = false,
    this.selectedValve,
  });

  ProximitySafe copyWith({
    double? userLat,
    double? userLng,
    double? userHeading,
    double? userSpeed,
    double? userAccuracy,
    List<ValveModel>? valves,
    bool? isMuted,
    ValveModel? selectedValve,
    bool clearSelectedValve = false,
  }) {
    return ProximitySafe(
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      userHeading: userHeading ?? this.userHeading,
      userSpeed: userSpeed ?? this.userSpeed,
      userAccuracy: userAccuracy ?? this.userAccuracy,
      valves: valves ?? this.valves,
      isMuted: isMuted ?? this.isMuted,
      selectedValve: clearSelectedValve ? null : (selectedValve ?? this.selectedValve),
    );
  }

  @override
  List<Object?> get props => [
        userLat,
        userLng,
        userHeading,
        userSpeed,
        userAccuracy,
        valves,
        isMuted,
        selectedValve,
      ];
}

/// User is within alarm radius of a valve — ALARM!
class ProximityAlert extends ProximityState {
  final double userLat;
  final double userLng;
  final double? userHeading;
  final double? userSpeed;
  final double? userAccuracy;
  final ValveModel nearestValve;
  final double distanceMeters;
  final List<ValveModel> valves;
  final bool isMuted;
  final bool isCritical; // Distance <= 0.5 meters (half a meter)
  final ValveModel? selectedValve;

  const ProximityAlert({
    required this.userLat,
    required this.userLng,
    this.userHeading,
    this.userSpeed,
    this.userAccuracy,
    required this.nearestValve,
    required this.distanceMeters,
    required this.valves,
    this.isMuted = false,
    this.isCritical = false,
    this.selectedValve,
  });

  ProximityAlert copyWith({
    double? userLat,
    double? userLng,
    double? userHeading,
    double? userSpeed,
    double? userAccuracy,
    ValveModel? nearestValve,
    double? distanceMeters,
    List<ValveModel>? valves,
    bool? isMuted,
    bool? isCritical,
    ValveModel? selectedValve,
    bool clearSelectedValve = false,
  }) {
    return ProximityAlert(
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      userHeading: userHeading ?? this.userHeading,
      userSpeed: userSpeed ?? this.userSpeed,
      userAccuracy: userAccuracy ?? this.userAccuracy,
      nearestValve: nearestValve ?? this.nearestValve,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      valves: valves ?? this.valves,
      isMuted: isMuted ?? this.isMuted,
      isCritical: isCritical ?? this.isCritical,
      selectedValve: clearSelectedValve ? null : (selectedValve ?? this.selectedValve),
    );
  }

  @override
  List<Object?> get props => [
        userLat,
        userLng,
        userHeading,
        userSpeed,
        userAccuracy,
        nearestValve,
        distanceMeters,
        valves,
        isMuted,
        isCritical,
        selectedValve,
      ];
}

/// Something went wrong (permission denied, GPS off …)
class ProximityError extends ProximityState {
  final String message;

  const ProximityError(this.message);

  @override
  List<Object?> get props => [message];
}