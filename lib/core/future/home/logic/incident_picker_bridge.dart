import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

/// Bridges command-palette (or other global UI) to the active [DashboardCubit]
/// and the dashboard's nested navigator (details stay inside home tab).
class IncidentPickerBridge {
  void Function(CurrentIncidentModel incident)? _selectListener;
  void Function()? _openDetailsListener;

  void register({
    required void Function(CurrentIncidentModel incident) onSelect,
    required void Function() onOpenDetails,
  }) {
    _selectListener = onSelect;
    _openDetailsListener = onOpenDetails;
  }

  void unregister() {
    _selectListener = null;
    _openDetailsListener = null;
  }

  void requestSelect(CurrentIncidentModel incident) {
    _selectListener?.call(incident);
    _openDetailsListener?.call();
  }
}
