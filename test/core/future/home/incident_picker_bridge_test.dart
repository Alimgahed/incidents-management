import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';

void main() {
  test(
    'keeps a notification target until incident data and a listener arrive',
    () {
      final bridge = IncidentPickerBridge();
      final target = CurrentIncidentModel(currentIncidentId: 42);
      CurrentIncidentModel? selected;
      var opened = false;

      bridge.requestSelectById('42');
      bridge.resolvePending([target]);
      expect(selected, isNull);

      bridge.register(
        onSelect: (incident) => selected = incident,
        onOpenDetails: () => opened = true,
      );

      expect(selected?.currentIncidentId, 42);
      expect(opened, isTrue);
    },
  );
}
