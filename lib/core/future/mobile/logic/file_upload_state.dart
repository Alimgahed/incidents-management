import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_upload_state.freezed.dart';

@freezed
class FileUploadState with _$FileUploadState {
  const factory FileUploadState.initial() = _Initial;
  const factory FileUploadState.fileSelected({
    required String fileName,
    required String filePath,
    required int fileSize,
    String? fileExtension,
  }) = _FileSelected;
  
  const factory FileUploadState.uploading({
    required double progress,
    required String fileName,
  }) = _Uploading;
  
  const factory FileUploadState.uploadSuccess({
    required String message,
    required String fileName,
  }) = _UploadSuccess;
  
  const factory FileUploadState.uploadError({
    required String error,
  }) = _UploadError;
}