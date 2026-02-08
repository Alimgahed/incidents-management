import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

part 'dash_board_state.freezed.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = DashboardInitial;
  const factory DashboardState.incidentSelected(CurrentIncidentModel incident) =
      DashboardIncidentSelected;
  const factory DashboardState.incidentDeselected() =
      DashboardIncidentDeselected;
  const factory DashboardState.filterChanged(String filter) =
      DashboardFilterChanged;
  const factory DashboardState.searchChanged(String query) =
      DashboardSearchChanged;
  const factory DashboardState.updating() = DashboardUpdating;
  const factory DashboardState.updateRequested({
    required int incidentId,
    required int newStatus,
    required int newSeverity,
  }) = DashboardUpdateRequested;
  const factory DashboardState.missionUpdateRequested({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) = DashboardMissionUpdateRequested;
  const factory DashboardState.incidentUpdated(CurrentIncidentModel incident) =
      DashboardIncidentUpdated;
  const factory DashboardState.missionUpdated({
    required CurrentIncidentModel incident,
    required int missionId,
  }) = DashboardMissionUpdated;
  const factory DashboardState.error(String message) = DashboardError;
}
