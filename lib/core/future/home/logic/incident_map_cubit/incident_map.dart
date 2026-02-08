import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

// Provide a lightweight copyWith for CurrentIncidentModel in case the model
// does not define one; this attempts to use toJson/fromJson if present,
// and falls back to a best-effort mutation if necessary.
extension _CurrentIncidentModelCopy on CurrentIncidentModel {
  CurrentIncidentModel copyWith({List<dynamic>? currentIncidentWithMissions}) {
    try {
      final map = (this as dynamic).toJson() as Map<String, dynamic>;
      // prefer camelCase key as used by the app model field; adjust if your JSON uses another key
      map['currentIncidentWithMissions'] = currentIncidentWithMissions
          ?.map(
            (m) => (m as dynamic).toJson != null ? (m as dynamic).toJson() : m,
          )
          .toList();
      return CurrentIncidentModel.fromJson(map);
    } catch (_) {
      // fallback: try to mutate the instance if fields are non-final, else return original
      try {
        (this as dynamic).currentIncidentWithMissions =
            currentIncidentWithMissions;
        return this;
      } catch (_) {
        return this;
      }
    }
  }
}

class IncidentMapCubit extends Cubit<IncidentMapState> {
  io.Socket? _socket;

  List<CurrentIncidentModel> incidentss = [];

  Timer? _reconnectTimer;
  Timer? _alertTimer;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  // ================= ALERT STATE =================
  bool _isAlertPlaying = false;
  html.AudioElement? _audio;

  // 🔊 SAME SOUND USED IN DASHBOARD CONTROLLER
  static const String alertSoundUrl =
      'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg';

  IncidentMapCubit() : super(IncidentMapInitial()) {
    _initSocket();
  }

  // ===========================================================================
  // SOCKET INITIALIZATION
  // ===========================================================================
  void _initSocket() {
    try {
      _socket = io.io(
        'http://172.16.0.31:5000',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(3000)
            .enableAutoConnect()
            .build(),
      );

      _setupSocketListeners();
    } catch (e) {
      emit(IncidentMapError(message: 'فشل في إنشاء اتصال Socket.IO'));
    }
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _socket?.emit('get_incidents');
    });

    _socket?.onDisconnect((_) => _attemptReconnect());

    _socket?.onConnectError((_) {
      emit(IncidentMapError(message: 'فشل الاتصال بالخادم'));
      _attemptReconnect();
    });

    _socket?.onError((_) {
      emit(IncidentMapError(message: 'خطأ في الاتصال بالخادم'));
    });

    _socket?.on('incident_snapshot', _handleIncidentSnapshot);
    _socket?.on('incident_created', _handleIncidentCreated);
    _socket?.on('incident_updated', _handleIncidentUpdated);
    _socket?.on('incident_deleted', _handleIncidentDeleted);

    _socket?.on('mission_updated', _handleMissionStatusUpdated);
    _socket?.on('mission_update_error', _handleMissionUpdateError);
  }

  // ===========================================================================
  // RECONNECTION LOGIC
  // ===========================================================================
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      emit(IncidentMapError(message: 'فشل الاتصال بالخادم بعد عدة محاولات'));
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      _socket?.connect();
    });
  }

  // ===========================================================================
  // 🔊 ALERT SOUND (WEB – SAME AS DASHBOARD, 7 SECONDS)
  // ===========================================================================
  void _playAlertFor7Seconds() {
    if (_isAlertPlaying) return;

    try {
      _isAlertPlaying = true;

      _audio?.pause();
      _audio = html.AudioElement()
        ..src = alertSoundUrl
        ..volume = 1.0
        ..autoplay = true;

      // ⏱ Stop after 7 seconds
      _alertTimer?.cancel();
      _alertTimer = Timer(const Duration(seconds: 7), _stopAlert);
    } catch (_) {
      _stopAlert();
    }
  }

  void _stopAlert() {
    try {
      _audio?.pause();
      _audio?.currentTime = 0;
    } catch (_) {}

    _audio = null;
    _isAlertPlaying = false;
  }

  // ===========================================================================
  // INCIDENT HANDLERS
  // ===========================================================================
  void _handleIncidentSnapshot(dynamic data) {
    try {
      if (data is! List) {
        emit(IncidentMapError(message: 'تنسيق بيانات غير صحيح'));
        return;
      }

      incidentss = data.map((e) => CurrentIncidentModel.fromJson(e)).toList();

      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    } catch (e) {
      emit(IncidentMapError(message: 'خطأ في تحميل البيانات'));
    }
  }

  void _handleIncidentCreated(dynamic data) {
    final newIncident = CurrentIncidentModel.fromJson(data);

    incidentss = [...incidentss, newIncident];
    emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));

    // 🚨 PLAY SAME ALERT SOUND (7 SECONDS)
    _playAlertFor7Seconds();
  }

  void _handleIncidentUpdated(dynamic data) {
    final updatedIncident = CurrentIncidentModel.fromJson(data);

    final index = incidentss.indexWhere(
      (i) => i.currentIncidentId == updatedIncident.currentIncidentId,
    );

    if (index != -1) {
      incidentss = List.from(incidentss)..[index] = updatedIncident;
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }

  void _handleIncidentDeleted(dynamic data) {
    final id = data is Map ? data['id'] : data;
    incidentss = incidentss.where((i) => i.currentIncidentId != id).toList();

    emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
  }

  // ===========================================================================
  // MISSION STATUS HANDLERS

  void _handleMissionStatusUpdated(dynamic data) {
    try {
      if (data is! Map) return;

      final incidentId = data['current_incident_id'] as int?;
      final missionId = data['current_incident_mission_id'] as int?;
      final newStatus = data['current_incident_mission_status'] as int?;

      if (incidentId == null || missionId == null || newStatus == null) return;

      // إيجاد الـ incident
      final incidentIndex = incidentss.indexWhere(
        (i) => i.currentIncidentId == incidentId,
      );
      if (incidentIndex == -1) return;

      final incident = incidentss[incidentIndex];

      // تحديث المهمة داخل الـ incident
      final missions = incident.currentIncidentWithMissions ?? [];

      final missionIndex = missions.indexWhere(
        (m) => m.currentIncidentMissionId == missionId,
      );

      if (missionIndex != -1) {
        final mission = missions[missionIndex];
        final updatedMission = CurrentIncidentWithMissions(
          missionName: mission.missionName,
          currentIncidentMissionStatusUpdatedBy:
              mission.currentIncidentMissionStatusUpdatedBy,
          currentIncidentMissionId: mission.currentIncidentMissionId,
          currentIncidentMissionOrder: mission.currentIncidentMissionOrder,

          idCurrentIncidentMission: mission.idCurrentIncidentMission,
          currentIncidentMissionStatus: newStatus,
          currentIncidentMissionStatusUpdatedAt: DateTime.now(),
          // Copy other fields from the original mission
        );

        missions[missionIndex] = updatedMission;
      }

      // تحديث الـ incident في القائمة
      final updatedIncident = incident.copyWith(
        currentIncidentWithMissions: missions,
      );

      incidentss[incidentIndex] = updatedIncident;

      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    } catch (e) {
      emit(IncidentMapError(message: 'فشل تحديث حالة المهمة'));
    }
  }

  void _handleMissionUpdateError(dynamic data) {
    final msg = data is Map ? data['message'] ?? 'فشل تحديث المهمة' : 'خطأ';
    emit(IncidentMapError(message: msg));

    if (incidentss.isNotEmpty) {
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }

  // ===========================================================================
  // UPDATE MISSION STATUS
  // ===========================================================================
  void updateMissionStatus({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) {
    if (!(_socket?.connected ?? false)) {
      emit(IncidentMapError(message: 'لا يوجد اتصال بالخادم'));
      return;
    }

    _socket?.emit('update_mission_status', {
      'incident_id': incidentId,
      'mission_id': missionId,
      'new_status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ===========================================================================
  // MANUAL REFRESH
  // ===========================================================================
  void refresh() {
    emit(IncidentMapLoading());
    _socket?.emit('get_incidents');
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================
  List<CurrentIncidentModel> get incidents => List.unmodifiable(incidentss);

  bool get isConnected => _socket?.connected ?? false;

  // ===========================================================================
  // CLEANUP
  // ===========================================================================
  @override
  Future<void> close() {
    _reconnectTimer?.cancel();
    _alertTimer?.cancel();
    _stopAlert();

    _socket?.dispose();
    _socket = null;

    return super.close();
  }
}
