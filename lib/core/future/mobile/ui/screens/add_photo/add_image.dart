import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_cubit.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_state.dart';
import 'package:incidents_managment/core/future/mobile/ui/widgets/add_image_widget.dart';

bool _isQueuedUploadMessage(String message) =>
    message.contains('سيتم رفع') || message.contains('وسيتم رفع');

class FileUploadScreen extends StatelessWidget {
  final int? incidentId;
  final int? userId;

  const FileUploadScreen({super.key, this.incidentId, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FileUploadCubit(repository: FileUploadRepository()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('رفع صور الأزمة'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  context.read<FileUploadCubit>().resetState();
                },
                tooltip: 'إعادة تعيين',
              ),
            ],
          ),
          body: BlocConsumer<FileUploadCubit, FileUploadState>(
            listener: (context, state) {
              state.maybeWhen(
                uploadSuccess: (message, fileName) {
                  final queued = _isQueuedUploadMessage(message);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            queued ? Icons.schedule_send : Icons.check_circle,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message)),
                        ],
                      ),
                      backgroundColor: queued
                          ? AppTheme.queuedColor
                          : AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                uploadError: (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(error)),
                        ],
                      ),
                      backgroundColor: AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderSection(context),
                    const SizedBox(height: 32),
                    _buildMainContent(context, state),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'رفع صور الأزمة',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, FileUploadState state) {
    return state.maybeWhen(
      initial: () => UploadButtonSection(
        onPickFile: () => context.read<FileUploadCubit>().pickFile(),
        onPickImageCamera: () => context.read<FileUploadCubit>().pickImage(
          source: ImageSource.camera,
        ),
        onPickImageGallery: () => context.read<FileUploadCubit>().pickImage(
          source: ImageSource.gallery,
        ),
      ),
      fileSelected: (fileName, filePath, fileSize, fileExtension) => Column(
        children: [
          FilePreviewCard(
            fileName: fileName,
            filePath: filePath,
            fileSize: fileSize,
            fileExtension: fileExtension ?? '',
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<FileUploadCubit>().resetState(),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('إلغاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: appColor,

                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: appColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Upload with incident parameters
                    context.read<FileUploadCubit>().uploadFile(
                      incidentId ?? 0,
                      filePath,
                      fileName,
                    );
                  },
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('رفع'),

                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: appColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      uploading: (progress, fileName) =>
          UploadProgressCard(progress: progress, fileName: fileName),
      uploadSuccess: (message, fileName) => UploadCompletionView(
        message: message,
        fileName: fileName,
        onUploadAnother: () => context.read<FileUploadCubit>().resetState(),
      ),
      uploadError: (error) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.errorColor.withAlpha(77),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'فشل الرفع',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.errorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.read<FileUploadCubit>().resetState(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('حاول مرة أخرى'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class UploadCompletionView extends StatelessWidget {
  final String message;
  final String fileName;
  final VoidCallback onUploadAnother;

  const UploadCompletionView({
    super.key,
    required this.message,
    required this.fileName,
    required this.onUploadAnother,
  });

  @override
  Widget build(BuildContext context) {
    final queued = _isQueuedUploadMessage(message);
    final statusColor = queued ? AppTheme.queuedColor : AppTheme.successColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withAlpha(77), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              queued ? Icons.schedule_send_rounded : Icons.check_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            queued ? 'تم حفظ الملف للمزامنة' : 'تم الرفع بنجاح!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$fileName\n$message',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onUploadAnother,
            icon: const Icon(Icons.add_rounded),
            label: const Text('رفع صورة أخرى'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: statusColor,
              minimumSize: const Size(48, 48),
            ),
          ),
        ],
      ),
    );
  }
}
