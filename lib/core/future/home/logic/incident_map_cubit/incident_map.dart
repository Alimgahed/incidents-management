import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

class IncidentMapCubit extends Cubit<IncidentMapState> {
  late io.Socket socket;
  List<CurrentIncidentModel> incidents = [];

  IncidentMapCubit() : super(IncidentMapInitial()) {
    _initSocket();
  }

  // ============================================================================
  // SOCKET.IO INITIALIZATION
  // ============================================================================
  void _initSocket() {
    socket = io.io(
      'http://172.16.0.31:5000',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((data) {
      print("Connected to Socket.IO server");
      // Connected to Socket.IO server
    });

    socket.onDisconnect((_) {
      // Disconnected from server
    });

    socket.onError((error) {
      emit(IncidentMapError(message: 'خطأ في الاتصال بالخادم'));
    });

    // =========================================================================
    // LISTEN FOR INCIDENT UPDATES
    // =========================================================================
    socket.on('incident_update', (data) {
      _handleIncidentUpdate(data);
    });
  }

  // ============================================================================
  // HANDLE INCIDENT DATA
  // ============================================================================
  void _handleIncidentUpdate(dynamic data) {
    try {
      emit(IncidentMapLoading());

      if (data is List) {
        incidents = List<CurrentIncidentModel>.from(
          data.map((item) => CurrentIncidentModel.fromJson(item)),
        );
      } else {
        incidents = [CurrentIncidentModel.fromJson(data)];
      }

      emit(IncidentMapLoaded(incidents: List.from(incidents)));
    } catch (e) {
      emit(IncidentMapError(message: 'خطأ في تحليل بيانات الحادث'));
    }
  }

  // ============================================================================
  // MAP MODEL → UI MAP
  // ============================================================================

  // ============================================================================
  // MANUAL INCIDENT CONTROL (Optional)
  // ============================================================================
  void addIncident(CurrentIncidentModel incident) {
    incidents.add(incident);
    emit(IncidentMapLoaded(incidents: List.from(incidents)));
  }

  void removeIncident(dynamic incidentId) {
    incidents.removeWhere((i) => i.currentIncidentId == incidentId);
    emit(IncidentMapLoaded(incidents: List.from(incidents)));
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================
  @override
  Future<void> close() {
    socket.dispose();
    return super.close();
  }
}
