import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_detail_dialogs.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/add_photo/add_image.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/network/api_constants.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/security/authenticated_image.dart';
import 'package:incidents_managment/core/security/session_manager.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class MobileIncidentDetailsScreen extends StatelessWidget {
  final int? incidentId;
  final CurrentIncidentModel? initialIncident;

  const MobileIncidentDetailsScreen({
    super.key,
    this.incidentId,
    this.initialIncident,
  });

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
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (_, state) => state.maybeWhen(
              error: (_) => true,
              orElse: () => false,
            ),
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
        child: BlocBuilder<IncidentMapCubit, dynamic>(
          builder: (context, _) {
            final targetId = incidentId ?? 0;
            final incidents = context.read<IncidentMapCubit>().incidents;
            final incident = incidents.firstWhere(
              (i) => i.currentIncidentId == targetId,
              orElse: () => initialIncident ?? CurrentIncidentModel(),
            );

            return Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                backgroundColor: const Color(0xFFF4F7FB),
                body: Stack(
                  children: [
                    CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Top Curved App Bar
                        SliverToBoxAdapter(
                          child: _buildTopBanner(context, incident),
                        ),

                        // Main Content
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // 1. Overview Card (Title, #ID, Headline, Branch, Status, Severity)
                              _buildIncidentHeaderCard(context, incident),
                              const SizedBox(height: 12),

                              // 2. 2x3 Details Grid
                              _buildDetailsGrid(context, incident),
                              const SizedBox(height: 12),

                              // 3. Location Section with Mini Map
                              _buildLocationSection(context, incident),
                              const SizedBox(height: 12),

                              // 4. Incident Notes Card
                              _buildNotesSection(context, incident),
                              const SizedBox(height: 12),

                              // 5. Missions Section
                              _buildMissionsSection(context, incident),
                              const SizedBox(height: 12),

                              // 6. Photos Section
                              _buildPhotosSection(context, incident),
                            ]),
                          ),
                        ),
                      ],
                    ),

                    // Bottom Floating Action Buttons Toolbar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: _buildBottomActionBar(context, incident),
                    ),
                  ],
                ),
              ),
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
              const Color(0xFF0F3866).withValues(alpha: 0.90),
              const Color(0xFF164780).withValues(alpha: 0.98),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right Button: Back Icon
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Center Title
                const Text(
                  'تفاصيل الأزمة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),

                // Left Button: More options (Three dots)
                GestureDetector(
                  onTap: () => _showMoreActionsMenu(context, incident),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
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
      BuildContext context, CurrentIncidentModel incident) {
    final title = incident.currentIncidentTypeName ??
        incident.currentIncidentDescription ??
        'بلاغ أزمة';
    final description = incident.currentIncidentDescription ?? 'لا يوجد وصف';
    final incidentNumber = incident.currentIncidentId ?? 0;
    final branch = incident.branchName ?? 'الفرع الرئيسي';

    final status = incident.currentIncidentStatus ?? 1;
    final severity = incident.currentIncidentSeverity ?? 1;

    return Transform.translate(
      offset: const Offset(0, -14),
      child: Container(
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
            // Top Row: Water droplet icon, Title/Description, ID Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Right: Water drop container
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF2563EB),
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Center: Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Left: # ID Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '# $incidentNumber',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E56A0),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),

            // Bottom Chips Row: Branch, Severity, Status
            Row(
              children: [
                // Branch chip
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Severity Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFEE2E2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.crisis_alert_rounded,
                        size: 15,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _getSeverityText(severity),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF2F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFCE7F3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        size: 15,
                        color: Color(0xFFDB2777),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _getStatusText(status),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDB2777),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 2. 2x3 DETAILS GRID
  // ==========================================
  Widget _buildDetailsGrid(
      BuildContext context, CurrentIncidentModel incident) {
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
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  icon: Icons.layers_rounded,
                  iconColor: const Color(0xFF2563EB),
                  label: 'نوع الأزمة',
                  value: incident.currentIncidentTypeName ?? 'غير محدد',
                  showArrow: true,
                ),
              ),
              Container(width: 1, height: 60, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: _buildGridItem(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  label: 'المسؤول',
                  value: incident.managerName ?? 'أحمد محمد',
                  showArrow: true,
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Row 2: أنشأ البلاغ | تاريخ الإنشاء
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF2563EB),
                  label: 'أنشأ البلاغ',
                  value: incident.username ?? 'محمد عبدالعزيز',
                  showArrow: true,
                ),
              ),
              Container(width: 1, height: 60, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: _buildGridItem(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  label: 'تاريخ الإنشاء',
                  value: incident.currentIncidentCreatedAt != null
                      ? _formatDate(incident.currentIncidentCreatedAt!)
                      : '21/05/2024 10:45',
                  showArrow: true,
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Row 3: آخر تحديث للأهمية | آخر تحديث للحالة
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFFEF4444),
                  label: 'آخر تحديث للأهمية',
                  value: incident.currentIncidentSeverityUpdateAt != null
                      ? _formatDate(
                          incident.currentIncidentSeverityUpdateAt!)
                      : '21/05/2024 11:15',
                  subValue:
                      'بواسطة: ${incident.severityUpdatedByUserName ?? "محمد علي"}',
                  showArrow: true,
                ),
              ),
              Container(width: 1, height: 60, color: const Color(0xFFF1F5F9)),
              Expanded(
                child: _buildGridItem(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF10B981),
                  label: 'آخر تحديث للحالة',
                  value: incident.currentIncidentStatusUpdatedAt != null
                      ? _formatDate(
                          incident.currentIncidentStatusUpdatedAt!)
                      : '21/05/2024 12:30',
                  subValue:
                      'بواسطة: ${incident.statusUpdatedByUserName ?? "أحمد محمد"}',
                  showArrow: true,
                ),
              ),
            ],
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
    String? subValue,
    bool showArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Action arrow icon on far right/start
          if (showArrow)
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 12,
              color: Color(0xFF94A3B8),
            ),
          if (showArrow) const SizedBox(width: 8),

          // Texts in middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subValue != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subValue,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Icon Container on left/end
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. LOCATION & COORDINATES SECTION
  // ==========================================
  Widget _buildLocationSection(
      BuildContext context, CurrentIncidentModel incident) {
    final lat = incident.currentIncidentXAxis ?? 26.5498;
    final lng = incident.currentIncidentYAxis ?? 30.8167;
    final address = incident.address ??
        '${incident.branchName ?? "سمالوط"}, المنيا';

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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.map_outlined,
                          size: 14, color: Color(0xFF2563EB)),
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

          // Map and Coordinates Box
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  // Map Preview (Interactive or static preview)
                  Expanded(
                    flex: 6,
                    child: Stack(
                      children: [
                        Container(
                          color: const Color(0xFFE2E8F0),
                          child: (incident.currentIncidentXAxis != null &&
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
                                        size: 40,
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
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Color(0xFF2563EB)),
                                const SizedBox(width: 4),
                                Text(
                                  incident.branchName ?? 'موقع البلاغ',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Coordinates Details on Left
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      color: const Color(0xFFF8FAFC),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.near_me_outlined,
                                  size: 14, color: Color(0xFF2563EB)),
                              SizedBox(width: 4),
                              Text(
                                'الإحداثيات',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'خط العرض: ${lat.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'خط الطول: ${lng.toStringAsFixed(4)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
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
      BuildContext context, CurrentIncidentModel incident) {
    final notes = incident.currentIncidentNotes ??
        'يوجد انخفاض في ضخ المياه ويحتاج إلى متابعة فنية عاجلة.';

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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
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
      BuildContext context, CurrentIncidentModel incident) {
    final missions = incident.currentIncidentWithMissions ?? [];
    final totalMissions = missions.length;
    final completedMissions = missions
        .where((m) =>
            m.currentIncidentMissionStatus == 6 ||
            m.currentIncidentMissionStatus == 7)
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
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
                        Icons.arrow_back_ios_new_rounded,
                        size: 10,
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
      BuildContext context, CurrentIncidentModel incident) {
    final photos = incident.photos ?? [];
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'عرض الكل ($totalPhotos)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 10,
                        color: Color(0xFF2563EB),
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
              itemCount: photos.isEmpty ? 5 : photos.length,
              separatorBuilder: (ctx, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) {
                // Last item showing +N overflow if more than 4 photos
                if (index == 4 && (totalPhotos > 5 || photos.isEmpty)) {
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
                          '+${totalPhotos > 5 ? (totalPhotos - 4) : 4}',
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

                if (photos.isNotEmpty && index < photos.length) {
                  final photo = photos[index];
                  final url = photo.id != null
                      ? ApiConstants.viewIncidentPhotoUrl(photo.id!)
                      : '';
                  return GestureDetector(
                    onTap: () => _showSinglePhoto(context, url),
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
                }

                // Sample fallback placeholder thumbnail
                return Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/header_banner.jpg'),
                      fit: BoxFit.cover,
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
  // BOTTOM ACTION BAR (4 BUTTONS MATCHING DESIGN)
  // ==========================================
  Widget _buildBottomActionBar(
      BuildContext context, CurrentIncidentModel incident) {
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
            // Button 1: عرض الموقع (Location)
            Expanded(
              child: _buildActionButton(
                icon: Icons.map_rounded,
                label: 'عرض الموقع',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => _openFullMap(context, incident),
              ),
            ),
            const SizedBox(width: 8),

            // Button 2: إضافة صور (Add Photos)
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
            const SizedBox(width: 8),

            // Button 3: إضافة تعليق (Comment/Notes)
            Expanded(
              child: _buildActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'إضافة تعليق',
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
                onTap: () => _showNotesDialog(context, incident),
              ),
            ),
            const SizedBox(width: 8),

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // MODALS & DIALOGS
  // ==========================================

  // --- ALL MISSIONS MODAL ---
  void _showAllMissionsDialog(
      BuildContext context, CurrentIncidentModel incident) {
    final missions = incident.currentIncidentWithMissions ?? [];

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
                            color: const Color(0xFFF3E8FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.assignment_rounded,
                              color: Color(0xFF9333EA), size: 22),
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
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    itemCount: missions.length,
                    separatorBuilder: (c, _) => const SizedBox(height: 10),
                    itemBuilder: (c, idx) {
                      final m = missions[idx];
                      final status = m.currentIncidentMissionStatus ?? 1;
                      final order = m.currentIncidentMissionOrder ?? (idx + 1);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(
                                    'الحالة: ${_getStatusText(status)}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Status Update Trigger
                            IconButton(
                              icon: const Icon(Icons.edit_note_rounded,
                                  color: Color(0xFF2563EB)),
                              onPressed: () {
                                Navigator.pop(ctx);
                                showStatusSelector(
                                  context,
                                  m,
                                  incident.currentIncidentId ?? 0,
                                  context.read<UpdateStatuesCubit>(),
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
      ),
    );
  }

  // --- ALL PHOTOS GALLERY MODAL ---
  void _showAllPhotosGallery(
      BuildContext context, CurrentIncidentModel incident) {
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
                          child: const Icon(Icons.photo_library_rounded,
                              color: Color(0xFF0284C7), size: 22),
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
                    maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: photos.length,
                    itemBuilder: (c, i) {
                      final p = photos[i];
                      final url = p.id != null
                          ? ApiConstants.viewIncidentPhotoUrl(p.id!)
                          : '';
                      return GestureDetector(
                        onTap: () => _showSinglePhoto(context, url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: AuthenticatedImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            placeholder: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: const Icon(Icons.broken_image,
                                color: Colors.grey),
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
  void _showNotesDialog(
      BuildContext context, CurrentIncidentModel incident) {
    final notes = incident.currentIncidentNotes ?? 'لا توجد ملاحظات مسجلة.';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.notes_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text('ملاحظات الأزمة',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(notes, style: const TextStyle(fontSize: 14, height: 1.5)),
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
      BuildContext context, CurrentIncidentModel incident) {
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
                leading: const Icon(Icons.person_add_alt_1_rounded,
                    color: Color(0xFF2563EB)),
                title: const Text('إسناد المهام والمستخدمين'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.pushNamed(Routes.missionAssign, arguments: incident);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.edit_rounded, color: Color(0xFF10B981)),
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
                leading: const Icon(Icons.refresh_rounded,
                    color: Color(0xFF64748B)),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  // --- SINGLE PHOTO VIEWER ---
  void _showSinglePhoto(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AuthenticatedImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  // Helper Formatter
  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _getSeverityText(int s) {
    switch (s) {
      case 4:
        return 'حرجة';
      case 3:
        return 'عالية';
      case 2:
        return 'متوسطة';
      default:
        return 'منخفضة';
    }
  }

  String _getStatusText(int s) {
    switch (s) {
      case 1:
        return 'تم التبليغ';
      case 2:
        return 'قيد المتابعة';
      case 3:
        return 'جاري التنفيذ';
      case 6:
      case 7:
        return 'مكتملة';
      default:
        return 'نشطة';
    }
  }

  Color _getStatusColor(int s) {
    switch (s) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 6:
      case 7:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF2563EB);
    }
  }
}
