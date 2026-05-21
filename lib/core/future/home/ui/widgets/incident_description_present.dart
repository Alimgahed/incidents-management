import 'package:flutter/material.dart';
import 'package:incidents_managment/core/helpers/incident_description_parse.dart';

/// Renders a CMS incident description as a short headline + optional structured rows.
class IncidentDescriptionPresentation extends StatelessWidget {
  const IncidentDescriptionPresentation({
    super.key,
    required this.description,
    this.compact = false,
    this.showRawExpansion = true,
    this.textColor,
    this.secondaryColor,
  });

  final String? description;
  final bool compact;
  final bool showRawExpansion;
  final Color? textColor;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    final parsed = IncidentDescriptionParser.parse(description);
    final primary = textColor ?? const Color(0xFF0F172A);
    final secondary = secondaryColor ?? const Color(0xFF64748B);

    if (parsed.raw.isEmpty) {
      return Text(
        'لا يوجد وصف متاح',
        style: TextStyle(
          fontSize: compact ? 14 : 15,
          color: secondary,
          height: 1.5,
        ),
      );
    }

    final titleStyle = TextStyle(
      fontSize: compact ? 15 : 16,
      fontWeight: FontWeight.w700,
      color: primary,
      height: 1.45,
    );
    final metaStyle = TextStyle(
      fontSize: compact ? 13 : 14,
      color: secondary,
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parsed.displayTitle, style: titleStyle),
        if (parsed.locationFromDescription != null) ...[
          const SizedBox(height: 8),
          _MetaRow(
            icon: Icons.place_outlined,
            text: parsed.locationFromDescription!,
            style: metaStyle,
          ),
        ],
        if (parsed.technicalDetails != null) ...[
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.tune_rounded,
            text: parsed.technicalDetails!,
            style: metaStyle,
          ),
        ],
        if (showRawExpansion && parsed.looksStructured) ...[
          const SizedBox(height: 10),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'النص الكامل من المصدر',
                style: TextStyle(
                  fontSize: 12,
                  color: secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SelectableText(
                    parsed.raw,
                    style: TextStyle(
                      fontSize: 13,
                      color: primary.withValues(alpha: 0.85),
                      height: 1.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else if (!showRawExpansion &&
            parsed.raw.trim().isNotEmpty &&
            !parsed.looksStructured) ...[
          const SizedBox(height: 6),
          SelectableText(
            parsed.raw,
            style: TextStyle(fontSize: 14, color: primary, height: 1.55),
          ),
        ],
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text, required this.style});

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: style.color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

/// One-line title for dense UI (app bars, map cards).
String incidentDescriptionHeadline(String? description) {
  return IncidentDescriptionParser.parse(description).displayTitle;
}
