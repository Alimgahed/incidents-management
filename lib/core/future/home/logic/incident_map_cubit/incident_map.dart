import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:audioplayers/audioplayers.dart';

import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/security/secure_storage_service.dart';
import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';
import 'package:incidents_managment/core/offline/data/models/cached_incident.dart';
import 'package:incidents_managment/core/offline/data/repositories/incident_cache_repository.dart';
import 'package:incidents_managment/core/offline/network/network_monitor.dart';
import 'package:incidents_managment/core/realtime/services/event_classifier.dart';
import 'package:incidents_managment/core/realtime/services/realtime_alert_manager.dart';

// ---------------------------------------------------------------------------
// Top-level isolate helpers (must live outside the class for compute())
// ---------------------------------------------------------------------------

/// Parses a raw socket snapshot list into typed models on a background isolate.
/// Using [List.generate] pre-allocates the backing array to the exact capacity
/// needed, avoiding repeated reallocation that a growable list would incur.
List<CurrentIncidentModel> _parseIncidentList(List<dynamic> data) {
  final list = <CurrentIncidentModel>[];
  for (final row in data) {
    if (row is! Map) continue;
    try {
      list.add(CurrentIncidentModel.fromJson(Map<String, dynamic>.from(row)));
    } catch (_) {
      // Keep other valid rows when one socket payload is malformed.
    }
  }
  list.sort((a, b) {
    final aTime = a.currentIncidentCreatedAt;
    final bTime = b.currentIncidentCreatedAt;
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  });
  return list;
}

class IncidentMapCubit extends Cubit<IncidentMapState> {
  io.Socket? _socket;

  List<CurrentIncidentModel> incidentss = [];

  DateTime? _lastIncidentPayloadAt;

  Timer? _reconnectTimer;
  Timer? _alertTimer;

  int _reconnectAttempts = 0;
  Timer? _heartbeatTimer;
  StreamSubscription<bool>? _networkSub;

  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void>? _initializeFuture;

  // ================= ALERT STATE =================

  // 🔊 SAME SOUND USED IN DASHBOARD CONTROLLER
  static const String alertSoundUrl =
      'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg';
  IncidentMapCubit() : super(IncidentMapInitial()) {
    _listenToNetworkChanges();
  }

  void _listenToNetworkChanges() {
    try {
      if (getIt.isRegistered<NetworkMonitorService>()) {
        final monitor = getIt<NetworkMonitorService>();
        monitor.addReconnectListener(() {
          if (kDebugMode) debugPrint('IncidentMap: Network restored, re-verifying socket connection');
          reconnectIfDisconnected();
        });
      }
    } catch (_) {}
  }

  void _bumpPayloadTime() {
    _lastIncidentPayloadAt = DateTime.now();
  }

  // ===========================================================================
  // SOCKET INITIALIZATION & CACHE PRELOADING
  // ===========================================================================
  Future<void> initialize() {
    if (_socket?.connected == true) return Future<void>.value();
    final running = _initializeFuture;
    if (running != null) return running;
    final future = _initialize();
    _initializeFuture = future;
    return future.whenComplete(() => _initializeFuture = null);
  }

  /// Public method to safely reconnect whenever the app returns from background
  /// or when the network recovers.
  void reconnectIfDisconnected() {
    if (isClosed) return;
    if (_socket == null || _socket?.connected != true) {
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      if (_socket == null) {
        initialize();
      } else {
        _socket?.connect();
      }
    }
  }

  Future<void> _loadFromCache() async {
    try {
      if (!getIt.isRegistered<IncidentCacheRepository>()) return;
      final cacheRepo = getIt<IncidentCacheRepository>();
      final cachedList = cacheRepo.list(limit: 500);
      if (cachedList.isEmpty) return;

      final loaded = <CurrentIncidentModel>[];
      for (final item in cachedList) {
        try {
          loaded.add(CurrentIncidentModel.fromJson(item.toMap()));
        } catch (_) {}
      }
      if (loaded.isNotEmpty && incidentss.isEmpty && !isClosed) {
        incidentss = loaded;
        _bumpPayloadTime();
        getIt<IncidentPickerBridge>().resolvePending(incidentss);
        emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
      }
    } catch (e) {
      if (kDebugMode) debugPrint('IncidentMap: cache load failed: $e');
    }
  }

  void _saveSnapshotToCache(List<CurrentIncidentModel> list) {
    try {
      if (!getIt.isRegistered<IncidentCacheRepository>()) return;
      final cacheRepo = getIt<IncidentCacheRepository>();
      final cachedItems = list
          .where((i) => i.currentIncidentId != null)
          .map((i) => CachedIncident.fromMap(
                i.toJson(),
                idOrTempId: i.currentIncidentId!,
              ))
          .toList();
      unawaited(cacheRepo.upsertAll(cachedItems));
    } catch (_) {}
  }

  Future<void> _initialize() async {
    try {
      // 0. Pre-load cached incidents from Hive immediately so the UI is responsive offline
      await _loadFromCache();

      // 1. Get token from storage securely
      final token = await getIt<SecureStorageService>().getUserToken();
      if (isClosed) return;

      // 2. ONLY connect if token exists
      if (token == null || token.trim().isEmpty) {
        return;
      }

      _socket?.dispose();
      _socket = null;

      // As requested, hardcode the external URL for the websocket in all cases
      final String socketUrl = 'https://crises.miniawater.com';
      final String socketPath = '/api/socket.io';

      if (kDebugMode) debugPrint('Initializing Socket.IO transport');

      // 4. Configure socket with auth and correct path
      // IMPORTANT: Transports configuration is an intentional, permanent decision.
      // Do NOT change mobile back to ['websocket']. The IIS/ARR reverse proxy on our backend
      // has a known frame-corruption bug with native WebSocket clients. It sends a correct 101
      // Switching Protocols but wraps the subsequent WebSocket frames in Transfer-Encoding: chunked,
      // which corrupts them for strict clients like Dart's web_socket_channel. Browsers tolerate this,
      // which is why kIsWeb can use ['polling', 'websocket'].
      final opts = io.OptionBuilder()
          .setTransports(kIsWeb ? ['polling', 'websocket'] : ['polling'])
          .setPath(socketPath)
          .enableReconnection() // Let socket.io client continuously auto-reconnect
          .setReconnectionAttempts(999999) // Infinite reconnection attempts
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .disableAutoConnect() // Don't connect until listeners are ready
          .disableMultiplex() // Force new connection, bypasses dead cache
          .setAuth({'token': token}) // Pass token in auth object
          .setExtraHeaders({
            'Authorization': 'Bearer $token',
          }) // And in headers just in case
          .build();

      // Only disable upgrade on native mobile clients due to IIS/ARR chunked transfer bug.
      // On Web, browsers handle WebSocket upgrade natively.
      if (!kIsWeb) {
        opts['upgrade'] = false;
      }
      opts['forceNew'] =
          true; // CRITICAL: Prevent reusing old authenticated connection

      if (kDebugMode) {
        debugPrint('Socket.IO transport configured');
      }

      _socket = io.io(socketUrl, opts);

      _socket?.onAny((event, _) {
        if (kDebugMode) debugPrint('Socket.IO event received: $event');
      });

      _socket?.on('connect_error', (_) {
        if (kDebugMode) {
          debugPrint('Socket.IO connection error (details redacted)');
        }
      });

      _socket?.on('error', (_) {
        if (kDebugMode) debugPrint('Socket.IO error (details redacted)');
      });

      // 3. Attach listeners BEFORE connecting to avoid race condition
      _setupSocketListeners();

      // 4. Start heartbeat timer to detect and resurrect silent dead connections
      _startHeartbeatTimer();

      // 5. Now connect manually
      _socket?.connect();
    } catch (e) {
      emit(IncidentMapError(message: 'فشل في إنشاء اتصال Socket.IO'));
    }
  }

  void _startHeartbeatTimer() {
    _heartbeatTimer?.cancel();
    // Every 25 seconds, verify if socket is connected. If not, trigger reconnect
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (isClosed) return;
      if (_socket != null && _socket?.connected != true) {
        if (kDebugMode) debugPrint('IncidentMap: Heartbeat detected disconnected socket, attempting reconnect');
        _socket?.connect();
      }
    });
  }

  void _setupSocketListeners() {
    _socket?.onConnect((_) {
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _socket?.emit('get_incidents');
    });

    _socket?.onDisconnect((_) => _attemptReconnect());

    _socket?.onConnectError((_) {
      _attemptReconnect();
    });

    _socket?.onError((_) {
      if (kDebugMode) debugPrint('IncidentMap: Socket error received');
    });

    _socket?.on('incident_snapshot', _handleIncidentSnapshot);
    _socket?.on('incident_created', _handleIncidentCreated);
    _socket?.on('incident_updated', _handleIncidentUpdated);
    _socket?.on('incident_deleted', _handleIncidentDeleted);

    _socket?.on('mission_updated', _handleMissionStatusUpdated);
    _socket?.on('mission_update_error', _handleMissionUpdateError);
  }

  // ===========================================================================
  // RECONNECTION LOGIC
  // ===========================================================================
  void _attemptReconnect() {
    _reconnectTimer?.cancel();
    // Exponential backoff: 2s, 4s, 6s... capped at 15s max
    _reconnectAttempts++;
    final delaySeconds = (_reconnectAttempts * 2).clamp(2, 15);
    _reconnectTimer = Timer(Duration(seconds: delaySeconds), () {
      if (isClosed) return;
      if (_socket?.connected != true) {
        _socket?.connect();
      }
    });
  }

  // ===========================================================================
  // 🔊 ALERT SOUND (WEB – SAME AS DASHBOARD, 7 SECONDS)
  // ===========================================================================
  // void _playAlertFor7Seconds() {
  //   if (_isAlertPlaying) return;

  //   try {
  //     _isAlertPlaying = true;

  //     _audio?.pause();
  //     _audio = html.AudioElement()
  //       ..src = alertSoundUrl
  //       ..volume = 1.0
  //       ..autoplay = true;

  //     // ⏱ Stop after 7 seconds
  //     _alertTimer?.cancel();
  //     _alertTimer = Timer(const Duration(seconds: 7), _stopAlert);
  //   } catch (_) {
  //     _stopAlert();
  //   }
  // }

  // void _stopAlert() {
  //   try {
  //     _audio?.pause();
  //     _audio?.currentTime = 0;
  //   } catch (_) {}

  //   _audio = null;
  //   _isAlertPlaying = false;
  // }

  // ===========================================================================
  // INCIDENT HANDLERS
  // ===========================================================================
  /// Parses the full incident snapshot off the main isolate via [compute] to
  /// avoid jank on large payloads. [List.generate] inside the helper
  /// pre-allocates the backing array to the exact capacity needed.
  Future<void> _handleIncidentSnapshot(dynamic data) async {
    if (isClosed) return;
    try {
      if (data is! List) {
        emit(IncidentMapError(message: 'تنسيق بيانات غير صحيح'));
        return;
      }

      if (kDebugMode) {
        debugPrint('IncidentMap: Received raw snapshot with ${data.length} items from server');
      }

      // Defensively copy to a plain List<dynamic> so it can be sent across
      // isolate boundaries safely (socket.io may return a non-growable view).
      incidentss = await compute(_parseIncidentList, List<dynamic>.from(data));
      if (isClosed) return;

      if (kDebugMode) {
        debugPrint('IncidentMap: Successfully parsed ${incidentss.length} incidents from snapshot');
      }
      getIt<IncidentPickerBridge>().resolvePending(incidentss);

      _bumpPayloadTime();
      _saveSnapshotToCache(incidentss);
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    } catch (e) {
      emit(IncidentMapError(message: 'خطأ في تحميل البيانات'));
    }
  }

  /// Recursively normalizes maps and lists to pure Dart `Map<String, dynamic>`
  /// preventing type-cast errors on Web (e.g. nested missions/photos).
  Map<String, dynamic> _deepNormalizeMap(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final map = <String, dynamic>{};
    raw.forEach((k, v) {
      final key = k.toString();
      if (v is Map) {
        map[key] = _deepNormalizeMap(v);
      } else if (v is List) {
        map[key] = v.map((item) {
          if (item is Map) return _deepNormalizeMap(item);
          return item;
        }).toList();
      } else {
        map[key] = v;
      }
    });
    return map;
  }

  CurrentIncidentModel _parseIncidentPayload(dynamic data) {
    if (data is CurrentIncidentModel) return data;
    dynamic payload = data;
    if (payload is String) {
      try {
        payload = jsonDecode(payload);
      } catch (_) {}
    }
    if (payload is Map) {
      if (payload.containsKey('incident') && payload['incident'] is Map) {
        payload = payload['incident'];
      } else if (payload.containsKey('data') &&
          payload['data'] is Map &&
          !payload.containsKey('current_incident_id')) {
        payload = payload['data'];
      }
      return CurrentIncidentModel.fromJson(_deepNormalizeMap(payload));
    }
    return CurrentIncidentModel.fromJson(payload as dynamic);
  }

  void _handleIncidentCreated(dynamic data) {
    try {
      if (kDebugMode) debugPrint('Socket.IO incident_created received: $data');
      final newIncident = _parseIncidentPayload(data);
      addIncident(newIncident);
      if (getIt.isRegistered<RealTimeAlertManager>()) {
        getIt<RealTimeAlertManager>().processEvent(
          EventClassifier.classifyCreated(newIncident),
        );
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('Error handling incident_created: $e\n$st');
      // If parsing fails, instantly refresh from server so incident is never lost
      refresh();
    }
  }

  /// Adds a new incident (or updates it if already present) directly to memory
  /// and emits [IncidentMapLoaded] with maximum performance (0ms delay).
  void addIncident(CurrentIncidentModel newIncident) {
    final updated = List<CurrentIncidentModel>.of(incidentss);

    final index = updated.indexWhere((i) {
      if (newIncident.currentIncidentId != null && i.currentIncidentId != null) {
        return i.currentIncidentId == newIncident.currentIncidentId;
      }
      return false;
    });

    if (index != -1) {
      updated[index] = newIncident;
    } else {
      updated.insert(0, newIncident);
    }

    updated.sort((a, b) {
      final aTime = a.currentIncidentCreatedAt;
      final bTime = b.currentIncidentCreatedAt;
      if (aTime == null && bTime == null) {
        final aId = a.currentIncidentId ?? 0;
        final bId = b.currentIncidentId ?? 0;
        return bId.compareTo(aId);
      }
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    incidentss = updated;
    _bumpPayloadTime();
    if (newIncident.currentIncidentId != null &&
        getIt.isRegistered<IncidentCacheRepository>()) {
      unawaited(getIt<IncidentCacheRepository>().upsert(
        CachedIncident.fromMap(
          newIncident.toJson(),
          idOrTempId: newIncident.currentIncidentId!,
        ),
      ));
    }
    emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
  }

  /// Immediately updates an incident's coordinates in memory and emits
  /// [IncidentMapLoaded], ensuring the map and marker re-center instantly.
  void updateIncidentLocation({
    required int incidentId,
    required double lat,
    required double lng,
  }) {
    final index = incidentss.indexWhere((i) => i.currentIncidentId == incidentId);
    if (index != -1) {
      final old = incidentss[index];
      final updatedIncident = old.copyWith(
        currentIncidentXAxis: lat,
        currentIncidentYAxis: lng,
      );
      final updated = List<CurrentIncidentModel>.of(incidentss);
      updated[index] = updatedIncident;
      incidentss = updated;
      _bumpPayloadTime();
      if (getIt.isRegistered<IncidentCacheRepository>()) {
        unawaited(getIt<IncidentCacheRepository>().upsert(
          CachedIncident.fromMap(
            updatedIncident.toJson(),
            idOrTempId: incidentId,
          ),
        ));
      }
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }



  void _handleIncidentUpdated(dynamic data) {
    try {
      if (kDebugMode) debugPrint('Socket.IO incident_updated received: $data');
      final updatedIncident = _parseIncidentPayload(data);

      final index = incidentss.indexWhere(
        (i) => i.currentIncidentId == updatedIncident.currentIncidentId,
      );

      if (index != -1) {
        final oldIncident = incidentss[index];
        final updated = List<CurrentIncidentModel>.of(incidentss);
        updated[index] = updatedIncident;
        incidentss = updated;
        _bumpPayloadTime();
        if (updatedIncident.currentIncidentId != null &&
            getIt.isRegistered<IncidentCacheRepository>()) {
          unawaited(getIt<IncidentCacheRepository>().upsert(
            CachedIncident.fromMap(
              updatedIncident.toJson(),
              idOrTempId: updatedIncident.currentIncidentId!,
            ),
          ));
        }
        if (getIt.isRegistered<RealTimeAlertManager>()) {
          final event =
              EventClassifier.classifyUpdated(oldIncident, updatedIncident);
          if (event != null) {
            getIt<RealTimeAlertManager>().processEvent(event);
          }
        }
        emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
      } else {
        addIncident(updatedIncident);
        if (getIt.isRegistered<RealTimeAlertManager>()) {
          getIt<RealTimeAlertManager>().processEvent(
            EventClassifier.classifyCreated(updatedIncident),
          );
        }
      }
    } catch (e, st) {
      if (kDebugMode) debugPrint('Error handling incident_updated: $e\n$st');
      refresh();
    }
  }

  void _handleIncidentDeleted(dynamic data) {
    final id = data is Map ? data['id'] : data;
    // where().toList() can't be pre-sized but growable:false signals to the
    // runtime that the resulting list won't be further mutated.
    incidentss = incidentss
        .where((i) => i.currentIncidentId != id)
        .toList(growable: false);

    _bumpPayloadTime();
    final delId = id is int ? id : int.tryParse('$id');
    if (delId != null && getIt.isRegistered<IncidentCacheRepository>()) {
      unawaited(getIt<IncidentCacheRepository>().remove(delId));
    }
    if (delId != null && getIt.isRegistered<RealTimeAlertManager>()) {
      getIt<RealTimeAlertManager>().processEvent(
        EventClassifier.classifyDeleted(delId),
      );
    }
    emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
  }

  // ===========================================================================
  // MISSION STATUS HANDLERS

  void _handleMissionStatusUpdated(dynamic data) {
    try {
      if (data is! Map) return;

      final incidentId = data['current_incident_id'] as int?;
      // The server might send the primary key as 'id' or 'mission_id'
      final pkId = data['id'] as int? ?? data['mission_id'] as int?;
      // And the foreign key (mission type) as 'current_incident_mission_id'
      final legacyId = data['current_incident_mission_id'] as int?;
      final newStatus = data['current_incident_mission_status'] as int?;
      // Order can help disambiguate when multiple missions share the same FK
      final order = data['current_incident_mission_order'] as int?;

      if (incidentId == null || newStatus == null) return;
      if (pkId == null && legacyId == null) return;

      // البحث عن الأزمة
      final incidentIndex = incidentss.indexWhere(
        (i) => i.currentIncidentId == incidentId,
      );
      if (incidentIndex == -1) {
        refresh();
        return;
      }

      final incident = incidentss[incidentIndex];
      final missions = List<CurrentIncidentWithMissions>.from(
        incident.currentIncidentWithMissions ?? const [],
      );

      var missionIndex = -1;

      // 1. Try matching by exact Primary Key (idCurrentIncidentMission)
      if (pkId != null) {
        missionIndex = missions.indexWhere(
          (m) => m.idCurrentIncidentMission == pkId,
        );
      }

      // 2. If not found, try legacyId as a PK (backend might put PK in this field)
      if (missionIndex == -1 && legacyId != null) {
        missionIndex = missions.indexWhere(
          (m) => m.idCurrentIncidentMission == legacyId,
        );
      }

      // 3. If still not found, try matching by FK (mission type) + order for disambiguation
      if (missionIndex == -1 && legacyId != null) {
        final fkMatches = <int>[];
        for (var i = 0; i < missions.length; i++) {
          if (missions[i].currentIncidentMissionId == legacyId) {
            fkMatches.add(i);
          }
        }

        if (fkMatches.length == 1) {
          // Only one mission with this FK — safe to update
          missionIndex = fkMatches.first;
        } else if (fkMatches.length > 1 && order != null) {
          // Multiple missions share this FK — use order to disambiguate
          final orderMatch = fkMatches.where(
            (i) => missions[i].currentIncidentMissionOrder == order,
          );
          if (orderMatch.length == 1) {
            missionIndex = orderMatch.first;
          } else {
            // Can't disambiguate — refresh from server for accurate data
            refresh();
            return;
          }
        } else if (fkMatches.length > 1) {
          // Multiple missions share this FK and no order to disambiguate
          // — refresh from server for accurate data
          refresh();
          return;
        }
      }

      final updatedByUserName = data['status_updated_by_user'] as String? ??
          data['updated_by_user'] as String? ??
          data['username'] as String?;

      if (missionIndex != -1) {
        final mission = missions[missionIndex];
        // Preserve ALL existing fields and update status + updated_at + statusUpdatedByUser.
        final updatedMission = CurrentIncidentWithMissions(
          idCurrentIncidentMission: mission.idCurrentIncidentMission,
          currentIncidentId: mission.currentIncidentId,
          currentIncidentMissionId: mission.currentIncidentMissionId,
          currentIncidentMissionOrder: mission.currentIncidentMissionOrder,
          currentIncidentMissionStatus: newStatus,
          currentIncidentMissionStatusUpdatedBy:
              mission.currentIncidentMissionStatusUpdatedBy,
          currentIncidentMissionStatusUpdatedAt: DateTime.now(),
          missionName: mission.missionName,
          assignedEmployees: mission.assignedEmployees,
          statusUpdatedByUser: updatedByUserName ?? mission.statusUpdatedByUser,
        );

        missions[missionIndex] = updatedMission;

        if (getIt.isRegistered<RealTimeAlertManager>()) {
          getIt<RealTimeAlertManager>().processEvent(
            EventClassifier.classifyMissionStatus(
              incidentId: incidentId,
              missionName: mission.missionName ??
                  'مهمة #${mission.currentIncidentMissionId}',
              newStatus: newStatus,
              oldStatus: mission.currentIncidentMissionStatus,
              branchName: incident.branchName,
              actorName: updatedByUserName ?? mission.statusUpdatedByUser,
            ),
          );
        }
      } else {
        // Mission not found locally — ask server for a fresh snapshot.
        refresh();
        return;
      }

      // تحديث الـ incident في القائمة
      final updatedIncident = incident.copyWith(
        currentIncidentWithMissions: missions,
      );

      final updated = List<CurrentIncidentModel>.of(incidentss);
      updated[incidentIndex] = updatedIncident;
      incidentss = updated;

      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    } catch (e) {
      emit(IncidentMapError(message: 'فشل تحديث حالة المهمة'));
    }
  }

  // ===========================================================================
  // OPTIMISTIC OFFLINE UPDATE INCIDENT
  // ===========================================================================
  void optimisticUpdateIncident({
    required int incidentId,
    required int newStatus,
    required int newSeverity,
  }) {
    if (getIt.isRegistered<RealTimeAlertManager>()) {
      getIt<RealTimeAlertManager>().recordLocalAction('incident_$incidentId');
    }
    final index = incidentss.indexWhere(
      (i) => i.currentIncidentId == incidentId,
    );
    if (index != -1) {
      final updatedIncident = incidentss[index].copyWith(
        currentIncidentStatus: newStatus,
        currentIncidentSeverity: newSeverity,
      );

      final updated = List<CurrentIncidentModel>.of(incidentss);
      updated[index] = updatedIncident;
      incidentss = updated;
      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }

  // ===========================================================================
  // OPTIMISTIC OFFLINE UPDATE MISSION
  // ===========================================================================
  void optimisticUpdateMission({
    required int incidentId,
    required int missionId,
    required int newStatus,
    String? updatedByUserName,
  }) {
    if (getIt.isRegistered<RealTimeAlertManager>()) {
      getIt<RealTimeAlertManager>().recordLocalAction('incident_$incidentId');
    }
    // Calls the same logic the socket uses, so the UI updates immediately
    // even if we are offline and haven't received a socket broadcast.
    _handleMissionStatusUpdated({
      'current_incident_id': incidentId,
      'id': missionId,
      'current_incident_mission_status': newStatus,
      ...? (updatedByUserName != null ? {'status_updated_by_user': updatedByUserName} : null),
    });
  }

  void _handleMissionUpdateError(dynamic data) {
    final msg = data is Map ? data['message'] ?? 'فشل تحديث المهمة' : 'خطأ';
    emit(IncidentMapError(message: msg));

    if (incidentss.isNotEmpty) {
      _bumpPayloadTime();
      emit(IncidentMapLoaded(incidents: List.unmodifiable(incidentss)));
    }
  }

  // ===========================================================================
  // UPDATE MISSION STATUS
  // ===========================================================================
  void updateMissionStatus({
    required int incidentId,
    required int missionId,
    required int newStatus,
  }) {
    if (!(_socket?.connected ?? false)) {
      emit(IncidentMapError(message: 'لا يوجد اتصال بالخادم'));
      return;
    }

    _socket?.emit('update_mission_status', {
      'incident_id': incidentId,
      'mission_id': missionId,
      'new_status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ===========================================================================
  // MANUAL REFRESH
  // ===========================================================================
  Future<void> refresh() async {
    // Only emit loading if we don't have incidents yet, preserving UI responsiveness
    if (incidentss.isEmpty) {
      emit(IncidentMapLoading());
    }

    if (_socket?.connected == true) {
      _socket?.emit('get_incidents');
    } else {
      await initialize();
      if (_socket?.connected == true) {
        _socket?.emit('get_incidents');
      } else {
        // Wait for connect event to fire and emit get_incidents
        _socket?.once('connect', (_) {
          _socket?.emit('get_incidents');
        });
        _socket?.connect();
      }
    }

    try {
      await stream
          .firstWhere((s) => s is IncidentMapLoaded || s is IncidentMapError)
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Timeout or stream closed, return gracefully
    }
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================
  List<CurrentIncidentModel> get incidents => List.unmodifiable(incidentss);

  bool get isConnected => _socket?.connected ?? false;

  DateTime? get lastIncidentPayloadAt => _lastIncidentPayloadAt;

  /// Get a specific incident by ID from the current list
  CurrentIncidentModel? getIncidentById(int incidentId) {
    try {
      return incidentss.firstWhere((i) => i.currentIncidentId == incidentId);
    } catch (_) {
      return null;
    }
  }

  // ===========================================================================
  // CLEANUP & LIFECYCLE DISCONNECT
  // ===========================================================================
  void disconnectSocket() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _alertTimer?.cancel();
    _networkSub?.cancel();
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    incidentss.clear();
    _lastIncidentPayloadAt = null;
    emit(IncidentMapInitial());
  }

  @override
  Future<void> close() {
    disconnectSocket();
    _audioPlayer.dispose();
    return super.close();
  }
}
