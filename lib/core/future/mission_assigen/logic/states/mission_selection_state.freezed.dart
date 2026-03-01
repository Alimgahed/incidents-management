// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_selection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionSelectionState {

 Map<int, Set<dynamic>> get missionUserMap; int? get activeMissionId; String get searchQuery; String? get selectedAuthority; String? get selectedSector;
/// Create a copy of MissionSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionSelectionStateCopyWith<MissionSelectionState> get copyWith => _$MissionSelectionStateCopyWithImpl<MissionSelectionState>(this as MissionSelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionSelectionState&&const DeepCollectionEquality().equals(other.missionUserMap, missionUserMap)&&(identical(other.activeMissionId, activeMissionId) || other.activeMissionId == activeMissionId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedAuthority, selectedAuthority) || other.selectedAuthority == selectedAuthority)&&(identical(other.selectedSector, selectedSector) || other.selectedSector == selectedSector));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(missionUserMap),activeMissionId,searchQuery,selectedAuthority,selectedSector);

@override
String toString() {
  return 'MissionSelectionState(missionUserMap: $missionUserMap, activeMissionId: $activeMissionId, searchQuery: $searchQuery, selectedAuthority: $selectedAuthority, selectedSector: $selectedSector)';
}


}

/// @nodoc
abstract mixin class $MissionSelectionStateCopyWith<$Res>  {
  factory $MissionSelectionStateCopyWith(MissionSelectionState value, $Res Function(MissionSelectionState) _then) = _$MissionSelectionStateCopyWithImpl;
@useResult
$Res call({
 Map<int, Set<dynamic>> missionUserMap, int? activeMissionId, String searchQuery, String? selectedAuthority, String? selectedSector
});




}
/// @nodoc
class _$MissionSelectionStateCopyWithImpl<$Res>
    implements $MissionSelectionStateCopyWith<$Res> {
  _$MissionSelectionStateCopyWithImpl(this._self, this._then);

  final MissionSelectionState _self;
  final $Res Function(MissionSelectionState) _then;

/// Create a copy of MissionSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? missionUserMap = null,Object? activeMissionId = freezed,Object? searchQuery = null,Object? selectedAuthority = freezed,Object? selectedSector = freezed,}) {
  return _then(_self.copyWith(
missionUserMap: null == missionUserMap ? _self.missionUserMap : missionUserMap // ignore: cast_nullable_to_non_nullable
as Map<int, Set<dynamic>>,activeMissionId: freezed == activeMissionId ? _self.activeMissionId : activeMissionId // ignore: cast_nullable_to_non_nullable
as int?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedAuthority: freezed == selectedAuthority ? _self.selectedAuthority : selectedAuthority // ignore: cast_nullable_to_non_nullable
as String?,selectedSector: freezed == selectedSector ? _self.selectedSector : selectedSector // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MissionSelectionState].
extension MissionSelectionStatePatterns on MissionSelectionState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MissionSelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MissionSelectionState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MissionSelectionState value)  $default,){
final _that = this;
switch (_that) {
case _MissionSelectionState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MissionSelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _MissionSelectionState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<int, Set<dynamic>> missionUserMap,  int? activeMissionId,  String searchQuery,  String? selectedAuthority,  String? selectedSector)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MissionSelectionState() when $default != null:
return $default(_that.missionUserMap,_that.activeMissionId,_that.searchQuery,_that.selectedAuthority,_that.selectedSector);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<int, Set<dynamic>> missionUserMap,  int? activeMissionId,  String searchQuery,  String? selectedAuthority,  String? selectedSector)  $default,) {final _that = this;
switch (_that) {
case _MissionSelectionState():
return $default(_that.missionUserMap,_that.activeMissionId,_that.searchQuery,_that.selectedAuthority,_that.selectedSector);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<int, Set<dynamic>> missionUserMap,  int? activeMissionId,  String searchQuery,  String? selectedAuthority,  String? selectedSector)?  $default,) {final _that = this;
switch (_that) {
case _MissionSelectionState() when $default != null:
return $default(_that.missionUserMap,_that.activeMissionId,_that.searchQuery,_that.selectedAuthority,_that.selectedSector);case _:
  return null;

}
}

}

/// @nodoc


class _MissionSelectionState implements MissionSelectionState {
  const _MissionSelectionState({final  Map<int, Set<dynamic>> missionUserMap = const {}, this.activeMissionId, this.searchQuery = '', this.selectedAuthority = null, this.selectedSector = null}): _missionUserMap = missionUserMap;
  

 final  Map<int, Set<dynamic>> _missionUserMap;
@override@JsonKey() Map<int, Set<dynamic>> get missionUserMap {
  if (_missionUserMap is EqualUnmodifiableMapView) return _missionUserMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_missionUserMap);
}

@override final  int? activeMissionId;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  String? selectedAuthority;
@override@JsonKey() final  String? selectedSector;

/// Create a copy of MissionSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MissionSelectionStateCopyWith<_MissionSelectionState> get copyWith => __$MissionSelectionStateCopyWithImpl<_MissionSelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MissionSelectionState&&const DeepCollectionEquality().equals(other._missionUserMap, _missionUserMap)&&(identical(other.activeMissionId, activeMissionId) || other.activeMissionId == activeMissionId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.selectedAuthority, selectedAuthority) || other.selectedAuthority == selectedAuthority)&&(identical(other.selectedSector, selectedSector) || other.selectedSector == selectedSector));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_missionUserMap),activeMissionId,searchQuery,selectedAuthority,selectedSector);

@override
String toString() {
  return 'MissionSelectionState(missionUserMap: $missionUserMap, activeMissionId: $activeMissionId, searchQuery: $searchQuery, selectedAuthority: $selectedAuthority, selectedSector: $selectedSector)';
}


}

/// @nodoc
abstract mixin class _$MissionSelectionStateCopyWith<$Res> implements $MissionSelectionStateCopyWith<$Res> {
  factory _$MissionSelectionStateCopyWith(_MissionSelectionState value, $Res Function(_MissionSelectionState) _then) = __$MissionSelectionStateCopyWithImpl;
@override @useResult
$Res call({
 Map<int, Set<dynamic>> missionUserMap, int? activeMissionId, String searchQuery, String? selectedAuthority, String? selectedSector
});




}
/// @nodoc
class __$MissionSelectionStateCopyWithImpl<$Res>
    implements _$MissionSelectionStateCopyWith<$Res> {
  __$MissionSelectionStateCopyWithImpl(this._self, this._then);

  final _MissionSelectionState _self;
  final $Res Function(_MissionSelectionState) _then;

/// Create a copy of MissionSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? missionUserMap = null,Object? activeMissionId = freezed,Object? searchQuery = null,Object? selectedAuthority = freezed,Object? selectedSector = freezed,}) {
  return _then(_MissionSelectionState(
missionUserMap: null == missionUserMap ? _self._missionUserMap : missionUserMap // ignore: cast_nullable_to_non_nullable
as Map<int, Set<dynamic>>,activeMissionId: freezed == activeMissionId ? _self.activeMissionId : activeMissionId // ignore: cast_nullable_to_non_nullable
as int?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,selectedAuthority: freezed == selectedAuthority ? _self.selectedAuthority : selectedAuthority // ignore: cast_nullable_to_non_nullable
as String?,selectedSector: freezed == selectedSector ? _self.selectedSector : selectedSector // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
