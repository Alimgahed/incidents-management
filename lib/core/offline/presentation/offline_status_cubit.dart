import 'dart:async';

import 'package:bloc/bloc.dart';

import '../data/repositories/attachment_cache_repository.dart';
import '../data/repositories/sync_queue_repository.dart';
import '../domain/sync_manager.dart';
import '../network/network_monitor.dart';
import 'offline_status_state.dart';

/// Aggregates network state + queue size + active sync into a single state
/// stream that the UI banner / chip can subscribe to.
class OfflineStatusCubit extends Cubit<OfflineStatusState> {
  OfflineStatusCubit({
    required this.networkMonitor,
    required this.syncManager,
    required this.queue,
    required this.attachments,
  }) : super(const OfflineStatusState.initial()) {
    _subscribeToInputs();
    _emitFromSources();
  }

  final NetworkMonitorService networkMonitor;
  final SyncManager syncManager;
  final SyncQueueRepository queue;
  final AttachmentCacheRepository attachments;

  StreamSubscription<bool>? _netSub;
  StreamSubscription<SyncStatusEvent>? _syncSub;
  StreamSubscription? _queueSub;
  StreamSubscription? _attachmentSub;

  /// Trigger a manual sync from the UI (e.g. pull-to-refresh, "Retry" button).
  ///
  /// Critically, this **forces a real reachability probe first**. On iOS the
  /// `connectivity_plus` change stream sometimes misses the airplane-mode-off
  /// transition; without this active probe the app would stay stuck on the
  /// offline banner even after the connection is back.
  Future<void> retryNow() async {
    emit(state.copyWith(isSyncing: true, lastEventMessage: 'Checking…'));
    final reachable = await networkMonitor.refresh();
    if (reachable) {
      await syncManager.syncNow();
    } else {
      emit(state.copyWith(
        isSyncing: false,
        isOnline: false,
        lastEventMessage: 'Still offline',
      ));
    }
  }

  void _subscribeToInputs() {
    _netSub = networkMonitor.onlineStream.listen((online) {
      emit(state.copyWith(isOnline: online));
    });

    _syncSub = syncManager.events.listen((event) {
      switch (event.kind) {
        case SyncStatusKind.started:
          emit(state.copyWith(isSyncing: true, lastEventMessage: 'Syncing…'));
          break;
        case SyncStatusKind.completed:
          emit(state.copyWith(
            isSyncing: false,
            pendingCount: event.pendingLeft ?? queue.countPending(),
            conflictCount: event.conflicts ?? queue.countConflicts(),
            pendingAttachmentCount: attachments.countPending(),
            lastEventMessage: 'Sync complete',
          ));
          break;
        case SyncStatusKind.pausedOffline:
          emit(state.copyWith(
            isSyncing: false,
            lastEventMessage: 'Paused — offline',
          ));
          break;
        case SyncStatusKind.itemFailed:
        case SyncStatusKind.itemConflict:
          emit(state.copyWith(
            pendingCount: queue.countPending(),
            conflictCount: queue.countConflicts(),
            lastEventMessage: event.message,
          ));
          break;
        case SyncStatusKind.itemSynced:
        case SyncStatusKind.attachmentSynced:
        case SyncStatusKind.itemStarted:
          emit(state.copyWith(
            pendingCount: queue.countPending(),
            pendingAttachmentCount: attachments.countPending(),
          ));
          break;
      }
    });

    _queueSub = queue.watch().listen((_) => _emitFromSources());
    _attachmentSub = attachments.watch().listen((_) => _emitFromSources());
  }

  void _emitFromSources() {
    emit(state.copyWith(
      isOnline: networkMonitor.isOnline,
      isSyncing: syncManager.isSyncing,
      pendingCount: queue.countPending(),
      conflictCount: queue.countConflicts(),
      pendingAttachmentCount: attachments.countPending(),
    ));
  }

  @override
  Future<void> close() async {
    await _netSub?.cancel();
    await _syncSub?.cancel();
    await _queueSub?.cancel();
    await _attachmentSub?.cancel();
    return super.close();
  }
}
