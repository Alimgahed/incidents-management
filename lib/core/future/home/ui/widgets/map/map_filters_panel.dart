import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/logic/map_filter_cubit.dart';

import 'package:incidents_managment/core/constant/enms.dart';

class MapFiltersPanel extends StatelessWidget {
  final List<CurrentIncidentModel> rawIncidents;
  final int filteredCount;

  const MapFiltersPanel({
    super.key,
    required this.rawIncidents,
    required this.filteredCount,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically extract unique filter options
    final Map<int, String> branches = {};
    final Map<int, String> severities = {};
    final Map<int, String> statuses = {};
    final Set<String> types = {};

    for (final inc in rawIncidents) {
      if (inc.branchId != null && inc.branchName != null) {
        branches[inc.branchId!] = inc.branchName!;
      }
      if (inc.currentIncidentSeverity != null) {
        severities[inc.currentIncidentSeverity!] = inc.severityName ?? getSeverityArabic(inc.currentIncidentSeverity!);
      }
      if (inc.currentIncidentStatus != null) {
        statuses[inc.currentIncidentStatus!] = inc.statusName ?? getStatusArabic(inc.currentIncidentStatus!);
      }
      if (inc.currentIncidentTypeName != null) {
        types.add(inc.currentIncidentTypeName!);
      }
    }

    // Sort severities by ID descending to match the image (4, 3, 2, 1)
    final sortedSeverities = severities.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterSection(
                    title: 'نطاق العرض',
                    child: _BranchDropdown(branches: branches),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'درجة الخطورة',
                    child: _SeverityList(severities: sortedSeverities),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'حالة الأزمة',
                    child: _StatusDropdown(statuses: statuses),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'نوع الأزمة',
                    child: _TypeDropdown(types: types.toList()),
                  ),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'فلترة النتائج',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4F8A),
            ),
          ),
          TextButton(
            onPressed: () => context.read<MapFilterCubit>().clearFilters(),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4F8A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'عرض النتائج ($filteredCount)',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _BranchDropdown extends StatelessWidget {
  final Map<int, String> branches;

  const _BranchDropdown({required this.branches});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MapFilterCubit>();
    final selectedId = cubit.state.branchId;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedId,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          hint: const Text('الكل'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('الكل'),
            ),
            ...branches.entries.map((e) => DropdownMenuItem<int?>(
                  value: e.key,
                  child: Text(e.value),
                ))
          ],
          onChanged: (val) => cubit.updateBranch(val),
        ),
      ),
    );
  }
}

class _SeverityList extends StatelessWidget {
  final List<MapEntry<int, String>> severities;

  const _SeverityList({required this.severities});

  Color _getSeverityColor(int severityId) {
    switch (severityId) {
      case 4:
        return const Color(0xFFDC2626); // Red
      case 3:
        return const Color(0xFFF59E0B); // Orange
      case 2:
        return const Color(0xFFFBBF24); // Yellow
      case 1:
        return const Color(0xFF10B981); // Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MapFilterCubit>();
    final selectedId = cubit.state.severityId;

    return Column(
      children: [
        _buildOption(
          context,
          title: 'الكل',
          isSelected: selectedId == null,
          color: const Color(0xFF1B4F8A),
          onTap: () => cubit.updateSeverity(null),
        ),
        ...severities.map((e) => _buildOption(
              context,
              title: '${e.value} (${e.key})',
              isSelected: selectedId == e.key,
              color: _getSeverityColor(e.key),
              onTap: () => cubit.updateSeverity(e.key),
            )),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF1B4F8A) : const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final Map<int, String> statuses;

  const _StatusDropdown({required this.statuses});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MapFilterCubit>();
    final selectedId = cubit.state.statusId;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: selectedId,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          hint: const Text('الكل'),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('الكل'),
            ),
            ...statuses.entries.map((e) => DropdownMenuItem<int?>(
                  value: e.key,
                  child: Text(e.value),
                ))
          ],
          onChanged: (val) => cubit.updateStatus(val),
        ),
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final List<String> types;

  const _TypeDropdown({required this.types});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MapFilterCubit>();
    final selectedType = cubit.state.typeName;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedType,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          hint: const Text('الكل'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('الكل'),
            ),
            ...types.map((type) => DropdownMenuItem<String?>(
                  value: type,
                  child: Text(type),
                ))
          ],
          onChanged: (val) => cubit.updateType(val),
        ),
      ),
    );
  }
}
