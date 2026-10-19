import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';

/// Live operational KPIs from the current incident list with premium styling.
class DashboardKpiStrip extends StatelessWidget {
  final List<CurrentIncidentModel> incidents;
  final bool connected;
  final bool compact;

  const DashboardKpiStrip({
    super.key,
    required this.incidents,
    required this.connected,
    this.compact = false,
  });

  static int _missionsTotal(List<CurrentIncidentModel> list) {
    var n = 0;
    for (final i in list) {
      n += i.currentIncidentWithMissions?.length ?? 0;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final total = incidents.length;
    final critical = incidents
        .where((i) => i.currentIncidentSeverity == 4)
        .length;
    final active = incidents
        .where((i) => (i.currentIncidentStatus ?? 0) != 7)
        .length;
    final missions = _missionsTotal(incidents);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(compact ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 640;
              final children = [
                _KpiCard(
                  label: 'إجمالي الحالات والبلاغات',
                  value: '$total',
                  icon: Icons.emergency_outlined,
                  baseColor: const Color(0xFF1B4F8A),
                  compact: compact,
                ),
                _KpiCard(
                  label: 'بلاغات درجة (شدة 4)',
                  value: '$critical',
                  icon: Icons.error_outline_rounded,
                  baseColor: const Color(0xFFEF4444),
                  compact: compact,
                ),
                _KpiCard(
                  label: 'حالات نشطة قيد المتابعة',
                  value: '$active',
                  icon: Icons.play_circle_outline,
                  baseColor: const Color(0xFF3B82F6),
                  compact: compact,
                ),
                _KpiCard(
                  label: 'إجمالي المهام المجدولة',
                  value: '$missions',
                  icon: Icons.assignment_outlined,
                  baseColor: const Color(0xFF10B981),
                  compact: compact,
                ),
              ];

              if (narrow) {
                return Wrap(
                  spacing: compact ? 8 : 12,
                  runSpacing: compact ? 8 : 12,
                  children: children
                      .map(
                        (w) => SizedBox(
                          width: (c.maxWidth - (compact ? 8 : 12)) / 2,
                          child: w,
                        ),
                      )
                      .toList(),
                );
              }
              return Row(
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) SizedBox(width: compact ? 8 : 12),
                    Expanded(child: children[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color baseColor;
  final bool compact;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.baseColor,
    this.compact = false,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (widget.compact) {
      return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: widget.baseColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Right thick border
            Container(width: 4, color: widget.baseColor),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Text details (aligned to right, but since it's RTL it comes first in Row unless reversed)
                    // Oh wait, in RTL, start is right, end is left.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // in RTL this means right aligned
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Simple static placeholder for sparkline (could be implemented as CustomPaint if needed)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomPaint(
                        size: const Size(40, 20),
                        painter: _SparklinePainter(
                          color: widget.baseColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                    // Left colored icon square
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.baseColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(widget.icon, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.9,
      size.width * 0.4,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.5,
      size.width,
      size.height * 0.2,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
