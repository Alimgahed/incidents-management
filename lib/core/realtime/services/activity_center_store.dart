import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:incidents_managment/core/realtime/models/realtime_event_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityCenterStore {
  static const int maxRetentionCount = 50;
  static const String _storageKey = 'realtime_activity_history_v1';

  final List<IncidentRealTimeEvent> _activities = [];
  final _activityStreamController = StreamController<List<IncidentRealTimeEvent>>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();

  Stream<List<IncidentRealTimeEvent>> get activitiesStream => _activityStreamController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  List<IncidentRealTimeEvent> get activities => List.unmodifiable(_activities);
  int get unreadCount => _activities.where((a) => !a.isRead).length;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _activities.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _activities.add(IncidentRealTimeEvent.fromJson(item));
          }
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('ActivityCenterStore: error loading history: $e');
    }
    _notify();
  }

  Future<void> addActivity(IncidentRealTimeEvent event) async {
    // Check if event with same ID is already present
    final index = _activities.indexWhere((a) => a.id == event.id);
    if (index != -1) {
      _activities[index] = event;
    } else {
      _activities.insert(0, event);
    }

    // Enforce retention limit
    if (_activities.length > maxRetentionCount) {
      _activities.removeRange(maxRetentionCount, _activities.length);
    }

    _notify();
    await _persist();
  }

  Future<void> markAsRead(String eventId) async {
    final index = _activities.indexWhere((a) => a.id == eventId);
    if (index != -1 && !_activities[index].isRead) {
      _activities[index] = _activities[index].copyWith(isRead: true);
      _notify();
      await _persist();
    }
  }

  Future<void> markAllAsRead() async {
    var changed = false;
    for (var i = 0; i < _activities.length; i++) {
      if (!_activities[i].isRead) {
        _activities[i] = _activities[i].copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) {
      _notify();
      await _persist();
    }
  }

  Future<void> clearAll() async {
    _activities.clear();
    _notify();
    await _persist();
  }

  void _notify() {
    if (!_activityStreamController.isClosed) {
      _activityStreamController.add(List.unmodifiable(_activities));
    }
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(unreadCount);
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_activities.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      if (kDebugMode) debugPrint('ActivityCenterStore: error persisting: $e');
    }
  }

  void dispose() {
    _activityStreamController.close();
    _unreadCountController.close();
  }
}
