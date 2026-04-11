import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final FileUploadRepository repository;

  FileUploadCubit({required this.repository})
    : super(const FileUploadState.initial());

  /// ==========================
  /// Pick Any File
  /// ==========================
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();
        final fileExtension = fileName.split('.').last;

        emit(
          FileUploadState.fileSelected(
            fileName: fileName,
            filePath: file.path,
            fileSize: fileSize,
            fileExtension: fileExtension,
          ),
        );
      }
    } catch (e) {
      emit(FileUploadState.uploadError(error: 'Failed to pick file: $e'));
    }
  }

  /// ==========================
  /// Pick Image
  /// ==========================
  Future<void> pickImage({required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final fileName = image.name;
        final fileSize = await file.length();
        final fileExtension = fileName.split('.').last;

        emit(
          FileUploadState.fileSelected(
            fileName: fileName,
            filePath: file.path,
            fileSize: fileSize,
            fileExtension: fileExtension,
          ),
        );
      }
    } catch (e) {
      emit(FileUploadState.uploadError(error: 'Failed to pick image: $e'));
    }
  }

  /// ==========================
  /// Ensure Location Permission
  /// FIX: Returns bool instead of throwing, emits error state directly
  /// ==========================
  Future<bool> _ensureLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(
        FileUploadState.uploadError(
          error:
              'Location services are disabled. Please enable GPS and try again.',
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // Request permission if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Still denied after request
    if (permission == LocationPermission.denied) {
      emit(
        FileUploadState.uploadError(
          error:
              'Location permission denied. Please allow location access to upload files.',
        ),
      );
      return false;
    }

    // Permanently denied — open app settings
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      emit(
        FileUploadState.uploadError(
          error:
              'Location permission permanently denied. Please enable it from app settings.',
        ),
      );
      return false;
    }

    return true;
  }

  /// ==========================
  /// Get Current Location
  /// FIX: Uses LocationSettings instead of deprecated desiredAccuracy
  /// ==========================
  Future<Position?> _getCurrentLocation() async {
    final hasPermission = await _ensureLocationPermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// ==========================
  /// Upload File With Location
  /// FIX: Guards against null position from failed permission
  /// ==========================
  Future<void> uploadFile(
    int incidentId,
    String filePath,
    String fileName,
  ) async {
    try {
      emit(FileUploadState.uploading(progress: 0.0, fileName: fileName));

      // Get current location (with permission handling)
      final position = await _getCurrentLocation();

      // If position is null, permission failed and error state already emitted
      if (position == null) return;

      await repository.uploadFile(
        filePath: filePath,
        fileName: fileName,
        incidentId: incidentId,
        description: "",
        xAxis: position.longitude,
        yAxis: position.latitude,
        onProgress: (progress) {
          emit(
            FileUploadState.uploading(progress: progress, fileName: fileName),
          );
        },
      );

      emit(
        FileUploadState.uploadSuccess(
          message: 'File uploaded successfully!',
          fileName: fileName,
        ),
      );
    } catch (e) {
      emit(FileUploadState.uploadError(error: e.toString()));
    }
  }

  /// ==========================
  /// Reset
  /// ==========================
  void resetState() {
    emit(const FileUploadState.initial());
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
