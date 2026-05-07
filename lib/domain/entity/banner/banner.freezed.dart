// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageBanner {

@JsonKey(name: 'description') String? get description;@JsonKey(name: 'imageUrl') String? get imageUrl;@JsonKey(name: 'linkUrl') String? get linkUrl;@JsonKey(name: 'order') int? get order;@JsonKey(name: 'title') String? get title;@JsonKey(name: 'expiredDate') DateTime? get expiredDate;
/// Create a copy of ImageBanner
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageBannerCopyWith<ImageBanner> get copyWith => _$ImageBannerCopyWithImpl<ImageBanner>(this as ImageBanner, _$identity);

  /// Serializes this ImageBanner to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageBanner&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.order, order) || other.order == order)&&(identical(other.title, title) || other.title == title)&&(identical(other.expiredDate, expiredDate) || other.expiredDate == expiredDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,imageUrl,linkUrl,order,title,expiredDate);

@override
String toString() {
  return 'ImageBanner(description: $description, imageUrl: $imageUrl, linkUrl: $linkUrl, order: $order, title: $title, expiredDate: $expiredDate)';
}


}

/// @nodoc
abstract mixin class $ImageBannerCopyWith<$Res>  {
  factory $ImageBannerCopyWith(ImageBanner value, $Res Function(ImageBanner) _then) = _$ImageBannerCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'description') String? description,@JsonKey(name: 'imageUrl') String? imageUrl,@JsonKey(name: 'linkUrl') String? linkUrl,@JsonKey(name: 'order') int? order,@JsonKey(name: 'title') String? title,@JsonKey(name: 'expiredDate') DateTime? expiredDate
});




}
/// @nodoc
class _$ImageBannerCopyWithImpl<$Res>
    implements $ImageBannerCopyWith<$Res> {
  _$ImageBannerCopyWithImpl(this._self, this._then);

  final ImageBanner _self;
  final $Res Function(ImageBanner) _then;

/// Create a copy of ImageBanner
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = freezed,Object? imageUrl = freezed,Object? linkUrl = freezed,Object? order = freezed,Object? title = freezed,Object? expiredDate = freezed,}) {
  return _then(_self.copyWith(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,expiredDate: freezed == expiredDate ? _self.expiredDate : expiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageBanner].
extension ImageBannerPatterns on ImageBanner {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageBanner value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageBanner() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageBanner value)  $default,){
final _that = this;
switch (_that) {
case _ImageBanner():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageBanner value)?  $default,){
final _that = this;
switch (_that) {
case _ImageBanner() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'description')  String? description, @JsonKey(name: 'imageUrl')  String? imageUrl, @JsonKey(name: 'linkUrl')  String? linkUrl, @JsonKey(name: 'order')  int? order, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'expiredDate')  DateTime? expiredDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageBanner() when $default != null:
return $default(_that.description,_that.imageUrl,_that.linkUrl,_that.order,_that.title,_that.expiredDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'description')  String? description, @JsonKey(name: 'imageUrl')  String? imageUrl, @JsonKey(name: 'linkUrl')  String? linkUrl, @JsonKey(name: 'order')  int? order, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'expiredDate')  DateTime? expiredDate)  $default,) {final _that = this;
switch (_that) {
case _ImageBanner():
return $default(_that.description,_that.imageUrl,_that.linkUrl,_that.order,_that.title,_that.expiredDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'description')  String? description, @JsonKey(name: 'imageUrl')  String? imageUrl, @JsonKey(name: 'linkUrl')  String? linkUrl, @JsonKey(name: 'order')  int? order, @JsonKey(name: 'title')  String? title, @JsonKey(name: 'expiredDate')  DateTime? expiredDate)?  $default,) {final _that = this;
switch (_that) {
case _ImageBanner() when $default != null:
return $default(_that.description,_that.imageUrl,_that.linkUrl,_that.order,_that.title,_that.expiredDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageBanner extends ImageBanner {
  const _ImageBanner({@JsonKey(name: 'description') this.description, @JsonKey(name: 'imageUrl') this.imageUrl, @JsonKey(name: 'linkUrl') this.linkUrl, @JsonKey(name: 'order') this.order, @JsonKey(name: 'title') this.title, @JsonKey(name: 'expiredDate') this.expiredDate}): super._();
  factory _ImageBanner.fromJson(Map<String, dynamic> json) => _$ImageBannerFromJson(json);

@override@JsonKey(name: 'description') final  String? description;
@override@JsonKey(name: 'imageUrl') final  String? imageUrl;
@override@JsonKey(name: 'linkUrl') final  String? linkUrl;
@override@JsonKey(name: 'order') final  int? order;
@override@JsonKey(name: 'title') final  String? title;
@override@JsonKey(name: 'expiredDate') final  DateTime? expiredDate;

/// Create a copy of ImageBanner
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageBannerCopyWith<_ImageBanner> get copyWith => __$ImageBannerCopyWithImpl<_ImageBanner>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageBannerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageBanner&&(identical(other.description, description) || other.description == description)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl)&&(identical(other.order, order) || other.order == order)&&(identical(other.title, title) || other.title == title)&&(identical(other.expiredDate, expiredDate) || other.expiredDate == expiredDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,imageUrl,linkUrl,order,title,expiredDate);

@override
String toString() {
  return 'ImageBanner(description: $description, imageUrl: $imageUrl, linkUrl: $linkUrl, order: $order, title: $title, expiredDate: $expiredDate)';
}


}

/// @nodoc
abstract mixin class _$ImageBannerCopyWith<$Res> implements $ImageBannerCopyWith<$Res> {
  factory _$ImageBannerCopyWith(_ImageBanner value, $Res Function(_ImageBanner) _then) = __$ImageBannerCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'description') String? description,@JsonKey(name: 'imageUrl') String? imageUrl,@JsonKey(name: 'linkUrl') String? linkUrl,@JsonKey(name: 'order') int? order,@JsonKey(name: 'title') String? title,@JsonKey(name: 'expiredDate') DateTime? expiredDate
});




}
/// @nodoc
class __$ImageBannerCopyWithImpl<$Res>
    implements _$ImageBannerCopyWith<$Res> {
  __$ImageBannerCopyWithImpl(this._self, this._then);

  final _ImageBanner _self;
  final $Res Function(_ImageBanner) _then;

/// Create a copy of ImageBanner
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = freezed,Object? imageUrl = freezed,Object? linkUrl = freezed,Object? order = freezed,Object? title = freezed,Object? expiredDate = freezed,}) {
  return _then(_ImageBanner(
description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,linkUrl: freezed == linkUrl ? _self.linkUrl : linkUrl // ignore: cast_nullable_to_non_nullable
as String?,order: freezed == order ? _self.order : order // ignore: cast_nullable_to_non_nullable
as int?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,expiredDate: freezed == expiredDate ? _self.expiredDate : expiredDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
