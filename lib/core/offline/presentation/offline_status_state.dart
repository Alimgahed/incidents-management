import 'package:equatable/equatable.dart';

/// Snapshot of the offline subsystem, consumed by the banner & status chip.
class OfflineStatusState extends Equatable {
  final bool isOnline;
  final bool isSyncing;
  final int pendingCount;
  final int conflictCount;
  final int pendingAttachmentCount;
  final String? lastEventMessage;

  const OfflineStatusState({
    required this.isOnline,
    required this.isSyncing,
    required this.pendingCount,
    required this.conflictCount,
    required this.pendingAttachmentCount,
    this.lastEventMessage,
  });

  const OfflineStatusState.initial()
      : isOnline = true,
        isSyncing = false,
        pendingCount = 0,
        conflictCount = 0,
        pendingAttachmentCount = 0,
        lastEventMessage = null;

  bool get hasPending => pendingCount > 0 || pendingAttachmentCount > 0;
  bool get hasConflicts => conflictCount > 0;
  bool get isClean => isOnline && !hasPending && !hasConflicts && !isSyncing;

  OfflineStatusState copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? pendingCount,
    int? conflictCount,
    int? pendingAttachmentCount,
    String? lastEventMessage,
    bool clearMessage = false,
  }) {
    return OfflineStatusState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      conflictCount: conflictCount ?? this.conflictCount,
      pendingAttachmentCount:
          pendingAttachmentCount ?? this.pendingAttachmentCount,
      lastEventMessage:
          clearMessage ? null : (lastEventMessage ?? this.lastEventMessage),
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        isSyncing,
        pendingCount,
        conflictCount,
        pendingAttachmentCount,
        lastEventMessage,
      ];
}
