import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';
import 'package:incidents_managment/core/future/mobile/data/repo/file_upload_repo.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_cubit.dart';
import 'package:incidents_managment/core/future/mobile/logic/file_upload_state.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
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
        builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
          value: MobileSystemBars.standard,
          child: Directionality(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Official Company Logo (Circular badge matching home screen)
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.water_drop_rounded,
                            color: appColor,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Company Name
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'رفع وتوثيق صور الأزمة',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'شركة مياه الشرب والصرف الصحي بالمنيا',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                            width: 38,
                            height: 38,
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
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'توثيق ميداني مباشر مع حفظ الإحداثيات الجغرافية للبلاغ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
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
        onPickImageCamera: () => context.read<FileUploadCubit>().pickImage(
          source: ImageSource.camera,
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
          const SizedBox(height: 24),
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
                  icon: const Icon(Icons.cancel_outlined, size: 20),
                  label: const Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<FileUploadCubit>().uploadFile(
                      widget.incidentId ?? 0,
                      filePath,
                      fileName,
                      updateLocation: _updateLocation,
                    );
                  },
                  icon: const Icon(Icons.cloud_upload_rounded, size: 22),
                  label: const Text(
                    'تأكيد رفع الصورة',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: appColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                    shadowColor: appColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'تعذر رفع الصورة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFDC2626),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.trim().isNotEmpty && error.trim() != 'null'
                      ? error
                      : 'حدث خطأ غير متوقع أثناء رفع الصورة، يرجى إعادة المحاولة',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF475569),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            context.read<FileUploadCubit>().resetState(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFDC2626),
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
    final statusColor = queued ? const Color(0xFFD97706) : const Color(0xFF10B981);
    final bgColor = queued ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5);
    final borderColor = queued ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              queued ? Icons.schedule_send_rounded : Icons.check_circle_rounded,
              size: 44,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            queued ? 'تم حفظ الصورة وستُرفع تلقائياً' : 'تم رفع الصورة بنجاح!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: statusColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Text(
              fileName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('العودة للأزمة'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF334155),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onUploadAnother,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                  label: const Text('رفع صورة أخرى'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
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
    );
  }
}
