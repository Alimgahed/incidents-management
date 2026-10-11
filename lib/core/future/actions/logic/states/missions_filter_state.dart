import 'package:equatable/equatable.dart';

class MissionsFilterState extends Equatable {
  final String searchName;
  final String? className;

  const MissionsFilterState({
    this.searchName = '',
    this.className,
  });

  MissionsFilterState copyWith({
    String? searchName,
    String? className,
    bool clearClassName = false,
  }) {
    return MissionsFilterState(
      searchName: searchName ?? this.searchName,
      className: clearClassName ? null : (className ?? this.className),
    );
  }

  bool get hasActiveFilters => searchName.isNotEmpty || className != null;

  @override
  List<Object?> get props => [searchName, className];
}
