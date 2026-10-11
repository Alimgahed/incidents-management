import 'package:flutter/material.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/constant/colors.dart';

class UserDataTable extends StatelessWidget {
  final List<ActiveUser> users;

  const UserDataTable({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.list, color: Color(0xFF1B4F8A), size: 22),
                const SizedBox(width: 8),
                Text(
                  'قائمة المستخدمين (${users.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B4F8A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Row(
              children: [
                _buildHeaderCell('المستخدم', flex: 2),
                _buildHeaderCell('كود الموظف', flex: 1),
                _buildHeaderCell('اسم المستخدم', flex: 1),
                _buildHeaderCell('الصلاحية', flex: 1),
                _buildHeaderCell('المجموعة', flex: 1),
                _buildHeaderCell('الإدارة / القطاع', flex: 2),
                _buildHeaderCell('الحالة', flex: 1, center: true),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Body
          if (users.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text('لا يوجد مستخدمين يطابقون شروط البحث', style: TextStyle(color: secondaryTextColor)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildTableRow(user);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String title, {required int flex, bool center = false}) {
    return Expanded(
      flex: flex,
      child: Row(
        mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          if (!center) const SizedBox(width: 4),
          if (!center) const Icon(Icons.unfold_more, size: 14, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  Widget _buildTableRow(ActiveUser user) {
    final name = user.empName?.trim().isNotEmpty == true ? user.empName! : (user.username ?? '—');
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final isActive = user.isActive == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // User Name & Avatar
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1B4F8A),
                  child: Text(
                    firstLetter,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.sectorManagementName ?? '—',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Emp Code
          Expanded(
            flex: 1,
            child: Text(
              user.empCode ?? '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
          // Username
          Expanded(
            flex: 1,
            child: Text(
              user.username ?? '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
          // Authority
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.authorityName == 'مدير النظام'
                      ? Colors.blue.shade50
                      : (user.authorityName == 'مدير عام' ? Colors.blue.shade50 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.authorityName ?? 'مستخدم',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: user.authorityName == 'مدير النظام'
                        ? Colors.blue.shade700
                        : (user.authorityName == 'مدير عام' ? Colors.blue.shade700 : Colors.grey.shade700),
                  ),
                ),
              ),
            ),
          ),
          // Group
          Expanded(
            flex: 1,
            child: Text(
              user.groupName ?? '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
          // Sector
          Expanded(
            flex: 2,
            child: Text(
              user.sectorManagementName ?? '—',
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'نشط' : 'غير نشط',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
