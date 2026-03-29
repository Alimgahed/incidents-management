// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registeration_post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistrationPostState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationPostState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationPostState()';
}


}

/// @nodoc
class $RegistrationPostStateCopyWith<$Res>  {
$RegistrationPostStateCopyWith(RegistrationPostState _, $Res Function(RegistrationPostState) __);
}


/// Adds pattern-matching-related methods to [RegistrationPostState].
extension RegistrationPostStatePatterns on RegistrationPostState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RegistrationPostStateInitial value)?  initial,TResult Function( RegistrationPostStateLoading value)?  loading,TResult Function( RegistrationPostStateLoaded value)?  loaded,TResult Function( RegistrationPostStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RegistrationPostStateInitial() when initial != null:
return initial(_that);case RegistrationPostStateLoading() when loading != null:
return loading(_that);case RegistrationPostStateLoaded() when loaded != null:
return loaded(_that);case RegistrationPostStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RegistrationPostStateInitial value)  initial,required TResult Function( RegistrationPostStateLoading value)  loading,required TResult Function( RegistrationPostStateLoaded value)  loaded,required TResult Function( RegistrationPostStateError value)  error,}){
final _that = this;
switch (_that) {
case RegistrationPostStateInitial():
return initial(_that);case RegistrationPostStateLoading():
return loading(_that);case RegistrationPostStateLoaded():
return loaded(_that);case RegistrationPostStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RegistrationPostStateInitial value)?  initial,TResult? Function( RegistrationPostStateLoading value)?  loading,TResult? Function( RegistrationPostStateLoaded value)?  loaded,TResult? Function( RegistrationPostStateError value)?  error,}){
final _that = this;
switch (_that) {
case RegistrationPostStateInitial() when initial != null:
return initial(_that);case RegistrationPostStateLoading() when loading != null:
return loading(_that);case RegistrationPostStateLoaded() when loaded != null:
return loaded(_that);case RegistrationPostStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( dynamic data)?  loaded,TResult Function( ApiErrorModel message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RegistrationPostStateInitial() when initial != null:
return initial();case RegistrationPostStateLoading() when loading != null:
return loading();case RegistrationPostStateLoaded() when loaded != null:
return loaded(_that.data);case RegistrationPostStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( dynamic data)  loaded,required TResult Function( ApiErrorModel message)  error,}) {final _that = this;
switch (_that) {
case RegistrationPostStateInitial():
return initial();case RegistrationPostStateLoading():
return loading();case RegistrationPostStateLoaded():
return loaded(_that.data);case RegistrationPostStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( dynamic data)?  loaded,TResult? Function( ApiErrorModel message)?  error,}) {final _that = this;
switch (_that) {
case RegistrationPostStateInitial() when initial != null:
return initial();case RegistrationPostStateLoading() when loading != null:
return loading();case RegistrationPostStateLoaded() when loaded != null:
return loaded(_that.data);case RegistrationPostStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class RegistrationPostStateInitial implements RegistrationPostState {
  const RegistrationPostStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationPostStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationPostState.initial()';
}


}




/// @nodoc


class RegistrationPostStateLoading implements RegistrationPostState {
  const RegistrationPostStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationPostStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationPostState.loading()';
}


}




/// @nodoc


class RegistrationPostStateLoaded implements RegistrationPostState {
  const RegistrationPostStateLoaded(this.data);
  

 final  dynamic data;

/// Create a copy of RegistrationPostState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationPostStateLoadedCopyWith<RegistrationPostStateLoaded> get copyWith => _$RegistrationPostStateLoadedCopyWithImpl<RegistrationPostStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationPostStateLoaded&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'RegistrationPostState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $RegistrationPostStateLoadedCopyWith<$Res> implements $RegistrationPostStateCopyWith<$Res> {
  factory $RegistrationPostStateLoadedCopyWith(RegistrationPostStateLoaded value, $Res Function(RegistrationPostStateLoaded) _then) = _$RegistrationPostStateLoadedCopyWithImpl;
@useResult
$Res call({
 dynamic data
});




}
/// @nodoc
class _$RegistrationPostStateLoadedCopyWithImpl<$Res>
    implements $RegistrationPostStateLoadedCopyWith<$Res> {
  _$RegistrationPostStateLoadedCopyWithImpl(this._self, this._then);

  final RegistrationPostStateLoaded _self;
  final $Res Function(RegistrationPostStateLoaded) _then;

/// Create a copy of RegistrationPostState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(RegistrationPostStateLoaded(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc


class RegistrationPostStateError implements RegistrationPostState {
  const RegistrationPostStateError(this.message);
  

 final  ApiErrorModel message;

/// Create a copy of RegistrationPostState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationPostStateErrorCopyWith<RegistrationPostStateError> get copyWith => _$RegistrationPostStateErrorCopyWithImpl<RegistrationPostStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationPostStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RegistrationPostState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $RegistrationPostStateErrorCopyWith<$Res> implements $RegistrationPostStateCopyWith<$Res> {
  factory $RegistrationPostStateErrorCopyWith(RegistrationPostStateError value, $Res Function(RegistrationPostStateError) _then) = _$RegistrationPostStateErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel message
});




}
/// @nodoc
class _$RegistrationPostStateErrorCopyWithImpl<$Res>
    implements $RegistrationPostStateErrorCopyWith<$Res> {
  _$RegistrationPostStateErrorCopyWithImpl(this._self, this._then);

  final RegistrationPostStateError _self;
  final $Res Function(RegistrationPostStateError) _then;

/// Create a copy of RegistrationPostState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(RegistrationPostStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
