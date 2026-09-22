import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/widgets/incident/shared_incident_form.dart');
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    content = content.replaceFirst(
      "if (isWeb) const Spacer() else const SizedBox(height: 30),",
      "const SizedBox(height: 30),"
    );
    file.writeAsStringSync(content);
    print('Fixed spacer bug');
  }
}
