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

class FileUploadScreen extends StatefulWidget {
  final int? incidentId;
  final int? userId;

  const FileUploadScreen({super.key, this.incidentId, this.userId});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  bool _updateLocation = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FileUploadCubit(repository: FileUploadRepository()),
      child: Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
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
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderBanner(context),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                        child: _buildMainContent(context, state),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F3B6C),
        image: DecorationImage(
          image: AssetImage('assets/images/header_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A2240).withValues(alpha: 0.94),
              const Color(0xFF0F3866).withValues(alpha: 0.88),
              const Color(0xFF164780).withValues(alpha: 0.97),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo (Right in RTL)
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.water_drop_rounded,
                          color: appColor,
                          size: 28,
                        ),
                      ),
                    ),

                    // Actions Row: Reset and Back Button
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                          tooltip: 'إعادة تعيين',
                          onPressed: () {
                            context.read<FileUploadCubit>().resetState();
                            setState(() {
                              _updateLocation = false;
                            });
                          },
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'رفع وتوثيق صور الأزمة',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'توثيق ميداني للبلاغ بالصور المباشرة والإحداثيات',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          const SizedBox(height: 16),
          // Checkbox for updating incident location with photo location
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _updateLocation
                    ? AppTheme.primaryColor
                    : Colors.grey.shade300,
                width: _updateLocation ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                value: _updateLocation,
                onChanged: (val) {
                  setState(() {
                    _updateLocation = val ?? false;
                  });
                },
                activeColor: AppTheme.primaryColor,
                checkboxShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _updateLocation
                        ? AppTheme.primaryColor.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: _updateLocation
                        ? AppTheme.primaryColor
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'تحديث موقع الأزمة بموقع الصورة',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                subtitle: const Text(
                  'سيتم تعيين إحداثيات الأزمة وفقاً للموقع الجغرافي للصورة الحالية',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<FileUploadCubit>().resetState();
                    setState(() {
                      _updateLocation = false;
                    });
                  },
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
                    // Upload with incident parameters and updateLocation flag
                    context.read<FileUploadCubit>().uploadFile(
                      widget.incidentId ?? 0,
                      filePath,
                      fileName,
                      updateLocation: _updateLocation,
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
