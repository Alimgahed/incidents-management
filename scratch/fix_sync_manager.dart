import 'dart:io';

void main() {
  final path = 'c:/Users/ali/incidents_managment/lib/core/offline/domain/sync_manager.dart';
  final file = File(path);
  
  if (file.existsSync()) {
    String content = file.readAsStringSync();
    
    // add foundation and image_picker imports if missing
    if (!content.contains("import 'package:flutter/foundation.dart';")) {
      content = content.replaceFirst(
        "import 'dart:io';",
        "import 'dart:io';\\nimport 'package:flutter/foundation.dart';\\nimport 'package:image_picker/image_picker.dart';"
      );
    }
    
    content = content.replaceFirst(
      '''
    final file = File(att.localFilePath);
    if (!await file.exists()) {
      await attachments.recordFailure(att.localId, 'File missing on disk');
      return;
    }
''',
      '''
    if (!kIsWeb) {
      final file = File(att.localFilePath);
      if (!await file.exists()) {
        await attachments.recordFailure(att.localId, 'File missing on disk');
        return;
      }
    }
'''
    );
    
    content = content.replaceFirst(
      '''
        'photo': await MultipartFile.fromFile(
          att.localFilePath,
          filename: att.fileName,
        ),
''',
      '''
        'photo': kIsWeb
            ? MultipartFile.fromBytes(await XFile(att.localFilePath).readAsBytes(), filename: att.fileName)
            : await MultipartFile.fromFile(
                att.localFilePath,
                filename: att.fileName,
              ),
'''
    );
    
    file.writeAsStringSync(content);
    print('Fixed SyncManager');
  }
}
