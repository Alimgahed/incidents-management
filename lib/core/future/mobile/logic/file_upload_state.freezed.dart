// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'file_upload_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FileUploadState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FileUploadState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileUploadState()';
}


}

/// @nodoc
class $FileUploadStateCopyWith<$Res>  {
$FileUploadStateCopyWith(FileUploadState _, $Res Function(FileUploadState) __);
}


/// Adds pattern-matching-related methods to [FileUploadState].
extension FileUploadStatePatterns on FileUploadState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _FileSelected value)?  fileSelected,TResult Function( _Uploading value)?  uploading,TResult Function( _UploadSuccess value)?  uploadSuccess,TResult Function( _UploadError value)?  uploadError,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _FileSelected() when fileSelected != null:
return fileSelected(_that);case _Uploading() when uploading != null:
return uploading(_that);case _UploadSuccess() when uploadSuccess != null:
return uploadSuccess(_that);case _UploadError() when uploadError != null:
return uploadError(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _FileSelected value)  fileSelected,required TResult Function( _Uploading value)  uploading,required TResult Function( _UploadSuccess value)  uploadSuccess,required TResult Function( _UploadError value)  uploadError,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _FileSelected():
return fileSelected(_that);case _Uploading():
return uploading(_that);case _UploadSuccess():
return uploadSuccess(_that);case _UploadError():
return uploadError(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _FileSelected value)?  fileSelected,TResult? Function( _Uploading value)?  uploading,TResult? Function( _UploadSuccess value)?  uploadSuccess,TResult? Function( _UploadError value)?  uploadError,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _FileSelected() when fileSelected != null:
return fileSelected(_that);case _Uploading() when uploading != null:
return uploading(_that);case _UploadSuccess() when uploadSuccess != null:
return uploadSuccess(_that);case _UploadError() when uploadError != null:
return uploadError(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function( String fileName,  String filePath,  int fileSize,  String? fileExtension)?  fileSelected,TResult Function( double progress,  String fileName)?  uploading,TResult Function( String message,  String fileName)?  uploadSuccess,TResult Function( String error)?  uploadError,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _FileSelected() when fileSelected != null:
return fileSelected(_that.fileName,_that.filePath,_that.fileSize,_that.fileExtension);case _Uploading() when uploading != null:
return uploading(_that.progress,_that.fileName);case _UploadSuccess() when uploadSuccess != null:
return uploadSuccess(_that.message,_that.fileName);case _UploadError() when uploadError != null:
return uploadError(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function( String fileName,  String filePath,  int fileSize,  String? fileExtension)  fileSelected,required TResult Function( double progress,  String fileName)  uploading,required TResult Function( String message,  String fileName)  uploadSuccess,required TResult Function( String error)  uploadError,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _FileSelected():
return fileSelected(_that.fileName,_that.filePath,_that.fileSize,_that.fileExtension);case _Uploading():
return uploading(_that.progress,_that.fileName);case _UploadSuccess():
return uploadSuccess(_that.message,_that.fileName);case _UploadError():
return uploadError(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function( String fileName,  String filePath,  int fileSize,  String? fileExtension)?  fileSelected,TResult? Function( double progress,  String fileName)?  uploading,TResult? Function( String message,  String fileName)?  uploadSuccess,TResult? Function( String error)?  uploadError,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _FileSelected() when fileSelected != null:
return fileSelected(_that.fileName,_that.filePath,_that.fileSize,_that.fileExtension);case _Uploading() when uploading != null:
return uploading(_that.progress,_that.fileName);case _UploadSuccess() when uploadSuccess != null:
return uploadSuccess(_that.message,_that.fileName);case _UploadError() when uploadError != null:
return uploadError(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements FileUploadState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'FileUploadState.initial()';
}


}




/// @nodoc


class _FileSelected implements FileUploadState {
  const _FileSelected({required this.fileName, required this.filePath, required this.fileSize, this.fileExtension});
  

 final  String fileName;
 final  String filePath;
 final  int fileSize;
 final  String? fileExtension;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FileSelectedCopyWith<_FileSelected> get copyWith => __$FileSelectedCopyWithImpl<_FileSelected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FileSelected&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.fileExtension, fileExtension) || other.fileExtension == fileExtension));
}


@override
int get hashCode => Object.hash(runtimeType,fileName,filePath,fileSize,fileExtension);

@override
String toString() {
  return 'FileUploadState.fileSelected(fileName: $fileName, filePath: $filePath, fileSize: $fileSize, fileExtension: $fileExtension)';
}


}

/// @nodoc
abstract mixin class _$FileSelectedCopyWith<$Res> implements $FileUploadStateCopyWith<$Res> {
  factory _$FileSelectedCopyWith(_FileSelected value, $Res Function(_FileSelected) _then) = __$FileSelectedCopyWithImpl;
@useResult
$Res call({
 String fileName, String filePath, int fileSize, String? fileExtension
});




}
/// @nodoc
class __$FileSelectedCopyWithImpl<$Res>
    implements _$FileSelectedCopyWith<$Res> {
  __$FileSelectedCopyWithImpl(this._self, this._then);

  final _FileSelected _self;
  final $Res Function(_FileSelected) _then;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fileName = null,Object? filePath = null,Object? fileSize = null,Object? fileExtension = freezed,}) {
  return _then(_FileSelected(
fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,fileSize: null == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int,fileExtension: freezed == fileExtension ? _self.fileExtension : fileExtension // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _Uploading implements FileUploadState {
  const _Uploading({required this.progress, required this.fileName});
  

 final  double progress;
 final  String fileName;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadingCopyWith<_Uploading> get copyWith => __$UploadingCopyWithImpl<_Uploading>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Uploading&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,progress,fileName);

@override
String toString() {
  return 'FileUploadState.uploading(progress: $progress, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$UploadingCopyWith<$Res> implements $FileUploadStateCopyWith<$Res> {
  factory _$UploadingCopyWith(_Uploading value, $Res Function(_Uploading) _then) = __$UploadingCopyWithImpl;
@useResult
$Res call({
 double progress, String fileName
});




}
/// @nodoc
class __$UploadingCopyWithImpl<$Res>
    implements _$UploadingCopyWith<$Res> {
  __$UploadingCopyWithImpl(this._self, this._then);

  final _Uploading _self;
  final $Res Function(_Uploading) _then;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? progress = null,Object? fileName = null,}) {
  return _then(_Uploading(
progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UploadSuccess implements FileUploadState {
  const _UploadSuccess({required this.message, required this.fileName});
  

 final  String message;
 final  String fileName;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadSuccessCopyWith<_UploadSuccess> get copyWith => __$UploadSuccessCopyWithImpl<_UploadSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadSuccess&&(identical(other.message, message) || other.message == message)&&(identical(other.fileName, fileName) || other.fileName == fileName));
}


@override
int get hashCode => Object.hash(runtimeType,message,fileName);

@override
String toString() {
  return 'FileUploadState.uploadSuccess(message: $message, fileName: $fileName)';
}


}

/// @nodoc
abstract mixin class _$UploadSuccessCopyWith<$Res> implements $FileUploadStateCopyWith<$Res> {
  factory _$UploadSuccessCopyWith(_UploadSuccess value, $Res Function(_UploadSuccess) _then) = __$UploadSuccessCopyWithImpl;
@useResult
$Res call({
 String message, String fileName
});




}
/// @nodoc
class __$UploadSuccessCopyWithImpl<$Res>
    implements _$UploadSuccessCopyWith<$Res> {
  __$UploadSuccessCopyWithImpl(this._self, this._then);

  final _UploadSuccess _self;
  final $Res Function(_UploadSuccess) _then;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? fileName = null,}) {
  return _then(_UploadSuccess(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UploadError implements FileUploadState {
  const _UploadError({required this.error});
  

 final  String error;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadErrorCopyWith<_UploadError> get copyWith => __$UploadErrorCopyWithImpl<_UploadError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadError&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'FileUploadState.uploadError(error: $error)';
}


}

/// @nodoc
abstract mixin class _$UploadErrorCopyWith<$Res> implements $FileUploadStateCopyWith<$Res> {
  factory _$UploadErrorCopyWith(_UploadError value, $Res Function(_UploadError) _then) = __$UploadErrorCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class __$UploadErrorCopyWithImpl<$Res>
    implements _$UploadErrorCopyWith<$Res> {
  __$UploadErrorCopyWithImpl(this._self, this._then);

  final _UploadError _self;
  final $Res Function(_UploadError) _then;

/// Create a copy of FileUploadState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_UploadError(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
