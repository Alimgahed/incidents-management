// lib/cubit/proximity_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:incidents_managment/core/future/valve/data/model/valve.dart';
import 'package:incidents_managment/core/future/valve/data/repo/valve_repo.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/alarm_service.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/service.dart';
import 'package:incidents_managment/core/future/valve/logic/state/valve_state.dart';

class ValveProximityCubit extends Cubit<ProximityState> {
  final ValveRepository _valveRepository;
  final ProximityService _proximityService;
  final AlarmService _alarmService;

  StreamSubscription<Position>? _positionSubscription;
  List<ValveModel> _valves = [];

  ValveProximityCubit({
    required ValveRepository valveRepository,
    required ProximityService proximityService,
    required AlarmService alarmService,
  })  : _valveRepository = valveRepository,
        _proximityService = proximityService,
        _alarmService = alarmService,
        super(const ProximityInitial());

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Call once from initState / BlocProvider setup.
  Future<void> initialize() async {
    emit(const ProximityLoading());

    // 1. Check & request location permission
    final permission = await _requestPermission();
    if (permission == null) return; // error already emitted

    // 2. Load valve locations
    try {
      _valves = await _valveRepository.fetchValves();
    } catch (e) {
      emit(ProximityError('فشل تحميل بيانات المحابس: $e'));
      return;
    }

    // 3. Start listening to GPS updates
    _startLocationStream();
  }

  /// Manually stop tracking (e.g. when screen is disposed).
  void stopTracking() {
    _positionSubscription?.cancel();
    _alarmService.stopAlarm();
  }

  /// Dismiss alarm without leaving screen.
  void dismissAlarm() {
    _alarmService.stopAlarm();

    if (state is ProximityAlert) {
      final s = state as ProximityAlert;
      emit(ProximitySafe(
        userLat: s.userLat,
        userLng: s.userLng,
        valves: s.valves,
      ));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<LocationPermission?> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(const ProximityError(
          'خدمة الموقع معطلة. الرجاء تشغيل GPS.'));
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
      emit(const ProximityError(
          'إذن الموقع مرفوض نهائياً. افتح الإعدادات وأعد التصريح.'));
      return null;
    }

    return permission;
  }

  void _startLocationStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // emit only when moved ≥ 5 metres to ignore GPS jitter
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position position) => _onNewPosition(position),
      onError: (e) => emit(ProximityError('خطأ في GPS: $e')),
    );
  }

  void _onNewPosition(Position position) {
    final result = _proximityService.checkProximity(
      userLat: position.latitude,
      userLng: position.longitude,
      valves: _valves,
    );

    if (result != null) {
      // Near a valve → alarm
      _alarmService.startAlarm();
      emit(ProximityAlert(
        userLat: position.latitude,
        userLng: position.longitude,
        nearestValve: result.valve,
        distanceMeters: result.distanceMeters,
        valves: _valves,
      ));
    } else {
      // Safe zone
      _alarmService.stopAlarm();
      emit(ProximitySafe(
        userLat: position.latitude,
        userLng: position.longitude,
        valves: _valves,
      ));
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    _alarmService.dispose();
    return super.close();
  }
}