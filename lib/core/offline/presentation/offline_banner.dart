import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'offline_status_cubit.dart';
import 'offline_status_state.dart';

/// Slim banner that pins itself to the top of any scaffold and shows:
///   * "Offline — N pending changes"  (red, when isOffline)
///   * "Syncing…"                     (blue, transient)
///   * "X conflicts to review"        (amber, persistent until cleared)
/// Renders nothing when everything is healthy ([OfflineStatusState.isClean]).
///
/// Wrap your top-level scaffold body like:
/// ```dart
/// body: Column(
///   children: [
///     const OfflineBanner(),
///     Expanded(child: <existing body>),
///   ],
/// ),
/// ```
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8)});

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
                  Icon(icon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Retry is ALWAYS tappable, even while offline. When offline
                  // it forces a fresh reachability probe — needed because iOS
                  // sometimes doesn't deliver the airplane-mode-off event.
                  if (!state.isOnline ||
                      state.pendingCount > 0 ||
                      state.conflictCount > 0)
                    TextButton(
                      onPressed: state.isSyncing
                          ? null
                          : () => context.read<OfflineStatusCubit>().retryNow(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Text(state.isSyncing ? 'Checking…' : 'Retry'),
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
      final pendingBits = <String>[
        if (s.pendingCount > 0) '${s.pendingCount} pending',
        if (s.pendingAttachmentCount > 0)
          '${s.pendingAttachmentCount} photo${s.pendingAttachmentCount == 1 ? '' : 's'}',
      ];
      final suffix = pendingBits.isEmpty ? '' : ' — ${pendingBits.join(', ')}';
      return (const Color(0xFFB71C1C), Icons.cloud_off_rounded,
          'Offline$suffix');
    }
    if (s.conflictCount > 0) {
      return (const Color(0xFFE65100), Icons.warning_amber_rounded,
          '${s.conflictCount} conflict${s.conflictCount == 1 ? '' : 's'} to review');
    }
    if (s.isSyncing) {
      return (const Color(0xFF1565C0), Icons.sync_rounded,
          'Syncing… ${s.pendingCount > 0 ? '(${s.pendingCount} left)' : ''}');
    }
    if (s.pendingCount > 0 || s.pendingAttachmentCount > 0) {
      final bits = <String>[
        if (s.pendingCount > 0) '${s.pendingCount} pending change${s.pendingCount == 1 ? '' : 's'}',
        if (s.pendingAttachmentCount > 0) '${s.pendingAttachmentCount} photo${s.pendingAttachmentCount == 1 ? '' : 's'}',
      ];
      return (const Color(0xFF1565C0), Icons.cloud_upload_outlined,
          bits.join(' • '));
    }
    return (Colors.green.shade700, Icons.cloud_done_outlined, 'All changes synced');
  }
}
