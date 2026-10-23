import 'package:equatable/equatable.dart';

enum IncidentEventType {
  created,
  severityIncreased,
  severityDecreased,
  statusChanged,
  missionAssigned,
  missionStatusChanged,
  resolved,
  rejected,
  updated,
  deleted,
  connectionLost,
  reconnected,
}

enum AlertPriority {
  low,
  medium,
  high,
  critical,
}

class IncidentRealTimeEvent extends Equatable {
  final String id;
  final IncidentEventType eventType;
  final AlertPriority priority;
  final int? incidentId;
  final String incidentTitle;
  final String? branchName;
  final String description;
  final DateTime timestamp;
  final String? actorName;
  final int? oldSeverity;
  final int? newSeverity;
  final int? oldStatus;
  final int? newStatus;
  final String? missionName;
  final bool isRead;

  const IncidentRealTimeEvent({
    required this.id,
    required this.eventType,
    required this.priority,
    this.incidentId,
    required this.incidentTitle,
    this.branchName,
    required this.description,
    required this.timestamp,
    this.actorName,
    this.oldSeverity,
    this.newSeverity,
    this.oldStatus,
    this.newStatus,
    this.missionName,
    this.isRead = false,
  });

  IncidentRealTimeEvent copyWith({
    String? id,
    IncidentEventType? eventType,
    AlertPriority? priority,
    int? incidentId,
    String? incidentTitle,
    String? branchName,
    String? description,
    DateTime? timestamp,
    String? actorName,
    int? oldSeverity,
    int? newSeverity,
    int? oldStatus,
    int? newStatus,
    String? missionName,
    bool? isRead,
  }) {
    return IncidentRealTimeEvent(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      priority: priority ?? this.priority,
      incidentId: incidentId ?? this.incidentId,
      incidentTitle: incidentTitle ?? this.incidentTitle,
      branchName: branchName ?? this.branchName,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      actorName: actorName ?? this.actorName,
      oldSeverity: oldSeverity ?? this.oldSeverity,
      newSeverity: newSeverity ?? this.newSeverity,
      oldStatus: oldStatus ?? this.oldStatus,
      newStatus: newStatus ?? this.newStatus,
      missionName: missionName ?? this.missionName,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventType': eventType.name,
        'priority': priority.name,
        'incidentId': incidentId,
        'incidentTitle': incidentTitle,
        'branchName': branchName,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'actorName': actorName,
        'oldSeverity': oldSeverity,
        'newSeverity': newSeverity,
        'oldStatus': oldStatus,
        'newStatus': newStatus,
        'missionName': missionName,
        'isRead': isRead,
      };

  factory IncidentRealTimeEvent.fromJson(Map<String, dynamic> json) {
    return IncidentRealTimeEvent(
      id: json['id'] as String,
      eventType: IncidentEventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => IncidentEventType.updated,
      ),
      priority: AlertPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => AlertPriority.low,
      ),
      incidentId: json['incidentId'] as int?,
      incidentTitle: json['incidentTitle'] as String? ?? 'أزمة',
      branchName: json['branchName'] as String?,
      description: json['description'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      actorName: json['actorName'] as String?,
      oldSeverity: json['oldSeverity'] as int?,
      newSeverity: json['newSeverity'] as int?,
      oldStatus: json['oldStatus'] as int?,
      newStatus: json['newStatus'] as int?,
      missionName: json['missionName'] as String?,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        eventType,
        priority,
        incidentId,
        incidentTitle,
        branchName,
        description,
        timestamp,
        actorName,
        oldSeverity,
        newSeverity,
        oldStatus,
        newStatus,
        missionName,
        isRead,
      ];
}
