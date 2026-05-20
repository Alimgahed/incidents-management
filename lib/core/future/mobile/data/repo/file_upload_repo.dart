import 'dart:io';
import 'package:dio/dio.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';

class FileUploadRepository {
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
      final dio = getIt<Dio>();

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('ملف الصورة غير موجود على الجهاز.');
      }

      final formData = FormData.fromMap({
        'description': description,
        'x_axis': xAxis.toString(),
        'y_axis': yAxis.toString(),
        'photo': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await dio.post(
        '/upload-incident-photo/$incidentId',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم رفع الملف بنجاح',
          'data': response.data,
          'statusCode': response.statusCode,
        };
      } else {
        throw Exception('فشل الرفع برمز الحالة: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة الاتصال بالخادم. يرجى المحاولة مرة أخرى.');
      }
      final errorMsg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message;
      throw Exception('فشل الرفع: $errorMsg');
    } catch (e) {
      throw Exception('فشل الرفع: $e');
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
      final dio = getIt<Dio>();

      final List<MultipartFile> files = [];
      for (var path in filePaths) {
        final file = File(path);
        if (await file.exists()) {
          final name = path.split('/').last;
          files.add(await MultipartFile.fromFile(path, filename: name));
        }
      }

      if (files.isEmpty) {
        throw Exception('قائمة الملفات المحددة فارغة أو غير صالحة.');
      }

      final formData = FormData.fromMap({
        'description': description,
        'user_id': userId.toString(),
        'x_axis': xAxis.toString(),
        'y_axis': yAxis.toString(),
        'photo': files,
      });

      final response = await dio.post(
        '/upload-incident-photo/$incidentId',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم رفع الملفات بنجاح',
          'data': response.data,
          'statusCode': response.statusCode,
        };
      } else {
        throw Exception('فشل الرفع برمز الحالة: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] ?? e.response?.data?['message'] ?? e.message;
      throw Exception('فشل الرفع المتعدد: $errorMsg');
    } catch (e) {
      throw Exception('فشل الرفع المتعدد: $e');
    }
  }

  /// ==========================
  /// Validate Image File (Backup method - client constraints are applied in Cubit)
  /// ==========================
  bool isValidImageFile(String filePath) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'pdf'];
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
