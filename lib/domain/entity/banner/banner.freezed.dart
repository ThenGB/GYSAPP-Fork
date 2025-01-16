// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'banner.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImageBanner _$ImageBannerFromJson(Map<String, dynamic> json) {
  return _ImageBanner.fromJson(json);
}

/// @nodoc
mixin _$ImageBanner {
  @JsonKey(name: 'description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'imageUrl')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'linkUrl')
  String? get linkUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'order')
  int? get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'title')
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'expiredDate')
  DateTime? get expiredDate => throw _privateConstructorUsedError;

  /// Serializes this ImageBanner to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageBanner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageBannerCopyWith<ImageBanner> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageBannerCopyWith<$Res> {
  factory $ImageBannerCopyWith(
          ImageBanner value, $Res Function(ImageBanner) then) =
      _$ImageBannerCopyWithImpl<$Res, ImageBanner>;
  @useResult
  $Res call(
      {@JsonKey(name: 'description') String? description,
      @JsonKey(name: 'imageUrl') String? imageUrl,
      @JsonKey(name: 'linkUrl') String? linkUrl,
      @JsonKey(name: 'order') int? order,
      @JsonKey(name: 'title') String? title,
      @JsonKey(name: 'expiredDate') DateTime? expiredDate});
}

/// @nodoc
class _$ImageBannerCopyWithImpl<$Res, $Val extends ImageBanner>
    implements $ImageBannerCopyWith<$Res> {
  _$ImageBannerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageBanner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? linkUrl = freezed,
    Object? order = freezed,
    Object? title = freezed,
    Object? expiredDate = freezed,
  }) {
    return _then(_value.copyWith(
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      linkUrl: freezed == linkUrl
          ? _value.linkUrl
          : linkUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      expiredDate: freezed == expiredDate
          ? _value.expiredDate
          : expiredDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImageBannerImplCopyWith<$Res>
    implements $ImageBannerCopyWith<$Res> {
  factory _$$ImageBannerImplCopyWith(
          _$ImageBannerImpl value, $Res Function(_$ImageBannerImpl) then) =
      __$$ImageBannerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'description') String? description,
      @JsonKey(name: 'imageUrl') String? imageUrl,
      @JsonKey(name: 'linkUrl') String? linkUrl,
      @JsonKey(name: 'order') int? order,
      @JsonKey(name: 'title') String? title,
      @JsonKey(name: 'expiredDate') DateTime? expiredDate});
}

/// @nodoc
class __$$ImageBannerImplCopyWithImpl<$Res>
    extends _$ImageBannerCopyWithImpl<$Res, _$ImageBannerImpl>
    implements _$$ImageBannerImplCopyWith<$Res> {
  __$$ImageBannerImplCopyWithImpl(
      _$ImageBannerImpl _value, $Res Function(_$ImageBannerImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImageBanner
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? linkUrl = freezed,
    Object? order = freezed,
    Object? title = freezed,
    Object? expiredDate = freezed,
  }) {
    return _then(_$ImageBannerImpl(
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      linkUrl: freezed == linkUrl
          ? _value.linkUrl
          : linkUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      expiredDate: freezed == expiredDate
          ? _value.expiredDate
          : expiredDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageBannerImpl extends _ImageBanner {
  const _$ImageBannerImpl(
      {@JsonKey(name: 'description') this.description,
      @JsonKey(name: 'imageUrl') this.imageUrl,
      @JsonKey(name: 'linkUrl') this.linkUrl,
      @JsonKey(name: 'order') this.order,
      @JsonKey(name: 'title') this.title,
      @JsonKey(name: 'expiredDate') this.expiredDate})
      : super._();

  factory _$ImageBannerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageBannerImplFromJson(json);

  @override
  @JsonKey(name: 'description')
  final String? description;
  @override
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @override
  @JsonKey(name: 'linkUrl')
  final String? linkUrl;
  @override
  @JsonKey(name: 'order')
  final int? order;
  @override
  @JsonKey(name: 'title')
  final String? title;
  @override
  @JsonKey(name: 'expiredDate')
  final DateTime? expiredDate;

  @override
  String toString() {
    return 'ImageBanner(description: $description, imageUrl: $imageUrl, linkUrl: $linkUrl, order: $order, title: $title, expiredDate: $expiredDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageBannerImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.linkUrl, linkUrl) || other.linkUrl == linkUrl) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.expiredDate, expiredDate) ||
                other.expiredDate == expiredDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, description, imageUrl, linkUrl, order, title, expiredDate);

  /// Create a copy of ImageBanner
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageBannerImplCopyWith<_$ImageBannerImpl> get copyWith =>
      __$$ImageBannerImplCopyWithImpl<_$ImageBannerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageBannerImplToJson(
      this,
    );
  }
}

abstract class _ImageBanner extends ImageBanner {
  const factory _ImageBanner(
          {@JsonKey(name: 'description') final String? description,
          @JsonKey(name: 'imageUrl') final String? imageUrl,
          @JsonKey(name: 'linkUrl') final String? linkUrl,
          @JsonKey(name: 'order') final int? order,
          @JsonKey(name: 'title') final String? title,
          @JsonKey(name: 'expiredDate') final DateTime? expiredDate}) =
      _$ImageBannerImpl;
  const _ImageBanner._() : super._();

  factory _ImageBanner.fromJson(Map<String, dynamic> json) =
      _$ImageBannerImpl.fromJson;

  @override
  @JsonKey(name: 'description')
  String? get description;
  @override
  @JsonKey(name: 'imageUrl')
  String? get imageUrl;
  @override
  @JsonKey(name: 'linkUrl')
  String? get linkUrl;
  @override
  @JsonKey(name: 'order')
  int? get order;
  @override
  @JsonKey(name: 'title')
  String? get title;
  @override
  @JsonKey(name: 'expiredDate')
  DateTime? get expiredDate;

  /// Create a copy of ImageBanner
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageBannerImplCopyWith<_$ImageBannerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
