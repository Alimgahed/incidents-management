import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/service.dart';

void main() {
  final service = ProximityService();

  test('returns no result when the valve list is empty', () {
    expect(
      service.checkProximity(userLat: 30, userLng: 31, valves: const []),
      isNull,
    );
  });

  test('selects the nearest valve and computes a finite distance', () {
    const near = ValveModel(id: 1, lat: 30.001, long: 31);
    const far = ValveModel(id: 2, lat: 30.03, long: 31);

    final result = service.checkProximity(
      userLat: 30,
      userLng: 31,
      valves: const [far, near],
    );

    expect(result?.valve.id, 1);
    expect(result?.distanceMeters, greaterThan(0));
    expect(result?.distanceMeters.isFinite, isTrue);
  });
}
