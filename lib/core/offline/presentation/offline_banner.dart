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
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(48, 48),
                      ),
                      child: Text(
                        state.isSyncing ? 'جارٍ التحقق…' : 'إعادة المحاولة',
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
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
