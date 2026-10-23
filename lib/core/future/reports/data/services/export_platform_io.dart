import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'export_platform_interface.dart';

class _IoExportHelper implements ExportPlatformHelper {
  @override
  Future<String> saveAndDownloadFile({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

ExportPlatformHelper getExportPlatformHelper() => _IoExportHelper();
