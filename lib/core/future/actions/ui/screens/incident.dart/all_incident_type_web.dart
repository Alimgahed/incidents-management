import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/di/dependcy_injection.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';
import 'package:incidents_managment/core/helpers/routing.dart';

class AllIncidentTypeWebScreen extends StatefulWidget {
  const AllIncidentTypeWebScreen({super.key});

  @override
  State<AllIncidentTypeWebScreen> createState() => _AllIncidentTypeWebScreenState();
}

class _AllIncidentTypeWebScreenState extends State<AllIncidentTypeWebScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    // Assuming search logic could be added to Cubit later, for now we just clear local state
    setState(() {
      _isSearchActive = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AllIncidentTypeCubit>()..getAllIncidentTypes(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9), // Enterprise background
        body: Column(
          children: [
            Builder(
              builder: (context) => _buildWebHeader(context),
            ),
            Expanded(
              child: BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
                builder: (context, state) {
                  return state.when(
                    initial: () => const Center(
                      child: BuildEmptyState(
                        title: 'لا توجد أنواع أزمات',
                        message: 'ابدأ بإضافة نوع جديد',
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator(color: appColor)),
                    loaded: (incidentTypes) {
                      if (incidentTypes.isEmpty) {
                        return const Center(
                          child: BuildEmptyState(
                            title: 'لا توجد أنواع أزمات مطابقة',
                            message: 'حاول تعديل معايير البحث',
                          ),
                        );
                      }
                      
                      // Local search filtering since cubit might not have it yet
                      final query = _searchController.text.toLowerCase();
                      final filteredList = query.isEmpty 
                          ? incidentTypes 
                          : incidentTypes.where((t) => 
                              t.incidentTypeName.toLowerCase().contains(query) || 
                              (t.className != null && t.className!.toLowerCase().contains(query))
                            ).toList();

                      return _buildGridView(filteredList);
                    },
                    error: (message) => const Center(child: Text("حدث خطأ في تحميل الأنواع", style: TextStyle(color: Colors.red))),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Breadcrumbs + Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("الرئيسية", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                  Text("الأزمات", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                  const Text("إدارة أنواع الأزمات", style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () => context.pushNamed(Routes.addIncidentType),
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                label: const Text("إضافة نوع أزمة جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Title + Search Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "أنواع الأزمات",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 350,
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _isSearchActive = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        fillColor: const Color(0xFFF8FAFC),
                        filled: true,
                        hintText: 'ابحث عن اسم الأزمة أو الفئة...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                        suffixIcon: _isSearchActive
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey.shade500, size: 18),
                                onPressed: _clearSearch,
                                splashRadius: 20,
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: appColor, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.tune, color: Colors.grey.shade700, size: 20),
                      onPressed: () {
                        // Filter logic could go here
                      },
                      tooltip: 'خيارات التصفية',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<IncidentType> incidentTypes) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2; // Default for smaller screens
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.all(40),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: incidentTypes.length,
          itemBuilder: (context, index) {
            final type = incidentTypes[index];
            return _buildEnterpriseTypeCard(context, type);
          },
        );
      },
    );
  }

  Widget _buildEnterpriseTypeCard(BuildContext context, IncidentType type) {
    final missionsCount = type.missions?.length ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // You can navigate to details or show a dialog here
        },
        borderRadius: BorderRadius.circular(12),
        hoverColor: appColor.withAlpha(10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: appColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.warning_amber_rounded, color: appColor, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.incidentTypeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'الفئة: ${type.className ?? 'غير متوفر'}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.task_alt_rounded, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '$missionsCount مهمة مرتبطة',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
