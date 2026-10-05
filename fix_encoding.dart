import 'dart:io';
import 'dart:convert';

void main() {
  final files = [
    'lib/core/future/actions/ui/screens/missions/relation_incident_mission.dart',
    'lib/core/future/home/ui/screens/home.dart',
    'lib/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart'
  ];
  
  for (final file in files) {
    final f = File(file);
    if (!f.existsSync()) continue;
    
    final content = f.readAsStringSync(encoding: utf8);
    if (content.contains('ط') || content.contains('ظ')) {
      try {
        final bytes = latin1.encode(content);
        final fixed = utf8.decode(bytes);
        f.writeAsStringSync(fixed, encoding: utf8);
        print('Fixed file: $file');
      } catch (e) {
        print('Could not fix file: $file Error: $e');
      }
    }
  }
}
