import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'dash_board_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardInitial());

  // ---------------- INTERNAL STATE ----------------
  CurrentIncidentModel? _selectedIncident;
  String _selectedFilter = 'الكل';
  String _searchQuery = '';

  // ---------------- GETTERS ----------------
  CurrentIncidentModel? get selectedIncident => _selectedIncident;
  String get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;

  // ---------------- INCIDENT SELECTION ----------------
  void selectIncident(CurrentIncidentModel? incident) {
    _selectedIncident = incident;
    emit(
      incident == null
          ? const DashboardIncidentDeselected()
          : DashboardIncidentSelected(incident),
    );
  }

  void deselectIncident() => selectIncident(null);

  // ---------------- FILTERING ----------------
  void updateFilter(String filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    emit(DashboardFilterChanged(filter));
  }

  void updateSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    emit(DashboardSearchChanged(query));
  }

  List<CurrentIncidentModel> filterIncidents(
    List<CurrentIncidentModel> incidents,
  ) {
    Iterable<CurrentIncidentModel> filtered = incidents;

    if (_selectedFilter != 'الكل') {
      const severityMap = {'حرجة': 4, 'عالية': 3, 'متوسطة': 2, 'منخفضة': 1};
      final severity = severityMap[_selectedFilter];
      if (severity != null) {
        filtered = filtered.where((i) => i.currentIncidentSeverity == severity);
      }
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return (i.currentIncidentDescription ?? '').toLowerCase().contains(q) ||
            (i.currentIncidentNotes ?? '').toLowerCase().contains(q) ||
            (i.currentIncidentId?.toString() ?? '').contains(q);
      });
    }

    return filtered.toList();
  }

  // ---------------- INCIDENT STATUS & SEVERITY ----------------
  void updateIncidentStatusAndSeverity({
    required int incidentId,
    required int newStatus,
    required int newSeverity,
  }) {
    emit(const DashboardUpdating());

    try {
      emit(
        DashboardUpdateRequested(
          incidentId: incidentId,
          newStatus: newStatus,
          newSeverity: newSeverity,
        ),
      );

      if (_selectedIncident?.currentIncidentId != incidentId) return;

      _selectedIncident = _copyIncident(
        _selectedIncident!,
        status: newStatus,
        severity: newSeverity,
      );

      emit(DashboardIncidentUpdated(_selectedIncident!));
    } catch (e) {
      emit(DashboardError('فشل في تحديث الأزمة: $e'));
    }
  }

  // ---------------- MISSION STATUS ----------------
  void updateMissionStatus({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) {
    emit(const DashboardUpdating());

    try {
      emit(
        DashboardMissionUpdateRequested(
          incidentId: incidentId,
          missionId: missionId,
          newStatus: newStatus,
        ),
      );

      if (_selectedIncident?.currentIncidentId != incidentId) return;

      final missions = _selectedIncident!.currentIncidentWithMissions ?? [];
      final index = missions.indexWhere(
        (m) => m.idCurrentIncidentMission == missionId,
      );

      if (index == -1) return;

      final updatedMissions = List<CurrentIncidentWithMissions>.from(missions);

      _selectedIncident = _copyIncident(
        _selectedIncident!,
        missions: updatedMissions,
      );

      emit(
        DashboardMissionUpdated(
          incident: _selectedIncident!,
          missionId: missionId,
        ),
      );
    } catch (e) {
      emit(DashboardError('فشل في تحديث حالة المهمة: $e'));
    }
  }

  // ---------------- SYNC WITH INCIDENT MAP ----------------
  void syncWithIncidents(List<CurrentIncidentModel> incidents) {
    if (_selectedIncident == null) return;

    final updated = incidents.firstWhere(
      (i) => i.currentIncidentId == _selectedIncident!.currentIncidentId,
      orElse: () => _selectedIncident!,
    );

    if (identical(updated, _selectedIncident)) return;

    _selectedIncident = updated;
    emit(DashboardIncidentSelected(updated));
  }

  // ---------------- HELPER ----------------
  CurrentIncidentModel _copyIncident(
    CurrentIncidentModel incident, {
    int? status,
    int? severity,
    List<CurrentIncidentWithMissions>? missions,
  }) {
    return CurrentIncidentModel(
        currentIncidentId: incident.currentIncidentId,
        currentIncidentDescription: incident.currentIncidentDescription,
        currentIncidentTypeId: incident.currentIncidentTypeId,
        currentIncidentCreatedBy: incident.currentIncidentCreatedBy,
        currentIncidentCreatedAt: incident.currentIncidentCreatedAt,
        currentIncidentSeverity: severity ?? incident.currentIncidentSeverity,
        currentIncidentSeverityUpdateBy:
            incident.currentIncidentSeverityUpdateBy,
        currentIncidentSeverityUpdateAt: severity != null
            ? DateTime.now()
            : incident.currentIncidentSeverityUpdateAt,
        currentIncidentStatus: status ?? incident.currentIncidentStatus,
        currentIncidentStatusUpdatedBy: incident.currentIncidentStatusUpdatedBy,
        currentIncidentStatusUpdatedAt: status != null
            ? DateTime.now()
            : incident.currentIncidentStatusUpdatedAt,
        currentIncidentXAxis: incident.currentIncidentXAxis,
        currentIncidentYAxis: incident.currentIncidentYAxis,
        currentIncidentNotes: incident.currentIncidentNotes,
      )
      ..currentIncidentWithMissions =
          missions ?? incident.currentIncidentWithMissions;
  }
}
