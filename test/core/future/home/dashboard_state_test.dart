import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/home_cubit.dart/home_states.dart';

void main() {
  group('HomeCubit tab selection', () {
    late HomeCubit cubit;

    setUp(() => cubit = HomeCubit());
    tearDown(() => cubit.close());

    test('updates selected tab and ignores duplicate selections', () async {
      final states = <HomeStates>[];
      final subscription = cubit.stream.listen(states.add);

      cubit.changeState(2);
      cubit.changeState(2);
      cubit.changeState(1);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.selectedIndex, 1);
      expect(states, hasLength(2));
      await subscription.cancel();
    });
  });

  group('DashboardCubit incident filtering', () {
    late DashboardCubit cubit;
    final incidents = [
      CurrentIncidentModel(
        currentIncidentId: 10,
        currentIncidentDescription: 'Pipe leak near station',
        currentIncidentNotes: 'north district',
        currentIncidentSeverity: 4,
        currentIncidentStatus: 1,
      ),
      CurrentIncidentModel(
        currentIncidentId: 11,
        currentIncidentDescription: 'Road obstruction',
        currentIncidentNotes: 'south district',
        currentIncidentSeverity: 2,
        currentIncidentStatus: 2,
      ),
    ];

    setUp(() => cubit = DashboardCubit());
    tearDown(() => cubit.close());

    test('search matches descriptions, notes, and incident identifiers', () {
      cubit.updateSearchQuery('NORTH');
      expect(cubit.filterIncidents(incidents).single.currentIncidentId, 10);

      cubit.updateSearchQuery('11');
      expect(cubit.filterIncidents(incidents).single.currentIncidentId, 11);
    });

    test('severity, status, and search filters compose', () {
      cubit
        ..updateFilter('حرجة')
        ..updateStatusFilter(1)
        ..updateSearchQuery('pipe');

      expect(cubit.filterIncidents(incidents).single.currentIncidentId, 10);
      expect(cubit.filterIncidents(const []), isEmpty);
    });

    test('filter state is retained across repeated reads', () {
      cubit.updateFilter('متوسطة');
      expect(cubit.filterIncidents(incidents).single.currentIncidentId, 11);
      expect(cubit.filterIncidents(incidents).single.currentIncidentId, 11);
      expect(cubit.selectedFilter, 'متوسطة');
    });
  });
}
