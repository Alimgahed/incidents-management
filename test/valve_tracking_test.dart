import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/logic/state/valve_state.dart';

void main() {
  group('Valve Proximity State - Live Technician Tracking Tests', () {
    test('ProximitySafe holds technician location, heading, speed, and accuracy', () {
      const state = ProximitySafe(
        userLat: 28.0871,
        userLng: 30.7501,
        userHeading: 45.0,
        userSpeed: 1.4,
        userAccuracy: 8.5,
        valves: [],
      );

      expect(state.userLat, equals(28.0871));
      expect(state.userLng, equals(30.7501));
      expect(state.userHeading, equals(45.0));
      expect(state.userSpeed, equals(1.4));
      expect(state.userAccuracy, equals(8.5));
      expect(state.valves, isEmpty);
      expect(state.isMuted, isFalse);
    });

    test('ProximitySafe copyWith updates heading, speed, and accuracy', () {
      const state = ProximitySafe(
        userLat: 28.0871,
        userLng: 30.7501,
        userHeading: 45.0,
        userSpeed: 1.4,
        userAccuracy: 8.5,
        valves: [],
      );

      final updated = state.copyWith(
        userHeading: 90.0,
        userSpeed: 2.1,
        userAccuracy: 5.0,
      );

      expect(updated.userHeading, equals(90.0));
      expect(updated.userSpeed, equals(2.1));
      expect(updated.userAccuracy, equals(5.0));
      expect(updated.userLat, equals(28.0871));
    });

    test('ProximityAlert preserves technician heading and accuracy during proximity alerts', () {
      const valve = ValveModel(
        id: 101,
        lat: 28.0872,
        long: 30.7502,
        status: 'يعمل',
      );

      const alert = ProximityAlert(
        userLat: 28.08715,
        userLng: 30.75015,
        userHeading: 180.0,
        userSpeed: 0.8,
        userAccuracy: 4.2,
        nearestValve: valve,
        distanceMeters: 6.5,
        valves: [valve],
        isCritical: false,
      );

      expect(alert.userHeading, equals(180.0));
      expect(alert.userSpeed, equals(0.8));
      expect(alert.userAccuracy, equals(4.2));
      expect(alert.nearestValve.id, equals(101));
      expect(alert.distanceMeters, equals(6.5));
    });

    test('Equatability includes heading, speed, and accuracy', () {
      const state1 = ProximitySafe(
        userLat: 28.0871,
        userLng: 30.7501,
        userHeading: 45.0,
        userSpeed: 1.0,
        userAccuracy: 10.0,
        valves: [],
      );

      const state2 = ProximitySafe(
        userLat: 28.0871,
        userLng: 30.7501,
        userHeading: 45.0,
        userSpeed: 1.0,
        userAccuracy: 10.0,
        valves: [],
      );

      const state3 = ProximitySafe(
        userLat: 28.0871,
        userLng: 30.7501,
        userHeading: 90.0, // Different heading
        userSpeed: 1.0,
        userAccuracy: 10.0,
        valves: [],
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}
