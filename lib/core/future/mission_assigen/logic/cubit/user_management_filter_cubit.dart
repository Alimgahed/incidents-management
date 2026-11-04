import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:incidents_managment/core/future/mission_assigen/data/model/all_active_user_model.dart';
import 'package:incidents_managment/core/future/mission_assigen/logic/states/user_management_filter_state.dart';
import 'package:incidents_managment/core/helpers/arabic_text_helper.dart';

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
    emit(
      state.copyWith(
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
      ),
    );
  }

  void resetFilters() {
    emit(const UserManagementFilterState());
  }

  List<ActiveUser> filterUsers(List<ActiveUser> users) {
    return users.where((user) {
      if (state.empCode.isNotEmpty) {
        final codeMatch =
            user.empCode?.toLowerCase().contains(state.empCode.toLowerCase()) ??
            false;
        if (!codeMatch) return false;
      }

      if (state.name.isNotEmpty) {
        final q = state.name.trim();
        final matchesName = ArabicTextHelper.contains(user.empName, q);
        final matchesUsername = (user.username ?? '').toLowerCase().contains(
          q.toLowerCase(),
        );
        final matchesCode = (user.empCode ?? '').toLowerCase().contains(
          q.toLowerCase(),
        );
        final matchesAuth = ArabicTextHelper.contains(user.authorityName, q);
        if (!matchesName && !matchesUsername && !matchesCode && !matchesAuth) {
          return false;
        }
      }

      if (state.status != null && state.status!.isNotEmpty) {
        final isActive = user.isActive != false;
        if ((state.status == 'نشط' || state.status == 'متاح') && !isActive) {
          return false;
        }
        if ((state.status == 'غير نشط' || state.status == 'غير متاح') &&
            isActive) {
          return false;
        }
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
        final hasClass =
            user.userClasses?.any(
              (c) => c.classInfo?.className == state.className,
            ) ??
            false;
        if (!hasClass) return false;
      }

      return true;
    }).toList();
  }
}
