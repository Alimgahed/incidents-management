// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_statues.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateStatuesStates {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateStatuesStates);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateStatuesStates()';
}


}

/// @nodoc
class $UpdateStatuesStatesCopyWith<$Res>  {
$UpdateStatuesStatesCopyWith(UpdateStatuesStates _, $Res Function(UpdateStatuesStates) __);
}


/// Adds pattern-matching-related methods to [UpdateStatuesStates].
extension UpdateStatuesStatesPatterns on UpdateStatuesStates {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( UpdateStatuesStatesInitial value)?  initial,TResult Function( UpdateStatuesStatesLoading value)?  loading,TResult Function( UpdateStatuesStatesSuccess value)?  success,TResult Function( UpdateStatuesStatesError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case UpdateStatuesStatesInitial() when initial != null:
return initial(_that);case UpdateStatuesStatesLoading() when loading != null:
return loading(_that);case UpdateStatuesStatesSuccess() when success != null:
return success(_that);case UpdateStatuesStatesError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( UpdateStatuesStatesInitial value)  initial,required TResult Function( UpdateStatuesStatesLoading value)  loading,required TResult Function( UpdateStatuesStatesSuccess value)  success,required TResult Function( UpdateStatuesStatesError value)  error,}){
final _that = this;
switch (_that) {
case UpdateStatuesStatesInitial():
return initial(_that);case UpdateStatuesStatesLoading():
return loading(_that);case UpdateStatuesStatesSuccess():
return success(_that);case UpdateStatuesStatesError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( UpdateStatuesStatesInitial value)?  initial,TResult? Function( UpdateStatuesStatesLoading value)?  loading,TResult? Function( UpdateStatuesStatesSuccess value)?  success,TResult? Function( UpdateStatuesStatesError value)?  error,}){
final _that = this;
switch (_that) {
case UpdateStatuesStatesInitial() when initial != null:
return initial(_that);case UpdateStatuesStatesLoading() when loading != null:
return loading(_that);case UpdateStatuesStatesSuccess() when success != null:
return success(_that);case UpdateStatuesStatesError() when error != null:
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
case UpdateStatuesStatesInitial() when initial != null:
return initial();case UpdateStatuesStatesLoading() when loading != null:
return loading();case UpdateStatuesStatesSuccess() when success != null:
return success();case UpdateStatuesStatesError() when error != null:
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
case UpdateStatuesStatesInitial():
return initial();case UpdateStatuesStatesLoading():
return loading();case UpdateStatuesStatesSuccess():
return success();case UpdateStatuesStatesError():
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
case UpdateStatuesStatesInitial() when initial != null:
return initial();case UpdateStatuesStatesLoading() when loading != null:
return loading();case UpdateStatuesStatesSuccess() when success != null:
return success();case UpdateStatuesStatesError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class UpdateStatuesStatesInitial implements UpdateStatuesStates {
  const UpdateStatuesStatesInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateStatuesStatesInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateStatuesStates.initial()';
}


}




/// @nodoc


class UpdateStatuesStatesLoading implements UpdateStatuesStates {
  const UpdateStatuesStatesLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateStatuesStatesLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateStatuesStates.loading()';
}


}




/// @nodoc


class UpdateStatuesStatesSuccess implements UpdateStatuesStates {
  const UpdateStatuesStatesSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateStatuesStatesSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'UpdateStatuesStates.success()';
}


}




/// @nodoc


class UpdateStatuesStatesError implements UpdateStatuesStates {
  const UpdateStatuesStatesError(this.message);
  

 final  ApiErrorModel message;

/// Create a copy of UpdateStatuesStates
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateStatuesStatesErrorCopyWith<UpdateStatuesStatesError> get copyWith => _$UpdateStatuesStatesErrorCopyWithImpl<UpdateStatuesStatesError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateStatuesStatesError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'UpdateStatuesStates.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $UpdateStatuesStatesErrorCopyWith<$Res> implements $UpdateStatuesStatesCopyWith<$Res> {
  factory $UpdateStatuesStatesErrorCopyWith(UpdateStatuesStatesError value, $Res Function(UpdateStatuesStatesError) _then) = _$UpdateStatuesStatesErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel message
});




}
/// @nodoc
class _$UpdateStatuesStatesErrorCopyWithImpl<$Res>
    implements $UpdateStatuesStatesErrorCopyWith<$Res> {
  _$UpdateStatuesStatesErrorCopyWithImpl(this._self, this._then);

  final UpdateStatuesStatesError _self;
  final $Res Function(UpdateStatuesStatesError) _then;

/// Create a copy of UpdateStatuesStates
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(UpdateStatuesStatesError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
