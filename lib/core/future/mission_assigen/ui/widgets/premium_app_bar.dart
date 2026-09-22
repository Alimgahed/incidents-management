import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/constant/colors.dart';
import 'package:incidents_managment/core/future/actions/data/models/current_incident.dart/current_incident_model.dart';
import 'package:incidents_managment/core/future/home/ui/widgets/incident_description_present.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/cubit/mission_selction_cubit.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/mission_selection_state.dart';
import 'severity_badge.dart'; // From previous extraction

const _kGradientStart = appColor;
const _kGradientEnd = Color(0xFF0D3B6E);

class PremiumAppBar extends StatelessWidget {
  final CurrentIncidentModel incident;
  final bool isWide;

  const PremiumAppBar({
    super.key,
    required this.incident,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    final headline = incidentDescriptionHeadline(
      incident.currentIncidentDescription,
    ).trim();
    final title = headline.isEmpty ? 'بدون وصف' : headline;

    return Container(
      // SafeArea naturally handles the top padding properly, avoiding manual MediaQuery padding risks
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: [
              // Back button
              GlassIconButton(
                icon: Icons.arrow_back_ios_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 14),
              // Title area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "تعيين مسؤول للمهمة",
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isWide) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          AppBarChip(
                            icon: Icons.location_on_rounded,
                            label: incident.branchName ?? 'غير محدد',
                          ),
                          const SizedBox(width: 8),
                          if (incident.currentIncidentTypeName != null)
                            AppBarChip(
                              icon: Icons.category_rounded,
                              label: incident.currentIncidentTypeName!,
                            ),
                          const SizedBox(width: 8),
                          SeverityBadge(
                            severity: incident.currentIncidentSeverity,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Mission count badge
              BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
                builder: (context, state) {
                  final count = context
                      .read<MissionSelectionCubit>()
                      .assignedMissionsCount;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(51)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_turned_in_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "\$count مهمة",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kGradientStart, _kGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kGradientEnd.withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const GlassIconButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(38)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class AppBarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const AppBarChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
