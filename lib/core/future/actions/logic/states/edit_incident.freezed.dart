// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_incident.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EditIncidentStates {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditIncidentStates);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditIncidentStates()';
}


}

/// @nodoc
class $EditIncidentStatesCopyWith<$Res>  {
$EditIncidentStatesCopyWith(EditIncidentStates _, $Res Function(EditIncidentStates) __);
}


/// Adds pattern-matching-related methods to [EditIncidentStates].
extension EditIncidentStatesPatterns on EditIncidentStates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EditIncidentStatesInitial value)?  initial,TResult Function( EditIncidentStatesLoading value)?  loading,TResult Function( EditIncidentStatesSuccess value)?  success,TResult Function( EditIncidentStatesError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EditIncidentStatesInitial() when initial != null:
return initial(_that);case EditIncidentStatesLoading() when loading != null:
return loading(_that);case EditIncidentStatesSuccess() when success != null:
return success(_that);case EditIncidentStatesError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EditIncidentStatesInitial value)  initial,required TResult Function( EditIncidentStatesLoading value)  loading,required TResult Function( EditIncidentStatesSuccess value)  success,required TResult Function( EditIncidentStatesError value)  error,}){
final _that = this;
switch (_that) {
case EditIncidentStatesInitial():
return initial(_that);case EditIncidentStatesLoading():
return loading(_that);case EditIncidentStatesSuccess():
return success(_that);case EditIncidentStatesError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EditIncidentStatesInitial value)?  initial,TResult? Function( EditIncidentStatesLoading value)?  loading,TResult? Function( EditIncidentStatesSuccess value)?  success,TResult? Function( EditIncidentStatesError value)?  error,}){
final _that = this;
switch (_that) {
case EditIncidentStatesInitial() when initial != null:
return initial(_that);case EditIncidentStatesLoading() when loading != null:
return loading(_that);case EditIncidentStatesSuccess() when success != null:
return success(_that);case EditIncidentStatesError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function()?  success,TResult Function( ApiErrorModel message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EditIncidentStatesInitial() when initial != null:
return initial();case EditIncidentStatesLoading() when loading != null:
return loading();case EditIncidentStatesSuccess() when success != null:
return success();case EditIncidentStatesError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function()  success,required TResult Function( ApiErrorModel message)  error,}) {final _that = this;
switch (_that) {
case EditIncidentStatesInitial():
return initial();case EditIncidentStatesLoading():
return loading();case EditIncidentStatesSuccess():
return success();case EditIncidentStatesError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function()?  success,TResult? Function( ApiErrorModel message)?  error,}) {final _that = this;
switch (_that) {
case EditIncidentStatesInitial() when initial != null:
return initial();case EditIncidentStatesLoading() when loading != null:
return loading();case EditIncidentStatesSuccess() when success != null:
return success();case EditIncidentStatesError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class EditIncidentStatesInitial implements EditIncidentStates {
  const EditIncidentStatesInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditIncidentStatesInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditIncidentStates.initial()';
}


}




/// @nodoc


class EditIncidentStatesLoading implements EditIncidentStates {
  const EditIncidentStatesLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditIncidentStatesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditIncidentStates.loading()';
}


}




/// @nodoc


class EditIncidentStatesSuccess implements EditIncidentStates {
  const EditIncidentStatesSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditIncidentStatesSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EditIncidentStates.success()';
}


}




/// @nodoc


class EditIncidentStatesError implements EditIncidentStates {
  const EditIncidentStatesError(this.message);
  

 final  ApiErrorModel message;

/// Create a copy of EditIncidentStates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditIncidentStatesErrorCopyWith<EditIncidentStatesError> get copyWith => _$EditIncidentStatesErrorCopyWithImpl<EditIncidentStatesError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditIncidentStatesError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'EditIncidentStates.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $EditIncidentStatesErrorCopyWith<$Res> implements $EditIncidentStatesCopyWith<$Res> {
  factory $EditIncidentStatesErrorCopyWith(EditIncidentStatesError value, $Res Function(EditIncidentStatesError) _then) = _$EditIncidentStatesErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel message
});




}
/// @nodoc
class _$EditIncidentStatesErrorCopyWithImpl<$Res>
    implements $EditIncidentStatesErrorCopyWith<$Res> {
  _$EditIncidentStatesErrorCopyWithImpl(this._self, this._then);

  final EditIncidentStatesError _self;
  final $Res Function(EditIncidentStatesError) _then;

/// Create a copy of EditIncidentStates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(EditIncidentStatesError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
