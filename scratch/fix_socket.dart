import 'dart:io';

void main() {
  final path = 'c:/Users/ali/incidents_managment/lib/core/future/home/logic/incident_map_cubit/incident_map.dart';
  final file = File(path);
  
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    
    // Add early return in initialize
    final target = 'Future<void> initialize() async {\\n    try {';
    final replacement = '''Future<void> initialize() async {
    try {
      if (_socket != null) {
        if (!_socket!.connected) {
          _socket!.connect();
        }
        return;
      }''';
      
    content = content.replaceFirst(target, replacement);
    
    file.writeAsStringSync(content);
    print('Fixed IncidentMapCubit initialize');
  } else {
    print('File not found');
  }
}
