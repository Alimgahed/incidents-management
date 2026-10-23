abstract class ExportPlatformHelper {
  Future<String> saveAndDownloadFile({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  });
}
