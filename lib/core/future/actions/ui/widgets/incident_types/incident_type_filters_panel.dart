import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/incident_type_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/incident_type_filter_state.dart';

class IncidentTypeFiltersPanel extends StatefulWidget {
  final List<IncidentType> rawTypes;

  const IncidentTypeFiltersPanel({super.key, required this.rawTypes});

  @override
  State<IncidentTypeFiltersPanel> createState() => _IncidentTypeFiltersPanelState();
}

class _IncidentTypeFiltersPanelState extends State<IncidentTypeFiltersPanel> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _getDistinctClasses() {
    return widget.rawTypes
        .map((e) => e.className)
        .where((s) => s != null && s.isNotEmpty)
        .map((s) => s!)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<IncidentTypeFilterCubit>().state;
    _searchController.text = state.searchName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncidentTypeFilterCubit, IncidentTypeFilterState>(
      listener: (context, state) {
        if (state.searchName != _searchController.text) {
          _searchController.text = state.searchName;
        }
      },
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, color: Color(0xFF1B4F8A), size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'فلاتر البحث',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4F8A),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.keyboard_arrow_up, color: Colors.grey.shade600),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Row 1: Search
                    _buildTextField(
                      label: 'بحث باسم نوع الأزمة',
                      icon: Icons.search,
                      controller: _searchController,
                      onChanged: (val) => context.read<IncidentTypeFilterCubit>().updateFilters(searchName: val),
                    ),
                    const SizedBox(height: 16),
                    // Row 2: Dropdowns
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isMobile = constraints.maxWidth < 600;
                        if (isMobile) {
                          return Column(
                            children: [
                              _buildDropdown(
                                label: 'الفئة (التصنيف)',
                                icon: Icons.category_outlined,
                                value: state.className,
                                items: _getDistinctClasses(),
                                onChanged: (val) => context.read<IncidentTypeFilterCubit>().updateFilters(className: val, clearClassName: val == null),
                              ),
                              const SizedBox(height: 12),
                              _buildDropdown(
                                label: 'عدد المهام',
                                icon: Icons.assignment_outlined,
                                value: state.missionCountFilter,
                                items: ['بدون مهام (0)', 'من 1 إلى 5 مهام', 'أكثر من 5 مهام'],
                                onChanged: (val) => context.read<IncidentTypeFilterCubit>().updateFilters(missionCountFilter: val, clearMissionCountFilter: val == null),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                label: 'الفئة (التصنيف)',
                                icon: Icons.category_outlined,
                                value: state.className,
                                items: _getDistinctClasses(),
                                onChanged: (val) => context.read<IncidentTypeFilterCubit>().updateFilters(className: val, clearClassName: val == null),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdown(
                                label: 'عدد المهام',
                                icon: Icons.assignment_outlined,
                                value: state.missionCountFilter,
                                items: ['بدون مهام (0)', 'من 1 إلى 5 مهام', 'أكثر من 5 مهام'],
                                onChanged: (val) => context.read<IncidentTypeFilterCubit>().updateFilters(missionCountFilter: val, clearMissionCountFilter: val == null),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    // Actions
                    Row(
                      children: [
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.read<IncidentTypeFilterCubit>().resetFilters();
                          },
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('إعادة تعيين'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(Icons.search, size: 18),
                          label: const Text('تطبيق الفلاتر'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4F8A),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1B4F8A)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'اكتب اسم نوع الأزمة...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1B4F8A)),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1B4F8A)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('الكل', style: TextStyle(fontSize: 13, color: Colors.black87)),
              ),
              icon: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.keyboard_arrow_down, size: 18),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('الكل', style: TextStyle(fontSize: 13, color: Colors.black87)),
                  ),
                ),
                ...items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(item, style: const TextStyle(fontSize: 13)),
                    ),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
