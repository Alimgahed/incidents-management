import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/realtime/models/realtime_event_model.dart';
import 'package:incidents_managment/core/realtime/services/activity_center_store.dart';
import 'package:incidents_managment/core/realtime/services/realtime_alert_manager.dart';

Future<void> showLiveActivityCenter(BuildContext context) async {
  final isMobile = MediaQuery.sizeOf(context).width < 700;

  if (isMobile) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LiveActivityCenterSheet(),
    );
  } else {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
          child: const LiveActivityCenterSheet(isDialog: true),
        ),
      ),
    );
  }
}

class LiveActivityCenterSheet extends StatefulWidget {
  final bool isDialog;

  const LiveActivityCenterSheet({super.key, this.isDialog = false});

  @override
  State<LiveActivityCenterSheet> createState() =>
      _LiveActivityCenterSheetState();
}

class _LiveActivityCenterSheetState extends State<LiveActivityCenterSheet> {
  late final ActivityCenterStore _store;
  late final RealTimeAlertManager _alertManager;

  @override
  void initState() {
    super.initState();
    _store = getIt<ActivityCenterStore>();
    _alertManager = getIt<RealTimeAlertManager>();
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 45) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: widget.isDialog ? null : height * 0.82,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: widget.isDialog
              ? BorderRadius.circular(20)
              : const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag handle on mobile
            if (!widget.isDialog)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'مركز الأنشطة المباشرة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            StreamBuilder<int>(
                              stream: _store.unreadCountStream,
                              initialData: _store.unreadCount,
                              builder: (context, snapshot) {
                                final count = snapshot.data ?? 0;
                                if (count == 0) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count جديد',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'تحديثات وإشعارات البلاغات والمهام لحظة بلحظة',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sound toggle button
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _alertManager.toggleSound(!_alertManager.soundEnabled);
                      });
                    },
                    icon: Icon(
                      _alertManager.soundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: _alertManager.soundEnabled
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    tooltip: _alertManager.soundEnabled
                        ? 'كتم صوت التنبيهات'
                        : 'تشغيل صوت التنبيهات',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                    tooltip: 'إغلاق',
                  ),
                ],
              ),
            ),

            // Secondary action strip: "تحديد الكل كمقروء"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              color: const Color(0xFFF8FAFC),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<List<IncidentRealTimeEvent>>(
                    stream: _store.activitiesStream,
                    initialData: _store.activities,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Text(
                        'إجمالي الأحداث الأخيرة: $count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      );
                    },
                  ),
                  TextButton.icon(
                    onPressed: () => _store.markAllAsRead(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text(
                      'تحديد الكل كمقروء',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Activities List
            Expanded(
              child: StreamBuilder<List<IncidentRealTimeEvent>>(
                stream: _store.activitiesStream,
                initialData: _store.activities,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 40,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'لا توجد أنشطة مسجلة حتى الآن',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'ستظهر هنا إشعارات الأزمات والتحديثات فور ورودها من الخادم',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return _ActivityItemTile(
                        event: item,
                        timeAgo: _formatTimeAgo(item.timestamp),
                        onTap: () {
                          _store.markAsRead(item.id);
                          Navigator.of(context).pop();
                          if (item.incidentId != null) {
                            _alertManager.navigateToIncidentDetails(
                              context,
                              item.incidentId!,
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItemTile extends StatelessWidget {
  final IncidentRealTimeEvent event;
  final String timeAgo;
  final VoidCallback onTap;

  const _ActivityItemTile({
    required this.event,
    required this.timeAgo,
    required this.onTap,
  });

  int? _getEventStatus() {
    if (event.newStatus != null) return event.newStatus;
    switch (event.eventType) {
      case IncidentEventType.created:
        return 1;
      case IncidentEventType.resolved:
        return 6;
      case IncidentEventType.rejected:
        return 7;
      default:
        return event.oldStatus;
    }
  }

  Color _getColor() {
    final status = _getEventStatus();
    if (status != null) {
      return getStatusColor(status);
    }
    switch (event.priority) {
      case AlertPriority.critical:
        return const Color(0xFFDC2626);
      case AlertPriority.high:
        return const Color(0xFFD97706);
      case AlertPriority.medium:
        return const Color(0xFF2563EB);
      case AlertPriority.low:
        return const Color(0xFF059669);
    }
  }

  IconData _getIcon() {
    switch (event.eventType) {
      case IncidentEventType.created:
        return Icons.add_alert_rounded;
      case IncidentEventType.severityIncreased:
        return Icons.trending_up_rounded;
      case IncidentEventType.severityDecreased:
        return Icons.trending_down_rounded;
      case IncidentEventType.statusChanged:
        return Icons.sync_alt_rounded;
      case IncidentEventType.missionAssigned:
        return Icons.assignment_ind_rounded;
      case IncidentEventType.missionStatusChanged:
        return Icons.assignment_turned_in_rounded;
      case IncidentEventType.resolved:
        return Icons.check_circle_rounded;
      case IncidentEventType.rejected:
        return Icons.cancel_rounded;
      case IncidentEventType.deleted:
        return Icons.delete_outline_rounded;
      case IncidentEventType.connectionLost:
        return Icons.wifi_off_rounded;
      case IncidentEventType.reconnected:
        return Icons.wifi_rounded;
      case IncidentEventType.updated:
        return Icons.edit_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final status = _getEventStatus();
    final isUnread = !event.isRead;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFFF8FAFC),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isUnread ? color.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? color.withValues(alpha: 0.35)
                  : const Color(0xFFE2E8F0),
              width: isUnread ? 1.4 : 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), size: 18, color: color),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.incidentTitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isUnread ? FontWeight.w800 : FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (status != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    getStatusArabic(status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                  ),
                                ),
                              if (event.branchName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    event.branchName!,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              if (event.actorName != null)
                                Text(
                                  'المستخدم: ${event.actorName}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (isUnread) ...[
                const SizedBox(width: 8),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
