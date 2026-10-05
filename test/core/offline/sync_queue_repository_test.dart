import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:incidents_managment/core/offline/data/models/cached_attachment.dart';
import 'package:incidents_managment/core/offline/data/models/cached_incident.dart';
import 'package:incidents_managment/core/offline/data/models/cached_mission.dart';
import 'package:incidents_managment/core/offline/data/models/sync_enums.dart';
import 'package:incidents_managment/core/offline/data/models/sync_queue_item.dart';
import 'package:incidents_managment/core/offline/data/repositories/sync_queue_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/attachment_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/mission_cache_repository.dart';
import 'package:incidents_managment/core/offline/domain/id_remap_service.dart';
import 'package:incidents_managment/core/offline/domain/temp_id_generator.dart';

void main() {
  late Directory hiveDirectory;
  late SyncQueueRepository repository;

  setUp(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('nsn_sync_queue_');
    Hive.init(hiveDirectory.path);
    if (!Hive.isAdapterRegistered(100)) {
      Hive.registerAdapter(SyncQueueItemAdapter());
    }
    if (!Hive.isAdapterRegistered(110)) {
      Hive.registerAdapter(SyncStateAdapter());
    }
    if (!Hive.isAdapterRegistered(111)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
    if (!Hive.isAdapterRegistered(101)) {
      Hive.registerAdapter<CachedIncident>(CachedIncidentAdapter());
    }
    if (!Hive.isAdapterRegistered(102)) {
      Hive.registerAdapter<CachedMission>(CachedMissionAdapter());
    }
    if (!Hive.isAdapterRegistered(103)) {
      Hive.registerAdapter<CachedAttachment>(CachedAttachmentAdapter());
    }
    await Hive.openBox<SyncQueueItem>('sync_queue');
    await Hive.openBox<CachedIncident>('cache_incidents');
    await Hive.openBox<CachedMission>('cache_missions');
    await Hive.openBox<CachedAttachment>('cache_attachments');
    await Hive.openBox('cache_kv');
    repository = SyncQueueRepository();
  });

  tearDown(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  SyncQueueItem item(String id, {String? payload}) => SyncQueueItem(
    id: id,
    operation: SyncOperation.post,
    endpoint: '/incidents',
    payloadJson: payload ?? '{"title":"Leak"}',
    entityRef: 'incident:local-1',
    createdAtMs: int.parse(id),
  );

  test(
    'persists queued writes and suppresses an identical active write',
    () async {
      final first = item('1');
      await repository.add(first);
      final reused = await repository.addIfNotExists(item('2'));

      expect(reused.id, '1');
      expect(repository.totalCount(), 1);
      expect(repository.pending().single.endpoint, '/incidents');
    },
  );

  test(
    'failed operations honor retry time and can be made retryable',
    () async {
      await repository.add(item('3'));
      await repository.markFailed(
        '3',
        'network unavailable',
        backoff: const Duration(hours: 1),
      );

      expect(repository.pending(), isEmpty);
      expect(repository.problematic().single.lastError, 'network unavailable');

      await repository.markRetryable('3');
      expect(repository.pending().single.id, '3');
    },
  );

  test('conflicts remain visible and successful writes are removed', () async {
    await repository.add(item('4'));
    await repository.markConflict('4', 'server version changed');

    expect(repository.countConflicts(), 1);
    expect(repository.pending(), isEmpty);

    await repository.markSynced('4');
    expect(repository.totalCount(), 0);
  });

  test('creates decreasing negative temporary IDs', () {
    final first = TempIdGenerator.nextNumeric();
    final second = TempIdGenerator.nextNumeric();
    expect(first, lessThan(0));
    expect(second, lessThan(first));
    expect(TempIdGenerator.isTempNumeric(first), isTrue);
  });

  test(
    'server ID reconciliation updates incident, attachment, and queued work',
    () async {
      final incidents = IncidentCacheRepository();
      final attachments = AttachmentCacheRepository();
      final followUp = SyncQueueItem(
        id: 'remap',
        operation: SyncOperation.put,
        endpoint: '/incidents/-7',
        payloadJson: '{"incident_id":-7}',
        entityRef: 'incident:-7',
        createdAtMs: 10,
      );
      await incidents.upsert(
        CachedIncident.fromMap(
          const {'current_incident_description': 'Offline report'},
          idOrTempId: -7,
          hasPendingChanges: true,
        ),
      );
      await attachments.add(
        CachedAttachment(
          localId: 'photo-1',
          incidentIdOrTempId: -7,
          localFilePath: '/tmp/photo.jpg',
          fileName: 'photo.jpg',
          description: '',
          xAxis: 31,
          yAxis: 30,
          createdAtMs: 10,
        ),
      );
      await repository.add(followUp);

      await IdRemapService(
        incidents: incidents,
        missions: MissionCacheRepository(),
        attachments: attachments,
        queue: repository,
      ).remapIncidentId(tempId: -7, serverId: 421);

      expect(incidents.get(-7), isNull);
      expect(incidents.get(421)?.toMap()['current_incident_id'], 421);
      expect(attachments.get('photo-1')?.incidentIdOrTempId, 421);
      expect(repository.get('remap')?.endpoint, '/incidents/421');
      expect(repository.get('remap')?.payload?['incident_id'], 421);
      expect(repository.get('remap')?.entityRef, 'incident:421');
    },
  );

  test(
    'attachment failure remains pending until the upload is acknowledged',
    () async {
      final attachments = AttachmentCacheRepository();
      await attachments.add(
        CachedAttachment(
          localId: 'pending-photo',
          incidentIdOrTempId: 12,
          localFilePath: '/tmp/photo.jpg',
          fileName: 'photo.jpg',
          description: '',
          xAxis: 31,
          yAxis: 30,
          createdAtMs: 10,
        ),
      );

      await attachments.recordFailure('pending-photo', 'timeout');
      expect(attachments.countPending(), 1);
      expect(attachments.get('pending-photo')?.retryCount, 1);

      await attachments.markUploaded(localId: 'pending-photo', serverId: 89);
      expect(attachments.countPending(), 0);
      expect(attachments.get('pending-photo')?.serverId, 89);
    },
  );
}
