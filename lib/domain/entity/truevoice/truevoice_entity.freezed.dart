// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'truevoice_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrueVoice {

 String get title; String get description; String get url; String get imageUrl;
/// Create a copy of TrueVoice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrueVoiceCopyWith<TrueVoice> get copyWith => _$TrueVoiceCopyWithImpl<TrueVoice>(this as TrueVoice, _$identity);

  /// Serializes this TrueVoice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrueVoice&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,url,imageUrl);

@override
String toString() {
  return 'TrueVoice(title: $title, description: $description, url: $url, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $TrueVoiceCopyWith<$Res>  {
  factory $TrueVoiceCopyWith(TrueVoice value, $Res Function(TrueVoice) _then) = _$TrueVoiceCopyWithImpl;
@useResult
$Res call({
 String title, String description, String url, String imageUrl
});




}
/// @nodoc
class _$TrueVoiceCopyWithImpl<$Res>
    implements $TrueVoiceCopyWith<$Res> {
  _$TrueVoiceCopyWithImpl(this._self, this._then);

  final TrueVoice _self;
  final $Res Function(TrueVoice) _then;

/// Create a copy of TrueVoice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? url = null,Object? imageUrl = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrueVoice].
extension TrueVoicePatterns on TrueVoice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrueVoice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrueVoice() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrueVoice value)  $default,){
final _that = this;
switch (_that) {
case _TrueVoice():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrueVoice value)?  $default,){
final _that = this;
switch (_that) {
case _TrueVoice() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String url,  String imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrueVoice() when $default != null:
return $default(_that.title,_that.description,_that.url,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String url,  String imageUrl)  $default,) {final _that = this;
switch (_that) {
case _TrueVoice():
return $default(_that.title,_that.description,_that.url,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String url,  String imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _TrueVoice() when $default != null:
return $default(_that.title,_that.description,_that.url,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrueVoice extends TrueVoice {
  const _TrueVoice({required this.title, required this.description, required this.url, required this.imageUrl}): super._();
  factory _TrueVoice.fromJson(Map<String, dynamic> json) => _$TrueVoiceFromJson(json);

@override final  String title;
@override final  String description;
@override final  String url;
@override final  String imageUrl;

/// Create a copy of TrueVoice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrueVoiceCopyWith<_TrueVoice> get copyWith => __$TrueVoiceCopyWithImpl<_TrueVoice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrueVoiceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrueVoice&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,url,imageUrl);

@override
String toString() {
  return 'TrueVoice(title: $title, description: $description, url: $url, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$TrueVoiceCopyWith<$Res> implements $TrueVoiceCopyWith<$Res> {
  factory _$TrueVoiceCopyWith(_TrueVoice value, $Res Function(_TrueVoice) _then) = __$TrueVoiceCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String url, String imageUrl
});




}
/// @nodoc
class __$TrueVoiceCopyWithImpl<$Res>
    implements _$TrueVoiceCopyWith<$Res> {
  __$TrueVoiceCopyWithImpl(this._self, this._then);

  final _TrueVoice _self;
  final $Res Function(_TrueVoice) _then;

/// Create a copy of TrueVoice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? url = null,Object? imageUrl = null,}) {
  return _then(_TrueVoice(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
