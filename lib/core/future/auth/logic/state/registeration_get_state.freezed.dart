// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'registeration_get_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RegistrationGetState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationGetState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationGetState()';
}


}

/// @nodoc
class $RegistrationGetStateCopyWith<$Res>  {
$RegistrationGetStateCopyWith(RegistrationGetState _, $Res Function(RegistrationGetState) __);
}


/// Adds pattern-matching-related methods to [RegistrationGetState].
extension RegistrationGetStatePatterns on RegistrationGetState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( RegistrationGetStateInitial value)?  initial,TResult Function( RegistrationGetStateLoading value)?  loading,TResult Function( RegistrationGetStateLoaded value)?  loaded,TResult Function( RegistrationGetStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case RegistrationGetStateInitial() when initial != null:
return initial(_that);case RegistrationGetStateLoading() when loading != null:
return loading(_that);case RegistrationGetStateLoaded() when loaded != null:
return loaded(_that);case RegistrationGetStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( RegistrationGetStateInitial value)  initial,required TResult Function( RegistrationGetStateLoading value)  loading,required TResult Function( RegistrationGetStateLoaded value)  loaded,required TResult Function( RegistrationGetStateError value)  error,}){
final _that = this;
switch (_that) {
case RegistrationGetStateInitial():
return initial(_that);case RegistrationGetStateLoading():
return loading(_that);case RegistrationGetStateLoaded():
return loaded(_that);case RegistrationGetStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( RegistrationGetStateInitial value)?  initial,TResult? Function( RegistrationGetStateLoading value)?  loading,TResult? Function( RegistrationGetStateLoaded value)?  loaded,TResult? Function( RegistrationGetStateError value)?  error,}){
final _that = this;
switch (_that) {
case RegistrationGetStateInitial() when initial != null:
return initial(_that);case RegistrationGetStateLoading() when loading != null:
return loading(_that);case RegistrationGetStateLoaded() when loaded != null:
return loaded(_that);case RegistrationGetStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( RegistrationModel data)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case RegistrationGetStateInitial() when initial != null:
return initial();case RegistrationGetStateLoading() when loading != null:
return loading();case RegistrationGetStateLoaded() when loaded != null:
return loaded(_that.data);case RegistrationGetStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( RegistrationModel data)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case RegistrationGetStateInitial():
return initial();case RegistrationGetStateLoading():
return loading();case RegistrationGetStateLoaded():
return loaded(_that.data);case RegistrationGetStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( RegistrationModel data)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case RegistrationGetStateInitial() when initial != null:
return initial();case RegistrationGetStateLoading() when loading != null:
return loading();case RegistrationGetStateLoaded() when loaded != null:
return loaded(_that.data);case RegistrationGetStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class RegistrationGetStateInitial implements RegistrationGetState {
  const RegistrationGetStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationGetStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationGetState.initial()';
}


}




/// @nodoc


class RegistrationGetStateLoading implements RegistrationGetState {
  const RegistrationGetStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationGetStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RegistrationGetState.loading()';
}


}




/// @nodoc


class RegistrationGetStateLoaded implements RegistrationGetState {
  const RegistrationGetStateLoaded(this.data);
  

 final  RegistrationModel data;

/// Create a copy of RegistrationGetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationGetStateLoadedCopyWith<RegistrationGetStateLoaded> get copyWith => _$RegistrationGetStateLoadedCopyWithImpl<RegistrationGetStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationGetStateLoaded&&(identical(other.data, data) || other.data == data));
}


@override
int get hashCode => Object.hash(runtimeType,data);

@override
String toString() {
  return 'RegistrationGetState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $RegistrationGetStateLoadedCopyWith<$Res> implements $RegistrationGetStateCopyWith<$Res> {
  factory $RegistrationGetStateLoadedCopyWith(RegistrationGetStateLoaded value, $Res Function(RegistrationGetStateLoaded) _then) = _$RegistrationGetStateLoadedCopyWithImpl;
@useResult
$Res call({
 RegistrationModel data
});




}
/// @nodoc
class _$RegistrationGetStateLoadedCopyWithImpl<$Res>
    implements $RegistrationGetStateLoadedCopyWith<$Res> {
  _$RegistrationGetStateLoadedCopyWithImpl(this._self, this._then);

  final RegistrationGetStateLoaded _self;
  final $Res Function(RegistrationGetStateLoaded) _then;

/// Create a copy of RegistrationGetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(RegistrationGetStateLoaded(
null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as RegistrationModel,
  ));
}


}

/// @nodoc


class RegistrationGetStateError implements RegistrationGetState {
  const RegistrationGetStateError(this.message);
  

 final  String message;

/// Create a copy of RegistrationGetState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegistrationGetStateErrorCopyWith<RegistrationGetStateError> get copyWith => _$RegistrationGetStateErrorCopyWithImpl<RegistrationGetStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RegistrationGetStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'RegistrationGetState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $RegistrationGetStateErrorCopyWith<$Res> implements $RegistrationGetStateCopyWith<$Res> {
  factory $RegistrationGetStateErrorCopyWith(RegistrationGetStateError value, $Res Function(RegistrationGetStateError) _then) = _$RegistrationGetStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$RegistrationGetStateErrorCopyWithImpl<$Res>
    implements $RegistrationGetStateErrorCopyWith<$Res> {
  _$RegistrationGetStateErrorCopyWithImpl(this._self, this._then);

  final RegistrationGetStateError _self;
  final $Res Function(RegistrationGetStateError) _then;

/// Create a copy of RegistrationGetState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(RegistrationGetStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
