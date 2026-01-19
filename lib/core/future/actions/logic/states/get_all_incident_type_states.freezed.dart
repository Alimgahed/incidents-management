// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'get_all_incident_type_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetAllIncidentTypeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentTypeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllIncidentTypeState()';
}


}

/// @nodoc
class $GetAllIncidentTypeStateCopyWith<$Res>  {
$GetAllIncidentTypeStateCopyWith(GetAllIncidentTypeState _, $Res Function(GetAllIncidentTypeState) __);
}


/// Adds pattern-matching-related methods to [GetAllIncidentTypeState].
extension GetAllIncidentTypeStatePatterns on GetAllIncidentTypeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetAllIncidentTypeStateInitial value)?  initial,TResult Function( GetAllIncidentTypeStateLoading value)?  loading,TResult Function( GetAllIncidentTypeStateLoaded value)?  loaded,TResult Function( GetAllIncidentTypeStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetAllIncidentTypeStateInitial() when initial != null:
return initial(_that);case GetAllIncidentTypeStateLoading() when loading != null:
return loading(_that);case GetAllIncidentTypeStateLoaded() when loaded != null:
return loaded(_that);case GetAllIncidentTypeStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetAllIncidentTypeStateInitial value)  initial,required TResult Function( GetAllIncidentTypeStateLoading value)  loading,required TResult Function( GetAllIncidentTypeStateLoaded value)  loaded,required TResult Function( GetAllIncidentTypeStateError value)  error,}){
final _that = this;
switch (_that) {
case GetAllIncidentTypeStateInitial():
return initial(_that);case GetAllIncidentTypeStateLoading():
return loading(_that);case GetAllIncidentTypeStateLoaded():
return loaded(_that);case GetAllIncidentTypeStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetAllIncidentTypeStateInitial value)?  initial,TResult? Function( GetAllIncidentTypeStateLoading value)?  loading,TResult? Function( GetAllIncidentTypeStateLoaded value)?  loaded,TResult? Function( GetAllIncidentTypeStateError value)?  error,}){
final _that = this;
switch (_that) {
case GetAllIncidentTypeStateInitial() when initial != null:
return initial(_that);case GetAllIncidentTypeStateLoading() when loading != null:
return loading(_that);case GetAllIncidentTypeStateLoaded() when loaded != null:
return loaded(_that);case GetAllIncidentTypeStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<IncidentType> data)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetAllIncidentTypeStateInitial() when initial != null:
return initial();case GetAllIncidentTypeStateLoading() when loading != null:
return loading();case GetAllIncidentTypeStateLoaded() when loaded != null:
return loaded(_that.data);case GetAllIncidentTypeStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<IncidentType> data)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case GetAllIncidentTypeStateInitial():
return initial();case GetAllIncidentTypeStateLoading():
return loading();case GetAllIncidentTypeStateLoaded():
return loaded(_that.data);case GetAllIncidentTypeStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<IncidentType> data)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case GetAllIncidentTypeStateInitial() when initial != null:
return initial();case GetAllIncidentTypeStateLoading() when loading != null:
return loading();case GetAllIncidentTypeStateLoaded() when loaded != null:
return loaded(_that.data);case GetAllIncidentTypeStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class GetAllIncidentTypeStateInitial implements GetAllIncidentTypeState {
  const GetAllIncidentTypeStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentTypeStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllIncidentTypeState.initial()';
}


}




/// @nodoc


class GetAllIncidentTypeStateLoading implements GetAllIncidentTypeState {
  const GetAllIncidentTypeStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentTypeStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllIncidentTypeState.loading()';
}


}




/// @nodoc


class GetAllIncidentTypeStateLoaded implements GetAllIncidentTypeState {
  const GetAllIncidentTypeStateLoaded(final  List<IncidentType> data): _data = data;
  

 final  List<IncidentType> _data;
 List<IncidentType> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of GetAllIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAllIncidentTypeStateLoadedCopyWith<GetAllIncidentTypeStateLoaded> get copyWith => _$GetAllIncidentTypeStateLoadedCopyWithImpl<GetAllIncidentTypeStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentTypeStateLoaded&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'GetAllIncidentTypeState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $GetAllIncidentTypeStateLoadedCopyWith<$Res> implements $GetAllIncidentTypeStateCopyWith<$Res> {
  factory $GetAllIncidentTypeStateLoadedCopyWith(GetAllIncidentTypeStateLoaded value, $Res Function(GetAllIncidentTypeStateLoaded) _then) = _$GetAllIncidentTypeStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<IncidentType> data
});




}
/// @nodoc
class _$GetAllIncidentTypeStateLoadedCopyWithImpl<$Res>
    implements $GetAllIncidentTypeStateLoadedCopyWith<$Res> {
  _$GetAllIncidentTypeStateLoadedCopyWithImpl(this._self, this._then);

  final GetAllIncidentTypeStateLoaded _self;
  final $Res Function(GetAllIncidentTypeStateLoaded) _then;

/// Create a copy of GetAllIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(GetAllIncidentTypeStateLoaded(
null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<IncidentType>,
  ));
}


}

/// @nodoc


class GetAllIncidentTypeStateError implements GetAllIncidentTypeState {
  const GetAllIncidentTypeStateError(this.message);
  

 final  String message;

/// Create a copy of GetAllIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAllIncidentTypeStateErrorCopyWith<GetAllIncidentTypeStateError> get copyWith => _$GetAllIncidentTypeStateErrorCopyWithImpl<GetAllIncidentTypeStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentTypeStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GetAllIncidentTypeState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $GetAllIncidentTypeStateErrorCopyWith<$Res> implements $GetAllIncidentTypeStateCopyWith<$Res> {
  factory $GetAllIncidentTypeStateErrorCopyWith(GetAllIncidentTypeStateError value, $Res Function(GetAllIncidentTypeStateError) _then) = _$GetAllIncidentTypeStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$GetAllIncidentTypeStateErrorCopyWithImpl<$Res>
    implements $GetAllIncidentTypeStateErrorCopyWith<$Res> {
  _$GetAllIncidentTypeStateErrorCopyWithImpl(this._self, this._then);

  final GetAllIncidentTypeStateError _self;
  final $Res Function(GetAllIncidentTypeStateError) _then;

/// Create a copy of GetAllIncidentTypeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(GetAllIncidentTypeStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
