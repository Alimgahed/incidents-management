import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/dashboard_kpi_strip.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_photo_gallery.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/helpers/incident_description_parse.dart';
import 'package:incidents_managment/core/helpers/responsive.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

// ==================== MAIN COMPONENT ====================
class IncidentDetailsPanel extends StatelessWidget {
  const IncidentDetailsPanel({
    super.key,
    this.contentPadding,
    this.showBackToList = false,
    this.onBackToList,
  });

  final EdgeInsets? contentPadding;
  final bool showBackToList;
  final VoidCallback? onBackToList;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType ||
          current is DashboardIncidentSelected ||
          current is DashboardIncidentUpdated ||
          current is DashboardMissionUpdated,
      builder: (context, state) {
        final incident = context.read<DashboardCubit>().selectedIncident;
        if (incident == null) {
          return const _EmptyIncidentState();
        }

        return _IncidentDetailContent(
          key: ValueKey<int?>(incident.currentIncidentId),
          incident: incident,
          contentPadding: contentPadding,
          showBackToList: showBackToList,
          onBackToList: onBackToList,
        );
      },
    );
  }
}

// ==================== CONTENT LAYOUT ====================
class _IncidentDetailContent extends StatelessWidget {
  const _IncidentDetailContent({
    super.key,
    required this.incident,
    required this.contentPadding,
    required this.showBackToList,
    required this.onBackToList,
  });

  final CurrentIncidentModel incident;
  final EdgeInsets? contentPadding;
  final bool showBackToList;
  final VoidCallback? onBackToList;

  @override
  Widget build(BuildContext context) {
    final padding =
        contentPadding ?? ResponsiveHelper.responsivePadding(context);
    final spacing = ResponsiveHelper.responsiveSpacing(
      context,
      mobileSpacing: 10,
      desktopSpacing: 10,
    );
    final isWide = MediaQuery.sizeOf(context).width > 1050;

    // Right Column widgets (Core Info)
    final rightColumnWidgets = <Widget>[
      _MissionsCard(incident: incident),
      SizedBox(height: spacing),

      if (incident.currentIncidentNotes != null) ...[
        SizedBox(height: spacing),
        _NotesCard(notes: incident.currentIncidentNotes!),
        SizedBox(height: spacing),
        _TimelineCard(incident: incident),
      ],
    ];

    // Left Column widgets (Media, Map & Timeline)
    final hasLocation =
        incident.currentIncidentXAxis != null &&
        incident.currentIncidentYAxis != null;

    final leftColumnWidgets = <Widget>[
      if (incident.address != null && incident.address!.isNotEmpty) ...[
        _AddressCard(address: incident.address!),
        SizedBox(height: spacing),
      ],
      if (incident.currentIncidentId != null) ...[
        IncidentPhotosGrid(
          incident: incident,
          incidentId: incident.currentIncidentId!,
        ),
        SizedBox(height: spacing),
      ],
      if (hasLocation)
        AppMapSection(
          lat: incident.currentIncidentXAxis!,
          lng: incident.currentIncidentYAxis!,
          mapHeight: 320,
        )
      else
        _NoLocationPlaceholder(),
    ];

    Widget mainLayout;
    if (isWide) {
      mainLayout = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // RIGHT COLUMN (Core Info - read first in RTL)
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rightColumnWidgets,
            ),
          ),
          SizedBox(width: spacing),
          // LEFT COLUMN (Secondary Info, Media & Timeline)
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: leftColumnWidgets,
            ),
          ),
        ],
      );
    } else {
      // Mobile stacked layout
      mainLayout = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...rightColumnWidgets,
          SizedBox(height: spacing),
          ...leftColumnWidgets,
        ],
      );
    }

    return Container(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showBackToList) _BackNavigation(onPressed: onBackToList),
          Expanded(
            child: SingleChildScrollView(
              padding: padding.copyWith(top: showBackToList ? 8 : padding.top),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Section (Always on top, full width)
                  _IncidentHeaderSection(incident: incident),
                  SizedBox(height: spacing),
                  // Responsive main content
                  mainLayout,
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HEADER SECTION ====================
class _IncidentHeaderSection extends StatelessWidget {
  const _IncidentHeaderSection({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    return _AnimatedFadeSlideIn(
      child: _ProfessionalIncidentHeader(incident: incident),
    );
  }
}

// ==================== BACK NAVIGATION ====================
class _BackNavigation extends StatelessWidget {
  const _BackNavigation({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            IconButton(
              tooltip: 'العودة إلى قائمة الأزمات',
              onPressed: onPressed,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
            const Expanded(
              child: Text(
                'تفاصيل الأزمة',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: primaryTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== DESCRIPTION & NOTES SECTION ====================
class _DescriptionAndNotesSection extends StatelessWidget {
  const _DescriptionAndNotesSection({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 768;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(flex: 3, child: _buildContent())],
          );
        }
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _DescriptionCard(incident: incident),
        if (incident.currentIncidentNotes != null) ...[
          const SizedBox(height: 12),
          _NotesCard(notes: incident.currentIncidentNotes!),
        ],
      ],
    );
  }
}

// ==================== PROFESSIONAL HEADER ====================
class _ProfessionalIncidentHeader extends StatefulWidget {
  const _ProfessionalIncidentHeader({required this.incident});
  final CurrentIncidentModel incident;

  @override
  State<_ProfessionalIncidentHeader> createState() =>
      _ProfessionalIncidentHeaderState();
}

class _ProfessionalIncidentHeaderState
    extends State<_ProfessionalIncidentHeader>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _HeaderContainer(incident: widget.incident),
      ),
    );
  }
}

// ==================== HEADER CONTAINER ====================
class _HeaderContainer extends StatelessWidget {
  const _HeaderContainer({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    final status = incident.currentIncidentStatus ?? 1;
    final severity = incident.currentIncidentSeverity ?? 1;
    final parsed = IncidentDescriptionParser.parse(
      incident.currentIncidentDescription,
    );

    return Container(
      decoration: _HeaderDecoration.build(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderTitle(
            title: parsed.displayTitle,
            icon: Icons.crisis_alert_rounded,
          ),
          const SizedBox(height: 10),
          _HeaderStatusBar(
            incident: incident,
            status: status,
            severity: severity,
          ),
        ],
      ),
    );
  }
}

// ==================== HEADER DECORATION ====================
class _HeaderDecoration {
  static BoxDecoration build() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [const Color(0xFF0A1628), const Color(0xFF1B4F8A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0A1628).withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

// ==================== HEADER TITLE ====================
class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconContainer(icon: icon),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ==================== ICON CONTAINER ====================
class _IconContainer extends StatelessWidget {
  const _IconContainer({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
      ),
      child: Icon(icon, size: 20, color: Colors.white),
    );
  }
}

// ==================== HEADER STATUS BAR ====================
class _HeaderStatusBar extends StatelessWidget {
  const _HeaderStatusBar({
    required this.incident,
    required this.status,
    required this.severity,
  });

  final CurrentIncidentModel incident;
  final int status;
  final int severity;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusChip(status: status),
          const SizedBox(width: 12),
          _SeverityChip(severity: severity),
          const SizedBox(width: 12),
          if (incident.branchName != null)
            _InfoChip(
              icon: Icons.location_city_rounded,
              label: incident.branchName!,
            ),
          if (incident.branchName != null) const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.person_outline_rounded,
            label: incident.managerName ?? 'بدون مسؤول',
          ),
          const SizedBox(width: 12),
          _InfoChip(
            icon: Icons.access_time,
            label:
                incident.currentIncidentCreatedAt?.timeAgoArabic() ??
                'غير محدد',
          ),
          const SizedBox(width: 12),
          _InfoChip(icon: Icons.assignment_outlined, label: _getMissionCount()),
          const SizedBox(width: 12),

          _ActionButtonsGroup(incident: incident),
        ],
      ),
    );
  }

  String _getMissionCount() {
    final count = incident.currentIncidentWithMissions?.length ?? 0;
    return count > 0 ? '$count مهمة' : 'بدون مهام';
  }
}

// ==================== STATUS CHIP ====================
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final int status;

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            getStatusArabic(status),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SEVERITY CHIP ====================
class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity});
  final int severity;

  @override
  Widget build(BuildContext context) {
    final color = getSeverityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(severity), size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            getSeverityArabic(severity),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    return switch (severity) {
      4 => Icons.priority_high_rounded,
      3 => Icons.warning_amber_rounded,
      2 => Icons.info_outline,
      _ => Icons.check_circle_outline,
    };
  }
}

// ==================== INFO CHIP ====================
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ACTION BUTTONS GROUP ====================
class _ActionButtonsGroup extends StatelessWidget {
  const _ActionButtonsGroup({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.edit_outlined,
          tooltip: 'تعديل الأزمة',
          onPressed: () => showEditDialog(
            context,
            incident,
            context.read<EditIncidentCubit>(),
          ),
        ),
        const SizedBox(width: 10),
        _ActionButton(
          icon: Icons.person_add_alt_1_outlined,
          tooltip: 'تعيين مسؤول',
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).pushNamed(
                Routes.missionAssign,
                arguments: incident,
              ),
        ),
      ],
    );
  }
}

// ==================== ACTION BUTTON ====================
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ==================== ANIMATED FADE SLIDE IN ====================
class _AnimatedFadeSlideIn extends StatefulWidget {
  const _AnimatedFadeSlideIn({required this.child});
  final Widget child;

  @override
  State<_AnimatedFadeSlideIn> createState() => _AnimatedFadeSlideInState();
}

class _AnimatedFadeSlideInState extends State<_AnimatedFadeSlideIn>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(position: _slideAnimation, child: widget.child),
    );
  }
}

// ==================== EMPTY STATE ====================
class _EmptyIncidentState extends StatefulWidget {
  const _EmptyIncidentState();

  @override
  State<_EmptyIncidentState> createState() => _EmptyIncidentStateState();
}

class _EmptyIncidentStateState extends State<_EmptyIncidentState>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _pulseController;
  late final Animation<double> _fadeIn;
  late final Animation<double> _slideUp;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<double>(
      begin: 24,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: FadeTransition(
        opacity: _fadeIn,
        child: AnimatedBuilder(
          animation: _slideUp,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _slideUp.value),
            child: child,
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PulsingIcon(pulseAnimation: _pulse),
                  const SizedBox(height: 28),
                  const _EmptyStateTitle(),
                  const SizedBox(height: 10),
                  const _EmptyStateSubtitle(),
                  const SizedBox(height: 36),
                  _FeatureRow(
                    items: const [
                      _FeatureHint(
                        icon: Icons.info_outline_rounded,
                        label: 'تفاصيل كاملة',
                        color: Color(0xFF0D9488),
                      ),
                      _FeatureHint(
                        icon: Icons.task_alt_rounded,
                        label: 'إدارة المهام',
                        color: Color(0xFF8B5CF6),
                      ),
                      _FeatureHint(
                        icon: Icons.map_outlined,
                        label: 'موقع الأزمة',
                        color: Color(0xFFEC4899),
                      ),
                      _FeatureHint(
                        icon: Icons.timeline_rounded,
                        label: 'الخط الزمني',
                        color: Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _SelectionHint(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== EMPTY STATE COMPONENTS ====================
class _PulsingIcon extends StatelessWidget {
  const _PulsingIcon({required this.pulseAnimation});
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) =>
          Transform.scale(scale: pulseAnimation.value, child: child),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [appColor.withOpacity(0.15), appColor.withOpacity(0.04)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: appColor.withOpacity(0.12),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: appColor.withOpacity(0.2), width: 1.5),
            ),
            child: Icon(
              Icons.crisis_alert_rounded,
              size: 44,
              color: appColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyStateTitle extends StatelessWidget {
  const _EmptyStateTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'اختر أزمة لعرض التفاصيل',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: primaryTextColor,
        letterSpacing: -0.3,
      ),
    );
  }
}

class _EmptyStateSubtitle extends StatelessWidget {
  const _EmptyStateSubtitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'انقر على أي أزمة من القائمة لعرض معلوماتها الكاملة\nومتابعة مهامها والتحكم بها',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 13, color: secondaryTextColor, height: 1.6),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.items});
  final List<_FeatureHint> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: items,
    );
  }
}

class _FeatureHint extends StatelessWidget {
  const _FeatureHint({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_forward_rounded,
          size: 16,
          color: appColor.withOpacity(0.5),
        ),
        const SizedBox(width: 6),
        Text(
          'اختر من القائمة على اليمين',
          style: TextStyle(
            fontSize: 12,
            color: appColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ==================== NO LOCATION PLACEHOLDER ====================
class _NoLocationPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_off_rounded, size: 40, color: Color(0xFFCBD5E1)),
          SizedBox(height: 8),
          Text(
            'لا يوجد موقع محدد لهذه الأزمة',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

// ==================== DESCRIPTION CARD ====================
class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'وصف البلاغ والأزمة',
      icon: Icons.description_outlined,
      child: IncidentDescriptionPresentation(
        description: incident.currentIncidentDescription,
        textColor: primaryTextColor,
        secondaryColor: secondaryTextColor,
      ),
    );
  }
}

// ==================== ADDRESS CARD ====================
class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address});
  final String address;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'العنوان',
      icon: Icons.location_on_outlined,
      child: Text(
        address,
        style: TextStyle(fontSize: 14, color: primaryTextColor, height: 1.5),
      ),
    );
  }
}

// ==================== NOTES CARD ====================
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});
  final String notes;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ملاحظات وتوجيهات إضافية',
      icon: Icons.sticky_note_2_outlined,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notes,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF92400E),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MISSIONS CARD ====================
class _MissionsCard extends StatelessWidget {
  const _MissionsCard({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    final missions = [...(incident.currentIncidentWithMissions ?? [])]
      ..sort(
        (a, b) => (a.currentIncidentMissionOrder ?? 0).compareTo(
          b.currentIncidentMissionOrder ?? 0,
        ),
      );

    if (missions.isEmpty) {
      return _SectionCard(
        title: 'المهام المطلوبة',
        icon: Icons.task_alt,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.checklist_rounded, size: 40, color: Color(0xFFCBD5E1)),
              SizedBox(height: 8),
              Text(
                'لا توجد مهام معينة حالياً للأزمة',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return _SectionCard(
      title: 'المهام المطلوبة',
      icon: Icons.task_alt,
      badge: '${missions.length}',
      child: Column(
        children: missions
            .map(
              (mission) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _MissionItem(
                  mission: mission,
                  incidentId: incident.currentIncidentId!,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ==================== MISSION ITEM ====================
class _MissionItem extends StatelessWidget {
  final CurrentIncidentWithMissions mission;
  final int incidentId;

  const _MissionItem({required this.mission, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final status = mission.currentIncidentMissionStatus ?? 1;
    final order = mission.currentIncidentMissionOrder ?? 0;
    final missionId = mission.currentIncidentMissionId;
    final statusColor = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF2F7)),
      ),
      child: Row(
        children: [
          _MissionOrderBadge(order: order),
          const SizedBox(width: 12),
          Expanded(
            child: _MissionContent(mission: mission, statusColor: statusColor),
          ),
          const SizedBox(width: 12),
          _MissionActionButton(
            missionId: missionId,
            incidentId: incidentId,
            mission: mission,
          ),
        ],
      ),
    );
  }
}

class _MissionOrderBadge extends StatelessWidget {
  const _MissionOrderBadge({required this.order});
  final int order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '$order',
          style: const TextStyle(color: appColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _MissionContent extends StatelessWidget {
  const _MissionContent({required this.mission, required this.statusColor});

  final CurrentIncidentWithMissions mission;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          mission.missionName ?? 'مهمة #${mission.currentIncidentMissionId}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            getStatusArabicLabel(mission.currentIncidentMissionStatus ?? 1),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _MissionActionButton extends StatelessWidget {
  const _MissionActionButton({
    required this.missionId,
    required this.incidentId,
    required this.mission,
  });

  final int? missionId;
  final int incidentId;
  final CurrentIncidentWithMissions mission;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: IconButton(
        icon: const Icon(Icons.sync_alt_rounded, size: 18),
        color: const Color(0xFF475569),
        onPressed: missionId == null
            ? null
            : () => showStatusSelector(
                context,
                mission,
                incidentId,
                context.read<UpdateStatuesCubit>(),
              ),
      ),
    );
  }
}

// ==================== TIMELINE CARD ====================
class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.incident});
  final CurrentIncidentModel incident;

  @override
  Widget build(BuildContext context) {
    final items = _buildTimelineItems();

    if (items.isEmpty) {
      return _SectionCard(
        title: 'الخط الزمني',
        icon: Icons.timeline,
        child: _EmptyTimelineState(),
      );
    }

    return _SectionCard(
      title: 'الخط الزمني للحالة',
      icon: Icons.timeline,
      child: Column(children: items),
    );
  }

  List<Widget> _buildTimelineItems() {
    final items = <_TimelineItem>[];

    if (incident.currentIncidentCreatedAt != null) {
      items.add(
        _TimelineItem(
          icon: Icons.add_circle_outline,
          title: 'تم إنشاء البلاغ',
          time: incident.currentIncidentCreatedAt!,
          userId: incident.currentIncidentCreatedBy,
          isFirst: true,
          isLast: false,
        ),
      );
    }

    if (incident.currentIncidentStatusUpdatedAt != null) {
      items.add(
        _TimelineItem(
          icon: Icons.update_rounded,
          title: 'تحديث حالة الأزمة',
          time: incident.currentIncidentStatusUpdatedAt!,
          userId: incident.currentIncidentStatusUpdatedBy,
          isFirst: false,
          isLast: false,
        ),
      );
    }

    if (incident.currentIncidentSeverityUpdateAt != null) {
      items.add(
        _TimelineItem(
          icon: Icons.priority_high_rounded,
          title: 'تحديث مستوى الخطورة',
          time: incident.currentIncidentSeverityUpdateAt!,
          userId: incident.currentIncidentSeverityUpdateBy,
          isFirst: false,
          isLast: true,
        ),
      );
    }

    return items;
  }
}

class _EmptyTimelineState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded, size: 40, color: Color(0xFFCBD5E1)),
          SizedBox(height: 8),
          Text(
            'لا توجد سجلات خط زمني حالياً',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

// ==================== TIMELINE ITEM ====================
class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.time,
    this.userId,
    required this.isFirst,
    required this.isLast,
  });

  final IconData icon;
  final String title;
  final DateTime time;
  final int? userId;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: appColor.withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 14, color: appColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time.timeAgoArabic(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  if (userId != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'بواسطة المعرّف: #$userId',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SECTION CARD ====================
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: appColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: appColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: appColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
