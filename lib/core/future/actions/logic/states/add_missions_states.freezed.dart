// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_missions_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddMissionsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddMissionsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddMissionsState()';
}


}

/// @nodoc
class $AddMissionsStateCopyWith<$Res>  {
$AddMissionsStateCopyWith(AddMissionsState _, $Res Function(AddMissionsState) __);
}


/// Adds pattern-matching-related methods to [AddMissionsState].
extension AddMissionsStatePatterns on AddMissionsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _addmissionsInitial value)?  initial,TResult Function( _addmissionsLoading value)?  loading,TResult Function( _addmissionsSuccess value)?  success,TResult Function( _addmissionsError value)?  error,TResult Function( _InputChanged value)?  inputChanged,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _addmissionsInitial() when initial != null:
return initial(_that);case _addmissionsLoading() when loading != null:
return loading(_that);case _addmissionsSuccess() when success != null:
return success(_that);case _addmissionsError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _addmissionsInitial value)  initial,required TResult Function( _addmissionsLoading value)  loading,required TResult Function( _addmissionsSuccess value)  success,required TResult Function( _addmissionsError value)  error,required TResult Function( _InputChanged value)  inputChanged,}){
final _that = this;
switch (_that) {
case _addmissionsInitial():
return initial(_that);case _addmissionsLoading():
return loading(_that);case _addmissionsSuccess():
return success(_that);case _addmissionsError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _addmissionsInitial value)?  initial,TResult? Function( _addmissionsLoading value)?  loading,TResult? Function( _addmissionsSuccess value)?  success,TResult? Function( _addmissionsError value)?  error,TResult? Function( _InputChanged value)?  inputChanged,}){
final _that = this;
switch (_that) {
case _addmissionsInitial() when initial != null:
return initial(_that);case _addmissionsLoading() when loading != null:
return loading(_that);case _addmissionsSuccess() when success != null:
return success(_that);case _addmissionsError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( ApiErrorModel message)?  error,TResult Function( int? selectedClassId,  String? missionName,  bool? isFormValid)?  inputChanged,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _addmissionsInitial() when initial != null:
return initial();case _addmissionsLoading() when loading != null:
return loading();case _addmissionsSuccess() when success != null:
return success();case _addmissionsError() when error != null:
return error(_that.message);case _InputChanged() when inputChanged != null:
return inputChanged(_that.selectedClassId,_that.missionName,_that.isFormValid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( ApiErrorModel message)  error,required TResult Function( int? selectedClassId,  String? missionName,  bool? isFormValid)  inputChanged,}) {final _that = this;
switch (_that) {
case _addmissionsInitial():
return initial();case _addmissionsLoading():
return loading();case _addmissionsSuccess():
return success();case _addmissionsError():
return error(_that.message);case _InputChanged():
return inputChanged(_that.selectedClassId,_that.missionName,_that.isFormValid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( ApiErrorModel message)?  error,TResult? Function( int? selectedClassId,  String? missionName,  bool? isFormValid)?  inputChanged,}) {final _that = this;
switch (_that) {
case _addmissionsInitial() when initial != null:
return initial();case _addmissionsLoading() when loading != null:
return loading();case _addmissionsSuccess() when success != null:
return success();case _addmissionsError() when error != null:
return error(_that.message);case _InputChanged() when inputChanged != null:
return inputChanged(_that.selectedClassId,_that.missionName,_that.isFormValid);case _:
  return null;

}
}

}

/// @nodoc


class _addmissionsInitial implements AddMissionsState {
  const _addmissionsInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _addmissionsInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddMissionsState.initial()';
}


}




/// @nodoc


class _addmissionsLoading implements AddMissionsState {
  const _addmissionsLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _addmissionsLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddMissionsState.loading()';
}


}




/// @nodoc


class _addmissionsSuccess implements AddMissionsState {
  const _addmissionsSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _addmissionsSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddMissionsState.success()';
}


}




/// @nodoc


class _addmissionsError implements AddMissionsState {
  const _addmissionsError(this.message);
  

 final  ApiErrorModel message;

/// Create a copy of AddMissionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$addmissionsErrorCopyWith<_addmissionsError> get copyWith => __$addmissionsErrorCopyWithImpl<_addmissionsError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _addmissionsError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AddMissionsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$addmissionsErrorCopyWith<$Res> implements $AddMissionsStateCopyWith<$Res> {
  factory _$addmissionsErrorCopyWith(_addmissionsError value, $Res Function(_addmissionsError) _then) = __$addmissionsErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel message
});




}
/// @nodoc
class __$addmissionsErrorCopyWithImpl<$Res>
    implements _$addmissionsErrorCopyWith<$Res> {
  __$addmissionsErrorCopyWithImpl(this._self, this._then);

  final _addmissionsError _self;
  final $Res Function(_addmissionsError) _then;

/// Create a copy of AddMissionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_addmissionsError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

/// @nodoc


class _InputChanged implements AddMissionsState {
  const _InputChanged({this.selectedClassId, this.missionName, this.isFormValid});
  

 final  int? selectedClassId;
 final  String? missionName;
 final  bool? isFormValid;

/// Create a copy of AddMissionsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InputChangedCopyWith<_InputChanged> get copyWith => __$InputChangedCopyWithImpl<_InputChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InputChanged&&(identical(other.selectedClassId, selectedClassId) || other.selectedClassId == selectedClassId)&&(identical(other.missionName, missionName) || other.missionName == missionName)&&(identical(other.isFormValid, isFormValid) || other.isFormValid == isFormValid));
}


@override
int get hashCode => Object.hash(runtimeType,selectedClassId,missionName,isFormValid);

@override
String toString() {
  return 'AddMissionsState.inputChanged(selectedClassId: $selectedClassId, missionName: $missionName, isFormValid: $isFormValid)';
}


}

/// @nodoc
abstract mixin class _$InputChangedCopyWith<$Res> implements $AddMissionsStateCopyWith<$Res> {
  factory _$InputChangedCopyWith(_InputChanged value, $Res Function(_InputChanged) _then) = __$InputChangedCopyWithImpl;
@useResult
$Res call({
 int? selectedClassId, String? missionName, bool? isFormValid
});




}
/// @nodoc
class __$InputChangedCopyWithImpl<$Res>
    implements _$InputChangedCopyWith<$Res> {
  __$InputChangedCopyWithImpl(this._self, this._then);

  final _InputChanged _self;
  final $Res Function(_InputChanged) _then;

/// Create a copy of AddMissionsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? selectedClassId = freezed,Object? missionName = freezed,Object? isFormValid = freezed,}) {
  return _then(_InputChanged(
selectedClassId: freezed == selectedClassId ? _self.selectedClassId : selectedClassId // ignore: cast_nullable_to_non_nullable
as int?,missionName: freezed == missionName ? _self.missionName : missionName // ignore: cast_nullable_to_non_nullable
as String?,isFormValid: freezed == isFormValid ? _self.isFormValid : isFormValid // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
