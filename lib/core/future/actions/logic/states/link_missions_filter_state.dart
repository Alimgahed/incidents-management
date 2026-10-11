import 'package:equatable/equatable.dart';

class LinkMissionsFilterState extends Equatable {
  final String searchName;
  final String? className;

  const LinkMissionsFilterState({
    this.searchName = '',
    this.className,
  });

  LinkMissionsFilterState copyWith({
    String? searchName,
    String? className,
    bool clearClassName = false,
  }) {
    return LinkMissionsFilterState(
      searchName: searchName ?? this.searchName,
      className: clearClassName ? null : (className ?? this.className),
    );
  }

  @override
  List<Object?> get props => [searchName, className];
}
