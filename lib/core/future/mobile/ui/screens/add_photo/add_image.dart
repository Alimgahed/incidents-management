import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_cubit.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_state.dart';
import 'package:incidents_managment/core/future/mobile/ui/widgets/add_image_widget.dart';

class FileUploadScreen extends StatelessWidget {
  final int? incidentId;
  final int? userId;
  
  const FileUploadScreen({
    super.key,
     this.incidentId,
     this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: BlocProvider(
        create: (context) => FileUploadCubit(repository: FileUploadRepository()),
        child: BlocConsumer<FileUploadCubit, FileUploadState>(
          listener: (context, state) {
            state.maybeWhen(
              uploadSuccess: (message, fileName) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(message)),
                      ],
                    ),
                    backgroundColor: AppTheme.successColor,
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
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.2),
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
          const SizedBox(height: 8),
          Text(
            'شارك الصور بشكل آمن',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
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
        onPickImageCamera: () => context
            .read<FileUploadCubit>()
            .pickImage(source: ImageSource.camera),
        onPickImageGallery: () => context
            .read<FileUploadCubit>()
            .pickImage(source: ImageSource.gallery),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.borderColor),
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
                      incidentId??0,
                          filePath,
                          fileName,
                        
                        );
                  },
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('رفع'),
                  style: ElevatedButton.styleFrom(
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
      uploading: (progress, fileName) => UploadProgressCard(
        progress: progress,
        fileName: fileName,
      ),
      uploadSuccess: (message, fileName) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.successColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'تم الرفع بنجاح!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.read<FileUploadCubit>().resetState(),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('رفع صورة أخرى'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      uploadError: (error) => Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.errorColor.withOpacity(0.3),
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