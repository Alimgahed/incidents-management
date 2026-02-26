import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FileUploadRepository {
  // Replace with your actual server IP and port
  static const String baseUrl = 'http://172.16.0.31:5000';

  /// ==============================
  /// Upload Single Incident Photo
  /// ==============================
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fileName,
    required Function(double) onProgress,
    required int incidentId,
    required String description,
    required double xAxis, // longitude
    required double yAxis, // latitude
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload-incident-photo/$incidentId');

      var request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['description'] = description;
      request.fields['x_axis'] = xAxis.toString();
      request.fields['y_axis'] = yAxis.toString();

      // File
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      onProgress(0.3);

      var streamedResponse = await request.send();
      onProgress(0.7);

      var response = await http.Response.fromStream(streamedResponse);
      onProgress(1.0);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Upload success',
          'data': responseData,
          'statusCode': response.statusCode,
        };
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on http.ClientException {
      throw Exception('Connection error. Please try again.');
    } on FormatException {
      throw Exception('Invalid response from server.');
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// ==================================
  /// Upload Multiple Incident Photos
  /// ==================================
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<String> filePaths,
    required Function(double) onProgress,
    required int incidentId,
    required String description,
    required int userId,
    required double xAxis,
    required double yAxis,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload-incident-photo/$incidentId');
      var request = http.MultipartRequest('POST', uri);

      // Text fields
      request.fields['description'] = description;
      request.fields['user_id'] = userId.toString();
      request.fields['x_axis'] = xAxis.toString();
      request.fields['y_axis'] = yAxis.toString();

      // Add multiple files
      for (int i = 0; i < filePaths.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', filePaths[i]),
        );

        onProgress((i + 1) / (filePaths.length * 2));
      }

      var streamedResponse = await request.send();
      onProgress(0.75);

      var response = await http.Response.fromStream(streamedResponse);
      onProgress(1.0);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': 'Multiple files uploaded successfully',
          'data': responseData,
          'statusCode': response.statusCode,
        };
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection.');
    } catch (e) {
      throw Exception('Multiple upload failed: $e');
    }
  }

  /// ==========================
  /// Validate Image File
  /// ==========================
  bool isValidImageFile(String filePath) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = filePath.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  /// ==========================
  /// Get File Size (Bytes)
  /// ==========================
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// ==========================
  /// Format File Size
  /// ==========================
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
