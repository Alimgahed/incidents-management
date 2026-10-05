import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:incidents_managment/core/offline/data/repositories/attachment_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/sync_queue_repository.dart';
import 'package:incidents_managment/core/offline/domain/sync_manager.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';
import 'package:incidents_managment/core/offline/presentation/offline_banner.dart';
import 'package:incidents_managment/core/offline/presentation/offline_status_cubit.dart';
import 'package:incidents_managment/core/offline/presentation/offline_status_state.dart';

void main() {
  testWidgets('offline banner explains pending work and exposes retry action', (
    tester,
  ) async {
    final cubit = _FakeOfflineStatusCubit();
    addTearDown(cubit.close);
    cubit.setOffline(pending: 2, attachments: 1);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OfflineStatusCubit>.value(
          value: cubit,
          child: const Scaffold(body: OfflineBanner()),
        ),
      ),
    );

    expect(find.textContaining('غير متصل'), findsOneWidget);
    expect(find.textContaining('تغييرات معلقة: 2'), findsOneWidget);
    expect(find.textContaining('مرفقات معلقة: 1'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    expect(cubit.retryCount, 1);
  });

  testWidgets('clean state does not consume layout space', (tester) async {
    final cubit = _FakeOfflineStatusCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<OfflineStatusCubit>.value(
          value: cubit,
          child: const Scaffold(body: OfflineBanner()),
        ),
      ),
    );

    expect(find.byType(OfflineBanner), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsNothing);
    expect(tester.getSize(find.byType(OfflineBanner)), Size.zero);
  });
}

class _FakeOfflineStatusCubit extends Cubit<OfflineStatusState>
    implements OfflineStatusCubit {
  _FakeOfflineStatusCubit() : super(const OfflineStatusState.initial());

  int retryCount = 0;

  @override
  NetworkMonitorService get networkMonitor => throw UnimplementedError();
  @override
  SyncManager get syncManager => throw UnimplementedError();
  @override
  SyncQueueRepository get queue => throw UnimplementedError();
  @override
  AttachmentCacheRepository get attachments => throw UnimplementedError();

  @override
  Future<void> retryNow() async {
    retryCount++;
  }

  void setOffline({required int pending, required int attachments}) => emit(
    OfflineStatusState(
      isOnline: false,
      isSyncing: false,
      pendingCount: pending,
      conflictCount: 0,
      pendingAttachmentCount: attachments,
    ),
  );
}
