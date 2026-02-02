import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map.dart';
import 'package:incidents_managment/core/future/home/logic/incident_map_cubit/incident_map_state.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => DashboardCubit())],
      child: MultiBlocListener(
        listeners: [
          // Listen to dashboard state changes
          BlocListener<DashboardCubit, DashboardState>(
            listener: (context, state) {
              if (state is DashboardError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(child: Text(state.message)),
                      ],
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              // Handle update requests by forwarding to IncidentMapCubit
              if (state is DashboardUpdateRequested) {
                // context.read<IncidentMapCubit>().updateIncidentStatusAndSeverity(
                //   incidentId: state.incidentId,
                //   newStatus: state.newStatus,
                //   newSeverity: state.newSeverity,
                // );
              }

              if (state is DashboardMissionUpdateRequested) {
                context.read<IncidentMapCubit>().updateMissionStatus(
                  incidentId: state.incidentId,
                  missionId: state.missionId,
                  newStatus: state.newStatus,
                );
              }
            },
          ),

          // Sync with incident map changes
          BlocListener<IncidentMapCubit, IncidentMapState>(
            listener: (context, state) {
              if (state is IncidentMapLoaded) {
                context.read<DashboardCubit>().syncWithIncidents(
                  state.incidents,
                );
              }
            },
          ),
        ],
        child: Row(
          children: [
            // Incidents List (Left Panel)
            Expanded(flex: 2, child: _buildIncidentsList()),

            // Details Panel (Right Panel)
            Expanded(flex: 3, child: _buildDetailsPanel()),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // INCIDENTS LIST
  // ============================================================================
  Widget _buildIncidentsList() {
    return BlocBuilder<IncidentMapCubit, IncidentMapState>(
      builder: (context, mapState) {
        final allIncidents = mapState is IncidentMapLoaded
            ? mapState.incidents
            : <CurrentIncidentModel>[];

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, dashboardState) {
            final dashboardCubit = context.read<DashboardCubit>();
            final filteredIncidents = dashboardCubit.filterIncidents(
              allIncidents,
            );

            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildListHeader(filteredIncidents.length, dashboardCubit),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildIncidentsListView(
                      filteredIncidents,
                      dashboardCubit,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListHeader(int count, DashboardCubit cubit) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'الأزمات النشطة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              const Spacer(),
              Text(
                '$count أزمة',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar
          TextField(
            onChanged: (value) => cubit.updateSearchQuery(value),
            decoration: InputDecoration(
              hintText: 'بحث في الأزمات...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2C5F8D)),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          _buildFilterChips(cubit),
        ],
      ),
    );
  }

  Widget _buildFilterChips(DashboardCubit cubit) {
    final filters = ['الكل', 'حرجة', 'عالية', 'متوسطة', 'منخفضة'];

    return Wrap(
      spacing: 8,
      children: filters.map((filter) {
        final isSelected = cubit.selectedFilter == filter;
        return FilterChip(
          label: Text(filter),
          selected: isSelected,
          onSelected: (_) => cubit.updateFilter(filter),
          backgroundColor: Colors.grey[200],
          selectedColor: const Color(0xFF2C5F8D),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          avatar: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        );
      }).toList(),
    );
  }

  Widget _buildIncidentsListView(
    List<CurrentIncidentModel> incidents,
    DashboardCubit cubit,
  ) {
    if (incidents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد أزمات', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: incidents.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final incident = incidents[index];

        return BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            final isSelected =
                cubit.selectedIncident?.currentIncidentId ==
                incident.currentIncidentId;

            return _buildIncidentCard(incident, isSelected, cubit);
          },
        );
      },
    );
  }

  Widget _buildIncidentCard(
    CurrentIncidentModel incident,
    bool isSelected,
    DashboardCubit cubit,
  ) {
    final severity = incident.currentIncidentSeverity ?? 1;
    final status = incident.currentIncidentStatus ?? 1;

    return InkWell(
      onTap: () => cubit.selectIncident(incident),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C5F8D).withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: _getStatusColor(status),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أزمة #${incident.currentIncidentId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incident.currentIncidentDescription ?? 'لا يوجد وصف',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(severity).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getSeverityArabic(severity),
                          style: TextStyle(
                            color: _getSeverityColor(severity),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (incident.currentIncidentCreatedAt != null)
                        Text(
                          _formatTime(incident.currentIncidentCreatedAt!),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getStatusArabic(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DETAILS PANEL
  // ============================================================================
  Widget _buildDetailsPanel() {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();
        final incident = cubit.selectedIncident;

        if (incident == null) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'اختر أزمة لعرض التفاصيل',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIncidentHeader(incident, cubit),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'الوصف',
                  Icons.description,
                  incident.currentIncidentDescription ?? 'لا يوجد وصف متاح',
                ),
                const SizedBox(height: 16),
                if (incident.currentIncidentXAxis != null &&
                    incident.currentIncidentYAxis != null)
                  _buildLocationCard(
                    incident.currentIncidentXAxis!,
                    incident.currentIncidentYAxis!,
                  ),
                const SizedBox(height: 16),
                if (incident.currentIncidentWithMissions != null &&
                    incident.currentIncidentWithMissions!.isNotEmpty)
                  _buildMissionsCard(incident, cubit),
                const SizedBox(height: 16),
                if (incident.currentIncidentNotes != null)
                  _buildInfoCard(
                    'ملاحظات',
                    Icons.notes,
                    incident.currentIncidentNotes!,
                  ),
                const SizedBox(height: 16),
                _buildTimestampsCard(incident),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncidentHeader(
    CurrentIncidentModel incident,
    DashboardCubit cubit,
  ) {
    final severity = incident.currentIncidentSeverity ?? 1;
    final status = incident.currentIncidentStatus ?? 1;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: _getStatusColor(status),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أزمة #${incident.currentIncidentId}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _getStatusArabic(status),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getSeverityColor(severity).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getSeverityColor(severity),
                            ),
                          ),
                          child: Text(
                            'درجة الخطورة: ${_getSeverityArabic(severity)}',
                            style: TextStyle(
                              color: _getSeverityColor(severity),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.blue,
                  size: 28,
                ),
                onPressed: () => _showEditDialog(context, incident, cubit),
              ),
            ],
          ),
          if (incident.currentIncidentCreatedAt != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'تم الإنشاء: ${_formatTime(incident.currentIncidentCreatedAt!)}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (incident.currentIncidentStatusUpdatedAt != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'تم التحديث: ${_formatTime(incident.currentIncidentStatusUpdatedAt!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2C5F8D), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(double lat, double lng) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Color(0xFF2C5F8D), size: 24),
              SizedBox(width: 12),
              Text(
                'الموقع',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.my_location, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'خط العرض: ${lat.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_searching, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'خط الطول: ${lng.toStringAsFixed(6)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsCard(
    CurrentIncidentModel incident,
    DashboardCubit cubit,
  ) {
    final missions = incident.currentIncidentWithMissions ?? [];
    final sortedMissions = List<CurrentIncidentWithMissions>.from(missions)
      ..sort(
        (a, b) => (a.currentIncidentMissionOrder ?? 0).compareTo(
          b.currentIncidentMissionOrder ?? 0,
        ),
      );

    final completedCount = sortedMissions
        .where((m) => m.currentIncidentMissionStatus == 2)
        .length;
    final progressPercent = missions.isNotEmpty
        ? completedCount / missions.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[300]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
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
                  color: const Color(0xFF2C5F8D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المهام',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    Text(
                      'قائمة المهام المطلوب إنجازها',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progressPercent == 1.0 ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$completedCount / ${missions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercent,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                progressPercent == 1.0 ? Colors.green : const Color(0xFF2C5F8D),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...sortedMissions.map(
            (mission) =>
                _buildMissionItem(mission, incident.currentIncidentId!, cubit),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionItem(
    CurrentIncidentWithMissions mission,
    int incidentId,
    DashboardCubit cubit,
  ) {
    final isCompleted = mission.currentIncidentMissionStatus == 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted ? Colors.green[300]! : Colors.grey[300]!,
          width: 1.5,
        ),
        boxShadow: [
          if (isCompleted)
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            activeColor: Colors.green,
            onChanged: (val) {
              final newStatus = val! ? 2 : 1;
              cubit.updateMissionStatus(
                incidentId: incidentId,
                missionId: mission.idCurrentIncidentMission!,
                newStatus: newStatus,
              );
            },
          ),
          const SizedBox(width: 8),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                      '${mission.currentIncidentMissionOrder ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مهمة #${mission.currentIncidentMissionId}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : const Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'مكتملة' : 'قيد التنفيذ',
                  style: TextStyle(
                    fontSize: 11,
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.pending,
                  size: 14,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  isCompleted ? 'مكتملة' : 'قيد التنفيذ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampsCard(CurrentIncidentModel incident) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF2C5F8D), size: 24),
              SizedBox(width: 12),
              Text(
                'المواعيد الزمنية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTimestampItem(
            'تاريخ الإنشاء',
            incident.currentIncidentCreatedAt,
          ),
          if (incident.currentIncidentSeverityUpdateAt != null)
            _buildTimestampItem(
              'آخر تحديث للخطورة',
              incident.currentIncidentSeverityUpdateAt,
            ),
          if (incident.currentIncidentStatusUpdatedAt != null)
            _buildTimestampItem(
              'آخر تحديث للحالة',
              incident.currentIncidentStatusUpdatedAt,
            ),
        ],
      ),
    );
  }

  Widget _buildTimestampItem(String label, DateTime? dateTime) {
    if (dateTime == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ${_formatDateTime(dateTime)}',
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // EDIT DIALOG
  // ============================================================================
  void _showEditDialog(
    BuildContext context,
    CurrentIncidentModel incident,
    DashboardCubit cubit,
  ) {
    int selectedStatus = incident.currentIncidentStatus ?? 1;
    int selectedSeverity = incident.currentIncidentSeverity ?? 1;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.settings_suggest_rounded, color: Colors.blue),
                    SizedBox(width: 10),
                    Text(
                      'تعديل بيانات الأزمة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1),

                // Status Dropdown
                _buildLabel("حالة الأزمة"),
                _buildDropdown(
                  value: selectedStatus,
                  icon: Icons.hourglass_empty_rounded,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('تم التبليغ')),
                    DropdownMenuItem(value: 2, child: Text('تم الارسال')),
                    DropdownMenuItem(value: 3, child: Text('قيد التنفيذ')),
                    DropdownMenuItem(value: 4, child: Text('قيد الانتظار')),
                    DropdownMenuItem(value: 5, child: Text('قيد المراجعة')),
                    DropdownMenuItem(value: 6, child: Text('تم حلها')),
                    DropdownMenuItem(value: 7, child: Text('تم الرفض')),
                  ],
                  onChanged: (v) => setState(() => selectedStatus = v!),
                ),
                const SizedBox(height: 16),

                // Severity Dropdown
                _buildLabel("شدة الأزمة"),
                _buildDropdown(
                  value: selectedSeverity,
                  icon: Icons.speed_rounded,
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('منخفضة')),
                    DropdownMenuItem(value: 2, child: Text('متوسطة')),
                    DropdownMenuItem(value: 3, child: Text('عالية')),
                    DropdownMenuItem(value: 4, child: Text('حرجة')),
                  ],
                  onChanged: (v) => setState(() => selectedSeverity = v!),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          cubit.updateIncidentStatusAndSeverity(
                            incidentId: incident.currentIncidentId!,
                            newStatus: selectedStatus,
                            newSeverity: selectedSeverity,
                          );
                        },
                        child: const Text('تحديث الأزمة'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================================
  // HELPER WIDGETS
  // ============================================================================
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required int value,
    required IconData icon,
    required List<DropdownMenuItem<int>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      icon: const Icon(
        Icons.arrow_drop_down_circle_outlined,
        color: Colors.blue,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blue[300], size: 20),
        filled: true,
        fillColor: Colors.blue[50]?.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 4:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 2:
        return Colors.yellow[700]!;
      case 1:
      default:
        return Colors.green;
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.purple;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.teal;
      case 6:
        return Colors.green;
      case 7:
        return Colors.red;
      default:
        return Colors.black45;
    }
  }

  String _getStatusArabic(int status) {
    switch (status) {
      case 1:
        return 'تم التبليغ';
      case 2:
        return 'تم الارسال';
      case 3:
        return 'قيد التنفيذ';
      case 4:
        return 'قيد الانتظار';
      case 5:
        return 'قيد المراجعة';
      case 6:
        return 'تم حلها';
      case 7:
        return 'تم الرفض';
      default:
        return 'غير معروف';
    }
  }

  String _getSeverityArabic(int severity) {
    switch (severity) {
      case 4:
        return 'حرجة';
      case 3:
        return 'عالية';
      case 2:
        return 'متوسطة';
      case 1:
      default:
        return 'منخفضة';
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    final mins = difference.inMinutes;
    final hours = difference.inHours;
    final days = difference.inDays;

    if (mins < 1) return 'قبل لحظات';
    if (mins == 1) return 'قبل دقيقة';
    if (mins == 2) return 'قبل دقيقتين';
    if (mins < 60 && mins >= 3 && mins <= 10) return 'قبل $mins دقائق';
    if (mins < 60) return 'قبل $mins دقيقة';

    if (hours == 1) return 'قبل ساعة';
    if (hours == 2) return 'قبل ساعتين';
    if (hours < 24 && hours >= 3 && hours <= 10) return 'قبل $hours ساعات';
    if (hours < 24) return 'قبل $hours ساعة';

    if (days == 1) return 'قبل يوم';
    if (days == 2) return 'قبل يومين';
    if (days < 7 && days >= 3 && days <= 10) return 'قبل $days أيام';
    if (days < 7) return 'قبل $days يوم';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
