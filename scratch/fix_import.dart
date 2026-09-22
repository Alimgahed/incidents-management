import 'dart:io';

void main() {
  final repoPath = 'c:/Users/ali/incidents_managment/lib/core/future/mobile/data/repo/file_upload_repo.dart';
  final repoFile = File(repoPath);
  if (repoFile.existsSync()) {
    String content = repoFile.readAsStringSync();
    content = content.replaceFirst(
      "import 'package:cross_file/cross_file.dart';",
      "import 'package:image_picker/image_picker.dart';"
    );
    repoFile.writeAsStringSync(content);
    print('Updated import');
  }
}
