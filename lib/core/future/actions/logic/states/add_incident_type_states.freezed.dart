// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_incident_type_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddIncidentTypeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddIncidentTypeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddIncidentTypeState()';
}


}

/// @nodoc
class $AddIncidentTypeStateCopyWith<$Res>  {
$AddIncidentTypeStateCopyWith(AddIncidentTypeState _, $Res Function(AddIncidentTypeState) __);
}


/// Adds pattern-matching-related methods to [AddIncidentTypeState].
extension AddIncidentTypeStatePatterns on AddIncidentTypeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Success value)?  success,TResult Function( _Error value)?  error,TResult Function( _InputChanged value)?  inputChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _InputChanged() when inputChanged != null:
return inputChanged(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Success value)  success,required TResult Function( _Error value)  error,required TResult Function( _InputChanged value)  inputChanged,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Success():
return success(_that);case _Error():
return error(_that);case _InputChanged():
return inputChanged(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Success value)?  success,TResult? Function( _Error value)?  error,TResult? Function( _InputChanged value)?  inputChanged,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Success() when success != null:
return success(_that);case _Error() when error != null:
return error(_that);case _InputChanged() when inputChanged != null:
return inputChanged(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( ApiErrorModel message)?  error,TResult Function( int? selectedClassId,  String? incidentName,  bool? isFormValid)?  inputChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success();case _Error() when error != null:
return error(_that.message);case _InputChanged() when inputChanged != null:
return inputChanged(_that.selectedClassId,_that.incidentName,_that.isFormValid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( ApiErrorModel message)  error,required TResult Function( int? selectedClassId,  String? incidentName,  bool? isFormValid)  inputChanged,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Success():
return success();case _Error():
return error(_that.message);case _InputChanged():
return inputChanged(_that.selectedClassId,_that.incidentName,_that.isFormValid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( ApiErrorModel message)?  error,TResult? Function( int? selectedClassId,  String? incidentName,  bool? isFormValid)?  inputChanged,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Success() when success != null:
return success();case _Error() when error != null:
return error(_that.message);case _InputChanged() when inputChanged != null:
return inputChanged(_that.selectedClassId,_that.incidentName,_that.isFormValid);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AddIncidentTypeState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddIncidentTypeState.initial()';
}


}




/// @nodoc


class _Loading implements AddIncidentTypeState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddIncidentTypeState.loading()';
}


}




/// @nodoc


class _Success implements AddIncidentTypeState {
  const _Success();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Success);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddIncidentTypeState.success()';
}


}




/// @nodoc


class _Error implements AddIncidentTypeState {
  const _Error(this.message);
  

 final  ApiErrorModel message;

/// Create a copy of AddIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AddIncidentTypeState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $AddIncidentTypeStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of AddIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class _InputChanged implements AddIncidentTypeState {
  const _InputChanged({this.selectedClassId, this.incidentName, this.isFormValid});
  

 final  int? selectedClassId;
 final  String? incidentName;
 final  bool? isFormValid;

/// Create a copy of AddIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InputChangedCopyWith<_InputChanged> get copyWith => __$InputChangedCopyWithImpl<_InputChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InputChanged&&(identical(other.selectedClassId, selectedClassId) || other.selectedClassId == selectedClassId)&&(identical(other.incidentName, incidentName) || other.incidentName == incidentName)&&(identical(other.isFormValid, isFormValid) || other.isFormValid == isFormValid));
}


@override
int get hashCode => Object.hash(runtimeType,selectedClassId,incidentName,isFormValid);

@override
String toString() {
  return 'AddIncidentTypeState.inputChanged(selectedClassId: $selectedClassId, incidentName: $incidentName, isFormValid: $isFormValid)';
}


}

/// @nodoc
abstract mixin class _$InputChangedCopyWith<$Res> implements $AddIncidentTypeStateCopyWith<$Res> {
  factory _$InputChangedCopyWith(_InputChanged value, $Res Function(_InputChanged) _then) = __$InputChangedCopyWithImpl;
@useResult
$Res call({
 int? selectedClassId, String? incidentName, bool? isFormValid
});




}
/// @nodoc
class __$InputChangedCopyWithImpl<$Res>
    implements _$InputChangedCopyWith<$Res> {
  __$InputChangedCopyWithImpl(this._self, this._then);

  final _InputChanged _self;
  final $Res Function(_InputChanged) _then;

/// Create a copy of AddIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedClassId = freezed,Object? incidentName = freezed,Object? isFormValid = freezed,}) {
  return _then(_InputChanged(
selectedClassId: freezed == selectedClassId ? _self.selectedClassId : selectedClassId // ignore: cast_nullable_to_non_nullable
as int?,incidentName: freezed == incidentName ? _self.incidentName : incidentName // ignore: cast_nullable_to_non_nullable
as String?,isFormValid: freezed == isFormValid ? _self.isFormValid : isFormValid // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
