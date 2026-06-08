import re
import sys

def main():
    path = r'c:\Users\ali\incidents_managment\lib\core\future\mission_assigen\ui\screens\mission_assign_web.dart'
    
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Rename classes
    content = content.replace('class MissionAssignMobileScreen extends StatelessWidget {', 'class MissionAssignWebScreen extends StatelessWidget {')
    content = content.replace('const MissionAssignMobileScreen', 'const MissionAssignWebScreen')

    # 2. Fix the Scaffold layout in _MissionAssignView build
    view_build_pattern = r'(_PremiumAppBar\(incident:\s*incident,\s*isWide:\s*isWide\),.*?)(_BottomActionBar)'
    
    def repl_view_build(m):
        return """_PremiumAppBar(incident: incident, isWide: isWide),
              Expanded(
                child: isWide
                    ? _buildWideLayout(context, missions, () => _showConfirmSheet(context))
                    : _buildNarrowLayout(context, missions),
              ),
              if (!isWide)
                """ + m.group(2)
    
    content = re.sub(view_build_pattern, repl_view_build, content, flags=re.DOTALL)

    # 3. Completely replace _buildWideLayout
    wide_layout_pattern = r'Widget _buildWideLayout\([^)]+\)\s*\{.*?(?=Widget _buildNarrowLayout)'
    new_wide_layout = """Widget _buildWideLayout(
    BuildContext context,
    List<CurrentIncidentWithMissions> missions,
    VoidCallback onAssign,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 24, 40, 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 320,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border(
                    left: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: _MissionsSidebar(missions: missions, incident: incident),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: _UsersPanel(isWide: true, onAssign: onAssign),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  """
    content = re.sub(wide_layout_pattern, new_wide_layout, content, flags=re.DOTALL)

    # 4. Completely replace _PremiumAppBar
    appbar_pattern = r'class _PremiumAppBar extends StatelessWidget \{.*?(?=class _GlassIconButton|\Z)'
    new_appbar = """class _PremiumAppBar extends StatelessWidget {
  final CurrentIncidentModel incident;
  final bool isWide;

  const _PremiumAppBar({required this.incident, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final headline = incidentDescriptionHeadline(
      incident.currentIncidentDescription,
    ).trim();
    final title = headline.isEmpty ? 'بدون وصف' : headline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black87, size: 18),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text("الرئيسية", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.chevron_left, size: 16, color: Colors.grey)),
                    Text("تعيين المهام", style: TextStyle(color: appColor, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isWide) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _AppBarChip(
                        icon: Icons.location_on_rounded,
                        label: incident.branchName ?? 'غير محدد',
                      ),
                      const SizedBox(width: 8),
                      if (incident.currentIncidentTypeName != null)
                        _AppBarChip(
                          icon: Icons.category_rounded,
                          label: incident.currentIncidentTypeName!,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          BlocBuilder<MissionSelectionCubit, MissionSelectionState>(
            builder: (context, state) {
              final count = context
                  .read<MissionSelectionCubit>()
                  .assignedMissionsCount;
              if (count == 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: appColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: appColor.withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: appColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$count",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "مهام محددة",
                      style: TextStyle(
                        color: appColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

"""
    content = re.sub(appbar_pattern, new_appbar, content, flags=re.DOTALL)

    # 5. Fix _UsersPanel constructor and call to _UsersList
    content = re.sub(
        r'class _UsersPanel extends StatelessWidget \{.*?const _UsersPanel\(\{required this\.isWide\}\);',
        'class _UsersPanel extends StatelessWidget {\n  final bool isWide;\n  final VoidCallback? onAssign;\n  const _UsersPanel({required this.isWide, this.onAssign});',
        content,
        flags=re.DOTALL
    )

    content = re.sub(
        r'loaded:\s*\(users\)\s*=>\s*_UsersList\(users:\s*users,\s*isWide:\s*isWide\),',
        'loaded: (users) => _UsersList(users: users, isWide: isWide, onAssign: onAssign),',
        content
    )

    # 6. Fix _UsersList constructor and build for wide mode
    content = re.sub(
        r'class _UsersList extends StatelessWidget \{.*?const _UsersList\(\{required this\.users, required this\.isWide\}\);',
        'class _UsersList extends StatelessWidget {\n  final List<dynamic> users;\n  final bool isWide;\n  final VoidCallback? onAssign;\n\n  const _UsersList({required this.users, required this.isWide, this.onAssign});',
        content,
        flags=re.DOTALL
    )
    
    wide_mode_pattern = r'(if \(isWide\) \{.*?Expanded\(\s*child:\s*GridView\.builder\(.*?\),.*?)\n\s+\]\,\n\s+\),\n\s+\);'
    footer_code = """
                if (onAssign != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text("إلغاء", style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: onAssign,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4F8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text("تعيين المهام", style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
"""
    match = re.search(wide_mode_pattern, content, flags=re.DOTALL)
    if match:
        new_wide_mode = match.group(1) + footer_code + "\n              ],\n            ),\n          );"
        content = content[:match.start()] + new_wide_mode + content[match.end():]

    # 7. Replace _UserCard
    user_card_pattern = r'class _UserCard extends StatelessWidget \{.*?(?=class _BottomActionBar|\Z)'
    new_user_card = '''class _UserCard extends StatelessWidget {
  final dynamic user;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  Color _avatarColor() {
    final name = user.empName ?? '';
    if (name.isEmpty) return appColor;
    final colors = [
      const Color(0xFF1B4F8A), const Color(0xFF059669),
      const Color(0xFFD97706), const Color(0xFF7C3AED),
      const Color(0xFFDC2626), const Color(0xFF0891B2),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? appColor.withAlpha(10) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? appColor.withAlpha(80) : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? appColor : color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      (user.empName?[0] ?? "").toUpperCase(),
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.empName ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isSelected ? appColor : const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "${user.authorityName ?? ''} - ${user.sectorManagementName ?? ''}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: appColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

'''
    content = re.sub(user_card_pattern, new_user_card, content, flags=re.DOTALL)
    
    # Write back
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print("Refactor applied successfully.")

if __name__ == '__main__':
    main()
