import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_picker_bridge.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/incident_details/mobile_incident_details_screen.dart';
import 'package:incidents_managment/core/realtime/models/realtime_event_model.dart';
import 'package:incidents_managment/core/realtime/services/activity_center_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealTimeAlertManager {
  final ActivityCenterStore activityStore;
  final AudioPlayer? _audioPlayer;

  final Map<String, DateTime> _dedupCache = {};
  final Map<String, DateTime> _localActionsCache = {};

  final List<IncidentRealTimeEvent> _activeAlerts = [];
  final List<IncidentRealTimeEvent> _pendingAlerts = [];

  final _activeAlertsController =
      StreamController<List<IncidentRealTimeEvent>>.broadcast();
  final _highlightController = StreamController<Set<int>>.broadcast();

  final Set<int> _highlightedIncidentIds = {};
  final Map<int, Timer> _highlightTimers = {};
  final Map<String, Timer> _alertTimers = {};

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  Stream<List<IncidentRealTimeEvent>> get activeAlertsStream =>
      _activeAlertsController.stream;
  List<IncidentRealTimeEvent> get activeAlerts =>
      List.unmodifiable(_activeAlerts);
  int get pendingAlertsCount => _pendingAlerts.length;

  Stream<Set<int>> get highlightedIncidentIdsStream =>
      _highlightController.stream;
  Set<int> get highlightedIncidentIds =>
      Set.unmodifiable(_highlightedIncidentIds);

  bool isIncidentHighlighted(int? id) =>
      id != null && _highlightedIncidentIds.contains(id);

  RealTimeAlertManager({
    required this.activityStore,
    AudioPlayer? audioPlayer,
    bool enableAudio = true,
  }) : _audioPlayer =
            enableAudio ? (audioPlayer ?? _createSafeAudioPlayer()) : null {
    _loadSoundSetting();
  }

  static AudioPlayer? _createSafeAudioPlayer() {
    try {
      return AudioPlayer();
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadSoundSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('realtime_sound_enabled') ?? true;
    } catch (_) {}
  }

  Future<void> toggleSound(bool enabled) async {
    _soundEnabled = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('realtime_sound_enabled', enabled);
    } catch (_) {}
  }

  /// Mark a locally originated action so echo events are not shown as intrusive alerts
  void recordLocalAction(String key) {
    _cleanOldEntries(_localActionsCache, const Duration(seconds: 10));
    _localActionsCache[key] = DateTime.now();
  }

  bool isLocalAction(String key, {int? incidentId}) {
    _cleanOldEntries(_localActionsCache, const Duration(seconds: 10));
    if (_localActionsCache.containsKey(key)) return true;
    if (incidentId != null && _localActionsCache.containsKey('incident_$incidentId')) return true;
    return false;
  }

  /// Handles incoming real-time event through the standardized processing pipeline
  Future<void> processEvent(
    IncidentRealTimeEvent event, {
    bool isLocallyOriginated = false,
  }) async {
    // 1. Deduplication check
    _cleanOldEntries(_dedupCache, const Duration(seconds: 12));
    final dedupKey =
        '${event.eventType.name}_${event.incidentId}_${event.newSeverity}_${event.newStatus}_${event.missionName}';

    if (_dedupCache.containsKey(dedupKey)) {
      if (kDebugMode) debugPrint('RealTimeAlertManager: discarded duplicate $dedupKey');
      return;
    }
    _dedupCache[dedupKey] = DateTime.now();

    // 2. Always persist to Activity Center
    await activityStore.addActivity(event);

    // 3. Highlight affected incident card
    if (event.incidentId != null) {
      _triggerIncidentHighlight(event.incidentId!);
    }

    // 4. If locally originated, don't show an intrusive alert popup to the acting user
    if (isLocallyOriginated || isLocalAction(dedupKey, incidentId: event.incidentId)) {
      return;
    }

    // 5. Enqueue Global Live Alert
    _enqueueAlert(event);

    // 6. Play appropriate sound if priority requires it and sound is enabled
    _maybePlayAlertSound(event.priority);
  }

  void _triggerIncidentHighlight(int incidentId) {
    _highlightTimers[incidentId]?.cancel();
    _highlightedIncidentIds.add(incidentId);
    _highlightController.add(Set.unmodifiable(_highlightedIncidentIds));

    // Highlight expires automatically after 3 seconds
    _highlightTimers[incidentId] = Timer(const Duration(seconds: 3), () {
      _highlightedIncidentIds.remove(incidentId);
      _highlightTimers.remove(incidentId);
      if (!_highlightController.isClosed) {
        _highlightController.add(Set.unmodifiable(_highlightedIncidentIds));
      }
    });
  }

  void _enqueueAlert(IncidentRealTimeEvent event) {
    // Keep max 2 alerts visible simultaneously to prevent screen flooding
    if (_activeAlerts.length < 2) {
      _activeAlerts.add(event);
      _scheduleAlertDismissal(event);
      _activeAlertsController.add(List.unmodifiable(_activeAlerts));
    } else {
      _pendingAlerts.add(event);
    }
  }

  void _scheduleAlertDismissal(IncidentRealTimeEvent event) {
    _alertTimers[event.id]?.cancel();

    // Critical alerts stay visible for 15 seconds; others stay 7 seconds
    final durationSeconds = event.priority == AlertPriority.critical
        ? 15
        : (event.priority == AlertPriority.high ? 8 : 6);

    _alertTimers[event.id] = Timer(Duration(seconds: durationSeconds), () {
      dismissAlert(event.id);
    });
  }

  void dismissAlert(String eventId) {
    _alertTimers[eventId]?.cancel();
    _alertTimers.remove(eventId);

    final index = _activeAlerts.indexWhere((a) => a.id == eventId);
    if (index != -1) {
      _activeAlerts.removeAt(index);

      // Promote next pending alert from queue if available
      if (_pendingAlerts.isNotEmpty && _activeAlerts.length < 2) {
        final next = _pendingAlerts.removeAt(0);
        _activeAlerts.add(next);
        _scheduleAlertDismissal(next);
      }

      _activeAlertsController.add(List.unmodifiable(_activeAlerts));
    }
  }

  void dismissAllAlerts() {
    for (final timer in _alertTimers.values) {
      timer.cancel();
    }
    _alertTimers.clear();
    _activeAlerts.clear();
    _pendingAlerts.clear();
    _activeAlertsController.add(List.unmodifiable(_activeAlerts));
  }

  Future<void> _maybePlayAlertSound(AlertPriority priority) async {
    if (!_soundEnabled || _audioPlayer == null) return;

    // Only play sound for Critical and High priority alerts
    if (priority == AlertPriority.critical || priority == AlertPriority.high) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.setVolume(1.0);
        await _audioPlayer.play(AssetSource('sounds/alarm.ogg'));

        // Stop sound after 2.5 seconds to avoid disruptive noise
        Timer(const Duration(milliseconds: 2500), () async {
          try {
            await _audioPlayer.stop();
          } catch (_) {}
        });
      } catch (e) {
        if (kDebugMode) debugPrint('RealTimeAlertManager: sound playback error: $e');
      }
    }
  }

  void _cleanOldEntries(Map<String, DateTime> map, Duration ttl) {
    final now = DateTime.now();
    map.removeWhere((_, time) => now.difference(time) > ttl);
  }

  /// Global navigation handler to open incident details across mobile and web
  void navigateToIncidentDetails(BuildContext context, int incidentId) {
    final incidentMapCubit = getIt.isRegistered<IncidentMapCubit>()
        ? getIt<IncidentMapCubit>()
        : null;

    final incidents = incidentMapCubit?.incidents ?? [];
    final incident = incidents.cast<CurrentIncidentModel?>().firstWhere(
          (i) => i?.currentIncidentId == incidentId,
          orElse: () => null,
        );

    final isMobile = MediaQuery.sizeOf(context).width < 600;

    if (isMobile) {
      if (incident != null) {
        final DashboardCubit dashboardCubit = () {
          try {
            return context.read<DashboardCubit>();
          } catch (_) {
            return DashboardCubit();
          }
        }();

        dashboardCubit.selectIncident(incident);
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: dashboardCubit),
                if (incidentMapCubit != null)
                  BlocProvider.value(value: incidentMapCubit),
              ],
              child: MobileIncidentDetailsScreen(
                incidentId: incidentId,
                initialIncident: incident,
              ),
            ),
          ),
        );
      }
    } else {
      // On Web: use IncidentPickerBridge to open details seamlessly
      if (incident != null && getIt.isRegistered<IncidentPickerBridge>()) {
        getIt<IncidentPickerBridge>().requestSelect(incident);
      } else if (getIt.isRegistered<IncidentPickerBridge>()) {
        getIt<IncidentPickerBridge>().requestSelectById(incidentId.toString());
      }
    }
  }

  void dispose() {
    dismissAllAlerts();
    for (final timer in _highlightTimers.values) {
      timer.cancel();
    }
    _highlightTimers.clear();
    _activeAlertsController.close();
    _highlightController.close();
    try {
      _audioPlayer?.dispose();
    } catch (_) {}
  }
}
