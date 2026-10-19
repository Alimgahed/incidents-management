import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'offline_status_cubit.dart';
import 'offline_status_state.dart';

/// Persistent, actionable summary of connectivity and pending offline work.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfflineStatusCubit, OfflineStatusState>(
      builder: (context, state) {
        if (state.isClean) return const SizedBox.shrink();
        final (background, icon, text) = _styleFor(state);

        return Material(
          color: background,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: padding,
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showStatusDetailsDialog(context, state),
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white70,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!state.isOnline ||
                      state.pendingCount > 0 ||
                      state.pendingAttachmentCount > 0 ||
                      state.conflictCount > 0)
                    TextButton(
                      onPressed: state.isSyncing
                          ? null
                          : () => context.read<OfflineStatusCubit>().retryNow(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: const Size(40, 36),
                      ),
                      child: Text(
                        state.isSyncing ? 'جارٍ التحقق…' : 'إعادة المحاولة',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (state.conflictCount > 0 || state.hasPending)
                    IconButton(
                      tooltip: 'تجاهل ومسح التنبيه',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () {
                        context.read<OfflineStatusCubit>().dismissConflicts();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStatusDetailsDialog(BuildContext context, OfflineStatusState state) {
    final cubit = context.read<OfflineStatusCubit>();
    final conflicts = cubit.getConflictDetails();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                state.conflictCount > 0
                    ? Icons.warning_amber_rounded
                    : (!state.isOnline ? Icons.cloud_off_rounded : Icons.info_outline_rounded),
                color: state.conflictCount > 0 ? const Color(0xFFE65100) : const Color(0xFF1B4F8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                state.conflictCount > 0 ? 'تفاصيل التعارضات' : 'حالة المزامنة والاتصال',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!state.isOnline) ...[
                  const Text(
                    'الجهاز حالياً غير متصل بالإنترنت. أي تعديلات أو بلاغات جديدة يتم حفظها بأمان داخل الذاكرة المحلية للجهاز لحين عودة الاتصال.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 10),
                ],
                if (state.conflictCount > 0) ...[
                  const Text(
                    'حدث تعارض أثناء محاولة مزامنة بعض البيانات المعدلة أوفلاين مع السيرفر، لأن البيانات على السيرفر تم تعديلها بواسطة مستخدم آخر أثناء انقطاع اتصالك.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  if (conflicts.isNotEmpty) ...[
                    const Text(
                      'العمليات المتأثرة:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    ...conflicts.map((item) {
                      final err = item.lastError ?? 'بيانات الخادم أحدث';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: Text(
                          '• ${item.operation.name}: $err',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9A3412)),
                        ),
                      );
                    }),
                  ],
                ] else if (state.hasPending) ...[
                  Text(
                    'يوجد ${state.pendingCount} تعديلات و ${state.pendingAttachmentCount} مرفقات في انتظار الإرسال للسيرفر.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            if (state.conflictCount > 0 || state.hasPending)
              TextButton(
                onPressed: () {
                  cubit.dismissConflicts();
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'مسح وتجاهل التنبيه',
                  style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                ),
              ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4F8A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('إغلاق', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  (Color, IconData, String) _styleFor(OfflineStatusState state) {
    if (!state.isOnline) {
      final pending = <String>[
        if (state.pendingCount > 0) 'تغييرات معلقة: ${state.pendingCount}',
        if (state.pendingAttachmentCount > 0)
          'مرفقات معلقة: ${state.pendingAttachmentCount}',
      ];
      final suffix = pending.isEmpty ? '' : ' • ${pending.join(' • ')}';
      return (
        const Color(0xFFB71C1C),
        Icons.cloud_off_rounded,
        'غير متصل$suffix',
      );
    }
    if (state.conflictCount > 0) {
      return (
        const Color(0xFFE65100),
        Icons.warning_amber_rounded,
        'تعارضات للمراجعة: ${state.conflictCount}',
      );
    }
    if (state.isSyncing) {
      final remaining = state.pendingCount > 0
          ? ' • المتبقي: ${state.pendingCount}'
          : '';
      return (
        const Color(0xFF1565C0),
        Icons.sync_rounded,
        'جارٍ مزامنة الأعمال$remaining',
      );
    }
    if (state.hasPending) {
      final pending = <String>[
        if (state.pendingCount > 0) 'تغييرات معلقة: ${state.pendingCount}',
        if (state.pendingAttachmentCount > 0)
          'مرفقات معلقة: ${state.pendingAttachmentCount}',
      ];
      return (
        const Color(0xFF1565C0),
        Icons.cloud_upload_outlined,
        pending.join(' • '),
      );
    }
    return (
      Colors.green.shade700,
      Icons.cloud_done_outlined,
      'تمت مزامنة جميع التغييرات',
    );
  }
}
