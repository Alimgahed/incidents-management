import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());

  // Current selected incident
  CurrentIncidentModel? _selectedIncident;

  // Filter settings
  String _selectedFilter = 'الكل';
  String _searchQuery = '';

  // Getters
  CurrentIncidentModel? get selectedIncident => _selectedIncident;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  // ============================================================================
  // INCIDENT SELECTION
  // ============================================================================
  void selectIncident(CurrentIncidentModel? incident) {
    _selectedIncident = incident;

    if (incident != null) {
      emit(DashboardIncidentSelected(incident: incident));
    } else {
      emit(DashboardIncidentDeselected());
    }
  }

  void deselectIncident() {
    _selectedIncident = null;
    emit(DashboardIncidentDeselected());
  }

  // ============================================================================
  // FILTERING
  // ============================================================================
  void updateFilter(String filter) {
    _selectedFilter = filter;
    emit(DashboardFilterChanged(filter: filter));
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    emit(DashboardSearchChanged(query: query));
  }

  List<CurrentIncidentModel> filterIncidents(
    List<CurrentIncidentModel> incidents,
  ) {
    var filtered = incidents;

    // Apply severity filter
    if (_selectedFilter != 'الكل') {
      const severityMap = {'حرجة': 4, 'عالية': 3, 'متوسطة': 2, 'منخفضة': 1};
      final targetSeverity = severityMap[_selectedFilter];
      if (targetSeverity != null) {
        filtered = filtered
            .where((i) => i.currentIncidentSeverity == targetSeverity)
            .toList();
      }
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((incident) {
        final description =
            incident.currentIncidentDescription?.toLowerCase() ?? '';
        final notes = incident.currentIncidentNotes?.toLowerCase() ?? '';
        final id = incident.currentIncidentId?.toString() ?? '';

        return description.contains(query) ||
            notes.contains(query) ||
            id.contains(query);
      }).toList();
    }

    return filtered;
  }

  // ============================================================================
  // UPDATE INCIDENT STATUS AND SEVERITY
  // ============================================================================
  void updateIncidentStatusAndSeverity({
    required int incidentId,
    required int newStatus,
    required int newSeverity,
  }) {
    emit(DashboardUpdating());

    try {
      // Emit event to update via Socket.IO
      // This will be handled by IncidentMapCubit
      emit(
        DashboardUpdateRequested(
          incidentId: incidentId,
          newStatus: newStatus,
          newSeverity: newSeverity,
        ),
      );

      // Update local selected incident if it matches
      if (_selectedIncident?.currentIncidentId == incidentId) {
        _selectedIncident =
            CurrentIncidentModel(
                currentIncidentId: _selectedIncident!.currentIncidentId,
                currentIncidentDescription:
                    _selectedIncident!.currentIncidentDescription,
                currentIncidentTypeId: _selectedIncident!.currentIncidentTypeId,
                currentIncidentCreatedBy:
                    _selectedIncident!.currentIncidentCreatedBy,
                currentIncidentCreatedAt:
                    _selectedIncident!.currentIncidentCreatedAt,
                currentIncidentSeverity: newSeverity,
                currentIncidentSeverityUpdateBy:
                    _selectedIncident!.currentIncidentSeverityUpdateBy,
                currentIncidentSeverityUpdateAt: DateTime.now(),
                currentIncidentStatus: newStatus,
                currentIncidentStatusUpdatedBy:
                    _selectedIncident!.currentIncidentStatusUpdatedBy,
                currentIncidentStatusUpdatedAt: DateTime.now(),
                currentIncidentXAxis: _selectedIncident!.currentIncidentXAxis,
                currentIncidentYAxis: _selectedIncident!.currentIncidentYAxis,
                currentIncidentNotes: _selectedIncident!.currentIncidentNotes,
              )
              ..currentIncidentWithMissions =
                  _selectedIncident!.currentIncidentWithMissions;

        emit(DashboardIncidentUpdated(incident: _selectedIncident!));
      }
    } catch (e) {
      emit(DashboardError(message: 'فشل في تحديث الأزمة: $e'));
    }
  }

  // ============================================================================
  // MISSION STATUS UPDATE
  // ============================================================================
  void updateMissionStatus({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) {
    emit(DashboardUpdating());

    try {
      // Emit event to update via Socket.IO
      // This will be handled by IncidentMapCubit
      emit(
        DashboardMissionUpdateRequested(
          incidentId: incidentId,
          missionId: missionId,
          newStatus: newStatus,
        ),
      );

      // Update local selected incident's missions if it matches
      if (_selectedIncident?.currentIncidentId == incidentId) {
        final missions = _selectedIncident!.currentIncidentWithMissions ?? [];
        final missionIndex = missions.indexWhere(
          (m) => m.idCurrentIncidentMission == missionId,
        );

        if (missionIndex != -1) {
          final updatedMissions = List<CurrentIncidentWithMissions>.from(
            missions,
          );
          updatedMissions[missionIndex] = CurrentIncidentWithMissions(
            idCurrentIncidentMission:
                missions[missionIndex].idCurrentIncidentMission,
            currentIncidentId: missions[missionIndex].currentIncidentId,
            currentIncidentMissionId:
                missions[missionIndex].currentIncidentMissionId,
            currentIncidentMissionOrder:
                missions[missionIndex].currentIncidentMissionOrder,
            currentIncidentMissionStatus: newStatus,
            currentIncidentMissionStatusUpdatedBy:
                missions[missionIndex].currentIncidentMissionStatusUpdatedBy,
            currentIncidentMissionStatusUpdatedAt: DateTime.now(),
          );

          _selectedIncident = CurrentIncidentModel(
            currentIncidentId: _selectedIncident!.currentIncidentId,
            currentIncidentDescription:
                _selectedIncident!.currentIncidentDescription,
            currentIncidentTypeId: _selectedIncident!.currentIncidentTypeId,
            currentIncidentCreatedBy:
                _selectedIncident!.currentIncidentCreatedBy,
            currentIncidentCreatedAt:
                _selectedIncident!.currentIncidentCreatedAt,
            currentIncidentSeverity: _selectedIncident!.currentIncidentSeverity,
            currentIncidentSeverityUpdateBy:
                _selectedIncident!.currentIncidentSeverityUpdateBy,
            currentIncidentSeverityUpdateAt:
                _selectedIncident!.currentIncidentSeverityUpdateAt,
            currentIncidentStatus: _selectedIncident!.currentIncidentStatus,
            currentIncidentStatusUpdatedBy:
                _selectedIncident!.currentIncidentStatusUpdatedBy,
            currentIncidentStatusUpdatedAt:
                _selectedIncident!.currentIncidentStatusUpdatedAt,
            currentIncidentXAxis: _selectedIncident!.currentIncidentXAxis,
            currentIncidentYAxis: _selectedIncident!.currentIncidentYAxis,
            currentIncidentNotes: _selectedIncident!.currentIncidentNotes,
          )..currentIncidentWithMissions = updatedMissions;

          emit(
            DashboardMissionUpdated(
              incident: _selectedIncident!,
              missionId: missionId,
            ),
          );
        }
      }
    } catch (e) {
      emit(DashboardError(message: 'فشل في تحديث حالة المهمة: $e'));
    }
  }

  // ============================================================================
  // SYNC WITH INCIDENT MAP CUBIT
  // ============================================================================
  void syncWithIncidents(List<CurrentIncidentModel> incidents) {
    // Update selected incident if it exists in the new list
    if (_selectedIncident != null) {
      final updated = incidents.firstWhere(
        (i) => i.currentIncidentId == _selectedIncident!.currentIncidentId,
        orElse: () => _selectedIncident!,
      );

      if (updated.currentIncidentId != null) {
        _selectedIncident = updated;
        emit(DashboardIncidentSelected(incident: updated));
      }
    }
  }
}
