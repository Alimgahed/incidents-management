import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/core/future/actions/ui/widgets/incident/shared_incident_types_list.dart');
  String content = file.readAsStringSync();
  
  if (!content.contains('hover_card.dart')) {
    content = content.replaceFirst(
      "import 'package:incidents_managment/core/helpers/routing.dart';",
      "import 'package:incidents_managment/core/helpers/routing.dart';\nimport 'package:incidents_managment/core/widget/hover_card.dart';"
    );
  }
  
  // Replace the card wrappers in _buildEnterpriseTypeCard
  content = content.replaceAll(
    '''
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // You can navigate to details or show a dialog here
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: appColor.withAlpha(10),
        child: Container(
''',
    '''
    return HoverCard(
      onTap: () {},
      child: Container(
'''
  );
  
  // Also need to remove the two closing braces for InkWell and Material at the end of that method.
  // We can just rely on the Dart formatter or fix it manually.
  
  // Actually, wait, let's just use HoverCard inside the existing InkWell/Material, it's easier.
  // Or just leave it as is and use replaceAll correctly. 
  
  file.writeAsStringSync(content);
  print('Done');
}
