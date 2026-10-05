import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

/// Bridges command-palette (or other global UI) to the active [DashboardCubit]
/// and the dashboard's nested navigator (details stay inside home tab).
class IncidentPickerBridge {
  void Function(CurrentIncidentModel incident)? _selectListener;
  void Function()? _openDetailsListener;
  CurrentIncidentModel? _pendingIncident;
  String? _pendingIncidentId;

  void register({
    required void Function(CurrentIncidentModel incident) onSelect,
    required void Function() onOpenDetails,
  }) {
    _selectListener = onSelect;
    _openDetailsListener = onOpenDetails;
    _dispatchPending();
  }

  void unregister() {
    _selectListener = null;
    _openDetailsListener = null;
  }

  void requestSelect(CurrentIncidentModel incident) {
    _pendingIncident = incident;
    _dispatchPending();
  }

  void requestSelectById(String incidentId) {
    _pendingIncidentId = incidentId;
  }

  void resolvePending(List<CurrentIncidentModel> incidents) {
    final id = _pendingIncidentId;
    if (id == null) return;
    for (final incident in incidents) {
      if (incident.currentIncidentId.toString() == id) {
        _pendingIncidentId = null;
        _pendingIncident = incident;
        _dispatchPending();
        return;
      }
    }
  }

  void _dispatchPending() {
    final incident = _pendingIncident;
    if (incident == null ||
        _selectListener == null ||
        _openDetailsListener == null)
      return;
    _pendingIncident = null;
    _selectListener!(incident);
    _openDetailsListener!();
  }
}
