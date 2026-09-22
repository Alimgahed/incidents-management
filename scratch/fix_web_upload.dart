import 'dart:io';

void main() {
  final cubitPath = 'c:/Users/ali/incidents_managment/lib/core/future/mobile/logic/file_upload_cubit.dart';
  final repoPath = 'c:/Users/ali/incidents_managment/lib/core/future/mobile/data/repo/file_upload_repo.dart';

  // FIX CUBIT
  final cubitFile = File(cubitPath);
  String cubitContent = cubitFile.readAsStringSync();

  // pickFile fix
  cubitContent = cubitContent.replaceFirst(
    '''
      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();
        final fileExtension = fileName.split('.').last;
''',
    '''
      if (result != null) {
        final platformFile = result.files.single;
        final fileName = platformFile.name;
        final fileSize = platformFile.size;
        final fileExtension = fileName.split('.').last;
        final filePath = platformFile.path ?? '';
'''
  );

  // replace file.path with filePath
  cubitContent = cubitContent.replaceFirst(
    '''
          FileUploadState.fileSelected(
            fileName: fileName,
            filePath: file.path,
            fileSize: fileSize,
            fileExtension: fileExtension,
          ),
''',
    '''
          FileUploadState.fileSelected(
            fileName: fileName,
            filePath: filePath,
            fileSize: fileSize,
            fileExtension: fileExtension,
          ),
'''
  );

  // pickImage fix
  cubitContent = cubitContent.replaceFirst(
    '''
      if (image != null) {
        final file = File(image.path);
        final fileName = image.name;
        final fileSize = await file.length();
        final fileExtension = fileName.split('.').last;
''',
    '''
      if (image != null) {
        final fileName = image.name;
        final fileSize = await image.length();
        final fileExtension = fileName.split('.').last;
'''
  );

  cubitFile.writeAsStringSync(cubitContent);
  print('Fixed FileUploadCubit');

  // FIX REPO
  final repoFile = File(repoPath);
  String repoContent = repoFile.readAsStringSync();

  // Add imports
  if (!repoContent.contains("import 'package:flutter/foundation.dart';")) {
    repoContent = repoContent.replaceFirst(
      "import 'dart:io';",
      "import 'dart:io';\nimport 'package:flutter/foundation.dart';\nimport 'package:cross_file/cross_file.dart';"
    );
  }

  repoContent = repoContent.replaceFirst(
    '''
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('ملف الصورة غير موجود على الجهاز.');
    }
''',
    '''
    if (!kIsWeb) {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('ملف الصورة غير موجود على الجهاز.');
      }
    }
'''
  );

  repoContent = repoContent.replaceFirst(
    '''
        'photo': await MultipartFile.fromFile(filePath, filename: fileName),
''',
    '''
        'photo': kIsWeb ? MultipartFile.fromBytes(await XFile(filePath).readAsBytes(), filename: fileName) : await MultipartFile.fromFile(filePath, filename: fileName),
'''
  );

  repoFile.writeAsStringSync(repoContent);
  print('Fixed FileUploadRepository');
}
