import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:audioplayers/audioplayers.dart';

import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/network/api_constants.dart';

// ---------------------------------------------------------------------------
// Top-level isolate helpers (must live outside the class for compute())
// ---------------------------------------------------------------------------

/// Parses a raw socket snapshot list into typed models on a background isolate.
/// Using [List.generate] pre-allocates the backing array to the exact capacity
/// needed, avoiding repeated reallocation that a growable list would incur.
List<CurrentIncidentModel> _parseIncidentList(List<dynamic> data) {
  final list = List<CurrentIncidentModel>.generate(
    data.length,
    (i) => CurrentIncidentModel.fromJson(data[i] as Map<String, dynamic>),
    growable: true,
  );
  list.sort((a, b) {
    final aTime = a.currentIncidentCreatedAt;
    final bTime = b.currentIncidentCreatedAt;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  });
  return list;
}

// Provide a lightweight copyWith for CurrentIncidentModel in case the model
// does not define one; this attempts to use toJson/fromJson if present,
// and falls back to a best-effort mutation if necessary.
extension _CurrentIncidentModelCopy on CurrentIncidentModel {
  CurrentIncidentModel copyWith({
    List<dynamic>? currentIncidentWithMissions,
    int? currentIncidentStatus,
    int? currentIncidentSeverity,
  }) {
    try {
      final map = (this as dynamic).toJson() as Map<String, dynamic>;
      
      if (currentIncidentWithMissions != null) {
        map['missions'] = currentIncidentWithMissions
            .map(
              (m) => (m as dynamic).toJson != null ? (m as dynamic).toJson() : m,
            )
            .toList();
      }

      if (currentIncidentStatus != null) {
        map['current_incident_status'] = currentIncidentStatus;
      }
      
      if (currentIncidentSeverity != null) {
        map['current_incident_severity'] = currentIncidentSeverity;
      }

      return CurrentIncidentModel.fromJson(map);
    } catch (_) {
      // fallback
      try {
        if (currentIncidentWithMissions != null) {
          (this as dynamic).currentIncidentWithMissions = currentIncidentWithMissions;
        }
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

  DateTime? _lastIncidentPayloadAt;

  Timer? _reconnectTimer;
  Timer? _alertTimer;

  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAlertPlaying = false;

  // ================= ALERT STATE =================

  // 🔊 SAME SOUND USED IN DASHBOARD CONTROLLER
  static const String alertSoundUrl =
      'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg';
  IncidentMapCubit() : super(IncidentMapInitial());

  void _bumpPayloadTime() {
    _lastIncidentPayloadAt = DateTime.now();
  }

  // ===========================================================================
  // SOCKET INITIALIZATION
  // ===========================================================================
  Future<void> initialize() async {
    try {
      // 1. Get token from storage securely
      final token = await getIt<SecureStorageService>().getUserToken();
      
      // 2. ONLY connect if token exists
      if (token == null || token.trim().isEmpty) {
        return;
      }
      
      // As requested, hardcode the external URL for the websocket in all cases
      final String socketUrl = 'https://crises.miniawater.com';
      final String socketPath = '/api/socket.io';
      
      print('🔌 Socket URL: $socketUrl');
      print('🔌 Socket Path: $socketPath');
      
      // 4. Configure socket with auth and correct path
      // IMPORTANT: Transports configuration is an intentional, permanent decision.
      // Do NOT change mobile back to ['websocket']. The IIS/ARR reverse proxy on our backend
      // has a known frame-corruption bug with native WebSocket clients. It sends a correct 101
      // Switching Protocols but wraps the subsequent WebSocket frames in Transfer-Encoding: chunked,
      // which corrupts them for strict clients like Dart's web_socket_channel. Browsers tolerate this,
      // which is why kIsWeb can use ['polling', 'websocket'].
      _socket = io.io(
        socketUrl,
        io.OptionBuilder()
            .setTransports(kIsWeb ? ['polling', 'websocket'] : ['polling'])
            .setPath(socketPath)
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setReconnectionDelay(3000)
            .disableAutoConnect() // Don't connect until listeners are ready
            .disableMultiplex() // Force new connection, bypasses dead cache
            .setAuth({'token': token}) // Pass token in auth object
            .setExtraHeaders({'Authorization': 'Bearer $token'}) // And in headers just in case
            .build(),
      );

      // DEBUG - add temporarily
      _socket?.onAny((event, data) {
        print('🔌 Socket event: $event | data: $data');
      });

      _socket?.on('connect_error', (data) {
        print('❌ Connect error: $data');
      });

      _socket?.on('error', (data) {
        print('❌ Socket error: $data');
      });

      // 3. Attach listeners BEFORE connecting to avoid race condition
      _setupSocketListeners();

      // 4. Now connect manually
      _socket?.connect();

      Future.delayed(const Duration(seconds: 3), () {
        print('🔌 Socket connected: ${_socket?.connected}');
        print('🔌 Socket id: ${_socket?.id}');
      });
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
  // void _playAlertFor7Seconds() {
  //   if (_isAlertPlaying) return;

  //   try {
  //     _isAlertPlaying = true;

  //     _audio?.pause();
  //     _audio = html.AudioElement()
  //       ..src = alertSoundUrl
  //       ..volume = 1.0
  //       ..autoplay = true;

  //     // ⏱ Stop after 7 seconds
  //     _alertTimer?.cancel();
  //     _alertTimer = Timer(const Duration(seconds: 7), _stopAlert);
  //   } catch (_) {
  //     _stopAlert();
  //   }
  // }

  // void _stopAlert() {
  //   try {
  //     _audio?.pause();
  //     _audio?.currentTime = 0;
  //   } catch (_) {}

  //   _audio = null;
  //   _isAlertPlaying = false;
  // }

  // ===========================================================================
  // INCIDENT HANDLERS
  // ===========================================================================
  /// Parses the full incident snapshot off the main isolate via [compute] to
  /// avoid jank on large payloads. [List.generate] inside the helper
  /// pre-allocates the backing array to the exact capacity needed.
  Future<void> _handleIncidentSnapshot(dynamic data) async {
    try {
      if (data is! List) {
        emit(IncidentMapError(message: 'تنسيق بيانات غير صحيح'));
        return;
      }

      // Defensively copy to a plain List<dynamic> so it can be sent across
      // isolate boundaries safely (socket.io may return a non-growable view).
      incidentss = await compute(_parseIncidentList, List<dynamic>.from(data));

      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    } catch (e) {
      emit(IncidentMapError(message: 'خطأ في تحميل البيانات'));
    }
  }

  void _handleIncidentCreated(dynamic data) {
    final newIncident = CurrentIncidentModel.fromJson(data);

    final updated = List<CurrentIncidentModel>.of(incidentss)..insert(0, newIncident);
    updated.sort((a, b) {
      final aTime = a.currentIncidentCreatedAt;
      final bTime = b.currentIncidentCreatedAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });
    incidentss = updated;
    _bumpPayloadTime();
    emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));

    _playAlertFor5Seconds();
  }

  Future<void> _playAlertFor5Seconds() async {
    if (_isAlertPlaying) return;
    try {
      _isAlertPlaying = true;
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('sounds/alarm.ogg'));
      
      _alertTimer?.cancel();
      _alertTimer = Timer(const Duration(seconds: 5), () async {
        await _audioPlayer.stop();
        _isAlertPlaying = false;
      });
    } catch (e) {
      _isAlertPlaying = false;
      debugPrint('Error playing alert sound: $e');
    }
  }

  void _handleIncidentUpdated(dynamic data) {
    final updatedIncident = CurrentIncidentModel.fromJson(data);

    final index = incidentss.indexWhere(
      (i) => i.currentIncidentId == updatedIncident.currentIncidentId,
    );

    if (index != -1) {
      // List.of pre-allocates to known capacity; direct index assignment
      // avoids a second allocation from cascade notation.
      final updated = List<CurrentIncidentModel>.of(incidentss);
      updated[index] = updatedIncident;
      incidentss = updated;
      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }

  void _handleIncidentDeleted(dynamic data) {
    final id = data is Map ? data['id'] : data;
    // where().toList() can't be pre-sized but growable:false signals to the
    // runtime that the resulting list won't be further mutated.
    incidentss = incidentss
        .where((i) => i.currentIncidentId != id)
        .toList(growable: false);

    _bumpPayloadTime();
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
      if (incidentIndex == -1) {
        // If incident not found, refresh to get latest
        refresh();
        return;
      }

      final incident = incidentss[incidentIndex];

      // تحديث المهمة داخل الـ incident
      // Copy the list so we don't mutate the previous state's list in place.
      final missions = List<CurrentIncidentWithMissions>.from(
        incident.currentIncidentWithMissions ?? const [],
      );

      // Try matching by current_incident_mission_id first (what the server sends),
      // then fall back to the row id (idCurrentIncidentMission) in case the server
      // payload's id refers to that.
      var missionIndex = missions.indexWhere(
        (m) => m.currentIncidentMissionId == missionId,
      );
      if (missionIndex == -1) {
        missionIndex = missions.indexWhere(
          (m) => m.idCurrentIncidentMission == missionId,
        );
      }

      if (missionIndex != -1) {
        final mission = missions[missionIndex];
        // Preserve ALL existing fields and only override status + updated_at.
        // The previous version dropped currentIncidentId and any future fields,
        // which broke the UI binding.
        final updatedMission = CurrentIncidentWithMissions(
          idCurrentIncidentMission: mission.idCurrentIncidentMission,
          currentIncidentId: mission.currentIncidentId,
          currentIncidentMissionId: mission.currentIncidentMissionId,
          currentIncidentMissionOrder: mission.currentIncidentMissionOrder,
          currentIncidentMissionStatus: newStatus,
          currentIncidentMissionStatusUpdatedBy:
              mission.currentIncidentMissionStatusUpdatedBy,
          currentIncidentMissionStatusUpdatedAt: DateTime.now(),
          missionName: mission.missionName,
        );

        missions[missionIndex] = updatedMission;
      } else {
        // Mission not found locally — ask server for a fresh snapshot.
        refresh();
        return;
      }

      // تحديث الـ incident في القائمة
      final updatedIncident = incident.copyWith(
        currentIncidentWithMissions: missions,
      );

      final updated = List<CurrentIncidentModel>.of(incidentss);
      updated[incidentIndex] = updatedIncident;
      incidentss = updated;

      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    } catch (e) {
      emit(IncidentMapError(message: 'فشل تحديث حالة المهمة'));
    }
  }

  // ===========================================================================
  // OPTIMISTIC OFFLINE UPDATE INCIDENT
  // ===========================================================================
  void optimisticUpdateIncident({
    required int incidentId,
    required int newStatus,
    required int newSeverity,
  }) {
    final index = incidentss.indexWhere((i) => i.currentIncidentId == incidentId);
    if (index != -1) {
      final updatedIncident = incidentss[index].copyWith(
        currentIncidentStatus: newStatus,
        currentIncidentSeverity: newSeverity,
      );

      final updated = List<CurrentIncidentModel>.of(incidentss);
      updated[index] = updatedIncident;
      incidentss = updated;
      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }

  // ===========================================================================
  // OPTIMISTIC OFFLINE UPDATE MISSION
  // ===========================================================================
  void optimisticUpdateMission({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) {
    // Calls the same logic the socket uses, so the UI updates immediately
    // even if we are offline and haven't received a socket broadcast.
    _handleMissionStatusUpdated({
      'incident_id': incidentId,
      'mission_id': missionId,
      'new_status': newStatus,
    });
  }

  void _handleMissionUpdateError(dynamic data) {
    final msg = data is Map ? data['message'] ?? 'فشل تحديث المهمة' : 'خطأ';
    emit(IncidentMapError(message: msg));

    if (incidentss.isNotEmpty) {
      _bumpPayloadTime();
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
    if (_socket?.connected ?? false) {
      emit(IncidentMapLoading());
      _socket?.emit('get_incidents');
    }
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================
  List<CurrentIncidentModel> get incidents => List.unmodifiable(incidentss);

  bool get isConnected => _socket?.connected ?? false;

  DateTime? get lastIncidentPayloadAt => _lastIncidentPayloadAt;

  /// Get a specific incident by ID from the current list
  CurrentIncidentModel? getIncidentById(int incidentId) {
    try {
      return incidentss.firstWhere(
        (i) => i.currentIncidentId == incidentId,
      );
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // CLEANUP & LIFECYCLE DISCONNECT
  // ===========================================================================
  void disconnectSocket() {
    _reconnectTimer?.cancel();
    _alertTimer?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  @override
  Future<void> close() {
    disconnectSocket();
    _audioPlayer.dispose();
    return super.close();
  }
}
