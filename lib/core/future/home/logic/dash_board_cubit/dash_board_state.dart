import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardIncidentSelected extends DashboardState {
  final CurrentIncidentModel incident;
  DashboardIncidentSelected({required this.incident});
}

class DashboardIncidentDeselected extends DashboardState {}

class DashboardFilterChanged extends DashboardState {
  final String filter;
  DashboardFilterChanged({required this.filter});
}

class DashboardSearchChanged extends DashboardState {
  final String query;
  DashboardSearchChanged({required this.query});
}

class DashboardUpdating extends DashboardState {}

class DashboardUpdateRequested extends DashboardState {
  final int incidentId;
  final int newStatus;
  final int newSeverity;

  DashboardUpdateRequested({
    required this.incidentId,
    required this.newStatus,
    required this.newSeverity,
  });
}

class DashboardMissionUpdateRequested extends DashboardState {
  final int incidentId;
  final int missionId;
  final int newStatus;

  DashboardMissionUpdateRequested({
    required this.incidentId,
    required this.missionId,
    required this.newStatus,
  });
}

class DashboardIncidentUpdated extends DashboardState {
  final CurrentIncidentModel incident;
  DashboardIncidentUpdated({required this.incident});
}

class DashboardMissionUpdated extends DashboardState {
  final CurrentIncidentModel incident;
  final int missionId;

  DashboardMissionUpdated({required this.incident, required this.missionId});
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError({required this.message});
}
