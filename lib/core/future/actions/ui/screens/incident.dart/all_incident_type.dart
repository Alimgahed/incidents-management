import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/cubit/incident/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/logic/states/get_all_incident_type_states.dart';
import 'package:incidents_managment/core/routing/routes.dart';
import 'package:incidents_managment/core/widget/gloable_widget.dart';

class AllIncidentType extends StatelessWidget {
  const AllIncidentType({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const GlobalAppBar(
        title: 'جميع أنواع الأزمات',
        leadingIcon: Icons.warning_amber_rounded,
      ),
      floatingActionButton: BuildFloatingActionButton(
        routeName: Routes.addIncidentType,
        text: 'إضافة نوع جديد',
      ),
      body: BlocBuilder<AllIncidentTypeCubit, GetAllIncidentTypeState>(
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Loadding(),
            loaded: (incidentTypes) =>
                _LoadedView(incidentTypes: incidentTypes),
            error: (message) => Error(),
          );
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  final List<IncidentType> incidentTypes;

  const _LoadedView({required this.incidentTypes});

  @override
  Widget build(BuildContext context) {
    if (incidentTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return RefreshIndicator(
      color: appColor,
      onRefresh: () async {
        context.read<AllIncidentTypeCubit>().getAllIncidentTypes();
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final crossAxisCount = _calculateCrossAxisCount(width);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'إجمالي الأنواع: ${incidentTypes.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: appColor,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: _calculateAspectRatio(
                      width,
                      crossAxisCount,
                    ),
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return _IncidentTypeCard(
                      incidentType: incidentTypes[index],
                      index: index,
                    );
                  }, childCount: incidentTypes.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 900) return 5;
    if (width > 600) return 3;
    return 1;
  }

  double _calculateAspectRatio(double width, int crossAxisCount) {
    if (crossAxisCount == 1) return 2.5;
    if (crossAxisCount == 2) return 1.4;
    return 1;
  }
}

class _IncidentTypeCard extends StatelessWidget {
  final IncidentType incidentType;
  final int index;

  const _IncidentTypeCard({required this.incidentType, required this.index});

  @override
  Widget build(BuildContext context) {
    final missionsCount = incidentType.missions?.length ?? 0;
    final colors = [
      const Color(0xFF1E3A5F),
      const Color(0xFF2C5F8D),
      const Color(0xFF3A7CA5),
      const Color(0xFF4E8FB8),
    ];
    final cardColor = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [cardColor, cardColor.withValues(alpha: 0.85)],
        ),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showIncidentTypeDetails(context, incidentType),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  incidentType.incidentTypeName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.category_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'الفئة: ${incidentType.className}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.task_alt_rounded, size: 18, color: cardColor),
                      const SizedBox(width: 6),
                      Text(
                        '$missionsCount مهمة',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cardColor,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: cardColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showIncidentTypeDetails(
    BuildContext context,
    IncidentType incidentType,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _IncidentTypeDetailsSheet(incidentType: incidentType),
    );
  }
}

class _IncidentTypeDetailsSheet extends StatelessWidget {
  final IncidentType incidentType;

  const _IncidentTypeDetailsSheet({required this.incidentType});

  @override
  Widget build(BuildContext context) {
    final missions = incidentType.missions ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [appColor, Color(0xFF2C5F8D)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            incidentType.incidentTypeName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: appColor,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'الفئة: ${incidentType.className}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: appColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: appColor, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'المهام المرتبطة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: appColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (missions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_late_outlined,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد مهام متاحة',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: missions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final mission = missions[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appColor.withOpacity(0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: appColor.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [appColor, Color(0xFF2C5F8D)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${mission.order ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mission.missionClassName ?? 'غير متوفر',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '#${mission.missionName ?? 'غير متوفر'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: appColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
