import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/actions/data/models/incident_type/all_incident_type.dart';
import 'package:incidents_managment/core/future/actions/ui/widgets/incident_types/incident_missions_dialog.dart';

class IncidentTypeGrid extends StatelessWidget {
  final List<IncidentType> incidentTypes;

  const IncidentTypeGrid({super.key, required this.incidentTypes});

  @override
  Widget build(BuildContext context) {
    if (incidentTypes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(Icons.category_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'لا توجد أنواع أزمات تطابق الفلتر',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cross axis count based on available width
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: incidentTypes.length,
          itemBuilder: (context, index) {
            final type = incidentTypes[index];
            return _IncidentTypeCard(incidentType: type);
          },
        );
      },
    );
  }
}

class _IncidentTypeCard extends StatelessWidget {
  final IncidentType incidentType;

  const _IncidentTypeCard({required this.incidentType});

  Color _getColorForClass(String? className) {
    if (className == null) return Colors.grey;
    if (className.contains('مياه')) return Colors.blue;
    if (className.contains('صرف')) return Colors.purple;
    if (className.contains('كهرباء') || className.contains('طاقة')) return Colors.red;
    if (className.contains('طرق')) return Colors.green;
    if (className.contains('أمن')) return Colors.teal;
    if (className.contains('اتصالات') || className.contains('معلومات')) return Colors.orange;
    if (className.contains('صحة') || className.contains('سلامة')) return Colors.blueAccent;
    return Colors.indigo;
  }

  IconData _getIconForClass(String? className) {
    if (className == null) return Icons.category;
    if (className.contains('مياه')) return Icons.water_drop;
    if (className.contains('صرف')) return Icons.plumbing;
    if (className.contains('كهرباء') || className.contains('طاقة')) return Icons.bolt;
    if (className.contains('طرق')) return Icons.add_road;
    if (className.contains('أمن')) return Icons.security;
    if (className.contains('اتصالات')) return Icons.cell_tower;
    if (className.contains('معلومات')) return Icons.dns;
    if (className.contains('صحة') || className.contains('سلامة')) return Icons.medical_services;
    return Icons.domain;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForClass(incidentType.className);
    final icon = _getIconForClass(incidentType.className);
    final missionsCount = incidentType.missions?.length ?? 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showIncidentMissionsDialog(context, incidentType);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: color, width: 4), // Arabic RTL border
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      incidentType.incidentTypeName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الفئة: ${incidentType.className ?? "غير محدد"}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.arrow_back_ios, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(
                          '$missionsCount مهام مرتبطة',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
