import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'file_upload_state.dart';

class FileUploadCubit extends Cubit<FileUploadState> {
  final FileUploadRepository repository;

  FileUploadCubit({required this.repository}) 
      : super(const FileUploadState.initial());

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = await file.length();
        final fileExtension = fileName.split('.').last;

        emit(FileUploadState.fileSelected(
          fileName: fileName,
          filePath: file.path,
          fileSize: fileSize,
          fileExtension: fileExtension,
        ));
      }
    } catch (e) {
      emit(FileUploadState.uploadError(error: 'Failed to pick file: $e'));
    }
  }

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

        emit(FileUploadState.fileSelected(
          fileName: fileName,
          filePath: file.path,
          fileSize: fileSize,
          fileExtension: fileExtension,
        ));
      }
    } catch (e) {
      emit(FileUploadState.uploadError(error: 'Failed to pick image: $e'));
    }
  }

  Future<void> uploadFile(
    
    int id,String filePath, String fileName) async {
    try {
      emit(FileUploadState.uploading(
        progress: 0.0,
        fileName: fileName,
      ));

      await repository.uploadFile(
        filePath: filePath,
        fileName: fileName,
        onProgress: (progress) {
          emit(FileUploadState.uploading(
            progress: progress,
            fileName: fileName,
          ));
        }, incidentId:id , description:"" , 
      );

      emit(FileUploadState.uploadSuccess(
        message: 'File uploaded successfully!',
        fileName: fileName,
      ));
    } catch (e) {
      emit(FileUploadState.uploadError(
        error: 'Upload failed: ${e.toString()}',
      ));
    }
  }

  void resetState() {
    emit(const FileUploadState.initial());
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}