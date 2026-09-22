import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/core/future/home/ui/widgets/map_widget.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    content = content.replaceAll(
      "Colors.yellow[700]!",
      "const Color(0xFF3B82F6)"
    );
    file.writeAsStringSync(content);
    print('Updated map_widget.dart');
  }
}
