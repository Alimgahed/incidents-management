// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'all_active_user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AllActiveUserState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllActiveUserState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AllActiveUserState()';
}


}

/// @nodoc
class $AllActiveUserStateCopyWith<$Res>  {
$AllActiveUserStateCopyWith(AllActiveUserState _, $Res Function(AllActiveUserState) __);
}


/// Adds pattern-matching-related methods to [AllActiveUserState].
extension AllActiveUserStatePatterns on AllActiveUserState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AllActiveUserStateInitial value)?  initial,TResult Function( AllActiveUserStateLoading value)?  loading,TResult Function( AllActiveUserStateLoaded value)?  loaded,TResult Function( AllActiveUserStateError value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AllActiveUserStateInitial() when initial != null:
return initial(_that);case AllActiveUserStateLoading() when loading != null:
return loading(_that);case AllActiveUserStateLoaded() when loaded != null:
return loaded(_that);case AllActiveUserStateError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AllActiveUserStateInitial value)  initial,required TResult Function( AllActiveUserStateLoading value)  loading,required TResult Function( AllActiveUserStateLoaded value)  loaded,required TResult Function( AllActiveUserStateError value)  error,}){
final _that = this;
switch (_that) {
case AllActiveUserStateInitial():
return initial(_that);case AllActiveUserStateLoading():
return loading(_that);case AllActiveUserStateLoaded():
return loaded(_that);case AllActiveUserStateError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AllActiveUserStateInitial value)?  initial,TResult? Function( AllActiveUserStateLoading value)?  loading,TResult? Function( AllActiveUserStateLoaded value)?  loaded,TResult? Function( AllActiveUserStateError value)?  error,}){
final _that = this;
switch (_that) {
case AllActiveUserStateInitial() when initial != null:
return initial(_that);case AllActiveUserStateLoading() when loading != null:
return loading(_that);case AllActiveUserStateLoaded() when loaded != null:
return loaded(_that);case AllActiveUserStateError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ActiveUser> data)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AllActiveUserStateInitial() when initial != null:
return initial();case AllActiveUserStateLoading() when loading != null:
return loading();case AllActiveUserStateLoaded() when loaded != null:
return loaded(_that.data);case AllActiveUserStateError() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ActiveUser> data)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case AllActiveUserStateInitial():
return initial();case AllActiveUserStateLoading():
return loading();case AllActiveUserStateLoaded():
return loaded(_that.data);case AllActiveUserStateError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ActiveUser> data)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case AllActiveUserStateInitial() when initial != null:
return initial();case AllActiveUserStateLoading() when loading != null:
return loading();case AllActiveUserStateLoaded() when loaded != null:
return loaded(_that.data);case AllActiveUserStateError() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class AllActiveUserStateInitial implements AllActiveUserState {
  const AllActiveUserStateInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllActiveUserStateInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AllActiveUserState.initial()';
}


}




/// @nodoc


class AllActiveUserStateLoading implements AllActiveUserState {
  const AllActiveUserStateLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllActiveUserStateLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AllActiveUserState.loading()';
}


}




/// @nodoc


class AllActiveUserStateLoaded implements AllActiveUserState {
  const AllActiveUserStateLoaded(final  List<ActiveUser> data): _data = data;
  

 final  List<ActiveUser> _data;
 List<ActiveUser> get data {
  if (_data is EqualUnmodifiableListView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_data);
}


/// Create a copy of AllActiveUserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllActiveUserStateLoadedCopyWith<AllActiveUserStateLoaded> get copyWith => _$AllActiveUserStateLoadedCopyWithImpl<AllActiveUserStateLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllActiveUserStateLoaded&&const DeepCollectionEquality().equals(other._data, _data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data));

@override
String toString() {
  return 'AllActiveUserState.loaded(data: $data)';
}


}

/// @nodoc
abstract mixin class $AllActiveUserStateLoadedCopyWith<$Res> implements $AllActiveUserStateCopyWith<$Res> {
  factory $AllActiveUserStateLoadedCopyWith(AllActiveUserStateLoaded value, $Res Function(AllActiveUserStateLoaded) _then) = _$AllActiveUserStateLoadedCopyWithImpl;
@useResult
$Res call({
 List<ActiveUser> data
});




}
/// @nodoc
class _$AllActiveUserStateLoadedCopyWithImpl<$Res>
    implements $AllActiveUserStateLoadedCopyWith<$Res> {
  _$AllActiveUserStateLoadedCopyWithImpl(this._self, this._then);

  final AllActiveUserStateLoaded _self;
  final $Res Function(AllActiveUserStateLoaded) _then;

/// Create a copy of AllActiveUserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = null,}) {
  return _then(AllActiveUserStateLoaded(
null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as List<ActiveUser>,
  ));
}


}

/// @nodoc


class AllActiveUserStateError implements AllActiveUserState {
  const AllActiveUserStateError(this.message);
  

 final  String message;

/// Create a copy of AllActiveUserState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllActiveUserStateErrorCopyWith<AllActiveUserStateError> get copyWith => _$AllActiveUserStateErrorCopyWithImpl<AllActiveUserStateError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllActiveUserStateError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AllActiveUserState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class $AllActiveUserStateErrorCopyWith<$Res> implements $AllActiveUserStateCopyWith<$Res> {
  factory $AllActiveUserStateErrorCopyWith(AllActiveUserStateError value, $Res Function(AllActiveUserStateError) _then) = _$AllActiveUserStateErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$AllActiveUserStateErrorCopyWithImpl<$Res>
    implements $AllActiveUserStateErrorCopyWith<$Res> {
  _$AllActiveUserStateErrorCopyWithImpl(this._self, this._then);

  final AllActiveUserStateError _self;
  final $Res Function(AllActiveUserStateError) _then;

/// Create a copy of AllActiveUserState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(AllActiveUserStateError(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
