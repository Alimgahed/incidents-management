// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dash_board_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState()';
}


}

/// @nodoc
class $DashboardStateCopyWith<$Res>  {
$DashboardStateCopyWith(DashboardState _, $Res Function(DashboardState) __);
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DashboardInitial value)?  initial,TResult Function( DashboardIncidentSelected value)?  incidentSelected,TResult Function( DashboardIncidentDeselected value)?  incidentDeselected,TResult Function( DashboardFilterChanged value)?  filterChanged,TResult Function( DashboardSearchChanged value)?  searchChanged,TResult Function( DashboardUpdating value)?  updating,TResult Function( DashboardUpdateRequested value)?  updateRequested,TResult Function( DashboardMissionUpdateRequested value)?  missionUpdateRequested,TResult Function( DashboardIncidentUpdated value)?  incidentUpdated,TResult Function( DashboardMissionUpdated value)?  missionUpdated,TResult Function( DashboardError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial(_that);case DashboardIncidentSelected() when incidentSelected != null:
return incidentSelected(_that);case DashboardIncidentDeselected() when incidentDeselected != null:
return incidentDeselected(_that);case DashboardFilterChanged() when filterChanged != null:
return filterChanged(_that);case DashboardSearchChanged() when searchChanged != null:
return searchChanged(_that);case DashboardUpdating() when updating != null:
return updating(_that);case DashboardUpdateRequested() when updateRequested != null:
return updateRequested(_that);case DashboardMissionUpdateRequested() when missionUpdateRequested != null:
return missionUpdateRequested(_that);case DashboardIncidentUpdated() when incidentUpdated != null:
return incidentUpdated(_that);case DashboardMissionUpdated() when missionUpdated != null:
return missionUpdated(_that);case DashboardError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DashboardInitial value)  initial,required TResult Function( DashboardIncidentSelected value)  incidentSelected,required TResult Function( DashboardIncidentDeselected value)  incidentDeselected,required TResult Function( DashboardFilterChanged value)  filterChanged,required TResult Function( DashboardSearchChanged value)  searchChanged,required TResult Function( DashboardUpdating value)  updating,required TResult Function( DashboardUpdateRequested value)  updateRequested,required TResult Function( DashboardMissionUpdateRequested value)  missionUpdateRequested,required TResult Function( DashboardIncidentUpdated value)  incidentUpdated,required TResult Function( DashboardMissionUpdated value)  missionUpdated,required TResult Function( DashboardError value)  error,}){
final _that = this;
switch (_that) {
case DashboardInitial():
return initial(_that);case DashboardIncidentSelected():
return incidentSelected(_that);case DashboardIncidentDeselected():
return incidentDeselected(_that);case DashboardFilterChanged():
return filterChanged(_that);case DashboardSearchChanged():
return searchChanged(_that);case DashboardUpdating():
return updating(_that);case DashboardUpdateRequested():
return updateRequested(_that);case DashboardMissionUpdateRequested():
return missionUpdateRequested(_that);case DashboardIncidentUpdated():
return incidentUpdated(_that);case DashboardMissionUpdated():
return missionUpdated(_that);case DashboardError():
return error(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DashboardInitial value)?  initial,TResult? Function( DashboardIncidentSelected value)?  incidentSelected,TResult? Function( DashboardIncidentDeselected value)?  incidentDeselected,TResult? Function( DashboardFilterChanged value)?  filterChanged,TResult? Function( DashboardSearchChanged value)?  searchChanged,TResult? Function( DashboardUpdating value)?  updating,TResult? Function( DashboardUpdateRequested value)?  updateRequested,TResult? Function( DashboardMissionUpdateRequested value)?  missionUpdateRequested,TResult? Function( DashboardIncidentUpdated value)?  incidentUpdated,TResult? Function( DashboardMissionUpdated value)?  missionUpdated,TResult? Function( DashboardError value)?  error,}){
final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial(_that);case DashboardIncidentSelected() when incidentSelected != null:
return incidentSelected(_that);case DashboardIncidentDeselected() when incidentDeselected != null:
return incidentDeselected(_that);case DashboardFilterChanged() when filterChanged != null:
return filterChanged(_that);case DashboardSearchChanged() when searchChanged != null:
return searchChanged(_that);case DashboardUpdating() when updating != null:
return updating(_that);case DashboardUpdateRequested() when updateRequested != null:
return updateRequested(_that);case DashboardMissionUpdateRequested() when missionUpdateRequested != null:
return missionUpdateRequested(_that);case DashboardIncidentUpdated() when incidentUpdated != null:
return incidentUpdated(_that);case DashboardMissionUpdated() when missionUpdated != null:
return missionUpdated(_that);case DashboardError() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( CurrentIncidentModel incident)?  incidentSelected,TResult Function()?  incidentDeselected,TResult Function( String filter)?  filterChanged,TResult Function( String query)?  searchChanged,TResult Function()?  updating,TResult Function( int incidentId,  int newStatus,  int newSeverity)?  updateRequested,TResult Function( int incidentId,  int missionId,  int newStatus)?  missionUpdateRequested,TResult Function( CurrentIncidentModel incident)?  incidentUpdated,TResult Function( CurrentIncidentModel incident,  int missionId)?  missionUpdated,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial();case DashboardIncidentSelected() when incidentSelected != null:
return incidentSelected(_that.incident);case DashboardIncidentDeselected() when incidentDeselected != null:
return incidentDeselected();case DashboardFilterChanged() when filterChanged != null:
return filterChanged(_that.filter);case DashboardSearchChanged() when searchChanged != null:
return searchChanged(_that.query);case DashboardUpdating() when updating != null:
return updating();case DashboardUpdateRequested() when updateRequested != null:
return updateRequested(_that.incidentId,_that.newStatus,_that.newSeverity);case DashboardMissionUpdateRequested() when missionUpdateRequested != null:
return missionUpdateRequested(_that.incidentId,_that.missionId,_that.newStatus);case DashboardIncidentUpdated() when incidentUpdated != null:
return incidentUpdated(_that.incident);case DashboardMissionUpdated() when missionUpdated != null:
return missionUpdated(_that.incident,_that.missionId);case DashboardError() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( CurrentIncidentModel incident)  incidentSelected,required TResult Function()  incidentDeselected,required TResult Function( String filter)  filterChanged,required TResult Function( String query)  searchChanged,required TResult Function()  updating,required TResult Function( int incidentId,  int newStatus,  int newSeverity)  updateRequested,required TResult Function( int incidentId,  int missionId,  int newStatus)  missionUpdateRequested,required TResult Function( CurrentIncidentModel incident)  incidentUpdated,required TResult Function( CurrentIncidentModel incident,  int missionId)  missionUpdated,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case DashboardInitial():
return initial();case DashboardIncidentSelected():
return incidentSelected(_that.incident);case DashboardIncidentDeselected():
return incidentDeselected();case DashboardFilterChanged():
return filterChanged(_that.filter);case DashboardSearchChanged():
return searchChanged(_that.query);case DashboardUpdating():
return updating();case DashboardUpdateRequested():
return updateRequested(_that.incidentId,_that.newStatus,_that.newSeverity);case DashboardMissionUpdateRequested():
return missionUpdateRequested(_that.incidentId,_that.missionId,_that.newStatus);case DashboardIncidentUpdated():
return incidentUpdated(_that.incident);case DashboardMissionUpdated():
return missionUpdated(_that.incident,_that.missionId);case DashboardError():
return error(_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( CurrentIncidentModel incident)?  incidentSelected,TResult? Function()?  incidentDeselected,TResult? Function( String filter)?  filterChanged,TResult? Function( String query)?  searchChanged,TResult? Function()?  updating,TResult? Function( int incidentId,  int newStatus,  int newSeverity)?  updateRequested,TResult? Function( int incidentId,  int missionId,  int newStatus)?  missionUpdateRequested,TResult? Function( CurrentIncidentModel incident)?  incidentUpdated,TResult? Function( CurrentIncidentModel incident,  int missionId)?  missionUpdated,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case DashboardInitial() when initial != null:
return initial();case DashboardIncidentSelected() when incidentSelected != null:
return incidentSelected(_that.incident);case DashboardIncidentDeselected() when incidentDeselected != null:
return incidentDeselected();case DashboardFilterChanged() when filterChanged != null:
return filterChanged(_that.filter);case DashboardSearchChanged() when searchChanged != null:
return searchChanged(_that.query);case DashboardUpdating() when updating != null:
return updating();case DashboardUpdateRequested() when updateRequested != null:
return updateRequested(_that.incidentId,_that.newStatus,_that.newSeverity);case DashboardMissionUpdateRequested() when missionUpdateRequested != null:
return missionUpdateRequested(_that.incidentId,_that.missionId,_that.newStatus);case DashboardIncidentUpdated() when incidentUpdated != null:
return incidentUpdated(_that.incident);case DashboardMissionUpdated() when missionUpdated != null:
return missionUpdated(_that.incident,_that.missionId);case DashboardError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DashboardInitial implements DashboardState {
  const DashboardInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.initial()';
}


}




/// @nodoc


class DashboardIncidentSelected implements DashboardState {
  const DashboardIncidentSelected(this.incident);
  

 final  CurrentIncidentModel incident;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardIncidentSelectedCopyWith<DashboardIncidentSelected> get copyWith => _$DashboardIncidentSelectedCopyWithImpl<DashboardIncidentSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardIncidentSelected&&(identical(other.incident, incident) || other.incident == incident));
}


@override
int get hashCode => Object.hash(runtimeType,incident);

@override
String toString() {
  return 'DashboardState.incidentSelected(incident: $incident)';
}


}

/// @nodoc
abstract mixin class $DashboardIncidentSelectedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardIncidentSelectedCopyWith(DashboardIncidentSelected value, $Res Function(DashboardIncidentSelected) _then) = _$DashboardIncidentSelectedCopyWithImpl;
@useResult
$Res call({
 CurrentIncidentModel incident
});




}
/// @nodoc
class _$DashboardIncidentSelectedCopyWithImpl<$Res>
    implements $DashboardIncidentSelectedCopyWith<$Res> {
  _$DashboardIncidentSelectedCopyWithImpl(this._self, this._then);

  final DashboardIncidentSelected _self;
  final $Res Function(DashboardIncidentSelected) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? incident = null,}) {
  return _then(DashboardIncidentSelected(
null == incident ? _self.incident : incident // ignore: cast_nullable_to_non_nullable
as CurrentIncidentModel,
  ));
}


}

/// @nodoc


class DashboardIncidentDeselected implements DashboardState {
  const DashboardIncidentDeselected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardIncidentDeselected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.incidentDeselected()';
}


}




/// @nodoc


class DashboardFilterChanged implements DashboardState {
  const DashboardFilterChanged(this.filter);
  

 final  String filter;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardFilterChangedCopyWith<DashboardFilterChanged> get copyWith => _$DashboardFilterChangedCopyWithImpl<DashboardFilterChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardFilterChanged&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,filter);

@override
String toString() {
  return 'DashboardState.filterChanged(filter: $filter)';
}


}

/// @nodoc
abstract mixin class $DashboardFilterChangedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardFilterChangedCopyWith(DashboardFilterChanged value, $Res Function(DashboardFilterChanged) _then) = _$DashboardFilterChangedCopyWithImpl;
@useResult
$Res call({
 String filter
});




}
/// @nodoc
class _$DashboardFilterChangedCopyWithImpl<$Res>
    implements $DashboardFilterChangedCopyWith<$Res> {
  _$DashboardFilterChangedCopyWithImpl(this._self, this._then);

  final DashboardFilterChanged _self;
  final $Res Function(DashboardFilterChanged) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? filter = null,}) {
  return _then(DashboardFilterChanged(
null == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DashboardSearchChanged implements DashboardState {
  const DashboardSearchChanged(this.query);
  

 final  String query;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSearchChangedCopyWith<DashboardSearchChanged> get copyWith => _$DashboardSearchChangedCopyWithImpl<DashboardSearchChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSearchChanged&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'DashboardState.searchChanged(query: $query)';
}


}

/// @nodoc
abstract mixin class $DashboardSearchChangedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardSearchChangedCopyWith(DashboardSearchChanged value, $Res Function(DashboardSearchChanged) _then) = _$DashboardSearchChangedCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$DashboardSearchChangedCopyWithImpl<$Res>
    implements $DashboardSearchChangedCopyWith<$Res> {
  _$DashboardSearchChangedCopyWithImpl(this._self, this._then);

  final DashboardSearchChanged _self;
  final $Res Function(DashboardSearchChanged) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(DashboardSearchChanged(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DashboardUpdating implements DashboardState {
  const DashboardUpdating();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardUpdating);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DashboardState.updating()';
}


}




/// @nodoc


class DashboardUpdateRequested implements DashboardState {
  const DashboardUpdateRequested({required this.incidentId, required this.newStatus, required this.newSeverity});
  

 final  int incidentId;
 final  int newStatus;
 final  int newSeverity;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardUpdateRequestedCopyWith<DashboardUpdateRequested> get copyWith => _$DashboardUpdateRequestedCopyWithImpl<DashboardUpdateRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardUpdateRequested&&(identical(other.incidentId, incidentId) || other.incidentId == incidentId)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus)&&(identical(other.newSeverity, newSeverity) || other.newSeverity == newSeverity));
}


@override
int get hashCode => Object.hash(runtimeType,incidentId,newStatus,newSeverity);

@override
String toString() {
  return 'DashboardState.updateRequested(incidentId: $incidentId, newStatus: $newStatus, newSeverity: $newSeverity)';
}


}

/// @nodoc
abstract mixin class $DashboardUpdateRequestedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardUpdateRequestedCopyWith(DashboardUpdateRequested value, $Res Function(DashboardUpdateRequested) _then) = _$DashboardUpdateRequestedCopyWithImpl;
@useResult
$Res call({
 int incidentId, int newStatus, int newSeverity
});




}
/// @nodoc
class _$DashboardUpdateRequestedCopyWithImpl<$Res>
    implements $DashboardUpdateRequestedCopyWith<$Res> {
  _$DashboardUpdateRequestedCopyWithImpl(this._self, this._then);

  final DashboardUpdateRequested _self;
  final $Res Function(DashboardUpdateRequested) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? incidentId = null,Object? newStatus = null,Object? newSeverity = null,}) {
  return _then(DashboardUpdateRequested(
incidentId: null == incidentId ? _self.incidentId : incidentId // ignore: cast_nullable_to_non_nullable
as int,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as int,newSeverity: null == newSeverity ? _self.newSeverity : newSeverity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class DashboardMissionUpdateRequested implements DashboardState {
  const DashboardMissionUpdateRequested({required this.incidentId, required this.missionId, required this.newStatus});
  

 final  int incidentId;
 final  int missionId;
 final  int newStatus;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardMissionUpdateRequestedCopyWith<DashboardMissionUpdateRequested> get copyWith => _$DashboardMissionUpdateRequestedCopyWithImpl<DashboardMissionUpdateRequested>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardMissionUpdateRequested&&(identical(other.incidentId, incidentId) || other.incidentId == incidentId)&&(identical(other.missionId, missionId) || other.missionId == missionId)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus));
}


@override
int get hashCode => Object.hash(runtimeType,incidentId,missionId,newStatus);

@override
String toString() {
  return 'DashboardState.missionUpdateRequested(incidentId: $incidentId, missionId: $missionId, newStatus: $newStatus)';
}


}

/// @nodoc
abstract mixin class $DashboardMissionUpdateRequestedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardMissionUpdateRequestedCopyWith(DashboardMissionUpdateRequested value, $Res Function(DashboardMissionUpdateRequested) _then) = _$DashboardMissionUpdateRequestedCopyWithImpl;
@useResult
$Res call({
 int incidentId, int missionId, int newStatus
});




}
/// @nodoc
class _$DashboardMissionUpdateRequestedCopyWithImpl<$Res>
    implements $DashboardMissionUpdateRequestedCopyWith<$Res> {
  _$DashboardMissionUpdateRequestedCopyWithImpl(this._self, this._then);

  final DashboardMissionUpdateRequested _self;
  final $Res Function(DashboardMissionUpdateRequested) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? incidentId = null,Object? missionId = null,Object? newStatus = null,}) {
  return _then(DashboardMissionUpdateRequested(
incidentId: null == incidentId ? _self.incidentId : incidentId // ignore: cast_nullable_to_non_nullable
as int,missionId: null == missionId ? _self.missionId : missionId // ignore: cast_nullable_to_non_nullable
as int,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class DashboardIncidentUpdated implements DashboardState {
  const DashboardIncidentUpdated(this.incident);
  

 final  CurrentIncidentModel incident;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardIncidentUpdatedCopyWith<DashboardIncidentUpdated> get copyWith => _$DashboardIncidentUpdatedCopyWithImpl<DashboardIncidentUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardIncidentUpdated&&(identical(other.incident, incident) || other.incident == incident));
}


@override
int get hashCode => Object.hash(runtimeType,incident);

@override
String toString() {
  return 'DashboardState.incidentUpdated(incident: $incident)';
}


}

/// @nodoc
abstract mixin class $DashboardIncidentUpdatedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardIncidentUpdatedCopyWith(DashboardIncidentUpdated value, $Res Function(DashboardIncidentUpdated) _then) = _$DashboardIncidentUpdatedCopyWithImpl;
@useResult
$Res call({
 CurrentIncidentModel incident
});




}
/// @nodoc
class _$DashboardIncidentUpdatedCopyWithImpl<$Res>
    implements $DashboardIncidentUpdatedCopyWith<$Res> {
  _$DashboardIncidentUpdatedCopyWithImpl(this._self, this._then);

  final DashboardIncidentUpdated _self;
  final $Res Function(DashboardIncidentUpdated) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? incident = null,}) {
  return _then(DashboardIncidentUpdated(
null == incident ? _self.incident : incident // ignore: cast_nullable_to_non_nullable
as CurrentIncidentModel,
  ));
}


}

/// @nodoc


class DashboardMissionUpdated implements DashboardState {
  const DashboardMissionUpdated({required this.incident, required this.missionId});
  

 final  CurrentIncidentModel incident;
 final  int missionId;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardMissionUpdatedCopyWith<DashboardMissionUpdated> get copyWith => _$DashboardMissionUpdatedCopyWithImpl<DashboardMissionUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardMissionUpdated&&(identical(other.incident, incident) || other.incident == incident)&&(identical(other.missionId, missionId) || other.missionId == missionId));
}


@override
int get hashCode => Object.hash(runtimeType,incident,missionId);

@override
String toString() {
  return 'DashboardState.missionUpdated(incident: $incident, missionId: $missionId)';
}


}

/// @nodoc
abstract mixin class $DashboardMissionUpdatedCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardMissionUpdatedCopyWith(DashboardMissionUpdated value, $Res Function(DashboardMissionUpdated) _then) = _$DashboardMissionUpdatedCopyWithImpl;
@useResult
$Res call({
 CurrentIncidentModel incident, int missionId
});




}
/// @nodoc
class _$DashboardMissionUpdatedCopyWithImpl<$Res>
    implements $DashboardMissionUpdatedCopyWith<$Res> {
  _$DashboardMissionUpdatedCopyWithImpl(this._self, this._then);

  final DashboardMissionUpdated _self;
  final $Res Function(DashboardMissionUpdated) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? incident = null,Object? missionId = null,}) {
  return _then(DashboardMissionUpdated(
incident: null == incident ? _self.incident : incident // ignore: cast_nullable_to_non_nullable
as CurrentIncidentModel,missionId: null == missionId ? _self.missionId : missionId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class DashboardError implements DashboardState {
  const DashboardError(this.message);
  

 final  String message;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardErrorCopyWith<DashboardError> get copyWith => _$DashboardErrorCopyWithImpl<DashboardError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DashboardState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $DashboardErrorCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory $DashboardErrorCopyWith(DashboardError value, $Res Function(DashboardError) _then) = _$DashboardErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$DashboardErrorCopyWithImpl<$Res>
    implements $DashboardErrorCopyWith<$Res> {
  _$DashboardErrorCopyWithImpl(this._self, this._then);

  final DashboardError _self;
  final $Res Function(DashboardError) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(DashboardError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
