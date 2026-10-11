import 'package:equatable/equatable.dart';

class UserManagementFilterState extends Equatable {
  final String empCode;
  final String name; // Searches both empName and username
  final String? status; // 'نشط' or 'غير نشط' or null for all
  final String? authorityName;
  final String? groupName;
  final String? sectorName;
  final String? className;

  const UserManagementFilterState({
    this.empCode = '',
    this.name = '',
    this.status,
    this.authorityName,
    this.groupName,
    this.sectorName,
    this.className,
  });

  UserManagementFilterState copyWith({
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
    return UserManagementFilterState(
      empCode: empCode ?? this.empCode,
      name: name ?? this.name,
      status: clearStatus ? null : (status ?? this.status),
      authorityName: clearAuthorityName ? null : (authorityName ?? this.authorityName),
      groupName: clearGroupName ? null : (groupName ?? this.groupName),
      sectorName: clearSectorName ? null : (sectorName ?? this.sectorName),
      className: clearClassName ? null : (className ?? this.className),
    );
  }

  bool get hasActiveFilters =>
      empCode.isNotEmpty ||
      name.isNotEmpty ||
      status != null ||
      authorityName != null ||
      groupName != null ||
      sectorName != null ||
      className != null;

  @override
  List<Object?> get props => [
        empCode,
        name,
        status,
        authorityName,
        groupName,
        sectorName,
        className,
      ];
}
