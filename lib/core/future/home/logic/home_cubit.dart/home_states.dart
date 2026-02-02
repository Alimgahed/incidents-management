import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_states.freezed.dart';

@freezed
class HomeStates with _$HomeStates {
  const factory HomeStates.initial() = HomeInitial;
  const factory HomeStates.changed(int index) = HomeChanged;
}
