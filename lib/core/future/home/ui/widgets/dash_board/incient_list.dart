import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/enms.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_cubit.dart';
import 'package:incidents_managment/core/future/home/logic/dash_board_cubit/dash_board_state.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/dash_board/list_header.dart';
import 'package:incidents_managment/core/helpers/date_format.dart';
import 'package:incidents_managment/core/theming/styling.dart';

class IncidentCard extends StatelessWidget {
  final CurrentIncidentModel incident;
  final bool isSelected;
  final VoidCallback onTap;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severity = incident.currentIncidentSeverity!;
    final status = incident.currentIncidentStatus!;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? appColor : Colors.grey.shade200,
              width: 1.5,
            ),
          ),

          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),

                child: Icon(
                  Icons.warning_amber_rounded,
                  color: getStatusColor(status),
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
                      style: TextStyles.size14(
                        fontWeight: FontWeight.w600,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.currentIncidentTypeName ?? 'لا يوجد وصف',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.size12(color: secondaryTextColor),
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
                            color: getSeverityColor(severity).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            getSeverityArabic(severity),
                            style: TextStyles.size12(
                              fontWeight: FontWeight.bold,
                              color: getSeverityColor(severity),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (incident.currentIncidentCreatedAt != null)
                          Text(
                            incident.currentIncidentCreatedAt!.timeAgoArabic(),
                            style: TextStyles.size12(color: secondaryTextColor),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  getStatusArabic(status),
                  style: TextStyles.size12(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======================= INCIDENT LIST WIDGET =======================
/// ======================= INCIDENT LIST WIDGET =======================
class IncidentsList extends StatelessWidget {
  final List<CurrentIncidentModel> allIncidents;

  const IncidentsList({super.key, required this.allIncidents});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final cubit = context.read<DashboardCubit>();

        // Use the cubit's filterIncidents function to get filtered results
        final incidents = cubit.filterIncidents(allIncidents);

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DashboardListHeader(count: incidents.length),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: incidents.length,

                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      final isSelected =
                          cubit.selectedIncident?.currentIncidentId ==
                          incident.currentIncidentId;

                      return IncidentCard(
                        incident: incident,
                        isSelected: isSelected,
                        onTap: () => cubit.selectIncident(incident),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
