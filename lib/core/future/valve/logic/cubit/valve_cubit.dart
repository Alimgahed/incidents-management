// lib/core/future/valve/logic/cubit/valve_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/data/repo/valve_repo.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/alarm_service.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/service.dart';
import 'package:incidents_managment/core/future/valve/logic/state/valve_state.dart';
import 'package:incidents_managment/core/network/api_result.dart';

class ValveProximityCubit extends Cubit<ProximityState> {
  final ValveRepo _valveRepository;
  final ProximityService _proximityService;
  final AlarmService _alarmService;

  StreamSubscription<Position>? _positionSubscription;
  Timer? _boundsDebounce;
  List<ValveModel> _valves = [];
  MapBounds? _currentBounds;
  int _requestId = 0;
  bool _isMuted = false;
  ValveModel? _selectedValve;
  Position? _lastPosition;
  Position? _previousPosition;
  double? _lastReliableHeading;
  bool _isHighAccuracy = true;

  MapBounds? get currentBounds => _currentBounds;
  bool get isMuted => _isMuted;

  ValveProximityCubit({
    required ValveRepo valveRepository,
    required ProximityService proximityService,
    required AlarmService alarmService,
  })  : _valveRepository = valveRepository,
        _proximityService = proximityService,
        _alarmService = alarmService,
        super(const ProximityInitial());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call once from initState / setup.
  Future<void> initialize({MapBounds? initialBounds}) async {
    emit(const ProximityLoading());

    // 1. Check & request location permission
    final permission = await _requestPermission();
    if (permission == null) return; // Error already emitted

    // 2. Determine initial coordinates to build viewport bounds
    double centerLat = 28.0871; // Minya Center default fallback
    double centerLng = 30.7501;

    try {
      // First attempt to get the immediate last known position from the OS
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _lastPosition = lastPos;
        centerLat = lastPos.latitude;
        centerLng = lastPos.longitude;
        if (lastPos.heading > 0) {
          _lastReliableHeading = lastPos.heading;
        }
      }
    } catch (_) {}

    // Use provided initial bounds or build viewport around coordinates
    final bounds = initialBounds ??
        MapBounds(
          latMin: centerLat - 0.03,
          latMax: centerLat + 0.03,
          longMin: centerLng - 0.03,
          longMax: centerLng + 0.03,
        );

    _currentBounds = bounds;

    // 3. Viewport-based initial load
    await _loadValvesForBounds(bounds);

    // 4. Start listening to GPS stream with high precision for live technician tracking
    _startLocationStream(accuracy: LocationAccuracy.high, distanceFilter: 0);

    // 5. In parallel, fetch fresh position to ensure accurate location immediately
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      _onNewPosition(pos);
    } catch (_) {}
  }

  /// Manually stop tracking (e.g. when screen is disposed).
  void stopTracking() {
    _positionSubscription?.cancel();
    _alarmService.stopAlarm();
  }

  /// Resume tracking when app comes back to foreground
  Future<void> resumeTracking() async {
    _startLocationStream(accuracy: LocationAccuracy.high, distanceFilter: 0);
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        _onNewPosition(pos);
      }
    } catch (_) {}
  }

  /// Pause alarm when app goes to background
  void pauseAlarmOnBackground() {
    _alarmService.stopAlarm();
  }

  /// Stops / mutes the alarm sound and marks alert as muted.
  void dismissAlarm() {
    _isMuted = true;
    _alarmService.stopAlarm();

    if (state is ProximityAlert) {
      final s = state as ProximityAlert;
      emit(s.copyWith(isMuted: true));
    } else if (state is ProximitySafe) {
      final s = state as ProximitySafe;
      emit(s.copyWith(isMuted: true));
    }
  }

  /// Turns alarm back on (unmute).
  void resumeAlarm() {
    _isMuted = false;
    if (state is ProximityAlert) {
      _alarmService.startAlarm();
      emit((state as ProximityAlert).copyWith(isMuted: false));
    } else if (_lastPosition != null) {
      _evaluateProximity(_lastPosition!);
    } else if (state is ProximitySafe) {
      emit((state as ProximitySafe).copyWith(isMuted: false));
    }
  }

  /// Toggle audio/alarm mute state.
  void toggleMute() {
    if (_isMuted) {
      resumeAlarm();
    } else {
      dismissAlarm();
    }
  }

  /// Select a valve to inspect in bottom sheet and highlight on map.
  void selectValve(ValveModel? valve) {
    _selectedValve = valve;
    if (state is ProximitySafe) {
      emit((state as ProximitySafe).copyWith(
        selectedValve: valve,
        clearSelectedValve: valve == null,
      ));
    } else if (state is ProximityAlert) {
      emit((state as ProximityAlert).copyWith(
        selectedValve: valve,
        clearSelectedValve: valve == null,
      ));
    }
  }

  /// Viewport Bounds Loading (reused from Web GIS implementation)
  /// Debounces map pan/zoom changes and uses request IDs to cancel race conditions.
  void updateMapBounds(MapBounds bounds) {
    _currentBounds = bounds;
    _boundsDebounce?.cancel();
    _boundsDebounce = Timer(const Duration(milliseconds: 350), () async {
      await _loadValvesForBounds(bounds);
    });
  }

  Future<void> _loadValvesForBounds(MapBounds bounds) async {
    final requestId = ++_requestId;

    try {
      final result = await _valveRepository.allValves(
        bounds: bounds,
        pageSize: 1000,
      );

      if (isClosed || requestId != _requestId) return;

      result.when(
        success: (response) {
          _valves = response.data;
          if (_lastPosition != null) {
            _evaluateProximity(_lastPosition!);
          } else {
            emit(ProximitySafe(
              userLat: (bounds.latMin + bounds.latMax) / 2,
              userLng: (bounds.longMin + bounds.longMax) / 2,
              userHeading: _lastReliableHeading,
              userSpeed: null,
              userAccuracy: null,
              valves: _valves,
              isMuted: _isMuted,
              selectedValve: _selectedValve,
            ));
          }
        },
        error: (error) {
          // In case of error (e.g. offline), retain cached valves in memory
          if (_valves.isEmpty && state is! ProximitySafe && state is! ProximityAlert) {
            emit(ProximityError('فشل تحميل بيانات المحابس للمنطقة: ${error.error}'));
          }
        },
      );
    } catch (e) {
      if (isClosed || requestId != _requestId) return;
      if (_valves.isEmpty && state is! ProximitySafe && state is! ProximityAlert) {
        emit(ProximityError('فشل الاتصال: $e'));
      }
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<LocationPermission?> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const ProximityError('خدمة الموقع معطلة. الرجاء تشغيل GPS.'));
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(const ProximityError('تم رفض إذن الموقع.'));
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        const ProximityError(
          'إذن الموقع مرفوض نهائياً. افتح الإعدادات وأعد التصريح.',
        ),
      );
      return null;
    }

    return permission;
  }

  void _startLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 0,
  }) {
    _positionSubscription?.cancel();

    final settings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          (Position position) => _onNewPosition(position),
          onError: (e) => emit(ProximityError('خطأ في GPS: $e')),
        );
  }

  void _onNewPosition(Position position) {
    if (isClosed) return;
    _updateHeading(position);
    _previousPosition = _lastPosition;
    _lastPosition = position;

    // If current bounds don't cover user position, automatically fetch valves around user
    if (_currentBounds != null &&
        !_boundsContains(_currentBounds!, position.latitude, position.longitude)) {
      final newBounds = MapBounds(
        latMin: position.latitude - 0.03,
        latMax: position.latitude + 0.03,
        longMin: position.longitude - 0.03,
        longMax: position.longitude + 0.03,
      );
      updateMapBounds(newBounds);
    }

    _evaluateProximity(position);
  }

  bool _boundsContains(MapBounds b, double lat, double lng) {
    return lat >= b.latMin && lat <= b.latMax && lng >= b.longMin && lng <= b.longMax;
  }

  void _updateHeading(Position position) {
    // 1. If GPS directly provides reliable heading while moving
    if (position.speed > 0.4 && position.heading > 0.0) {
      _applyHeadingWithFilter(position.heading);
      return;
    }

    // 2. If moving but GPS heading is missing or 0.0, compute bearing from previous position
    if (_previousPosition != null) {
      final double distanceMoved = Geolocator.distanceBetween(
        _previousPosition!.latitude,
        _previousPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Only calculate bearing if moved significantly (>= 1.2m) to avoid GPS drift noise
      if (distanceMoved >= 1.2) {
        double bearing = Geolocator.bearingBetween(
          _previousPosition!.latitude,
          _previousPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (bearing < 0) {
          bearing += 360.0;
        }
        _applyHeadingWithFilter(bearing);
      }
      // If stationary or moving < 1.0m, preserve _lastReliableHeading without jitter
    }
  }

  void _applyHeadingWithFilter(double rawHeading) {
    if (_lastReliableHeading == null) {
      _lastReliableHeading = rawHeading;
      return;
    }

    double diff = (rawHeading - _lastReliableHeading!) % 360;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    // Filter small noise (< 2.5 degrees), smoothly blend larger heading turns
    if (diff.abs() > 2.5) {
      _lastReliableHeading = (_lastReliableHeading! + diff * 0.45) % 360;
      if (_lastReliableHeading! < 0) {
        _lastReliableHeading = _lastReliableHeading! + 360;
      }
    }
  }

  void _evaluateProximity(Position position) {
    if (isClosed) return;

    final result = _proximityService.checkProximity(
      userLat: position.latitude,
      userLng: position.longitude,
      valves: _valves,
    );

    if (result == null) {
      emit(ProximitySafe(
        userLat: position.latitude,
        userLng: position.longitude,
        userHeading: _lastReliableHeading,
        userSpeed: position.speed,
        userAccuracy: position.accuracy,
        valves: _valves,
        isMuted: _isMuted,
        selectedValve: _selectedValve,
      ));
      return;
    }

    final bool isNear = _proximityService.isWithinAlarmRadius(result.distanceMeters);
    final bool isCritical = result.isCritical; // Half-meter proximity alert!

    if (isNear) {
      // Near valve: start alarm if not muted
      if (!_isMuted) {
        _alarmService.startAlarm();
      }

      emit(
        ProximityAlert(
          userLat: position.latitude,
          userLng: position.longitude,
          userHeading: _lastReliableHeading,
          userSpeed: position.speed,
          userAccuracy: position.accuracy,
          nearestValve: result.valve,
          distanceMeters: result.distanceMeters,
          valves: _valves,
          isMuted: _isMuted,
          isCritical: isCritical,
          selectedValve: _selectedValve,
        ),
      );

      // Upgrade to high precision GPS near valves
      _upgradeAccuracyIfNecessary();
    } else {
      // Safe zone: stop alarm and reset mute flag for next encounter
      _alarmService.stopAlarm();
      _isMuted = false;

      emit(
        ProximitySafe(
          userLat: position.latitude,
          userLng: position.longitude,
          userHeading: _lastReliableHeading,
          userSpeed: position.speed,
          userAccuracy: position.accuracy,
          valves: _valves,
          isMuted: false,
          selectedValve: _selectedValve,
        ),
      );

      // Downgrade GPS filter slightly if far away to conserve battery while maintaining live marker
      if (result.distanceMeters > 300) {
        _downgradeAccuracyIfNecessary();
      }
    }
  }

  void _upgradeAccuracyIfNecessary() {
    if (!_isHighAccuracy) {
      _isHighAccuracy = true;
      _startLocationStream(accuracy: LocationAccuracy.high, distanceFilter: 0);
    }
  }

  void _downgradeAccuracyIfNecessary() {
    if (_isHighAccuracy) {
      _isHighAccuracy = false;
      _startLocationStream(accuracy: LocationAccuracy.high, distanceFilter: 1);
    }
  }

  @override
  Future<void> close() {
    _boundsDebounce?.cancel();
    _positionSubscription?.cancel();
    _alarmService.dispose();
    return super.close();
  }
}
