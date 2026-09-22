import 'dart:io';

void main() {
  final file = File('c:/Users/ali/incidents_managment/lib/core/widget/gloable_widget.dart');
  String content = file.readAsStringSync();
  
  content = content.replaceAll(
    '''
  static void show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
''',
    '''
  static void show(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    if (!context.mounted) return;
    showDialog(
'''
  );
  
  file.writeAsStringSync(content);
  print('Updated dialogs in gloable_widget.dart');
}
