import 'dart:async';

import 'package:hive/hive.dart';
import 'package:synchronized/synchronized.dart';

import '../local_database.dart';
import '../models/sync_enums.dart';
import '../models/sync_queue_item.dart';

/// Thin, typed wrapper around the [SyncQueueItem] Hive box.
///
/// All mutations go through a single [_lock] so concurrent producers
/// (UI thread enqueueing while [SyncManager] is draining) don't corrupt the
/// box state.
class SyncQueueRepository {
  final Lock _lock = Lock();

  Box<SyncQueueItem> get _box => LocalDatabase.syncQueue;

  /// Exposes the underlying box's change notifications. UI layers can watch
  /// this to drive a “pending count” badge in real time.
  Stream<BoxEvent> watch() => _box.watch();

  Future<void> add(SyncQueueItem item) =>
      _lock.synchronized(() => _box.put(item.id, item));

  Future<void> update(SyncQueueItem item) =>
      _lock.synchronized(() => _box.put(item.id, item));

  Future<void> remove(String id) =>
      _lock.synchronized(() => _box.delete(id));

  SyncQueueItem? get(String id) => _box.get(id);

  /// All items still in flight or waiting, oldest first.
  List<SyncQueueItem> pending() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final items = _box.values.where((i) {
      if (i.state != SyncState.pending && i.state != SyncState.failed) {
        return false;
      }
      // honor exponential-backoff "do not retry before" windows
      if (i.nextEligibleAtMs != null && i.nextEligibleAtMs! > now) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
    return items;
  }

  /// Items the user should be alerted about (failed after max retries, or
  /// conflicting with server state).
  List<SyncQueueItem> problematic() {
    return _box.values
        .where((i) => i.state == SyncState.failed || i.state == SyncState.conflict)
        .toList();
  }

  int countPending() => _box.values
      .where((i) => i.state == SyncState.pending || i.state == SyncState.failed)
      .length;

  int countConflicts() =>
      _box.values.where((i) => i.state == SyncState.conflict).length;

  int totalCount() => _box.length;

  Future<void> markSyncing(String id) => _lock.synchronized(() async {
        final item = _box.get(id);
        if (item == null) return;
        item.state = SyncState.syncing;
        item.lastAttemptAtMs = DateTime.now().millisecondsSinceEpoch;
        await _box.put(id, item);
      });

  Future<void> markSynced(String id) => _lock.synchronized(() async {
        // Drop synced items from disk — successful operations don't need to
        // linger in the queue.
        await _box.delete(id);
      });

  Future<void> markFailed(String id, String error,
      {Duration? backoff}) =>
      _lock.synchronized(() async {
        final item = _box.get(id);
        if (item == null) return;
        item.retryCount += 1;
        item.lastError = error;
        item.state = SyncState.failed;
        final delay = backoff ??
            Duration(milliseconds: 500 * (1 << item.retryCount.clamp(0, 8)));
        item.nextEligibleAtMs =
            DateTime.now().millisecondsSinceEpoch + delay.inMilliseconds;
        await _box.put(id, item);
      });

  Future<void> markConflict(String id, String detail) =>
      _lock.synchronized(() async {
        final item = _box.get(id);
        if (item == null) return;
        item.state = SyncState.conflict;
        item.lastError = detail;
        await _box.put(id, item);
      });

  Future<void> markRetryable(String id) => _lock.synchronized(() async {
        final item = _box.get(id);
        if (item == null) return;
        item.state = SyncState.pending;
        await _box.put(id, item);
      });

  /// Removes everything in the queue. Used by Logout.
  Future<void> clear() => _lock.synchronized(() => _box.clear());
}
