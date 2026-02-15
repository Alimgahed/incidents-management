import 'dart:async';

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
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/incident_details.dart';
import 'package:incidents_managment/core/future/mobile/ui/screens/add_photo/add_image.dart';
import 'package:incidents_managment/core/gloable/gloable.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/helpers/routing.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/theming/styling.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class MobileIncidentsListScreen extends StatelessWidget {
  const MobileIncidentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyActions: false,
        leading: Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
        ),
        backgroundColor: appColor,
        title: const Text(
          'إدارة الأزمات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final cubit = context.watch<DashboardCubit>();
              final hasFilters = cubit.hasActiveFilters;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () => _showFilterBottomSheet(context),
                  ),
                  if (hasFilters)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: warningColor,
                      ),
                    ),
                ],
              );
            },
          ),
        
        ],
      ),

      // 👇 IMPORTANT: Listen to BOTH cubits
      body: BlocBuilder<IncidentMapCubit, IncidentMapState>(
        builder: (context, incidentState) {

          final incidents = incidentState is IncidentMapLoaded
              ? incidentState.incidents
              : <CurrentIncidentModel>[];

          return BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, dashboardState) {

              final dashboardCubit = context.watch<DashboardCubit>();

              final filteredIncidents =
                  dashboardCubit.filterIncidents(incidents);

              return Column(
                children: [
                  /// Stats Card (show filtered count)
                  _MobileStatsCard(
                    totalIncidents: filteredIncidents.length,
                  ),

                  /// List
                  Expanded(
                    child: filteredIncidents.isEmpty
                        ?  _EmptyStateWidget()
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: filteredIncidents.length,
                          itemBuilder: (context, index) {
                            final incident =
                                filteredIncidents[index];
                        
                            return _MobileIncidentCard(
                              incident: incident,
                              onTap: () {
                              incidentID = incident.currentIncidentId ?? 0;
                        
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BlocProvider.value(
                                      value: dashboardCubit,
                                      child:
                                          const MobileIncidentDetailsScreen(),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                  ),
                ],
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(Routes.addIncidentMobile);
        },
        backgroundColor: appColor,
        icon: const Icon(Icons.add,color: Colors.white),
        label: Text('إضافة أزمة جديدة',
          style:TextStyles.size16(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final dashboardCubit = context.read<DashboardCubit>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: dashboardCubit,
        child: _FilterBottomSheet(),
      ),
    );
  }
}



    
  


// Mobile Stats Card
class _MobileStatsCard extends StatelessWidget {
  final int totalIncidents;

  const _MobileStatsCard({required this.totalIncidents});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [appColor, appColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalIncidents',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'إجمالي الأزمات',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'نشط',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Mobile Incident Card
class _MobileIncidentCard extends StatelessWidget {
  final CurrentIncidentModel incident;
  final VoidCallback onTap;

  const _MobileIncidentCard({
    required this.incident,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severity = incident.currentIncidentSeverity ?? 1;
    final status = incident.currentIncidentStatus ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: getSeverityColor(severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: getSeverityColor(severity),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فرع ${incident.branchName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (incident.currentIncidentCreatedAt != null)
                            Text(
                              incident.currentIncidentCreatedAt!
                                  .timeAgoArabic(),
                              style: TextStyle(
                                fontSize: 12,
                                color: secondaryTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: secondaryTextColor,
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Description
                Text(
                  incident.currentIncidentTypeName ?? 'لا يوجد وصف',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: secondaryTextColor,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Footer Row
                Row(
                  children: [
                    // Severity Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getSeverityColor(severity).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: getSeverityColor(severity).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSeverityIcon(severity),
                            size: 14,
                            color: getSeverityColor(severity),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            getSeverityArabic(severity),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: getSeverityColor(severity),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getStatusArabic(status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}

// Empty State Widget
class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_outlined,
              size: 80,
              color: appColor.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد أزمات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي أزمات',
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  int? _tempStatus;
  int? _tempSeverity;
  int? _tempBranch;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DashboardCubit>();
    _tempStatus = cubit.selectedStatus;
    _tempSeverity = cubit.selectedSeverity;
    _tempBranch = cubit.selectedBranchId;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'تصفية الأزمات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
                const Spacer(),
                if (cubit.hasActiveFilters)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tempStatus = null;
                        _tempSeverity = null;
                        _tempBranch = null;
                      });
                    },
                    child: Text(
                      'مسح الكل',
                      style: TextStyle(
                        color: warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Status Filter
            _buildFilterSection(
              title: 'الحالة',
              icon: Icons.sync_alt,
              child: _buildStatusFilter(),
            ),
            
            const SizedBox(height: 20),
            
            // Severity Filter
            _buildFilterSection(
              title: 'درجة الخطورة',
              icon: Icons.priority_high,
              child: _buildSeverityFilter(),
            ),
            
            const SizedBox(height: 20),
            
            // Branch Filter
            _buildFilterSection(
              title: 'الفرع',
              icon: Icons.location_city,
              child: _buildBranchFilter(),
            ),
            
            const SizedBox(height: 32),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cubit.updateStatusFilter(_tempStatus);
                  cubit.updateSeverityFilter(_tempSeverity);
                  cubit.updateBranchFilter(_tempBranch);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تطبيق الفلتر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: appColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildStatusFilter() {
    const statuses = [
      {'id': 1, 'label': 'تم التبليغ'},
      {'id': 2, 'label': 'تم الارسال'},
      {'id': 3, 'label': 'قيد التنفيذ'},
      {'id': 4, 'label': 'قيد الانتظار'},
      {'id': 5, 'label': 'قيد المراجعة'},
      {'id': 6, 'label': 'تم حلها'},
      {'id': 7, 'label': 'تم الرفض'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final id = status['id'] as int;
        final label = status['label'] as String;
        final isSelected = _tempStatus == id;
        final color = getStatusColor(id);

        return FilterChip(
          selected: isSelected,
          label: Text(label),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withOpacity(0.1),
          selectedColor: color,
          checkmarkColor: Colors.white,
          onSelected: (selected) {
            setState(() {
              _tempStatus = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSeverityFilter() {
    const severities = [
      {'id': 1, 'label': 'منخفضة'},
      {'id': 2, 'label': 'متوسطة'},
      {'id': 3, 'label': 'عالية'},
      {'id': 4, 'label': 'حرجة'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: severities.map((severity) {
        final id = severity['id'] as int;
        final label = severity['label'] as String;
        final isSelected = _tempSeverity == id;
        final color = getSeverityColor(id);

        return FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSeverityIcon(id),
                size: 14,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          labelStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
          backgroundColor: color.withOpacity(0.1),
          selectedColor: color,
          checkmarkColor: Colors.white,
          onSelected: (selected) {
            setState(() {
              _tempSeverity = selected ? id : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildBranchFilter() {
    const branches = [
      {'id': 1, 'label': 'المنيا'},
      {'id': 2, 'label': 'المنيا الجديدة'},
      {'id': 3, 'label': 'سمالوط'},
      {'id': 4, 'label': 'مطاي'},
      {'id': 5, 'label': 'بني مزار'},
      {'id': 6, 'label': 'مغاغة'},
      {'id': 7, 'label': 'العدوة'},
      {'id': 8, 'label': 'أبو قرقاص'},
      {'id': 9, 'label': 'ملاوي'},
      {'id': 10, 'label': 'ديرمواس'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          isExpanded: true,
          value: _tempBranch,
          hint: const Text('اختر الفرع'),
          icon: Icon(Icons.arrow_drop_down, color: accentColor),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('جميع الفروع'),
            ),
            ...branches.map((branch) {
              final id = branch['id'] as int;
              final label = branch['label'] as String;
              return DropdownMenuItem<int?>(
                value: id,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: _tempBranch == id ? appColor : secondaryTextColor,
                    ),
                    const SizedBox(width: 8),
                    Text(label),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _tempBranch = value;
            });
          },
        ),
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}

// ============================================================================
// SCREEN 2: MOBILE INCIDENT DETAILS
// ============================================================================

class MobileIncidentDetailsScreen extends StatelessWidget {
  const MobileIncidentDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return  MultiBlocProvider(
      providers: [
        // Creating the cubits here in the MultiBlocProvider
       
      
        BlocProvider<EditIncidentCubit>(
          create: (context) => EditIncidentCubit(editIncidentRepo: getIt<EditIncidentRepo>()),
        ),
        BlocProvider<UpdateStatuesCubit>(
          create: (context) => UpdateStatuesCubit(updateStatuesRepo: getIt<UpdateStatuesRepo>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Bloc listeners for state changes
          BlocListener<DashboardCubit, DashboardState>(
            listenWhen: (_, state) => state.maybeWhen(
              error: (_) => true,
              updateRequested: (_, __, ___) => true,
              missionUpdateRequested: (_, __, ___) => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message)),
                        ],
                      ),
                    ),
                  );
                },
                updateRequested: (incidentId, newStatus, newSeverity) {
                  // You can add your logic here for updateRequested
                },
                missionUpdateRequested: (incidentId, missionId, newStatus) {
                  // You can add your logic here for missionUpdateRequested
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<EditIncidentCubit, EditIncidentStates>(
            listenWhen: (previous, current) => current.maybeWhen(
              error: (_) => true,
              success: () => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message.error ?? "")),
                        ],
                      ),
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(child: Text("تم تحديث الأزمة بنجاح")),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          BlocListener<UpdateStatuesCubit, UpdateStatuesStates>(
            listenWhen: (previous, current) => current.maybeWhen(
              error: (_) => true,
              success: () => true,
              orElse: () => false,
            ),
            listener: (context, state) {
              state.maybeWhen(
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text(message.error ?? "")),
                        ],
                      ),
                    ),
                  );
                },
                success: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.green,
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          const Expanded(child: Text("تم تحديث المهمة بنجاح")),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () {},
              );
            },
          ),
          // ================= MAP → DASHBOARD SYNC =================
         
        ],
      child:BlocBuilder<IncidentMapCubit, IncidentMapState>(
  builder: (context, state) {
    final incidents = state is IncidentMapLoaded
        ? state.incidents
        : <CurrentIncidentModel>[];
    final incident = incidents.firstWhere(
      (i) => i.currentIncidentId == incidentID,
      orElse: () => CurrentIncidentModel(),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to FileUploadScreen with incident ID and user ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FileUploadScreen(
                incidentId: incident.currentIncidentId ?? 0,
                userId: 1, 
              ),
            ),
          );
        },
        backgroundColor: appColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'إضافة صور الأزمة',
          style: TextStyles.size16(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Collapsible App Bar
          _MobileSliverAppBar(incident: incident),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Quick Actions Row
                _QuickActionsRow(incident: incident),

                const SizedBox(height: 16),

                // Stats Cards
                _MobileStatsRow(incident: incident),

                const SizedBox(height: 16),

                // Description Section
                _MobileSection(
                  title: 'وصف الأزمة',
                  icon: Icons.description_outlined,
                  child: Text(
                    incident.currentIncidentDescription ?? 'لا يوجد وصف متاح',
                    style: const TextStyle(
                      fontSize: 15,
                      color: primaryTextColor,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Missions Section
                _MobileMissionsSection(incident: incident),

                const SizedBox(height: 16),

                // Metadata Section
                _MobileMetadataSection(incident: incident),

                const SizedBox(height: 16),

                // Timeline Section
                _MobileTimelineSection(incident: incident),

                const SizedBox(height: 16),

                // Location Section
                if (incident.currentIncidentXAxis != null &&
                    incident.currentIncidentYAxis != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AppMapSection(
                      lat: incident.currentIncidentXAxis!,
                      lng: incident.currentIncidentYAxis!,
                    ),
                  ),

                const SizedBox(height: 16),

                // Notes Section
                if (incident.currentIncidentNotes != null)
                  _MobileSection(
                    title: 'ملاحظات',
                    icon: Icons.sticky_note_2_outlined,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: warningColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              incident.currentIncidentNotes!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: primaryTextColor,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  },
)
    ));
  }
}

// Mobile Sliver App Bar
class _MobileSliverAppBar extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileSliverAppBar({required this.incident});

  @override
  Widget build(BuildContext context) {
    final status = incident.currentIncidentStatus ?? 1;
    final severity = incident.currentIncidentSeverity ?? 1;

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: appColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => showEditDialog(
              context,
              incident,
              context.read<EditIncidentCubit>(),
            ),
          ),
        ),
     
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [appColor, appColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أزمة #${incident.currentIncidentDescription}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            if (incident.branchName != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_city,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    incident.branchName!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MobileStatusChip(
                        text: getStatusArabic(status),
                        color: getStatusColor(status),
                      ),
                      const SizedBox(width: 8),
                      _MobileSeverityChip(
                        text: getSeverityArabic(severity),
                        severity: severity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileStatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _MobileStatusChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSeverityChip extends StatelessWidget {
  final String text;
  final int severity;

  const _MobileSeverityChip({required this.text, required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = getSeverityColor(severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getSeverityIcon(severity), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 4:
        return Icons.priority_high;
      case 3:
        return Icons.warning;
      case 2:
        return Icons.info;
      default:
        return Icons.check_circle;
    }
  }
}

// Quick Actions Row
class _QuickActionsRow extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _QuickActionsRow({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickActionButton(
              icon: Icons.edit,
              label: 'تعديل',
              color: accentColor,
              onTap: () => showEditDialog(
                context,
                incident,
                context.read<EditIncidentCubit>(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.location_on,
              label: 'الموقع',
              color: const Color(0xFF10B981),
              onTap: () {
                // Open map
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickActionButton(
              icon: Icons.message,
              label: 'تعليق',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                // Add comment
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Mobile Stats Row
class _MobileStatsRow extends StatefulWidget {
  final CurrentIncidentModel incident;

  const _MobileStatsRow({required this.incident});

  @override
  State<_MobileStatsRow> createState() => _MobileStatsRowState();
}

class _MobileStatsRowState extends State<_MobileStatsRow> {
  late Duration _elapsed;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initElapsed();
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initElapsed() {
    final createdAt = widget.incident.currentIncidentCreatedAt;
    if (createdAt == null) {
      _elapsed = Duration.zero;
      return;
    }
    _elapsed = DateTime.now().difference(createdAt);
  }

  void _startTimerIfNeeded() {
    if (widget.incident.currentIncidentStatus == 7) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsed += const Duration(seconds: 1);
      });
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final missions = widget.incident.currentIncidentWithMissions ?? [];
    final completedMissions = missions
        .where((m) => m.currentIncidentMissionStatus == 6)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _MobileStatCard(
              icon: Icons.assignment_outlined,
              title: 'المهام',
              value: '${missions.length}',
              subtitle: '$completedMissions مكتملة',
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MobileStatCard(
              icon: Icons.access_time,
              title: 'الوقت',
              value: _elapsed.format(),
              subtitle: widget.incident.currentIncidentStatus == 7
                  ? 'موقوف'
                  : 'نشط',
              color: const Color(0xFFEC4899),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _MobileStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: secondaryTextColor,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: disabledTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Mobile Section Widget
class _MobileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  const _MobileSection({
    required this.title,
    required this.icon,
    required this.child,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appColor,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// Mobile Missions Section
class _MobileMissionsSection extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileMissionsSection({required this.incident});

  @override
  Widget build(BuildContext context) {
    final missions = [...(incident.currentIncidentWithMissions ?? [])]
      ..sort((a, b) => (a.currentIncidentMissionOrder ?? 0)
          .compareTo(b.currentIncidentMissionOrder ?? 0));

    return _MobileSection(
      title: 'المهام',
      icon: Icons.task_alt,
      badge: '${missions.length}',
      child: Column(
        children: missions.map((mission) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MobileMissionItem(
              mission: mission,
              incidentId: incident.currentIncidentId!,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MobileMissionItem extends StatelessWidget {
  final CurrentIncidentWithMissions mission;
  final int incidentId;

  const _MobileMissionItem({
    required this.mission,
    required this.incidentId,
  });

  @override
  Widget build(BuildContext context) {
    final status = mission.currentIncidentMissionStatus ?? 1;
    final order = mission.currentIncidentMissionOrder ?? 0;
    final statusColor = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Order Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: appColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$order',
                style: const TextStyle(
                  color: appColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Mission Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mission.missionName ?? 'مهمة #${mission.currentIncidentMissionId}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    getStatusArabicLabel(status),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: accentColor,
            onPressed: mission.currentIncidentMissionId == null
                ? null
                : () => showStatusSelector(
                    context,
                    mission,
                    incidentId,
                    context.read<UpdateStatuesCubit>(),
                  ),
          ),
        ],
      ),
    );
  }
}

// Mobile Metadata Section
class _MobileMetadataSection extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileMetadataSection({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _MobileSection(
      title: 'معلومات النظام',
      icon: Icons.info_outlined,
      child: Column(
        children: [
          _MobileMetadataRow(
            icon: Icons.category,
            label: 'نوع الأزمة',
            value: '#${incident.currentIncidentTypeName ?? '-'}',
          ),
          const Divider(height: 24),
          _MobileMetadataRow(
            icon: Icons.apartment,
            label: 'الفرع',
            value: incident.branchName ?? '#${incident.branchId ?? '-'}',
          ),
          const Divider(height: 24),
          _MobileMetadataRow(
            icon: Icons.person_add,
            label: 'تم الإنشاء بواسطة',
            value: '#${incident.username ?? '-'}',
          ),
        ],
      ),
    );
  }
}

class _MobileMetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MobileMetadataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: secondaryTextColor,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
      ],
    );
  }
}

// Mobile Timeline Section
class _MobileTimelineSection extends StatelessWidget {
  final CurrentIncidentModel incident;

  const _MobileTimelineSection({required this.incident});

  @override
  Widget build(BuildContext context) {
    return _MobileSection(
      title: 'الخط الزمني',
      icon: Icons.timeline,
      child: Column(
        children: [
          if (incident.currentIncidentCreatedAt != null)
            _MobileTimelineItem(
              icon: Icons.add_circle_outline,
              title: 'تم الإنشاء',
              time: incident.currentIncidentCreatedAt!,
              userId: incident.currentIncidentCreatedBy,
              isFirst: true,
            ),
          if (incident.currentIncidentStatusUpdatedAt != null)
            _MobileTimelineItem(
              icon: Icons.update,
              title: 'آخر تحديث للحالة',
              time: incident.currentIncidentStatusUpdatedAt!,
              userId: incident.currentIncidentStatusUpdatedBy,
            ),
          if (incident.currentIncidentSeverityUpdateAt != null)
            _MobileTimelineItem(
              icon: Icons.priority_high,
              title: 'آخر تحديث للخطورة',
              time: incident.currentIncidentSeverityUpdateAt!,
              userId: incident.currentIncidentSeverityUpdateBy,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _MobileTimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final DateTime time;
  final int? userId;
  final bool isFirst;
  final bool isLast;

  const _MobileTimelineItem({
    required this.icon,
    required this.title,
    required this.time,
    this.userId,
    this.isFirst = false,
    this.isLast = false,
  });

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
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor, width: 2),
                ),
                child: Icon(icon, size: 14, color: accentColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: borderColor,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time.timeAgoArabic(),
                    style: TextStyle(
                      fontSize: 12,
                      color: secondaryTextColor,
                    ),
                  ),
                  if (userId != null)
                    Text(
                      'بواسطة: #$userId',
                      style: TextStyle(
                        fontSize: 11,
                        color: disabledTextColor,
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
}

// Mobile Location Section

