import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/user_management_filter_state.dart';

class UserManagementFilterCubit extends Cubit<UserManagementFilterState> {
  UserManagementFilterCubit() : super(const UserManagementFilterState());

  void updateFilters({
    String? empCode,
    String? name,
    String? status,
    String? authorityName,
    String? groupName,
    String? sectorName,
    String? className,
    bool clearStatus = false,
    bool clearAuthorityName = false,
    bool clearGroupName = false,
    bool clearSectorName = false,
    bool clearClassName = false,
  }) {
    emit(state.copyWith(
      empCode: empCode,
      name: name,
      status: status,
      authorityName: authorityName,
      groupName: groupName,
      sectorName: sectorName,
      className: className,
      clearStatus: clearStatus,
      clearAuthorityName: clearAuthorityName,
      clearGroupName: clearGroupName,
      clearSectorName: clearSectorName,
      clearClassName: clearClassName,
    ));
  }

  void resetFilters() {
    emit(const UserManagementFilterState());
  }

  List<ActiveUser> filterUsers(List<ActiveUser> users) {
    return users.where((user) {
      if (state.empCode.isNotEmpty) {
        final codeMatch = user.empCode?.toLowerCase().contains(state.empCode.toLowerCase()) ?? false;
        if (!codeMatch) return false;
      }
      
      if (state.name.isNotEmpty) {
        final searchTerms = state.name.toLowerCase().split(' ').where((s) => s.isNotEmpty).toList();
        final empName = user.empName?.toLowerCase() ?? '';
        final username = user.username?.toLowerCase() ?? '';
        
        bool matchesName = true;
        for (var term in searchTerms) {
          if (!empName.contains(term) && !username.contains(term)) {
            matchesName = false;
            break;
          }
        }
        if (!matchesName) return false;
      }

      if (state.status != null) {
        final isActive = user.isActive == true;
        if (state.status == 'نشط' && !isActive) return false;
        if (state.status == 'غير نشط' && isActive) return false;
      }

      if (state.authorityName != null && state.authorityName!.isNotEmpty) {
        if (user.authorityName != state.authorityName) return false;
      }

      if (state.groupName != null && state.groupName!.isNotEmpty) {
        if (user.groupName != state.groupName) return false;
      }

      if (state.sectorName != null && state.sectorName!.isNotEmpty) {
        if (user.sectorManagementName != state.sectorName) return false;
      }

      if (state.className != null && state.className!.isNotEmpty) {
        final hasClass = user.userClasses?.any((c) => c.classInfo?.className == state.className) ?? false;
        if (!hasClass) return false;
      }

      return true;
    }).toList();
  }
}
