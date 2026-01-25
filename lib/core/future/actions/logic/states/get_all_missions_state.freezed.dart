// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_all_missions_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetAllMissionState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllMissionState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllMissionState()';
}


}

/// @nodoc
class $GetAllMissionStateCopyWith<$Res>  {
$GetAllMissionStateCopyWith(GetAllMissionState _, $Res Function(GetAllMissionState) __);
}


/// Adds pattern-matching-related methods to [GetAllMissionState].
extension GetAllMissionStatePatterns on GetAllMissionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetAllMissionStateInitial value)?  initial,TResult Function( GetAllMissionStateLoading value)?  loading,TResult Function( GetAllMissionStateLoaded value)?  loaded,TResult Function( GetAllMissionStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetAllMissionStateInitial() when initial != null:
return initial(_that);case GetAllMissionStateLoading() when loading != null:
return loading(_that);case GetAllMissionStateLoaded() when loaded != null:
return loaded(_that);case GetAllMissionStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetAllMissionStateInitial value)  initial,required TResult Function( GetAllMissionStateLoading value)  loading,required TResult Function( GetAllMissionStateLoaded value)  loaded,required TResult Function( GetAllMissionStateError value)  error,}){
final _that = this;
switch (_that) {
case GetAllMissionStateInitial():
return initial(_that);case GetAllMissionStateLoading():
return loading(_that);case GetAllMissionStateLoaded():
return loaded(_that);case GetAllMissionStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetAllMissionStateInitial value)?  initial,TResult? Function( GetAllMissionStateLoading value)?  loading,TResult? Function( GetAllMissionStateLoaded value)?  loaded,TResult? Function( GetAllMissionStateError value)?  error,}){
final _that = this;
switch (_that) {
case GetAllMissionStateInitial() when initial != null:
return initial(_that);case GetAllMissionStateLoading() when loading != null:
return loading(_that);case GetAllMissionStateLoaded() when loaded != null:
return loaded(_that);case GetAllMissionStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<AllMissionModel> data)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetAllMissionStateInitial() when initial != null:
return initial();case GetAllMissionStateLoading() when loading != null:
return loading();case GetAllMissionStateLoaded() when loaded != null:
return loaded(_that.data);case GetAllMissionStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<AllMissionModel> data)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case GetAllMissionStateInitial():
return initial();case GetAllMissionStateLoading():
return loading();case GetAllMissionStateLoaded():
return loaded(_that.data);case GetAllMissionStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<AllMissionModel> data)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case GetAllMissionStateInitial() when initial != null:
return initial();case GetAllMissionStateLoading() when loading != null:
return loading();case GetAllMissionStateLoaded() when loaded != null:
return loaded(_that.data);case GetAllMissionStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class GetAllMissionStateInitial implements GetAllMissionState {
  const GetAllMissionStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllMissionStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllMissionState.initial()';
}


}




/// @nodoc


class GetAllMissionStateLoading implements GetAllMissionState {
  const GetAllMissionStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllMissionStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllMissionState.loading()';
}


}




/// @nodoc


class GetAllMissionStateLoaded implements GetAllMissionState {
  const GetAllMissionStateLoaded(final  List<AllMissionModel> data): _data = data;
  

 final  List<AllMissionModel> _data;
 List<AllMissionModel> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of GetAllMissionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAllMissionStateLoadedCopyWith<GetAllMissionStateLoaded> get copyWith => _$GetAllMissionStateLoadedCopyWithImpl<GetAllMissionStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllMissionStateLoaded&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'GetAllMissionState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $GetAllMissionStateLoadedCopyWith<$Res> implements $GetAllMissionStateCopyWith<$Res> {
  factory $GetAllMissionStateLoadedCopyWith(GetAllMissionStateLoaded value, $Res Function(GetAllMissionStateLoaded) _then) = _$GetAllMissionStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<AllMissionModel> data
});




}
/// @nodoc
class _$GetAllMissionStateLoadedCopyWithImpl<$Res>
    implements $GetAllMissionStateLoadedCopyWith<$Res> {
  _$GetAllMissionStateLoadedCopyWithImpl(this._self, this._then);

  final GetAllMissionStateLoaded _self;
  final $Res Function(GetAllMissionStateLoaded) _then;

/// Create a copy of GetAllMissionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(GetAllMissionStateLoaded(
null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<AllMissionModel>,
  ));
}


}

/// @nodoc


class GetAllMissionStateError implements GetAllMissionState {
  const GetAllMissionStateError(this.message);
  

 final  String message;

/// Create a copy of GetAllMissionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAllMissionStateErrorCopyWith<GetAllMissionStateError> get copyWith => _$GetAllMissionStateErrorCopyWithImpl<GetAllMissionStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllMissionStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GetAllMissionState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $GetAllMissionStateErrorCopyWith<$Res> implements $GetAllMissionStateCopyWith<$Res> {
  factory $GetAllMissionStateErrorCopyWith(GetAllMissionStateError value, $Res Function(GetAllMissionStateError) _then) = _$GetAllMissionStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$GetAllMissionStateErrorCopyWithImpl<$Res>
    implements $GetAllMissionStateErrorCopyWith<$Res> {
  _$GetAllMissionStateErrorCopyWithImpl(this._self, this._then);

  final GetAllMissionStateError _self;
  final $Res Function(GetAllMissionStateError) _then;

/// Create a copy of GetAllMissionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(GetAllMissionStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
