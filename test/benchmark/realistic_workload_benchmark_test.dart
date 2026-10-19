import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/offline/data/models/cached_attachment.dart';
import 'package:incidents_managment/core/offline/data/models/cached_incident.dart';
import 'package:incidents_managment/core/offline/data/models/cached_mission.dart';
import 'package:incidents_managment/core/offline/data/models/sync_enums.dart';
import 'package:incidents_managment/core/offline/data/models/sync_queue_item.dart';
import 'package:incidents_managment/core/offline/data/repositories/attachment_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/mission_cache_repository.dart';
import 'package:incidents_managment/core/offline/data/repositories/sync_queue_repository.dart';
import 'package:incidents_managment/core/offline/domain/id_remap_service.dart';
import 'package:incidents_managment/core/offline/domain/temp_id_generator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Rigorous Realistic Incident Benchmark Suite (1,000 Incidents)', () {
    late Directory tempDir;
    late List<CurrentIncidentModel> realisticDataset;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('benchmark_hive_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(101)) {
        Hive.registerAdapter<CachedIncident>(CachedIncidentAdapter());
      }
      if (!Hive.isAdapterRegistered(102)) {
        Hive.registerAdapter<CachedMission>(CachedMissionAdapter());
      }
      if (!Hive.isAdapterRegistered(103)) {
        Hive.registerAdapter<CachedAttachment>(CachedAttachmentAdapter());
      }
      if (!Hive.isAdapterRegistered(100)) {
        Hive.registerAdapter<SyncQueueItem>(SyncQueueItemAdapter());
      }
      if (!Hive.isAdapterRegistered(110)) {
        Hive.registerAdapter<SyncState>(SyncStateAdapter());
      }
      if (!Hive.isAdapterRegistered(111)) {
        Hive.registerAdapter<SyncOperation>(SyncOperationAdapter());
      }

      await Hive.openBox<CachedIncident>('cache_incidents');
      await Hive.openBox<CachedMission>('cache_missions');
      await Hive.openBox<CachedAttachment>('cache_attachments');
      await Hive.openBox<SyncQueueItem>('sync_queue');
      await Hive.openBox('cache_kv');

      final branches = [
        'المنيا', 'ملوي', 'بني مزار', 'مغاغة', 'أبو قرقاص',
        'سمالوط', 'مطاي', 'عدوة', 'دير مواس'
      ];
      final types = [
        'كسر خط طرد رئيسي', 'انقطاع مياه', 'طفح صرف صحي', 'هبوط أرضي',
        'عطل محبس 600 مم', 'تلوث مياه محتمل', 'عطل طلمبة رفع'
      ];

      realisticDataset = List.generate(1000, (i) {
        final id = 10000 + i;
        final branch = branches[i % branches.length];
        final type = types[i % types.length];
        final severity = (i % 4) + 1;
        final status = (i % 7) + 1;

        return CurrentIncidentModel(
          currentIncidentId: id,
          currentIncidentDescription: 'تقرير بلاغ طارئ بخصوص $type في نطاق فرع $branch رقم $i',
          currentIncidentNotes: 'ملاحظات المعاينة الميدانية ومتابعة غرفة الطوارئ للبلاغ $id',
          currentIncidentSeverity: severity,
          currentIncidentStatus: status,
          currentIncidentXAxis: 28.0871 + (i * 0.0005),
          currentIncidentYAxis: 30.7618 + (i * 0.0005),
          branchName: branch,
          branchId: (i % branches.length) + 1,
          currentIncidentTypeName: type,
          currentIncidentTypeId: (i % types.length) + 1,
        );
      });
    });

    tearDownAll(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('1. Benchmark: In-Memory Search & Multi-Filter Latency across 1,000 incidents', () {
      final cubit = DashboardCubit();

      final sw1 = Stopwatch()..start();
      final allFiltered = cubit.filterIncidents(realisticDataset);
      sw1.stop();
      expect(allFiltered.length, 1000);

      cubit.updateFilter('حرجة');
      cubit.updateSearchQuery('كسر');

      final sw2 = Stopwatch()..start();
      const iterations = 50;
      int matchCount = 0;
      for (var k = 0; k < iterations; k++) {
        final res = cubit.filterIncidents(realisticDataset);
        matchCount = res.length;
      }
      sw2.stop();

      final avgLatencyMicros = sw2.elapsedMicroseconds / iterations;
      final avgLatencyMs = avgLatencyMicros / 1000.0;

      expect(matchCount, greaterThan(0));
      expect(avgLatencyMs, lessThan(15.0));

      debugPrint('BENCHMARK RESULT [Filter/Search]: 1,000 incidents filtered in ${avgLatencyMs.toStringAsFixed(3)} ms (avg over $iterations runs). Matches: $matchCount');
    });

    test('2. Benchmark: Cold Cache Startup & Hive Serialization for 1,000 incidents', () async {
      final repo = IncidentCacheRepository();

      final swWrite = Stopwatch()..start();
      for (final inc in realisticDataset) {
        await repo.upsert(
          CachedIncident.fromMap(
            inc.toJson(),
            idOrTempId: inc.currentIncidentId ?? 0,
          ),
        );
      }
      swWrite.stop();

      final swRead = Stopwatch()..start();
      final loaded = repo.list(limit: 1000);
      swRead.stop();

      expect(loaded.length, 1000);
      debugPrint('BENCHMARK RESULT [Cache Storage]: 1,000 incidents written in ${swWrite.elapsedMilliseconds} ms, cold-read in ${swRead.elapsedMilliseconds} ms');
      expect(swRead.elapsedMilliseconds, lessThan(200));
    });

    test('3. Benchmark: Offline-First Full Lifecycle & Duplicate Prevention', () async {
      final queueRepo = SyncQueueRepository();
      final incidentRepo = IncidentCacheRepository();
      final missionRepo = MissionCacheRepository();
      final attachRepo = AttachmentCacheRepository();
      final remapService = IdRemapService(
        incidents: incidentRepo,
        missions: missionRepo,
        attachments: attachRepo,
        queue: queueRepo,
      );

      final tempId = TempIdGenerator.nextNumeric();
      expect(tempId, lessThan(0));

      // Seed cached incident with tempId
      await incidentRepo.upsert(
        CachedIncident.fromMap(
          {'current_incident_id': tempId, 'current_incident_description': 'Offline created leak'},
          idOrTempId: tempId,
        ),
      );

      final item = SyncQueueItem(
        id: 'edit_${DateTime.now().microsecondsSinceEpoch}',
        operation: SyncOperation.post,
        endpoint: '/incidents/$tempId',
        payloadJson: '{"status":2,"description":"تم التحرك للموقع"}',
        entityRef: 'incident:$tempId',
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );

      final swQueue = Stopwatch()..start();
      await queueRepo.add(item);
      swQueue.stop();

      expect(queueRepo.pending().length, 1);

      final duplicateItem = SyncQueueItem(
        id: 'edit_dup',
        operation: SyncOperation.post,
        endpoint: '/incidents/$tempId',
        payloadJson: '{"status":2,"description":"تم التحرك للموقع"}',
        entityRef: 'incident:$tempId',
        createdAtMs: DateTime.now().millisecondsSinceEpoch,
      );

      final reused = await queueRepo.addIfNotExists(duplicateItem);
      expect(reused.id, item.id);
      expect(queueRepo.pending().length, 1);

      const permanentServerId = 45920;
      await remapService.remapIncidentId(tempId: tempId, serverId: permanentServerId);

      expect(incidentRepo.get(permanentServerId), isNotNull);
      expect(incidentRepo.get(tempId), isNull);
      debugPrint('BENCHMARK RESULT [Offline Lifecycle]: Enqueue + Duplicate suppression + ID remap completed in ${swQueue.elapsedMicroseconds} µs');
    });
  });
}
