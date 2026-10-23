import 'package:flutter/material.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';

class MobileHomeFilterChips extends StatelessWidget {
  final DashboardCubit dashboardCubit;
  final TextEditingController searchController;
  final List<CurrentIncidentModel> incidents;

  const MobileHomeFilterChips({
    super.key,
    required this.dashboardCubit,
    required this.searchController,
    required this.incidents,
  });

  @override
  Widget build(BuildContext context) {
    final status = dashboardCubit.selectedStatus;
    final severity = dashboardCubit.selectedSeverity;
    final branchId = dashboardCubit.selectedBranchId;
    final typeId = dashboardCubit.selectedIncidentTypeId;
    final hasPhotos = dashboardCubit.selectedHasPhotos;
    final hasSearch = searchController.text.trim().isNotEmpty;

    final hasAnyFilter = status != null ||
        severity != null ||
        branchId != null ||
        typeId != null ||
        hasPhotos != null ||
        hasSearch;

    if (!hasAnyFilter) return const SizedBox.shrink();

    String getBranchLabel(int bId) {
      for (var i = 0; i < incidents.length; i++) {
        final inc = incidents[i];
        if (inc.branchId == bId &&
            inc.branchName != null &&
            inc.branchName!.trim().isNotEmpty) {
          return inc.branchName!;
        }
      }
      return 'فرع #$bId';
    }

    String getTypeLabel(int tId) {
      for (var i = 0; i < incidents.length; i++) {
        final inc = incidents[i];
        if (inc.currentIncidentTypeId == tId &&
            inc.currentIncidentTypeName != null &&
            inc.currentIncidentTypeName!.trim().isNotEmpty) {
          return inc.currentIncidentTypeName!;
        }
      }
      return 'نوع #$tId';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // RTL natural flow
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Clear All Button
            GestureDetector(
              onTap: () {
                searchController.clear();
                dashboardCubit.clearAllFilters();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: Color(0xFFDC2626),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'إعادة ضبط',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Search Query Chip
            if (hasSearch) ...[
              _buildFilterPill(
                label: 'بحث: ${searchController.text.trim()}',
                icon: Icons.search_rounded,
                color: const Color(0xFF2563EB),
                onClear: () {
                  searchController.clear();
                  dashboardCubit.updateSearchQuery('');
                },
              ),
              const SizedBox(width: 6),
            ],

            // Status Chip
            if (status != null) ...[
              _buildFilterPill(
                label: 'الحالة: ${getStatusArabic(status)}',
                icon: Icons.sync_alt_rounded,
                color: getStatusColor(status),
                onClear: () => dashboardCubit.updateStatusFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Severity Chip
            if (severity != null) ...[
              _buildFilterPill(
                label: 'الخطورة: ${getSeverityArabic(severity)}',
                icon: Icons.priority_high_rounded,
                color: getSeverityColor(severity),
                onClear: () => dashboardCubit.updateSeverityFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Branch Chip
            if (branchId != null) ...[
              _buildFilterPill(
                label: 'الفرع: ${getBranchLabel(branchId)}',
                icon: Icons.location_city_rounded,
                color: const Color(0xFF0D9488),
                onClear: () => dashboardCubit.updateBranchFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Incident Type Chip
            if (typeId != null) ...[
              _buildFilterPill(
                label: 'النوع: ${getTypeLabel(typeId)}',
                icon: Icons.category_rounded,
                color: const Color(0xFF7C3AED),
                onClear: () => dashboardCubit.updateIncidentTypeFilter(null),
              ),
              const SizedBox(width: 6),
            ],

            // Has Photos Chip
            if (hasPhotos != null) ...[
              _buildFilterPill(
                label: hasPhotos ? 'يحتوي على صور' : 'بدون صور',
                icon: hasPhotos
                    ? Icons.photo_library_rounded
                    : Icons.no_photography_rounded,
                color: hasPhotos
                    ? const Color(0xFF0284C7)
                    : const Color(0xFF64748B),
                onClear: () => dashboardCubit.updateHasPhotosFilter(null),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onClear,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
