// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_assign_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MissionAssignState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionAssignState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MissionAssignState()';
}


}

/// @nodoc
class $MissionAssignStateCopyWith<$Res>  {
$MissionAssignStateCopyWith(MissionAssignState _, $Res Function(MissionAssignState) __);
}


/// Adds pattern-matching-related methods to [MissionAssignState].
extension MissionAssignStatePatterns on MissionAssignState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MissionAssignStateInitial value)?  initial,TResult Function( MissionAssignStateLoading value)?  loading,TResult Function( MissionAssignStateLoaded value)?  loaded,TResult Function( MissionAssignStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MissionAssignStateInitial() when initial != null:
return initial(_that);case MissionAssignStateLoading() when loading != null:
return loading(_that);case MissionAssignStateLoaded() when loaded != null:
return loaded(_that);case MissionAssignStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MissionAssignStateInitial value)  initial,required TResult Function( MissionAssignStateLoading value)  loading,required TResult Function( MissionAssignStateLoaded value)  loaded,required TResult Function( MissionAssignStateError value)  error,}){
final _that = this;
switch (_that) {
case MissionAssignStateInitial():
return initial(_that);case MissionAssignStateLoading():
return loading(_that);case MissionAssignStateLoaded():
return loaded(_that);case MissionAssignStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MissionAssignStateInitial value)?  initial,TResult? Function( MissionAssignStateLoading value)?  loading,TResult? Function( MissionAssignStateLoaded value)?  loaded,TResult? Function( MissionAssignStateError value)?  error,}){
final _that = this;
switch (_that) {
case MissionAssignStateInitial() when initial != null:
return initial(_that);case MissionAssignStateLoading() when loading != null:
return loading(_that);case MissionAssignStateLoaded() when loaded != null:
return loaded(_that);case MissionAssignStateError() when error != null:
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
case MissionAssignStateInitial() when initial != null:
return initial();case MissionAssignStateLoading() when loading != null:
return loading();case MissionAssignStateLoaded() when loaded != null:
return loaded(_that.data);case MissionAssignStateError() when error != null:
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
case MissionAssignStateInitial():
return initial();case MissionAssignStateLoading():
return loading();case MissionAssignStateLoaded():
return loaded(_that.data);case MissionAssignStateError():
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
case MissionAssignStateInitial() when initial != null:
return initial();case MissionAssignStateLoading() when loading != null:
return loading();case MissionAssignStateLoaded() when loaded != null:
return loaded(_that.data);case MissionAssignStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class MissionAssignStateInitial implements MissionAssignState {
  const MissionAssignStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionAssignStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MissionAssignState.initial()';
}


}




/// @nodoc


class MissionAssignStateLoading implements MissionAssignState {
  const MissionAssignStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionAssignStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MissionAssignState.loading()';
}


}




/// @nodoc


class MissionAssignStateLoaded implements MissionAssignState {
  const MissionAssignStateLoaded(this.data);
  

 final  dynamic data;

/// Create a copy of MissionAssignState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionAssignStateLoadedCopyWith<MissionAssignStateLoaded> get copyWith => _$MissionAssignStateLoadedCopyWithImpl<MissionAssignStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionAssignStateLoaded&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'MissionAssignState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $MissionAssignStateLoadedCopyWith<$Res> implements $MissionAssignStateCopyWith<$Res> {
  factory $MissionAssignStateLoadedCopyWith(MissionAssignStateLoaded value, $Res Function(MissionAssignStateLoaded) _then) = _$MissionAssignStateLoadedCopyWithImpl;
@useResult
$Res call({
 dynamic data
});




}
/// @nodoc
class _$MissionAssignStateLoadedCopyWithImpl<$Res>
    implements $MissionAssignStateLoadedCopyWith<$Res> {
  _$MissionAssignStateLoadedCopyWithImpl(this._self, this._then);

  final MissionAssignStateLoaded _self;
  final $Res Function(MissionAssignStateLoaded) _then;

/// Create a copy of MissionAssignState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(MissionAssignStateLoaded(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc


class MissionAssignStateError implements MissionAssignState {
  const MissionAssignStateError(this.message);
  

 final  ApiErrorModel message;

/// Create a copy of MissionAssignState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MissionAssignStateErrorCopyWith<MissionAssignStateError> get copyWith => _$MissionAssignStateErrorCopyWithImpl<MissionAssignStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MissionAssignStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'MissionAssignState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $MissionAssignStateErrorCopyWith<$Res> implements $MissionAssignStateCopyWith<$Res> {
  factory $MissionAssignStateErrorCopyWith(MissionAssignStateError value, $Res Function(MissionAssignStateError) _then) = _$MissionAssignStateErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel message
});




}
/// @nodoc
class _$MissionAssignStateErrorCopyWithImpl<$Res>
    implements $MissionAssignStateErrorCopyWith<$Res> {
  _$MissionAssignStateErrorCopyWithImpl(this._self, this._then);

  final MissionAssignStateError _self;
  final $Res Function(MissionAssignStateError) _then;

/// Create a copy of MissionAssignState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(MissionAssignStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
