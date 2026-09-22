import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File('lib/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart');
  var content = await file.readAsString();

  content = content.replaceAllMapped(RegExp(r"'([^']*)'|" '"([^"]*)"'), (match) {
    var text = match.group(1) ?? match.group(2) ?? '';
    if (text.contains('ط')) {
      try {
        final bytes = latin1.encode(text);
        final fixed = utf8.decode(bytes);
        return match.group(1) != null ? "'$fixed'" : '"$fixed"';
      } catch (e) {
        return match.group(0)!;
      }
    }
    return match.group(0)!;
  });

  await file.writeAsString(content);
}
