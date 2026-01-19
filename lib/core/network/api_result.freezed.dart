// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ApiResult<T> {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResult<T>);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ApiResult<$T>()';
}


}

/// @nodoc
class $ApiResultCopyWith<T,$Res>  {
$ApiResultCopyWith(ApiResult<T> _, $Res Function(ApiResult<T>) __);
}


/// Adds pattern-matching-related methods to [ApiResult].
extension ApiResultPatterns<T> on ApiResult<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ApiResultSuccess<T> value)?  success,TResult Function( ApiResultError<T> value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ApiResultSuccess() when success != null:
return success(_that);case ApiResultError() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ApiResultSuccess<T> value)  success,required TResult Function( ApiResultError<T> value)  error,}){
final _that = this;
switch (_that) {
case ApiResultSuccess():
return success(_that);case ApiResultError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ApiResultSuccess<T> value)?  success,TResult? Function( ApiResultError<T> value)?  error,}){
final _that = this;
switch (_that) {
case ApiResultSuccess() when success != null:
return success(_that);case ApiResultError() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( T data)?  success,TResult Function( ApiErrorModel error)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ApiResultSuccess() when success != null:
return success(_that.data);case ApiResultError() when error != null:
return error(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( T data)  success,required TResult Function( ApiErrorModel error)  error,}) {final _that = this;
switch (_that) {
case ApiResultSuccess():
return success(_that.data);case ApiResultError():
return error(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( T data)?  success,TResult? Function( ApiErrorModel error)?  error,}) {final _that = this;
switch (_that) {
case ApiResultSuccess() when success != null:
return success(_that.data);case ApiResultError() when error != null:
return error(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class ApiResultSuccess<T> implements ApiResult<T> {
  const ApiResultSuccess(this.data);
  

 final  T data;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResultSuccessCopyWith<T, ApiResultSuccess<T>> get copyWith => _$ApiResultSuccessCopyWithImpl<T, ApiResultSuccess<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResultSuccess<T>&&const DeepCollectionEquality().equals(other.data, data));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data));

@override
String toString() {
  return 'ApiResult<$T>.success(data: $data)';
}


}

/// @nodoc
abstract mixin class $ApiResultSuccessCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiResultSuccessCopyWith(ApiResultSuccess<T> value, $Res Function(ApiResultSuccess<T>) _then) = _$ApiResultSuccessCopyWithImpl;
@useResult
$Res call({
 T data
});




}
/// @nodoc
class _$ApiResultSuccessCopyWithImpl<T,$Res>
    implements $ApiResultSuccessCopyWith<T, $Res> {
  _$ApiResultSuccessCopyWithImpl(this._self, this._then);

  final ApiResultSuccess<T> _self;
  final $Res Function(ApiResultSuccess<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? data = freezed,}) {
  return _then(ApiResultSuccess<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,
  ));
}


}

/// @nodoc


class ApiResultError<T> implements ApiResult<T> {
  const ApiResultError(this.error);
  

 final  ApiErrorModel error;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiResultErrorCopyWith<T, ApiResultError<T>> get copyWith => _$ApiResultErrorCopyWithImpl<T, ApiResultError<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiResultError<T>&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'ApiResult<$T>.error(error: $error)';
}


}

/// @nodoc
abstract mixin class $ApiResultErrorCopyWith<T,$Res> implements $ApiResultCopyWith<T, $Res> {
  factory $ApiResultErrorCopyWith(ApiResultError<T> value, $Res Function(ApiResultError<T>) _then) = _$ApiResultErrorCopyWithImpl;
@useResult
$Res call({
 ApiErrorModel error
});




}
/// @nodoc
class _$ApiResultErrorCopyWithImpl<T,$Res>
    implements $ApiResultErrorCopyWith<T, $Res> {
  _$ApiResultErrorCopyWithImpl(this._self, this._then);

  final ApiResultError<T> _self;
  final $Res Function(ApiResultError<T>) _then;

/// Create a copy of ApiResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(ApiResultError<T>(
null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiErrorModel,
  ));
}


}

// dart format on
