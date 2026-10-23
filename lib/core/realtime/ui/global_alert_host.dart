import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/realtime/models/realtime_event_model.dart';
import 'package:incidents_managment/core/realtime/services/realtime_alert_manager.dart';

class GlobalAlertHost extends StatelessWidget {
  const GlobalAlertHost({super.key});

  @override
  Widget build(BuildContext context) {
    if (!getIt.isRegistered<RealTimeAlertManager>()) {
      return const SizedBox.shrink();
    }

    final alertManager = getIt<RealTimeAlertManager>();

    return StreamBuilder<List<IncidentRealTimeEvent>>(
      stream: alertManager.activeAlertsStream,
      initialData: alertManager.activeAlerts,
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? [];
        if (alerts.isEmpty) return const SizedBox.shrink();

        final screenWidth = MediaQuery.sizeOf(context).width;
        final isMobile = screenWidth < 700;

        return Positioned(
          top: isMobile ? 48 : 24,
          left: isMobile ? 16 : 24,
          right: isMobile ? 16 : null,
          width: isMobile ? null : 420,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final alert in alerts)
                    _GlobalAlertCard(
                      key: ValueKey(alert.id),
                      event: alert,
                      onDismiss: () => alertManager.dismissAlert(alert.id),
                      onOpenDetails: () {
                        alertManager.dismissAlert(alert.id);
                        if (alert.incidentId != null) {
                          alertManager.navigateToIncidentDetails(
                            context,
                            alert.incidentId!,
                          );
                        }
                      },
                    ),
                  if (alertManager.pendingAlertsCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1E293B,
                            ).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            '+${alertManager.pendingAlertsCount} تنبيهات أخرى في الانتظار',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GlobalAlertCard extends StatefulWidget {
  final IncidentRealTimeEvent event;
  final VoidCallback onDismiss;
  final VoidCallback onOpenDetails;

  const _GlobalAlertCard({
    super.key,
    required this.event,
    required this.onDismiss,
    required this.onOpenDetails,
  });

  @override
  State<_GlobalAlertCard> createState() => _GlobalAlertCardState();
}

class _GlobalAlertCardState extends State<_GlobalAlertCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int? _getEventStatus() {
    if (widget.event.newStatus != null) {
      return widget.event.newStatus;
    }
    switch (widget.event.eventType) {
      case IncidentEventType.created:
        return 1;
      case IncidentEventType.resolved:
        return 6;
      case IncidentEventType.rejected:
        return 7;
      default:
        return widget.event.oldStatus;
    }
  }

  Color _getPrimaryColor() {
    final status = _getEventStatus();
    if (status != null) {
      return getStatusColor(status);
    }
    switch (widget.event.priority) {
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

  Color _getBgColor() {
    final status = _getEventStatus();
    if (status != null) {
      return getStatusColor(status).withValues(alpha: 0.12);
    }
    switch (widget.event.priority) {
      case AlertPriority.critical:
        return const Color(0xFFFEF2F2);
      case AlertPriority.high:
        return const Color(0xFFFFFBEB);
      case AlertPriority.medium:
        return const Color(0xFFEFF6FF);
      case AlertPriority.low:
        return const Color(0xFFF0FDF4);
    }
  }

  IconData _getIcon() {
    final status = _getEventStatus();
    if (status != null) {
      switch (status) {
        case 1:
          return Icons.campaign_rounded;
        case 2:
          return Icons.send_rounded;
        case 3:
          return Icons.engineering_rounded;
        case 4:
          return Icons.hourglass_top_rounded;
        case 5:
          return Icons.rule_rounded;
        case 6:
          return Icons.check_circle_rounded;
        case 7:
          return Icons.cancel_rounded;
      }
    }
    switch (widget.event.priority) {
      case AlertPriority.critical:
        return Icons.warning_rounded;
      case AlertPriority.high:
        return Icons.warning_amber_rounded;
      case AlertPriority.medium:
        return Icons.info_outline_rounded;
      case AlertPriority.low:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    final status = _getEventStatus();
    final isCritical = widget.event.priority == AlertPriority.critical;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCritical
                  ? primaryColor.withValues(alpha: 0.8)
                  : primaryColor.withValues(alpha: 0.35),
              width: isCritical ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: isCritical ? 0.22 : 0.12),
                blurRadius: isCritical ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top strip for status / priority
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _getBgColor(),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(),
                            size: 18,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Title and description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.incidentTitle,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.event.description,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Close button
                        InkWell(
                          onTap: widget.onDismiss,
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Action row with status, branch, actor and details button
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
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: 0.3),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    getStatusArabic(status),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              if (widget.event.branchName != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.event.branchName!,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              Text(
                                widget.event.actorName != null
                                    ? 'بواسطة: ${widget.event.actorName}'
                                    : 'الآن',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Action Button
                        if (widget.event.incidentId != null)
                          InkWell(
                            onTap: widget.onOpenDetails,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'عرض تفاصيل الأزمة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 14,
                                    color: primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
