import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/theming/app_theme.dart';

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 12 : 16),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.8)),
        boxShadow: compact
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      padding: EdgeInsets.all(compact ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: connected
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: connected
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulsingDot(
                        color: connected
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        connected
                            ? 'متصل بالتدفق العملياتي المباشر'
                            : 'غير متصل بالبث المباشر',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: connected
                              ? const Color(0xFF065F46)
                              : const Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'البيانات فورية ومحدثة تلقائياً',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 640;
              final children = [
                _KpiCard(
                  label: 'إجمالي الحالات والبلاغات',
                  value: '$total',
                  icon: Icons.emergency_outlined,
                  baseColor: const Color(0xFF1B4F8A),
                  gradientColors: const [Color(0xFF1B4F8A), Color(0xFF1B4F8A)],
                  compact: compact,
                ),
                _KpiCard(
                  label: 'بلاغات حرجة (شدة 4)',
                  value: '$critical',
                  icon: Icons.error_outline_rounded,
                  baseColor: const Color(0xFFEF4444),
                  gradientColors: const [Color(0xFFDC2626), Color(0xFFF87171)],
                  compact: compact,
                ),
                _KpiCard(
                  label: 'حالات نشطة قيد المتابعة',
                  value: '$active',
                  icon: Icons.play_circle_outline,
                  baseColor: const Color(0xFF2563EB),
                  gradientColors: const [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  compact: compact,
                ),
                _KpiCard(
                  label: 'إجمالي المهام المجدولة',
                  value: '$missions',
                  icon: Icons.checklist_rtl_rounded,
                  baseColor: const Color(0xFF0D9488),
                  gradientColors: const [Color(0xFF0D9488), Color(0xFF2DD4BF)],
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
  final List<Color> gradientColors;
  final bool compact;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.baseColor,
    required this.gradientColors,
    this.compact = false,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Container(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFBFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEDF2F7)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0, -4, 0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? widget.baseColor.withOpacity(0.4)
                : const Color(0xFFEDF2F7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.baseColor.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: -24,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      widget.baseColor.withOpacity(0.08),
                      widget.baseColor.withOpacity(0.01),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              start: 0,
              top: 0,
              bottom: 0,
              width: 4.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.baseColor.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.value,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.3 + 0.7 * _controller.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4 * _controller.value),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
