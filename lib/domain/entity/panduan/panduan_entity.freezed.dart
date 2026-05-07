// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'panduan_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Panduan {

 String get title; String get description; String get url; String get imageUrl;
/// Create a copy of Panduan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PanduanCopyWith<Panduan> get copyWith => _$PanduanCopyWithImpl<Panduan>(this as Panduan, _$identity);

  /// Serializes this Panduan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Panduan&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,url,imageUrl);

@override
String toString() {
  return 'Panduan(title: $title, description: $description, url: $url, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $PanduanCopyWith<$Res>  {
  factory $PanduanCopyWith(Panduan value, $Res Function(Panduan) _then) = _$PanduanCopyWithImpl;
@useResult
$Res call({
 String title, String description, String url, String imageUrl
});




}
/// @nodoc
class _$PanduanCopyWithImpl<$Res>
    implements $PanduanCopyWith<$Res> {
  _$PanduanCopyWithImpl(this._self, this._then);

  final Panduan _self;
  final $Res Function(Panduan) _then;

/// Create a copy of Panduan
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


/// Adds pattern-matching-related methods to [Panduan].
extension PanduanPatterns on Panduan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Panduan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Panduan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Panduan value)  $default,){
final _that = this;
switch (_that) {
case _Panduan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Panduan value)?  $default,){
final _that = this;
switch (_that) {
case _Panduan() when $default != null:
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
case _Panduan() when $default != null:
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
case _Panduan():
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
case _Panduan() when $default != null:
return $default(_that.title,_that.description,_that.url,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Panduan extends Panduan {
  const _Panduan({required this.title, required this.description, required this.url, required this.imageUrl}): super._();
  factory _Panduan.fromJson(Map<String, dynamic> json) => _$PanduanFromJson(json);

@override final  String title;
@override final  String description;
@override final  String url;
@override final  String imageUrl;

/// Create a copy of Panduan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PanduanCopyWith<_Panduan> get copyWith => __$PanduanCopyWithImpl<_Panduan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PanduanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Panduan&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,url,imageUrl);

@override
String toString() {
  return 'Panduan(title: $title, description: $description, url: $url, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$PanduanCopyWith<$Res> implements $PanduanCopyWith<$Res> {
  factory _$PanduanCopyWith(_Panduan value, $Res Function(_Panduan) _then) = __$PanduanCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String url, String imageUrl
});




}
/// @nodoc
class __$PanduanCopyWithImpl<$Res>
    implements _$PanduanCopyWith<$Res> {
  __$PanduanCopyWithImpl(this._self, this._then);

  final _Panduan _self;
  final $Res Function(_Panduan) _then;

/// Create a copy of Panduan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? url = null,Object? imageUrl = null,}) {
  return _then(_Panduan(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
