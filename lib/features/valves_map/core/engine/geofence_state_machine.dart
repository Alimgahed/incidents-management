enum GeofenceState {
  outside,
  entering,
  inside,
  exiting,
}

/// A highly optimized state machine to determine proximity alerts.
/// This prevents spamming alerts when the user is standing near the edge of a boundary.
class GeofenceStateMachine {
  final double enterThresholdMeters;
  final double insideThresholdMeters;
  final double exitThresholdMeters;

  GeofenceState _currentState = GeofenceState.outside;

  GeofenceStateMachine({
    this.enterThresholdMeters = 100.0,
    this.insideThresholdMeters = 50.0,
    this.exitThresholdMeters = 120.0, // Hysteresis to prevent bouncing
  });

  GeofenceState get currentState => _currentState;

  /// Updates the state machine based on the new distance.
  /// Returns the new state. If the state didn't change, returns the current state.
  GeofenceState updateDistance(double distanceInMeters) {
    switch (_currentState) {
      case GeofenceState.outside:
      case GeofenceState.exiting:
        if (distanceInMeters <= insideThresholdMeters) {
          _currentState = GeofenceState.inside;
        } else if (distanceInMeters <= enterThresholdMeters) {
          _currentState = GeofenceState.entering;
        } else {
          _currentState = GeofenceState.outside;
        }
        break;

      case GeofenceState.entering:
        if (distanceInMeters <= insideThresholdMeters) {
          _currentState = GeofenceState.inside;
        } else if (distanceInMeters > exitThresholdMeters) {
          _currentState = GeofenceState.exiting;
        }
        break;

      case GeofenceState.inside:
        if (distanceInMeters > insideThresholdMeters && distanceInMeters <= exitThresholdMeters) {
          // Still in the zone, but moved away from the core
          _currentState = GeofenceState.entering;
        } else if (distanceInMeters > exitThresholdMeters) {
          _currentState = GeofenceState.exiting;
        }
        break;
    }

    return _currentState;
  }

  void reset() {
    _currentState = GeofenceState.outside;
  }
}
