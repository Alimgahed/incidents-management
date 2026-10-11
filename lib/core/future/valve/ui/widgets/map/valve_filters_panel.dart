import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/valve/data/model/all_valves_response.dart';
import 'package:incidents_managment/core/future/valve/logic/cubit/valve_filter_cubit.dart';

class ValveFiltersPanel extends StatelessWidget {
  final ValveFilterOptions filterOptions;
  final int filteredCount;
  final int? totalCount;
  final VoidCallback? onApply;

  const ValveFiltersPanel({
    super.key,
    required this.filterOptions,
    required this.filteredCount,
    this.totalCount,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
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
                  const _FilterSection(
                    title: 'بحث برقم المحبس',
                    child: _SearchField(),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'حالة المحبس',
                    child: _StringDropdown(
                      value: context.watch<ValveFilterCubit>().state.status,
                      items: filterOptions.statuses,
                      onChanged: (val) =>
                          context.read<ValveFilterCubit>().updateStatus(val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'نوع المحبس',
                    child: _TypeDropdown(types: filterOptions.valveTypes),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'قطر المحبس',
                    child: _IntDropdown(
                      value: context.watch<ValveFilterCubit>().state.diameter,
                      items: filterOptions.diameters,
                      suffix: ' مم',
                      onChanged: (val) =>
                          context.read<ValveFilterCubit>().updateDiameter(val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'قطر الماسورة',
                    child: _IntDropdown(
                      value: context.watch<ValveFilterCubit>().state.pipeDiameter,
                      items: filterOptions.pipeDiameters,
                      suffix: ' مم',
                      onChanged: (val) => context
                          .read<ValveFilterCubit>()
                          .updatePipeDiameter(val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'الاتجاه',
                    child: _StringDropdown(
                      value: context.watch<ValveFilterCubit>().state.direction,
                      items: filterOptions.directions,
                      onChanged: (val) =>
                          context.read<ValveFilterCubit>().updateDirection(val),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FilterSection(
                    title: 'سنة التركيب',
                    child: _IntDropdown(
                      value:
                          context.watch<ValveFilterCubit>().state.inServiceYear,
                      items: filterOptions.inServiceYears,
                      onChanged: (val) => context
                          .read<ValveFilterCubit>()
                          .updateInServiceYear(val),
                    ),
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
            'فلترة المحابس',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4F8A),
            ),
          ),
          TextButton(
            onPressed: () => context.read<ValveFilterCubit>().clearFilters(),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final label = totalCount != null
        ? 'عرض النتائج ($filteredCount / $totalCount)'
        : 'عرض النتائج ($filteredCount)';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B4F8A),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            label,
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
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<ValveFilterCubit>().state.searchQuery,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'ابحث برقم المحبس أو اسمه...',
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 16,
        ),
      ),
      onChanged: (val) =>
          context.read<ValveFilterCubit>().updateSearchQuery(val),
    );
  }
}

class _DropdownShell extends StatelessWidget {
  final Widget child;

  const _DropdownShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}

class _StringDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StringDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = items.contains(value) ? value : null;
    return _DropdownShell(
      child: DropdownButton<String>(
        isExpanded: true,
        value: selected,
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('الكل', style: TextStyle(fontSize: 14)),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('الكل', style: TextStyle(fontSize: 14)),
            ),
          ),
          ...items.map(
            (s) => DropdownMenuItem(
              value: s,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(s, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _IntDropdown extends StatelessWidget {
  final int? value;
  final List<int> items;
  final ValueChanged<int?> onChanged;
  final String suffix;

  const _IntDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final selected = items.contains(value) ? value : null;
    return _DropdownShell(
      child: DropdownButton<int>(
        isExpanded: true,
        value: selected,
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('الكل', style: TextStyle(fontSize: 14)),
        ),
        items: [
          const DropdownMenuItem<int>(
            value: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('الكل', style: TextStyle(fontSize: 14)),
            ),
          ),
          ...items.map(
            (n) => DropdownMenuItem(
              value: n,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('$n$suffix', style: const TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final List<ValveTypeOption> types;

  const _TypeDropdown({required this.types});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<ValveFilterCubit>().state.valveTypeId;
    final ids = types.map((t) => t.id).whereType<int>().toSet();
    final value = ids.contains(selected) ? selected : null;
    return _DropdownShell(
      child: DropdownButton<int>(
        isExpanded: true,
        value: value,
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('الكل', style: TextStyle(fontSize: 14)),
        ),
        items: [
          const DropdownMenuItem<int>(
            value: null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('الكل', style: TextStyle(fontSize: 14)),
            ),
          ),
          ...types.where((t) => t.id != null).map(
                (t) => DropdownMenuItem(
                  value: t.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      t.name ?? 'نوع ${t.id}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
        ],
        onChanged: (val) =>
            context.read<ValveFilterCubit>().updateValveTypeId(val),
      ),
    );
  }
}
