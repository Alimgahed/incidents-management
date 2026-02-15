import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FileUploadRepository {
  // Replace with your actual server IP and port
  static const String baseUrl = 'http://172.16.0.31:5000';
  
  /// Upload incident photo
  /// 
  /// Parameters:
  /// - [incidentId]: The ID of the incident
  /// - [filePath]: Path to the image file
  /// - [fileName]: Name of the file
  /// - [description]: Description of the incident photo
  /// - [userId]: ID of the user uploading the photo
  /// - [onProgress]: Callback for upload progress
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fileName,
    required Function(double) onProgress,
    required int incidentId,
    required String description,
  }) async {
    try {
      // Create the URI with incident ID in path
      var uri = Uri.parse('$baseUrl/upload-incident-photo/$incidentId');
      
      // Create multipart request
      var request = http.MultipartRequest('POST', uri);
      
      // Add text fields (must match backend requirements)
      request.fields['description'] = description;
      
      // Add file with field name "photo" (must match backend)
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo', // Field name must match backend: request.files.get("photo")
          filePath,
        ),
      );
      
      // Optional: Add headers if needed
      // request.headers['Authorization'] = 'Bearer YOUR_TOKEN';
      
      // Send request with progress simulation
      onProgress(0.3); // Starting upload
      
      var streamedResponse = await request.send();
      
      onProgress(0.7); // Upload in progress
      
      // Get response
      var response = await http.Response.fromStream(streamedResponse);
      
      onProgress(1.0); // Complete
      
      if (response.statusCode == 200) {
        // Parse response body
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

  /// Upload multiple incident photos
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required List<String> filePaths,
    required Function(double) onProgress,
    required int incidentId,
    required String description,
    required int userId,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload-incident-photo/$incidentId');
      var request = http.MultipartRequest('POST', uri);
      
      // Add text fields
      request.fields['description'] = description;
      request.fields['user_id'] = userId.toString();
      
      // Add multiple files
      for (int i = 0; i < filePaths.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo', // Same field name for all files
            filePaths[i],
          ),
        );
        // Update progress during file addition
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
  
  /// Validate if file is an image
  bool isValidImageFile(String filePath) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
    final extension = filePath.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }
  
  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }
  
  /// Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}