import 'package:flutter/material.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/routing/app_router.dart';
import 'package:incidents_managment/incidents.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();

  // Connect to your Flask-SocketIO server
  IO.Socket socket = IO.io('http://172.16.0.31:5000', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  socket.connect();

  // Connection established
  socket.on('connect', (_) {
    print('Connected to server');

    // Optional: join a specific incident
    // socket.emit('join_incident', {'incident_id': 12});
  });

  // Listen for incidents
  socket.on('incident_update', (data) {
    print('Received active incidents: $data');
    // data is already a list of maps (dict) from Python
  });

  runApp(Incidents(appRouter: AppRouter()));
}
