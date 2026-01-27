// ============================================================================
// HOME STATE - States for HomeCubit
// ============================================================================

import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

abstract class IncidentMapState {
  const IncidentMapState();
}

class IncidentMapInitial extends IncidentMapState {}

class IncidentMapLoading extends IncidentMapState {}

class IncidentMapLoaded extends IncidentMapState {
  final List<CurrentIncidentModel> incidents;

  const IncidentMapLoaded({required this.incidents});
}

class IncidentMapError extends IncidentMapState {
  final String message;

  const IncidentMapError({required this.message});
}
