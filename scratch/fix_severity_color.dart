import 'dart:io';

void main() {
  final files = [
    'c:/Users/ali/incidents_managment/lib/core/future/mission_assigen/ui/widgets/severity_badge.dart',
    'c:/Users/ali/incidents_managment/lib/core/future/mission_assigen/ui/screens/mission_assign_mobile.dart',
    'c:/Users/ali/incidents_managment/lib/core/future/mission_assigen/ui/screens/mission_assign_web.dart',
    'c:/Users/ali/incidents_managment/lib/core/future/home/ui/widgets/map_widget.dart'
  ];
  
  for (final path in files) {
    final file = File(path);
    if (file.existsSync()) {
      String content = file.readAsStringSync();
      // change dark amber to bright amber
      content = content.replaceAll(
        '0xFFD97706',
        '0xFFFFC107'
      );
      file.writeAsStringSync(content);
      print('Updated \$path');
    }
  }
}
