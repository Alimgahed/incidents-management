import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/offline/data/models/cached_attachment.dart';
import 'package:incidents_managment/core/offline/data/repositories/attachment_cache_repository.dart';
import 'package:incidents_managment/core/offline/domain/sync_manager.dart';
import 'package:incidents_managment/core/offline/domain/temp_id_generator.dart';

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
    bool updateLocation = false,
  }) async {
    final dio = getIt<Dio>();
    final attachmentRepo = getIt<AttachmentCacheRepository>();

    // 1. Copy file to durable storage so it survives OS cache purges.
    //    On web this is skipped — picker paths are session-scoped.
    String durablePath = filePath;
    if (!kIsWeb) {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('ملف الصورة غير موجود على الجهاز.');
      }
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final attachDir = Directory('${appDir.path}/offline_attachments');
        if (!await attachDir.exists()) {
          await attachDir.create(recursive: true);
        }
        final ext = fileName.contains('.')
            ? '.${fileName.split('.').last}'
            : '';
        final durableFile = File('${attachDir.path}/${const Uuid().v4()}$ext');
        await file.copy(durableFile.path);
        durablePath = durableFile.path;
      } catch (e) {
        // If copy fails, fall back to original path — still better than
        // blocking the user. SyncManager will detect a missing file later.
        if (kDebugMode) debugPrint('⚠️ Durable copy failed: $e');
      }
    } else {
      // On web: convert picked file bytes to a persistent Data URI so it survives
      // page reloads and can be safely replayed offline from IndexedDB/Hive.
      try {
        if (!filePath.startsWith('data:')) {
          final bytes = await XFile(filePath).readAsBytes();
          final mime = _guessMime(fileName);
          durablePath = UriData.fromBytes(bytes, mimeType: mime).toString();
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('⚠️ Web durable data uri conversion failed: $e');
        }
      }
    }

    // 2. Register the attachment locally — the UI shows it immediately
    //    and the SyncManager picks it up later if needed.
    final cached = CachedAttachment(
      localId: TempIdGenerator.nextString(),
      incidentIdOrTempId: incidentId,
      localFilePath: durablePath,
      fileName: fileName,
      mimeType: _guessMime(fileName),
      description: description,
      xAxis: xAxis,
      yAxis: yAxis,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      updateLocation: updateLocation,
    );
    // 2. For negative temp incident ids, defer until incident is synced.
    if (incidentId < 0) {
      await attachmentRepo.add(cached);
      onProgress(1.0); // optimistic completion for UI
      return {
        'success': true,
        'message': 'تم حفظ الصورة محلياً وسيتم رفعها عند مزامنة البلاغ',
        'data': {'local_id': cached.localId, '__offline': true},
        'statusCode': 202,
      };
    }

    // 3. Attempt live upload with generous timeout (20s) for mobile networks.
    try {
      final formMap = <String, dynamic>{
        'description': description,
        'x_axis': xAxis.toString(),
        'y_axis': yAxis.toString(),
        if (updateLocation) 'update_location': 'true',
        'photo': kIsWeb
            ? (durablePath.startsWith('data:')
                ? MultipartFile.fromBytes(
                    UriData.parse(durablePath).contentAsBytes(),
                    filename: fileName,
                  )
                : MultipartFile.fromBytes(
                    await XFile(filePath).readAsBytes(),
                    filename: fileName,
                  ))
            : await MultipartFile.fromFile(durablePath, filename: fileName),
      };
      final formData = FormData.fromMap(formMap);

      final response = await dio.post(
        '/upload-incident-photo/$incidentId',
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            onProgress(sent / total);
          }
        },
        options: Options(
          connectTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          extra: {'noOfflineQueue': true},
        ),
      );

      if (response.statusCode == 200) {
        int serverId = 0;
        if (response.data is Map<String, dynamic>) {
          final v =
              (response.data as Map<String, dynamic>)['id'] ??
              (response.data as Map<String, dynamic>)['photo_id'];
          if (v is int) serverId = v;
        }
        cached.isUploaded = true;
        cached.serverId = serverId;
        cached.uploadedAtMs = DateTime.now().millisecondsSinceEpoch;
        await attachmentRepo.add(cached);

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
      // Check for network/timeout/transport failure
      final isNetworkOrTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError ||
          (e.error != null &&
              e.error.toString().toLowerCase().contains('socket')) ||
          (e.error != null &&
              e.error.toString().toLowerCase().contains('stream')) ||
          (e.message != null &&
              e.message!.toLowerCase().contains('socket'));

      if (isNetworkOrTimeout) {
        cached.retryCount = 1;
        cached.lastError =
            e.message ?? e.error?.toString() ?? 'Network/Timeout error';
        await attachmentRepo.add(cached);
        return {
          'success': true,
          'message': 'سيتم رفع الصورة تلقائياً عند استقرار الاتصال',
          'data': {'local_id': cached.localId, '__offline': true},
          'statusCode': 202,
        };
      }

      // Extract a meaningful error message from server response without returning null
      String errorMsg = 'حدث خطأ أثناء رفع الصورة، يرجى المحاولة لاحقاً';
      final responseData = e.response?.data;
      if (responseData is Map) {
        final err = responseData['error'] ??
            responseData['message'] ??
            responseData['msg'] ??
            responseData['detail'];
        if (err != null &&
            err.toString().trim().isNotEmpty &&
            err.toString().trim() != 'null') {
          errorMsg = err.toString().trim();
        }
      } else if (responseData is String && responseData.trim().isNotEmpty) {
        if (!responseData.contains('<html') && responseData.length < 200) {
          errorMsg = responseData.trim();
        } else if (e.response?.statusCode != null) {
          errorMsg = 'فشل الرفع من الخادم برمز (${e.response!.statusCode})';
        }
      } else if (e.message != null &&
          e.message!.trim().isNotEmpty &&
          e.message!.trim() != 'null') {
        errorMsg = e.message!.trim();
      } else if (e.error != null && e.error.toString() != 'null') {
        errorMsg = e.error.toString();
      }

      throw Exception(errorMsg);
    } catch (e) {
      String msg = e.toString().replaceFirst('Exception: ', '').trim();
      if (msg.isEmpty || msg == 'null') {
        msg = 'حدث خطأ غير متوقع أثناء معالجة الصورة، يرجى إعادة المحاولة';
      }
      throw Exception(msg);
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
    if (filePaths.isEmpty) {
      throw Exception('قائمة الملفات المحددة فارغة أو غير صالحة.');
    }
    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < filePaths.length; i++) {
      final path = filePaths[i];
      final name = path.split('/').last;
      final result = await uploadFile(
        filePath: path,
        fileName: name,
        incidentId: incidentId,
        description: description,
        xAxis: xAxis,
        yAxis: yAxis,
        onProgress: (progress) => onProgress((i + progress) / filePaths.length),
      );
      results.add(result);
    }
    return {
      'success': true,
      'message': 'تم رفع الملفات بنجاح',
      'data': results,
      'statusCode': 200,
    };
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
    if (kIsWeb) {
      final bytes = await XFile(filePath).readAsBytes();
      return bytes.length;
    }
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
