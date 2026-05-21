import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'offline_status_cubit.dart';
import 'offline_status_state.dart';

/// Compact chip suitable for placement in an app-bar action area. Mirrors the
/// banner colors but takes far less vertical room.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfflineStatusCubit, OfflineStatusState>(
      builder: (context, state) {
        final (color, icon, label) = _styleFor(state);
        return Tooltip(
          message: _tooltipFor(state),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            // Tap always works — even when offline it forces a real probe.
            onTap: state.isSyncing
                ? null
                : () => context.read<OfflineStatusCubit>().retryNow(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                border: Border.all(color: color.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
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

  (Color, IconData, String) _styleFor(OfflineStatusState s) {
    if (!s.isOnline) {
      return (const Color(0xFFB71C1C), Icons.cloud_off_rounded, 'Offline');
    }
    if (s.conflictCount > 0) {
      return (const Color(0xFFE65100), Icons.warning_amber_rounded,
          '${s.conflictCount}');
    }
    if (s.isSyncing) {
      return (const Color(0xFF1565C0), Icons.sync_rounded, 'Syncing');
    }
    if (s.pendingCount > 0) {
      return (
        const Color(0xFF1565C0),
        Icons.cloud_upload_outlined,
        '${s.pendingCount}'
      );
    }
    return (Colors.green.shade700, Icons.cloud_done_outlined, 'Live');
  }

  String _tooltipFor(OfflineStatusState s) {
    final parts = <String>[
      s.isOnline ? 'Online' : 'Offline',
      if (s.pendingCount > 0) '${s.pendingCount} queued change(s)',
      if (s.pendingAttachmentCount > 0)
        '${s.pendingAttachmentCount} photo(s) to upload',
      if (s.conflictCount > 0) '${s.conflictCount} conflict(s)',
      if (s.isSyncing) 'Sync in progress',
    ];
    return parts.join(' · ');
  }
}
