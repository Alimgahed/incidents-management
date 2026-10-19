import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/data/repos/edit_incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/update_statues.dart';
import 'package:incidents_managment/core/future/actions/logic/states/edit_incident.dart';
import 'package:incidents_managment/core/future/actions/logic/states/update_statues.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/add_photo/add_image.dart';
import 'package:incidents_managment/core/helpers/incident_description_parse.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:flutter/services.dart';
import 'package:incidents_managment/core/future/mobile/ui/theme/mobile_system_bars.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/security/authenticated_image.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class MobileIncidentDetailsScreen extends StatefulWidget {
  final int? incidentId;
  final CurrentIncidentModel? initialIncident;

  const MobileIncidentDetailsScreen({
    super.key,
    this.incidentId,
    this.initialIncident,
  });

  @override
  State<MobileIncidentDetailsScreen> createState() =>
      _MobileIncidentDetailsScreenState();
}

class _MobileIncidentDetailsScreenState
    extends State<MobileIncidentDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetId =
          widget.incidentId ?? widget.initialIncident?.currentIncidentId;
      if (widget.initialIncident != null) {
        context.read<DashboardCubit>().selectIncident(widget.initialIncident!);
      } else if (targetId != null) {
        final incidents = context.read<IncidentMapCubit>().incidents;
        final matches = incidents.where((i) => i.currentIncidentId == targetId);
        if (matches.isNotEmpty) {
          context.read<DashboardCubit>().selectIncident(matches.first);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EditIncidentCubit>(
          create: (context) =>
              EditIncidentCubit(editIncidentRepo: getIt<EditIncidentRepo>()),
        ),
        BlocProvider<UpdateStatuesCubit>(
          create: (context) =>
              UpdateStatuesCubit(updateStatuesRepo: getIt<UpdateStatuesRepo>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<IncidentMapCubit, IncidentMapState>(
            listener: (context, mapState) {
              if (mapState is IncidentMapLoaded) {
                context.read<DashboardCubit>().syncWithIncidents(
                  mapState.incidents,
                );
              }
            },
          ),
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (_, state) =>
                state.maybeWhen(error: (_) => true, orElse: () => false),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(message),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<EditIncidentCubit, EditIncidentStates>(
            listener: (context, state) {
              state.maybeWhen(
                error: (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(msg.error ?? 'حدث خطأ'),
                    ),
                  );
                },
                success: () {
                  context.read<IncidentMapCubit>().refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('تم تحديث الأزمة بنجاح'),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<UpdateStatuesCubit, UpdateStatuesStates>(
            listener: (context, state) {
              state.maybeWhen(
                error: (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(msg.error ?? 'حدث خطأ'),
                    ),
                  );
                },
                success: () {
                  context.read<IncidentMapCubit>().refresh();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('تم تحديث حالة المهمة بنجاح'),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
        ],
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashState) {
            return BlocBuilder<IncidentMapCubit, IncidentMapState>(
              builder: (context, mapState) {
                final targetId =
                    widget.incidentId ??
                    widget.initialIncident?.currentIncidentId ??
                    0;

                final mapIncidents = mapState is IncidentMapLoaded
                    ? mapState.incidents
                    : context.read<IncidentMapCubit>().incidents;

                CurrentIncidentModel? liveIncident;
                try {
                  liveIncident = mapIncidents.firstWhere(
                    (i) => i.currentIncidentId == targetId,
                  );
                } catch (_) {}

                final dashIncident = context
                    .read<DashboardCubit>()
                    .selectedIncident;
                if (dashIncident != null &&
                    dashIncident.currentIncidentId == targetId) {
                  liveIncident = liveIncident ?? dashIncident;
                }

                final incident =
                    liveIncident ??
                    widget.initialIncident ??
                    CurrentIncidentModel();

                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: MobileSystemBars.standard,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Scaffold(
                      backgroundColor: const Color(0xFFF4F7FB),
                      bottomNavigationBar: _buildBottomActionBar(context, incident),
                      body: RefreshIndicator(
                        onRefresh: () async {
                          await context.read<IncidentMapCubit>().refresh();
                        },
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            // Top Curved App Bar
                            SliverToBoxAdapter(
                              child: _buildTopBanner(context, incident),
                            ),

                            // Main Content
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                32,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildListDelegate([
                                  // 1. Overview Card (Title, #ID, Headline, Branch, Status, Severity)
                                  _buildIncidentHeaderCard(
                                    context,
                                    incident,
                                  ),
                                  const SizedBox(height: 12),

                                  // 2. 2x3 Details Grid
                                  _buildDetailsGrid(context, incident),
                                  const SizedBox(height: 12),

                                  // 3. Location Section with Mini Map
                                  _buildLocationSection(context, incident),
                                  const SizedBox(height: 12),

                                  // 4. Incident Notes Card (Only when real notes exist)
                                  if (incident.currentIncidentNotes !=
                                          null &&
                                      incident.currentIncidentNotes!
                                          .trim()
                                          .isNotEmpty) ...[
                                    _buildNotesSection(context, incident),
                                    const SizedBox(height: 12),
                                  ],

                                  // 5. Missions Section
                                  _buildMissionsSection(context, incident),
                                  const SizedBox(height: 12),

                                  // 6. Photos Section (Only when real photos exist)
                                  if (incident.photos != null &&
                                      incident.photos!.isNotEmpty) ...[
                                    _buildPhotosSection(context, incident),
                                  ],
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // TOP BANNER
  // ==========================================
  Widget _buildTopBanner(BuildContext context, CurrentIncidentModel incident) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F3B6C),
        image: DecorationImage(
          image: AssetImage('assets/images/header_banner.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A2240).withValues(alpha: 0.94),
              const Color(0xFF0F3866).withValues(alpha: 0.88),
              const Color(0xFF164780).withValues(alpha: 0.97),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
            child: Column(
              children: [
                // Top Action Bar: Logo on Right, Options & Back Button on Left (in RTL)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo (Right in RTL)
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(
                            Icons.water_drop_rounded,
                            color: appColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    // Actions on Left: More menu & Back button
                    Row(
                      children: [
                        // More options (Three dots)
                        GestureDetector(
                          onTap: () => _showMoreActionsMenu(context, incident),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Screen Title
                const Text(
                  'تفاصيل الأزمة',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),

                // Company Subtitle
                Text(
                  'شركة مياه الشرب والصرف الصحي بالمنيا',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. INCIDENT HEADER CARD
  // ==========================================
  Widget _buildIncidentHeaderCard(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final title =
        incident.currentIncidentTypeName ??
        incident.currentIncidentDescription ??
        'بلاغ أزمة';
    final incidentNumber = incident.currentIncidentId ?? 0;
    final branch = incident.branchName ?? 'الفرع الرئيسي';

    final status = incident.currentIncidentStatus ?? 1;
    final severity = incident.currentIncidentSeverity ?? 1;

    final rawDescription = (incident.currentIncidentDescription ?? '').trim();
    final parsed = IncidentDescriptionParser.parse(rawDescription);
    final hasDescription = rawDescription.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Water droplet icon, Title (نوع الأزمة), # ID Badge
            Row(
              children: [
                // Right: Water drop container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Center: Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),

                // Left: # ID Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Text(
                    '# $incidentNumber',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E56A0),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Chips Row: Branch, Severity, Status
            Row(
              children: [
                // Branch chip
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'فرع $branch',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Severity Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getSeverityColor(
                        severity,
                      ).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.crisis_alert_rounded,
                        size: 15,
                        color: _getSeverityColor(severity),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _getSeverityText(severity, incident.severityName),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _getSeverityColor(severity),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _getStatusColor(status).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 15,
                        color: _getStatusColor(status),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _getStatusText(status, incident.statusName),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (hasDescription) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 14),

              // Section Header: تفاصيل البلاغ والأزمة
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'تفاصيل ووصف البلاغ',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Full parsed title / description text
              Text(
                parsed.displayTitle.isNotEmpty
                    ? parsed.displayTitle
                    : rawDescription,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  height: 1.5,
                ),
              ),

              if (parsed.locationFromDescription != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        parsed.locationFromDescription!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              if (parsed.technicalDetails != null) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        parsed.technicalDetails!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // النص الكامل من المصدر (كما هو في شاشة الويب)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 15,
                          color: Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'النص الكامل من المصدر',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      rawDescription,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1E293B),
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
  }

  // ==========================================
  // 2. 2x3 DETAILS GRID
  // ==========================================
  Widget _buildDetailsGrid(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEEF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: نوع الأزمة | المسؤول
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGridItem(
                    icon: Icons.layers_rounded,
                    iconColor: const Color(0xFF2563EB),
                    label: 'نوع الأزمة',
                    value: incident.currentIncidentTypeName ?? 'غير محدد',
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: _buildGridItem(
                    icon: Icons.person_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    label: 'المسؤول',
                    value: incident.managerName ?? 'غير محدد',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Row 2: أنشأ البلاغ | تاريخ الإنشاء
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGridItem(
                    icon: Icons.person_outline_rounded,
                    iconColor: const Color(0xFF2563EB),
                    label: 'أنشأ البلاغ',
                    value: incident.username ?? 'غير محدد',
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: _buildGridItem(
                    icon: Icons.calendar_month_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    label: 'تاريخ الإنشاء',
                    value: incident.currentIncidentCreatedAt != null
                        ? _formatDateOnly(incident.currentIncidentCreatedAt!)
                        : 'غير محدد',
                    timeValue: incident.currentIncidentCreatedAt != null
                        ? _formatTimeOnly(incident.currentIncidentCreatedAt!)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Row 3: آخر تحديث للأهمية | آخر تحديث للحالة
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildGridItem(
                    icon: Icons.bar_chart_rounded,
                    iconColor: const Color(0xFFEF4444),
                    label: 'آخر تحديث للأهمية',
                    value: incident.currentIncidentSeverityUpdateAt != null
                        ? _formatDateOnly(
                            incident.currentIncidentSeverityUpdateAt!,
                          )
                        : (incident.currentIncidentCreatedAt != null
                              ? _formatDateOnly(
                                  incident.currentIncidentCreatedAt!,
                                )
                              : 'غير محدد'),
                    timeValue: incident.currentIncidentSeverityUpdateAt != null
                        ? _formatTimeOnly(
                            incident.currentIncidentSeverityUpdateAt!,
                          )
                        : (incident.currentIncidentCreatedAt != null
                              ? _formatTimeOnly(
                                  incident.currentIncidentCreatedAt!,
                                )
                              : null),
                    subValue: incident.severityUpdatedByUserName != null
                        ? 'بواسطة: ${incident.severityUpdatedByUserName}'
                        : null,
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
                Expanded(
                  child: _buildGridItem(
                    icon: Icons.access_time_rounded,
                    iconColor: const Color(0xFF10B981),
                    label: 'آخر تحديث للحالة',
                    value: incident.currentIncidentStatusUpdatedAt != null
                        ? _formatDateOnly(
                            incident.currentIncidentStatusUpdatedAt!,
                          )
                        : (incident.currentIncidentCreatedAt != null
                              ? _formatDateOnly(
                                  incident.currentIncidentCreatedAt!,
                                )
                              : 'غير محدد'),
                    timeValue: incident.currentIncidentStatusUpdatedAt != null
                        ? _formatTimeOnly(
                            incident.currentIncidentStatusUpdatedAt!,
                          )
                        : (incident.currentIncidentCreatedAt != null
                              ? _formatTimeOnly(
                                  incident.currentIncidentCreatedAt!,
                                )
                              : null),
                    subValue: incident.statusUpdatedByUserName != null
                        ? 'بواسطة: ${incident.statusUpdatedByUserName}'
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? timeValue,
    String? subValue,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container on start (right in RTL)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),

          // Texts in column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                if (timeValue != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    timeValue,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
                if (subValue != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subValue,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. LOCATION & COORDINATES SECTION
  // ==========================================
  Widget _buildLocationSection(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final lat = incident.currentIncidentXAxis ?? 26.5498;
    final lng = incident.currentIncidentYAxis ?? 30.8167;
    final address =
        incident.address ?? '${incident.branchName ?? "سمالوط"}, المنيا';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEEF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Row(
            children: [
              // Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Title and Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الموقع الجغرافي',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Button: عرض على الخريطة
              GestureDetector(
                onTap: () => _openFullMap(context, incident),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 14,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'عرض على الخريطة',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Map Preview (Full width, increased height, coordinates hidden)
          Container(
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                children: [
                  Positioned.fill(
                    child:
                        (incident.currentIncidentXAxis != null &&
                            incident.currentIncidentYAxis != null)
                        ? AppMapSection(lat: lat, lng: lng)
                        : Image.asset(
                            'assets/images/map_bg.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (ctx, error, stackTrace) => Container(
                              color: const Color(0xFFE0F2FE),
                              child: const Center(
                                child: Icon(
                                  Icons.map_rounded,
                                  size: 44,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ),
                          ),
                  ),
                  // Center Pin Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 15,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            incident.branchName ?? 'موقع البلاغ',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. NOTES SECTION
  // ==========================================
  Widget _buildNotesSection(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final rawNotes = incident.currentIncidentNotes;
    if (rawNotes == null || rawNotes.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final notes = rawNotes.trim();

    return GestureDetector(
      onTap: () => _showNotesDialog(context, incident),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEEF4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notes Icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.sticky_note_2_rounded,
                color: Color(0xFFD97706),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملاحظات الأزمة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notes,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. MISSIONS SECTION
  // ==========================================
  Widget _buildMissionsSection(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final missions = incident.currentIncidentWithMissions ?? [];
    final totalMissions = missions.length;
    final completedMissions = missions
        .where(
          (m) =>
              m.currentIncidentMissionStatus == 6 ||
              m.currentIncidentMissionStatus == 7,
        )
        .length;

    final progress = totalMissions > 0
        ? (completedMissions / totalMissions).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEEF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              // Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Color(0xFF9333EA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title
              const Expanded(
                child: Text(
                  'المهام المرتبطة',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),

              // Button: عرض الكل (5)
              GestureDetector(
                onTap: () => _showAllMissionsDialog(context, incident),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض الكل ($totalMissions)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 4),

                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: Color(0xFF2563EB),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Progress Bar and Counter
          Row(
            children: [
              Text(
                '$completedMissions / $totalMissions مكتملة',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress == 0 && totalMissions == 0 ? 0.6 : progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 6. PHOTOS SECTION
  // ==========================================
  Widget _buildPhotosSection(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final photos = incident.photos ?? [];
    if (photos.isEmpty) {
      return const SizedBox.shrink();
    }
    final totalPhotos = photos.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEEF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              // Icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Color(0xFF0284C7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title
              const Expanded(
                child: Text(
                  'الصور والمرفقات',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),

              // Button: عرض الكل (X)
              GestureDetector(
                onTap: () => _showAllPhotosGallery(context, incident),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chevron_left_rounded,
                        size: 16,
                        color: Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'عرض الكل ($totalPhotos)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Horizontal Thumbnails Preview Row
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (ctx, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) {
                // Last item showing +N overflow if more than 5 photos
                if (index == 4 && totalPhotos > 5) {
                  return GestureDetector(
                    onTap: () => _showAllPhotosGallery(context, incident),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '+${totalPhotos - 4}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final photo = photos[index];
                final url = photo.id != null
                    ? ApiConstants.viewIncidentPhotoUrl(photo.id!)
                    : '';
                return GestureDetector(
                  onTap: () => _openFullScreenViewer(
                    context,
                    photos: photos,
                    initialIndex: index,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFFF1F5F9),
                      child: AuthenticatedImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                        placeholder: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: const Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BOTTOM ACTION BAR (3 BUTTONS)
  // ==========================================
  Widget _buildBottomActionBar(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Button 1: تعيين مسؤول (Assign Manager / Missions)
            Expanded(
              child: _buildActionButton(
                icon: Icons.person_add_alt_1_rounded,
                label: 'تعيين مسؤول',
                color: const Color(0xFF7C3AED),
                bgColor: const Color(0xFFF5F3FF),
                onTap: () {
                  context.pushNamed(Routes.missionAssign, arguments: incident);
                },
              ),
            ),
            const SizedBox(width: 6),

            // Button 2: عرض الموقع (Location)
            Expanded(
              child: _buildActionButton(
                icon: Icons.map_rounded,
                label: 'عرض الموقع',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => _openFullMap(context, incident),
              ),
            ),
            const SizedBox(width: 6),

            // Button 3: إضافة صور (Add Photos)
            Expanded(
              child: _buildActionButton(
                icon: Icons.camera_alt_rounded,
                label: 'إضافة صور',
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                onTap: () {
                  final currentUserId =
                      getIt<SessionManager>().getCurrentUser()?.userId ?? 1;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileUploadScreen(
                        incidentId: incident.currentIncidentId ?? 0,
                        userId: currentUserId,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),

            // Button 4: تعديل الأزمة (Solid Blue Edit Button)
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'تعديل الأزمة',
                color: Colors.white,
                bgColor: const Color(0xFF1D4ED8),
                isSolid: true,
                onTap: () => showEditDialog(
                  context,
                  incident,
                  context.read<EditIncidentCubit>(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    bool isSolid = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODALS & DIALOGS
  // ==========================================

  // --- ALL MISSIONS MODAL ---
  void _showAllMissionsDialog(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final incidentId = incident.currentIncidentId ?? 0;
    final mapCubit = context.read<IncidentMapCubit>();
    final updateStatuesCubit = context.read<UpdateStatuesCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MultiBlocProvider(
        providers: [
          BlocProvider<IncidentMapCubit>.value(value: mapCubit),
          BlocProvider<UpdateStatuesCubit>.value(value: updateStatuesCubit),
        ],
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocBuilder<IncidentMapCubit, IncidentMapState>(
            builder: (modalContext, mapState) {
              final mapIncidents = mapState is IncidentMapLoaded
                  ? mapState.incidents
                  : mapCubit.incidents;

              CurrentIncidentModel currentIncident = incident;
              try {
                currentIncident = mapIncidents.firstWhere(
                  (i) => i.currentIncidentId == incidentId,
                  orElse: () => incident,
                );
              } catch (_) {
                currentIncident = incident;
              }

              final missions = [
                ...(currentIncident.currentIncidentWithMissions ?? []),
              ]..sort(
                  (a, b) => (a.currentIncidentMissionOrder ?? 0).compareTo(
                    b.currentIncidentMissionOrder ?? 0,
                  ),
                );

              return SafeArea(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3E8FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.assignment_rounded,
                                    color: Color(0xFF9333EA),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'سجل المهام المرتبطة (${missions.length})',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(ctx),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),

                      // List of Missions
                      if (missions.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'لا توجد مهام مسجلة لهذه الأزمة',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        )
                      else
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.sizeOf(context).height * 0.65,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            itemCount: missions.length,
                            separatorBuilder: (c, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (c, idx) {
                              final m = missions[idx];
                              final status =
                                  m.currentIncidentMissionStatus ?? 1;
                              final order =
                                  m.currentIncidentMissionOrder ?? (idx + 1);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Order Circle
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF1E56A0),
                                      child: Text(
                                        '$order',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Mission Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.missionName ??
                                                'مهمة #${m.currentIncidentMissionId}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(status)
                                                      .withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  getStatusArabicLabel(status),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        _getStatusColor(status),
                                                  ),
                                                ),
                                              ),
                                              if (m.statusUpdatedByUser !=
                                                      null &&
                                                  m.statusUpdatedByUser!
                                                      .trim()
                                                      .isNotEmpty)
                                                Text(
                                                  'بواسطة: ${m.statusUpdatedByUser}',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Color(0xFF64748B),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          if (m.assignedEmployees != null &&
                                              m.assignedEmployees!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: m.assignedEmployees!.map(
                                                (emp) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue
                                                        .withValues(alpha: 0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                      color: Colors.blue
                                                          .withValues(
                                                              alpha: 0.2),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.person_outline,
                                                        size: 11,
                                                        color: Color(0xFF2563EB),
                                                      ),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        emp.empName ??
                                                            'مستخدم',
                                                        style: const TextStyle(
                                                          fontSize: 10.5,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFF2563EB),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ).toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Status Update Trigger
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_note_rounded,
                                        color: Color(0xFF2563EB),
                                      ),
                                      onPressed: () {
                                        showStatusSelector(
                                          modalContext,
                                          m,
                                          currentIncident.currentIncidentId ??
                                              incidentId,
                                          updateStatuesCubit,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- ALL PHOTOS GALLERY MODAL ---
  void _showAllPhotosGallery(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    final photos = incident.photos ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: Color(0xFF0284C7),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'معرض صور الأزمة (${photos.length})',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              if (photos.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'لا توجد صور مرفقة لهذه الأزمة',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.72,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: photos.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (c, i) {
                      final p = photos[i];
                      final url = p.id != null
                          ? ApiConstants.viewIncidentPhotoUrl(p.id!)
                          : '';
                      final uploadDate =
                          p.currentIncidentPhotoUploadedAt != null
                          ? '${_formatDateOnly(p.currentIncidentPhotoUploadedAt!)}  ${_formatTimeOnly(p.currentIncidentPhotoUploadedAt!)}'
                          : 'غير محدد';
                      final uploader =
                          p.userName != null && p.userName!.trim().isNotEmpty
                          ? p.userName!
                          : (p.currentIncidentPhotoUploadedBy != null
                                ? 'مستخدم #${p.currentIncidentPhotoUploadedBy}'
                                : 'غير معروف');
                      final hasCoords = p.xAxis != null && p.yAxis != null;
                      final desc =
                          p.description != null &&
                              p.description!.trim().isNotEmpty
                          ? p.description!
                          : null;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.pop(ctx);
                            _openFullScreenViewer(
                              context,
                              photos: photos,
                              initialIndex: i,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Photo Thumbnail with zoom badge
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 88,
                                        height: 88,
                                        color: const Color(0xFFE2E8F0),
                                        child: AuthenticatedImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                          placeholder: const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                          errorWidget: const Icon(
                                            Icons.broken_image_rounded,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      left: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in_rounded,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                // Photo Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEFF6FF),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: const Color(0xFFBFDBFE),
                                              ),
                                            ),
                                            child: Text(
                                              'صورة #${p.id ?? (i + 1)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1D4ED8),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.fullscreen_rounded,
                                            size: 18,
                                            color: Color(0xFF2563EB),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'تكبير',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      // Timestamp
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            uploadDate,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Uploader
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline_rounded,
                                            size: 13,
                                            color: Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              uploader,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF475569),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Coordinates if available
                                      if (hasCoords) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              size: 13,
                                              color: Color(0xFF059669),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '${p.xAxis!.toStringAsFixed(5)}, ${p.yAxis!.toStringAsFixed(5)}',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF059669),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      // Description / Notes if available
                                      if (desc != null) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          desc,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- NOTES DIALOG ---
  void _showNotesDialog(BuildContext context, CurrentIncidentModel incident) {
    final notes = incident.currentIncidentNotes ?? 'لا توجد ملاحظات مسجلة.';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.notes_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'ملاحظات الأزمة',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            notes,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إغلاق'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D4ED8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                showEditDialog(
                  context,
                  incident,
                  context.read<EditIncidentCubit>(),
                );
              },
              child: const Text('تعديل الملاحظات'),
            ),
          ],
        ),
      ),
    );
  }

  // --- MORE ACTIONS MENU ---
  void _showMoreActionsMenu(
    BuildContext context,
    CurrentIncidentModel incident,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF2563EB),
                ),
                title: const Text('إسناد المهام والمستخدمين'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed(Routes.missionAssign, arguments: incident);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.edit_rounded,
                  color: Color(0xFF10B981),
                ),
                title: const Text('تعديل بيانات الأزمة'),
                onTap: () {
                  Navigator.pop(ctx);
                  showEditDialog(
                    context,
                    incident,
                    context.read<EditIncidentCubit>(),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF64748B),
                ),
                title: const Text('تحديث بيانات الأزمة'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.read<IncidentMapCubit>().refresh();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FULL MAP DIALOG ---
  void _openFullMap(BuildContext context, CurrentIncidentModel incident) {
    final lat = incident.currentIncidentXAxis;
    final lng = incident.currentIncidentYAxis;
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد إحداثيات مسجلة لهذه الأزمة')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 380,
          child: Column(
            children: [
              AppBar(
                title: Text(incident.branchName ?? 'موقع الأزمة'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Expanded(
                child: AppMapSection(lat: lat, lng: lng),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- FULL SCREEN INTERACTIVE PHOTO VIEWER ---
  void _openFullScreenViewer(
    BuildContext context, {
    required List<CurrentIncidentPhoto> photos,
    int initialIndex = 0,
  }) {
    if (photos.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenInteractivePhotoViewer(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  // Helper Formatter
  String _formatDateOnly(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTimeOnly(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isPm ? 'م' : 'ص';
    return '$displayHour:$minute $period';
  }

  String _getSeverityText(int s, [String? backendSeverityName]) {
    if (backendSeverityName != null && backendSeverityName.trim().isNotEmpty) {
      return backendSeverityName;
    }
    return getSeverityArabic(s);
  }

  Color _getSeverityColor(int s) {
    return getSeverityColor(s);
  }

  String _getStatusText(int s, [String? backendStatusName]) {
    if (backendStatusName != null && backendStatusName.trim().isNotEmpty) {
      return backendStatusName;
    }
    return getStatusArabic(s);
  }

  Color _getStatusColor(int s) {
    return getStatusColor(s);
  }
}

/// Full screen interactive photo viewer with pinch-to-zoom, pan, double-tap zoom,
/// swiping between photos, and expandable details panel showing all photo information.
class _FullScreenInteractivePhotoViewer extends StatefulWidget {
  final List<CurrentIncidentPhoto> photos;
  final int initialIndex;

  const _FullScreenInteractivePhotoViewer({
    required this.photos,
    this.initialIndex = 0,
  });

  @override
  State<_FullScreenInteractivePhotoViewer> createState() =>
      _FullScreenInteractivePhotoViewerState();
}

class _FullScreenInteractivePhotoViewerState
    extends State<_FullScreenInteractivePhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, TransformationController> _transformControllers = {};
  bool _showDetailsOverlay = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  TransformationController _getControllerForIndex(int index) {
    return _transformControllers.putIfAbsent(
      index,
      () => TransformationController(),
    );
  }

  void _resetZoom(int index) {
    final controller = _transformControllers[index];
    if (controller != null) {
      controller.value = Matrix4.identity();
    }
  }

  void _handleDoubleTap(int index) {
    final controller = _getControllerForIndex(index);
    if (controller.value.isIdentity()) {
      // Zoom in 2.5x centered
      controller.value = Matrix4.diagonal3Values(2.5, 2.5, 1.0);
    } else {
      // Reset back to normal
      controller.value = Matrix4.identity();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _transformControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final date =
        '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isPm ? 'م' : 'ص';
    return '$date  $displayHour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];
    final total = widget.photos.length;

    final uploadDate = photo.currentIncidentPhotoUploadedAt != null
        ? _formatDate(photo.currentIncidentPhotoUploadedAt!)
        : null;
    final uploader = photo.userName != null && photo.userName!.trim().isNotEmpty
        ? photo.userName!
        : (photo.currentIncidentPhotoUploadedBy != null
              ? 'مستخدم #${photo.currentIncidentPhotoUploadedBy}'
              : null);
    final desc =
        photo.description != null && photo.description!.trim().isNotEmpty
        ? photo.description!
        : null;
    final hasCoords = photo.xAxis != null && photo.yAxis != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.black,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Photo PageView
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final p = widget.photos[index];
                  final url = p.id != null
                      ? ApiConstants.viewIncidentPhotoUrl(p.id!)
                      : (p.filePath ?? '');

                  final transformController = _getControllerForIndex(index);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _showDetailsOverlay = !_showDetailsOverlay;
                      });
                    },
                    onDoubleTap: () => _handleDoubleTap(index),
                    child: Center(
                      child: InteractiveViewer(
                        transformationController: transformController,
                        minScale: 0.8,
                        maxScale: 5.0,
                        clipBehavior: Clip.none,
                        child: AuthenticatedImage(
                          imageUrl: url,
                          fit: BoxFit.contain,
                          placeholder: const Center(
                            child: SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                          errorWidget: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                color: Colors.white54,
                                size: 54,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'تعذر تحميل الصورة',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Top Bar Controls (animated fade)
              AnimatedOpacity(
                opacity: _showDetailsOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showDetailsOverlay,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Close button
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            tooltip: 'رجوع',
                          ),
                          const SizedBox(width: 8),
                          // Photo Index Indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / $total',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Reset Zoom Action
                          IconButton(
                            icon: const Icon(
                              Icons.zoom_out_map_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => _resetZoom(_currentIndex),
                            tooltip: 'إعادة ضبط التكبير',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Details Panel (animated fade)
              AnimatedOpacity(
                opacity: _showDetailsOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showDetailsOverlay,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.9),
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.75, 1.0],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo ID & Zoom hint badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    photo.id != null
                                        ? 'صورة #${photo.id}'
                                        : 'صورة #${_currentIndex + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (photo.currentIncidentStatusId != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'حالة #${photo.currentIncidentStatusId}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                const Text(
                                  'اضغط مرتين للتكبير / التصغير',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Description / Notes
                            if (desc != null) ...[
                              Text(
                                desc,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Upload Date & Time
                            if (uploadDate != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'تاريخ الرفع: $uploadDate',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Uploader
                            if (uploader != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline_rounded,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'بواسطة: $uploader',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Coordinates
                            if (hasCoords)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Color(0xFF34D399),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'الإحداثيات: ${photo.xAxis!.toStringAsFixed(6)}, ${photo.yAxis!.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      color: Color(0xFF34D399),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
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
  }
}
