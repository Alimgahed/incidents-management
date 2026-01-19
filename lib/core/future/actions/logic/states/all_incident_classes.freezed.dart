// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'all_incident_classes.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetAllIncidentClassesState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentClassesState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllIncidentClassesState()';
}


}

/// @nodoc
class $GetAllIncidentClassesStateCopyWith<$Res>  {
$GetAllIncidentClassesStateCopyWith(GetAllIncidentClassesState _, $Res Function(GetAllIncidentClassesState) __);
}


/// Adds pattern-matching-related methods to [GetAllIncidentClassesState].
extension GetAllIncidentClassesStatePatterns on GetAllIncidentClassesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetAllIncidentClassesStateInitial value)?  initial,TResult Function( GetAllIncidentClassesStateLoading value)?  loading,TResult Function( GetAllIncidentClassesStateLoaded value)?  loaded,TResult Function( GetAllIncidentClassesStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetAllIncidentClassesStateInitial() when initial != null:
return initial(_that);case GetAllIncidentClassesStateLoading() when loading != null:
return loading(_that);case GetAllIncidentClassesStateLoaded() when loaded != null:
return loaded(_that);case GetAllIncidentClassesStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetAllIncidentClassesStateInitial value)  initial,required TResult Function( GetAllIncidentClassesStateLoading value)  loading,required TResult Function( GetAllIncidentClassesStateLoaded value)  loaded,required TResult Function( GetAllIncidentClassesStateError value)  error,}){
final _that = this;
switch (_that) {
case GetAllIncidentClassesStateInitial():
return initial(_that);case GetAllIncidentClassesStateLoading():
return loading(_that);case GetAllIncidentClassesStateLoaded():
return loaded(_that);case GetAllIncidentClassesStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetAllIncidentClassesStateInitial value)?  initial,TResult? Function( GetAllIncidentClassesStateLoading value)?  loading,TResult? Function( GetAllIncidentClassesStateLoaded value)?  loaded,TResult? Function( GetAllIncidentClassesStateError value)?  error,}){
final _that = this;
switch (_that) {
case GetAllIncidentClassesStateInitial() when initial != null:
return initial(_that);case GetAllIncidentClassesStateLoading() when loading != null:
return loading(_that);case GetAllIncidentClassesStateLoaded() when loaded != null:
return loaded(_that);case GetAllIncidentClassesStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<IncidentClass> data)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetAllIncidentClassesStateInitial() when initial != null:
return initial();case GetAllIncidentClassesStateLoading() when loading != null:
return loading();case GetAllIncidentClassesStateLoaded() when loaded != null:
return loaded(_that.data);case GetAllIncidentClassesStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<IncidentClass> data)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case GetAllIncidentClassesStateInitial():
return initial();case GetAllIncidentClassesStateLoading():
return loading();case GetAllIncidentClassesStateLoaded():
return loaded(_that.data);case GetAllIncidentClassesStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<IncidentClass> data)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case GetAllIncidentClassesStateInitial() when initial != null:
return initial();case GetAllIncidentClassesStateLoading() when loading != null:
return loading();case GetAllIncidentClassesStateLoaded() when loaded != null:
return loaded(_that.data);case GetAllIncidentClassesStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class GetAllIncidentClassesStateInitial implements GetAllIncidentClassesState {
  const GetAllIncidentClassesStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentClassesStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllIncidentClassesState.initial()';
}


}




/// @nodoc


class GetAllIncidentClassesStateLoading implements GetAllIncidentClassesState {
  const GetAllIncidentClassesStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentClassesStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GetAllIncidentClassesState.loading()';
}


}




/// @nodoc


class GetAllIncidentClassesStateLoaded implements GetAllIncidentClassesState {
  const GetAllIncidentClassesStateLoaded(final  List<IncidentClass> data): _data = data;
  

 final  List<IncidentClass> _data;
 List<IncidentClass> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of GetAllIncidentClassesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAllIncidentClassesStateLoadedCopyWith<GetAllIncidentClassesStateLoaded> get copyWith => _$GetAllIncidentClassesStateLoadedCopyWithImpl<GetAllIncidentClassesStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentClassesStateLoaded&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'GetAllIncidentClassesState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $GetAllIncidentClassesStateLoadedCopyWith<$Res> implements $GetAllIncidentClassesStateCopyWith<$Res> {
  factory $GetAllIncidentClassesStateLoadedCopyWith(GetAllIncidentClassesStateLoaded value, $Res Function(GetAllIncidentClassesStateLoaded) _then) = _$GetAllIncidentClassesStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<IncidentClass> data
});




}
/// @nodoc
class _$GetAllIncidentClassesStateLoadedCopyWithImpl<$Res>
    implements $GetAllIncidentClassesStateLoadedCopyWith<$Res> {
  _$GetAllIncidentClassesStateLoadedCopyWithImpl(this._self, this._then);

  final GetAllIncidentClassesStateLoaded _self;
  final $Res Function(GetAllIncidentClassesStateLoaded) _then;

/// Create a copy of GetAllIncidentClassesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(GetAllIncidentClassesStateLoaded(
null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<IncidentClass>,
  ));
}


}

/// @nodoc


class GetAllIncidentClassesStateError implements GetAllIncidentClassesState {
  const GetAllIncidentClassesStateError(this.message);
  

 final  String message;

/// Create a copy of GetAllIncidentClassesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetAllIncidentClassesStateErrorCopyWith<GetAllIncidentClassesStateError> get copyWith => _$GetAllIncidentClassesStateErrorCopyWithImpl<GetAllIncidentClassesStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetAllIncidentClassesStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'GetAllIncidentClassesState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $GetAllIncidentClassesStateErrorCopyWith<$Res> implements $GetAllIncidentClassesStateCopyWith<$Res> {
  factory $GetAllIncidentClassesStateErrorCopyWith(GetAllIncidentClassesStateError value, $Res Function(GetAllIncidentClassesStateError) _then) = _$GetAllIncidentClassesStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$GetAllIncidentClassesStateErrorCopyWithImpl<$Res>
    implements $GetAllIncidentClassesStateErrorCopyWith<$Res> {
  _$GetAllIncidentClassesStateErrorCopyWithImpl(this._self, this._then);

  final GetAllIncidentClassesStateError _self;
  final $Res Function(GetAllIncidentClassesStateError) _then;

/// Create a copy of GetAllIncidentClassesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(GetAllIncidentClassesStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
