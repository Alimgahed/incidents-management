import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/actions/data/models/missions/all_mission_model.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/missions_cubit/missions_filter_cubit.dart';
import 'package:incidents_managment/core/future/actions/logic/states/missions_filter_state.dart';

class MissionsFiltersPanel extends StatefulWidget {
  final List<AllMissionModel> rawMissions;

  const MissionsFiltersPanel({super.key, required this.rawMissions});

  @override
  State<MissionsFiltersPanel> createState() => _MissionsFiltersPanelState();
}

class _MissionsFiltersPanelState extends State<MissionsFiltersPanel> {
  final TextEditingController _searchController = TextEditingController();

  List<String> _getDistinctClasses() {
    return widget.rawMissions
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
    final state = context.read<MissionsFilterCubit>().state;
    _searchController.text = state.searchName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MissionsFilterCubit, MissionsFilterState>(
      listener: (context, state) {
        if (state.searchName != _searchController.text) {
          _searchController.text = state.searchName;
        }
      },
      builder: (context, state) {
        final distinctClasses = _getDistinctClasses();

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
                    if (state.hasActiveFilters)
                      TextButton.icon(
                        onPressed: () {
                          _searchController.clear();
                          context.read<MissionsFilterCubit>().resetFilters();
                        },
                        icon: const Icon(Icons.refresh, size: 16, color: Colors.red),
                        label: const Text(
                          'إعادة تعيين',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 650;
                    if (isMobile) {
                      return Column(
                        children: [
                          _buildSearchField(),
                          const SizedBox(height: 16),
                          _buildClassDropdown(distinctClasses, state.className),
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildSearchField()),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: _buildClassDropdown(distinctClasses, state.className),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'بحث باسم المهمة أو التصنيف',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              context.read<MissionsFilterCubit>().updateFilters(searchName: val);
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: 'ابحث عن اسم المهمة...',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        context.read<MissionsFilterCubit>().updateFilters(searchName: '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassDropdown(List<String> classes, String? selectedClass) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تصفية حسب التصنيف',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selectedClass,
              hint: const Text('جميع التصنيفات', style: TextStyle(fontSize: 13, color: Colors.grey)),
              icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('جميع التصنيفات', style: TextStyle(fontSize: 13)),
                ),
                ...classes.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ],
              onChanged: (val) {
                context.read<MissionsFilterCubit>().updateFilters(
                      className: val,
                      clearClassName: val == null,
                    );
              },
            ),
          ),
        ),
      ],
    );
  }
}
