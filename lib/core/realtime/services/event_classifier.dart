import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/realtime/models/realtime_event_model.dart';

class EventClassifier {
  /// Classifies a freshly created incident event
  static IncidentRealTimeEvent classifyCreated(CurrentIncidentModel incident) {
    final severity = incident.currentIncidentSeverity ?? 1;
    final priority = _priorityFromSeverity(severity);
    final sevText = getSeverityArabic(severity);
    final title = incident.currentIncidentTypeName ??
        incident.currentIncidentDescription ??
        'أزمة جديدة';

    return IncidentRealTimeEvent(
      id: 'created_${incident.currentIncidentId}_${incident.currentIncidentCreatedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
      eventType: IncidentEventType.created,
      priority: priority,
      incidentId: incident.currentIncidentId,
      incidentTitle: title,
      branchName: incident.branchName,
      description: 'تم تسجيل أزمة جديدة ($sevText): $title',
      timestamp: incident.currentIncidentCreatedAt ?? DateTime.now(),
      actorName: incident.username ?? incident.managerName,
      newSeverity: severity,
      newStatus: incident.currentIncidentStatus ?? 1,
    );
  }

  /// Classifies an incident update by comparing existing state with incoming update
  static IncidentRealTimeEvent? classifyUpdated(
    CurrentIncidentModel oldIncident,
    CurrentIncidentModel newIncident,
  ) {
    final oldSev = oldIncident.currentIncidentSeverity;
    final newSev = newIncident.currentIncidentSeverity;
    final oldStat = oldIncident.currentIncidentStatus;
    final newStat = newIncident.currentIncidentStatus;

    final incidentId = newIncident.currentIncidentId ?? oldIncident.currentIncidentId;
    final title = newIncident.currentIncidentTypeName ??
        newIncident.currentIncidentDescription ??
        oldIncident.currentIncidentTypeName ??
        'أزمة #$incidentId';
    final branch = newIncident.branchName ?? oldIncident.branchName;
    final actor = newIncident.severityUpdatedByUserName ??
        newIncident.statusUpdatedByUserName ??
        newIncident.username ??
        newIncident.managerName;
    final now = DateTime.now();

    // 1. Severity changed
    if (newSev != null && oldSev != null && newSev != oldSev) {
      if (newSev > oldSev) {
        final priority = newSev == 4
            ? AlertPriority.critical
            : (newSev == 3 ? AlertPriority.high : AlertPriority.medium);
        return IncidentRealTimeEvent(
          id: 'sev_inc_${incidentId}_${newSev}_${now.millisecondsSinceEpoch}',
          eventType: IncidentEventType.severityIncreased,
          priority: priority,
          incidentId: incidentId,
          incidentTitle: title,
          branchName: branch,
          description:
              'تم رفع درجة الخطورة من ${getSeverityArabic(oldSev)} إلى ${getSeverityArabic(newSev)}',
          timestamp: newIncident.currentIncidentSeverityUpdateAt ?? now,
          actorName: actor,
          oldSeverity: oldSev,
          newSeverity: newSev,
          oldStatus: oldStat,
          newStatus: newStat,
        );
      } else {
        return IncidentRealTimeEvent(
          id: 'sev_dec_${incidentId}_${newSev}_${now.millisecondsSinceEpoch}',
          eventType: IncidentEventType.severityDecreased,
          priority: AlertPriority.low,
          incidentId: incidentId,
          incidentTitle: title,
          branchName: branch,
          description:
              'تم خفض درجة الخطورة من ${getSeverityArabic(oldSev)} إلى ${getSeverityArabic(newSev)}',
          timestamp: newIncident.currentIncidentSeverityUpdateAt ?? now,
          actorName: actor,
          oldSeverity: oldSev,
          newSeverity: newSev,
          oldStatus: oldStat,
          newStatus: newStat,
        );
      }
    }

    // 2. Status changed
    if (newStat != null && oldStat != null && newStat != oldStat) {
      if (newStat == 6) {
        // Resolved / Closed
        return IncidentRealTimeEvent(
          id: 'status_resolved_${incidentId}_${now.millisecondsSinceEpoch}',
          eventType: IncidentEventType.resolved,
          priority: AlertPriority.medium,
          incidentId: incidentId,
          incidentTitle: title,
          branchName: branch,
          description: 'تم حل الأزمة وإغلاقها بنجاح',
          timestamp: newIncident.currentIncidentStatusUpdatedAt ?? now,
          actorName: actor,
          oldStatus: oldStat,
          newStatus: newStat,
          newSeverity: newSev,
        );
      } else if (newStat == 7) {
        // Rejected / Cancelled
        return IncidentRealTimeEvent(
          id: 'status_rejected_${incidentId}_${now.millisecondsSinceEpoch}',
          eventType: IncidentEventType.rejected,
          priority: AlertPriority.high,
          incidentId: incidentId,
          incidentTitle: title,
          branchName: branch,
          description: 'تم رفض البلاغ وتغيير حالته إلى: تم الرفض',
          timestamp: newIncident.currentIncidentStatusUpdatedAt ?? now,
          actorName: actor,
          oldStatus: oldStat,
          newStatus: newStat,
          newSeverity: newSev,
        );
      } else {
        return IncidentRealTimeEvent(
          id: 'status_changed_${incidentId}_${newStat}_${now.millisecondsSinceEpoch}',
          eventType: IncidentEventType.statusChanged,
          priority: AlertPriority.medium,
          incidentId: incidentId,
          incidentTitle: title,
          branchName: branch,
          description: 'تغيرت حالة الأزمة إلى: ${getStatusArabic(newStat)}',
          timestamp: newIncident.currentIncidentStatusUpdatedAt ?? now,
          actorName: actor,
          oldStatus: oldStat,
          newStatus: newStat,
          newSeverity: newSev,
        );
      }
    }

    // 3. Missions assigned (missions list grew)
    final oldMissionsCount = oldIncident.currentIncidentWithMissions?.length ?? 0;
    final newMissionsCount = newIncident.currentIncidentWithMissions?.length ?? 0;
    if (newMissionsCount > oldMissionsCount) {
      return IncidentRealTimeEvent(
        id: 'mission_assign_${incidentId}_${newMissionsCount}_${now.millisecondsSinceEpoch}',
        eventType: IncidentEventType.missionAssigned,
        priority: AlertPriority.medium,
        incidentId: incidentId,
        incidentTitle: title,
        branchName: branch,
        description: 'تم إسناد مهام جديدة للأزمة (إجمالي $newMissionsCount مهمة)',
        timestamp: now,
        actorName: actor,
        newSeverity: newSev,
        newStatus: newStat,
      );
    }

    // 4. Meaningful operational update (location, description, manager)
    final descChanged = oldIncident.currentIncidentDescription != newIncident.currentIncidentDescription;
    final notesChanged = oldIncident.currentIncidentNotes != newIncident.currentIncidentNotes;
    final managerChanged = oldIncident.managerId != newIncident.managerId;
    final locationChanged = oldIncident.currentIncidentXAxis != newIncident.currentIncidentXAxis ||
        oldIncident.currentIncidentYAxis != newIncident.currentIncidentYAxis;

    if (descChanged || notesChanged || managerChanged || locationChanged) {
      return IncidentRealTimeEvent(
        id: 'general_upd_${incidentId}_${now.millisecondsSinceEpoch}',
        eventType: IncidentEventType.updated,
        priority: AlertPriority.low,
        incidentId: incidentId,
        incidentTitle: title,
        branchName: branch,
        description: locationChanged
            ? 'تم تحديث الإحداثيات الجغرافية لموقع الأزمة'
            : (managerChanged
                ? 'تم تعيين مسؤول جديد لإدارة الأزمة: ${newIncident.managerName ?? ""}'
                : 'تم تحديث البيانات والملحوظات الخاصة بالأزمة'),
        timestamp: now,
        actorName: actor,
        newSeverity: newSev,
        newStatus: newStat,
      );
    }

    return null;
  }

  /// Classifies a mission status update
  static IncidentRealTimeEvent classifyMissionStatus({
    required int incidentId,
    required String missionName,
    required int newStatus,
    int? oldStatus,
    String? branchName,
    String? actorName,
  }) {
    final now = DateTime.now();
    final statusText = getStatusArabic(newStatus);
    final isDone = newStatus == 6;

    return IncidentRealTimeEvent(
      id: 'mission_stat_${incidentId}_${newStatus}_${now.millisecondsSinceEpoch}',
      eventType: IncidentEventType.missionStatusChanged,
      priority: isDone ? AlertPriority.medium : AlertPriority.medium,
      incidentId: incidentId,
      incidentTitle: missionName,
      branchName: branchName,
      missionName: missionName,
      description: isDone
          ? 'تم اكتمال المهمة بنجاح: $missionName'
          : 'تحديث حالة المهمة ($missionName) إلى: $statusText',
      timestamp: now,
      actorName: actorName,
      oldStatus: oldStatus,
      newStatus: newStatus,
    );
  }

  /// Classifies an incident deletion
  static IncidentRealTimeEvent classifyDeleted(int incidentId) {
    return IncidentRealTimeEvent(
      id: 'deleted_${incidentId}_${DateTime.now().millisecondsSinceEpoch}',
      eventType: IncidentEventType.deleted,
      priority: AlertPriority.medium,
      incidentId: incidentId,
      incidentTitle: 'أزمة #$incidentId',
      description: 'تم حذف البلاغ رقم #$incidentId من المنظومة',
      timestamp: DateTime.now(),
    );
  }

  static AlertPriority _priorityFromSeverity(int severity) {
    switch (severity) {
      case 4:
        return AlertPriority.critical;
      case 3:
        return AlertPriority.high;
      case 2:
      case 1:
      default:
        return AlertPriority.medium;
    }
  }
}
