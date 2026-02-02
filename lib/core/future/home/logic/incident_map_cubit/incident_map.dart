import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

class IncidentMapCubit extends Cubit<IncidentMapState> {
  io.Socket? _socket;
  List<CurrentIncidentModel> _incidents = [];
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  IncidentMapCubit() : super(IncidentMapInitial()) {
    _initSocket();
  }

  // ============================================================================
  // SOCKET.IO INITIALIZATION WITH RECONNECTION LOGIC
  // ============================================================================
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

      // Request initial data on connect
      _socket?.emit('get_incidents');
    });

    _socket?.onDisconnect((_) {
      _attemptReconnect();
    });

    _socket?.onConnectError((error) {
      emit(IncidentMapError(message: 'خطأ في الاتصال: فشل الاتصال بالخادم'));
      _attemptReconnect();
    });

    _socket?.onError((error) {
      emit(IncidentMapError(message: 'خطأ في الاتصال بالخادم'));
    });

    // Listen to incident events
    _socket?.on('incident_snapshot', _handleIncidentSnapshot);
    _socket?.on('incident_created', _handleIncidentCreated);
    _socket?.on('incident_updated', _handleIncidentUpdated);
    _socket?.on('incident_deleted', _handleIncidentDeleted);

    // NEW: Listen to mission update responses
    _socket?.on('mission_status_updated', _handleMissionStatusUpdated);
    _socket?.on('mission_update_error', _handleMissionUpdateError);
  }

  // ============================================================================
  // RECONNECTION LOGIC
  // ============================================================================
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      emit(
        IncidentMapError(
          message: 'فشل الاتصال بالخادم بعد عدة محاولات. يرجى المحاولة لاحقاً',
        ),
      );
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectAttempts++;
      _socket?.connect();
    });
  }

  // ============================================================================
  // HANDLE INCIDENT EVENTS
  // ============================================================================
  void _handleIncidentSnapshot(dynamic data) {
    try {
      if (data is! List) {
        emit(IncidentMapError(message: 'تنسيق بيانات غير صحيح'));
        return;
      }
      print(data);
      _incidents = data
          .map((item) {
            try {
              return CurrentIncidentModel.fromJson(item);
            } catch (e) {
              return null;
            }
          })
          .whereType<CurrentIncidentModel>()
          .toList();

      emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
    } catch (e) {
      emit(IncidentMapError(message: 'خطأ في تحميل البيانات'));
    }
  }

  void _handleIncidentCreated(dynamic data) {
    try {
      final newIncident = CurrentIncidentModel.fromJson(data);
      final updatedIncidents = [..._incidents, newIncident];
      _incidents = updatedIncidents;
      emit(IncidentMapLoaded(incidents: List.unmodifiable(updatedIncidents)));
    } catch (e) {
      print('Error parsing created incident: $e');
    }
  }

  void _handleIncidentUpdated(dynamic data) {
    try {
      final updatedIncident = CurrentIncidentModel.fromJson(data);

      final index = _incidents.indexWhere(
        (i) => i.currentIncidentId == updatedIncident.currentIncidentId,
      );

      if (index != -1) {
        _incidents = List.from(_incidents)..[index] = updatedIncident;
        emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
      } else {
        _handleIncidentCreated(data);
      }
    } catch (e) {
      // Silently fail for individual incident parsing errors
    }
  }

  void _handleIncidentDeleted(dynamic data) {
    try {
      final incidentId = data is Map ? data['id'] : data;

      _incidents = _incidents
          .where((i) => i.currentIncidentId != incidentId)
          .toList();

      emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
    } catch (e) {
      // Silently fail
    }
  }

  // ============================================================================
  // NEW: HANDLE MISSION STATUS UPDATE EVENTS
  // ============================================================================
  void _handleMissionStatusUpdated(dynamic data) {
    try {
      // Expected data format:
      // {
      //   "incident_id": int,
      //   "mission_id": int,
      //   "new_status": int,
      //   "updated_at": string (ISO date)
      // }

      if (data is! Map) return;

      final incidentId = data['incident_id'] as int?;
      final missionId = data['mission_id'] as int?;
      final newStatus = data['new_status'] as int?;
      final updatedAt = data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : DateTime.now();

      if (incidentId == null || missionId == null || newStatus == null) return;

      // Find and update the incident in local state
      final incidentIndex = _incidents.indexWhere(
        (i) => i.currentIncidentId == incidentId,
      );

      if (incidentIndex != -1) {
        final incident = _incidents[incidentIndex];
        final missions = incident.currentIncidentWithMissions ?? [];

        final missionIndex = missions.indexWhere(
          (m) => m.idCurrentIncidentMission == missionId,
        );

        if (missionIndex != -1) {
          // Update the mission status
          final updatedMission = CurrentIncidentWithMissions(
            idCurrentIncidentMission:
                missions[missionIndex].idCurrentIncidentMission,
            currentIncidentId: missions[missionIndex].currentIncidentId,
            currentIncidentMissionId:
                missions[missionIndex].currentIncidentMissionId,
            currentIncidentMissionOrder:
                missions[missionIndex].currentIncidentMissionOrder,
            currentIncidentMissionStatus: newStatus,
            currentIncidentMissionStatusUpdatedBy:
                missions[missionIndex].currentIncidentMissionStatusUpdatedBy,
            currentIncidentMissionStatusUpdatedAt: updatedAt,
          );

          final updatedMissions = List<CurrentIncidentWithMissions>.from(
            missions,
          )..[missionIndex] = updatedMission;

          // Create updated incident with new missions list
          final updatedIncident = CurrentIncidentModel(
            currentIncidentId: incident.currentIncidentId,
            currentIncidentDescription: incident.currentIncidentDescription,
            currentIncidentTypeId: incident.currentIncidentTypeId,
            currentIncidentCreatedBy: incident.currentIncidentCreatedBy,
            currentIncidentCreatedAt: incident.currentIncidentCreatedAt,
            currentIncidentSeverity: incident.currentIncidentSeverity,
            currentIncidentSeverityUpdateBy:
                incident.currentIncidentSeverityUpdateBy,
            currentIncidentSeverityUpdateAt:
                incident.currentIncidentSeverityUpdateAt,
            currentIncidentStatus: incident.currentIncidentStatus,
            currentIncidentStatusUpdatedBy:
                incident.currentIncidentStatusUpdatedBy,
            currentIncidentStatusUpdatedAt:
                incident.currentIncidentStatusUpdatedAt,
            currentIncidentXAxis: incident.currentIncidentXAxis,
            currentIncidentYAxis: incident.currentIncidentYAxis,
            currentIncidentNotes: incident.currentIncidentNotes,
          )..currentIncidentWithMissions = updatedMissions;

          _incidents = List.from(_incidents)..[incidentIndex] = updatedIncident;
          emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
        }
      }
    } catch (e) {
      print('Error handling mission status update: $e');
    }
  }

  void _handleMissionUpdateError(dynamic data) {
    try {
      final errorMessage = data is Map
          ? (data['message'] as String? ?? 'فشل في تحديث حالة المهمة')
          : 'فشل في تحديث حالة المهمة';

      emit(IncidentMapError(message: errorMessage));

      // Re-emit the loaded state to keep UI functional
      if (_incidents.isNotEmpty) {
        emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
      }
    } catch (e) {
      print('Error handling mission update error: $e');
    }
  }

  // ============================================================================
  // NEW: UPDATE MISSION STATUS
  // ============================================================================
  /// Updates the status of a mission and sends the update to the backend
  ///
  /// Parameters:
  /// - [incidentId]: The ID of the incident containing the mission
  /// - [missionId]: The ID of the mission to update
  /// - [newStatus]: The new status value (1 = pending, 2 = completed)
  void updateMissionStatus({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) {
    if (_socket == null || !(_socket?.connected ?? false)) {
      emit(IncidentMapError(message: 'لا يوجد اتصال بالخادم'));
      return;
    }

    try {
      // Emit the update event to the backend
      _socket?.emit('update_mission_status', {
        'incident_id': incidentId,
        'mission_id': missionId,
        'new_status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      });

      print(
        'Mission status update sent: Incident=$incidentId, Mission=$missionId, Status=$newStatus',
      );
    } catch (e) {
      emit(IncidentMapError(message: 'فشل في إرسال تحديث حالة المهمة'));
      print('Error updating mission status: $e');
    }
  }

  // ============================================================================
  // MANUAL INCIDENT CONTROL (For Testing/Offline Mode)
  // ============================================================================
  void addIncident(CurrentIncidentModel incident) {
    if (!_incidents.any(
      (i) => i.currentIncidentId == incident.currentIncidentId,
    )) {
      _incidents = [..._incidents, incident];
      emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
    }
  }

  void updateIncident(CurrentIncidentModel incident) {
    final index = _incidents.indexWhere(
      (i) => i.currentIncidentId == incident.currentIncidentId,
    );

    if (index != -1) {
      _incidents = List.from(_incidents)..[index] = incident;
      emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
    }
  }

  void removeIncident(dynamic incidentId) {
    _incidents = _incidents
        .where((i) => i.currentIncidentId != incidentId)
        .toList();
    emit(IncidentMapLoaded(incidents: List.unmodifiable(_incidents)));
  }

  // ============================================================================
  // MANUAL REFRESH
  // ============================================================================
  void refresh() {
    emit(IncidentMapLoading());
    _socket?.emit('get_incidents');
  }

  // ============================================================================
  // GETTERS
  // ============================================================================
  List<CurrentIncidentModel> get incidents => List.unmodifiable(_incidents);
  bool get isConnected => _socket?.connected ?? false;

  // ============================================================================
  // CLEANUP
  // ============================================================================
  @override
  Future<void> close() {
    _reconnectTimer?.cancel();
    _socket?.off('incident_snapshot');
    _socket?.off('incident_created');
    _socket?.off('incident_updated');
    _socket?.off('incident_deleted');
    _socket?.off('mission_status_updated');
    _socket?.off('mission_update_error');
    _socket?.dispose();
    _socket = null;
    return super.close();
  }
}
