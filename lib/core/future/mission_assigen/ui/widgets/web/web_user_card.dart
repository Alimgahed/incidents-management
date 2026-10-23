import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';

class WebUserCard extends StatelessWidget {
  final ActiveUser user;
  final bool isSelected;
  final VoidCallback onToggle;

  const WebUserCard({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onToggle,
  });

  // Deterministic pastel palette generator for initials avatar
  static const List<_AvatarPalette> _palettes = [
    _AvatarPalette(bg: Color(0xFFDCFCE7), fg: Color(0xFF15803D)), // Mint green
    _AvatarPalette(bg: Color(0xFFF3E8FF), fg: Color(0xFF7E22CE)), // Lavender purple
    _AvatarPalette(bg: Color(0xFFE0F2FE), fg: Color(0xFF0369A1)), // Sky cyan
    _AvatarPalette(bg: Color(0xFFFFEDD5), fg: Color(0xFFC2410C)), // Peach orange
    _AvatarPalette(bg: Color(0xFFFCE7F3), fg: Color(0xFFBE185D)), // Rose pink
    _AvatarPalette(bg: Color(0xFFFEF3C7), fg: Color(0xFFB45309)), // Amber yellow
    _AvatarPalette(bg: Color(0xFFE0E7FF), fg: Color(0xFF4338CA)), // Indigo
    _AvatarPalette(bg: Color(0xFFCCFBF1), fg: Color(0xFF0F766E)), // Teal
  ];

  _AvatarPalette _getPalette(String name) {
    if (name.isEmpty) return _palettes[0];
    final index = name.hashCode.abs() % _palettes.length;
    return _palettes[index];
  }

  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) return 'م';
    final trimmed = name.trim();
    // Return first character
    return trimmed.characters.first;
  }

  @override
  Widget build(BuildContext context) {
    final name = user.empName ?? user.username ?? 'مستخدم';
    final palette = _getPalette(name);
    final initial = _getInitial(name);
    final isAvailable = user.isActive != false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(12),
        hoverColor: isSelected ? const Color(0xFFEBF5FF) : const Color(0xFFF8FAFC),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF2563EB).withAlpha(15)
                    : Colors.black.withAlpha(5),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Row: Checkbox on start (right in RTL), 3-dots on end (left in RTL)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Checkbox
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          )
                        : null,
                  ),
                  // Options icon
                  const Icon(
                    Icons.more_vert_rounded,
                    color: Color(0xFF94A3B8),
                    size: 16,
                  ),
                ],
              ),

              // Center: Circular Avatar with initial
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: palette.bg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: palette.fg,
                    ),
                  ),
                ),
              ),

              // Employee Info: Name, Role, Sector
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.authorityName ?? 'موظف',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.sectorManagementName != null &&
                      user.sectorManagementName!.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      user.sectorManagementName!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF94A3B8),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),

              // Bottom Row: Availability / Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isAvailable ? 'متاح' : 'غير متاح',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isAvailable
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
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

class _AvatarPalette {
  final Color bg;
  final Color fg;
  const _AvatarPalette({required this.bg, required this.fg});
}
