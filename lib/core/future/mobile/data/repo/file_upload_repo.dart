import 'dart:io';
import 'package:dio/dio.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/offline/data/models/cached_attachment.dart';
import 'package:incidents_managment/core/offline/data/repositories/attachment_cache_repository.dart';
import 'package:incidents_managment/core/offline/domain/sync_manager.dart';
import 'package:incidents_managment/core/offline/domain/temp_id_generator.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';

class FileUploadRepository {
  /// ==============================
  /// Upload Single Incident Photo
  /// ==============================
  ///
  /// Offline behaviour:
  ///   * The file is registered with [AttachmentCacheRepository] immediately
  ///     so the UI can render a preview from the local path.
  ///   * If the device is offline, we return a synthetic success result and
  ///     defer the actual upload to [SyncManager].
  ///   * If the device is online but the upload fails on the network layer,
  ///     the [SyncManager] will retry on the next reconnect.
  Future<Map<String, dynamic>> uploadFile({
    required String filePath,
    required String fileName,
    required Function(double) onProgress,
    required int incidentId,
    required String description,
    required double xAxis, // longitude
    required double yAxis, // latitude
  }) async {
    final dio = getIt<Dio>();
    final attachmentRepo = getIt<AttachmentCacheRepository>();
    final monitor = getIt<NetworkMonitorService>();

    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('ملف الصورة غير موجود على الجهاز.');
    }

    // 1. Always register the attachment locally first — the UI shows it
    //    immediately and the SyncManager picks it up later if needed.
    final cached = CachedAttachment(
      localId: TempIdGenerator.nextString(),
      incidentIdOrTempId: incidentId,
      localFilePath: filePath,
      fileName: fileName,
      mimeType: _guessMime(fileName),
      description: description,
      xAxis: xAxis,
      yAxis: yAxis,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await attachmentRepo.add(cached);

    // 2. Offline or referencing a not-yet-synced incident → defer upload.
    if (monitor.isOffline || incidentId < 0) {
      onProgress(1.0); // optimistic completion for UI
      return {
        'success': true,
        'message': 'تم حفظ الصورة محلياً وسيتم رفعها عند الاتصال',
        'data': {
          'local_id': cached.localId,
          '__offline': true,
        },
        'statusCode': 202,
      };
    }

    // 3. Online → upload now, mark cached attachment uploaded on success.
    try {
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
        int serverId = 0;
        if (response.data is Map<String, dynamic>) {
          final v = (response.data as Map<String, dynamic>)['id'] ??
              (response.data as Map<String, dynamic>)['photo_id'];
          if (v is int) serverId = v;
        }
        await attachmentRepo.markUploaded(
          localId: cached.localId,
          serverId: serverId,
        );

        return {
          'success': true,
          'message': 'تم رفع الملف بنجاح',
          'data': response.data,
          'statusCode': response.statusCode,
        };
      } else {
        await attachmentRepo.recordFailure(
            cached.localId, 'HTTP ${response.statusCode}');
        throw Exception('فشل الرفع برمز الحالة: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Network died → leave the cached attachment as "pending" so SyncManager
      // retries it on reconnect.
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        await attachmentRepo.recordFailure(
            cached.localId, e.message ?? 'Transport error');
        return {
          'success': true,
          'message': 'سيتم رفع الصورة تلقائياً عند الاتصال',
          'data': {
            'local_id': cached.localId,
            '__offline': true,
          },
          'statusCode': 202,
        };
      }
      await attachmentRepo.recordFailure(
          cached.localId, e.response?.data?.toString() ?? e.message ?? 'Error');
      final errorMsg = e.response?.data?['error'] ??
          e.response?.data?['message'] ??
          e.message;
      throw Exception('فشل الرفع: $errorMsg');
    } catch (e) {
      await attachmentRepo.recordFailure(cached.localId, e.toString());
      throw Exception('فشل الرفع: $e');
    }
  }

  String _guessMime(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'bmp' => 'image/bmp',
      'pdf' => 'application/pdf',
      _ => 'application/octet-stream',
    };
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
