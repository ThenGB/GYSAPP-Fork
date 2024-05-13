// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kesaksian_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Kesaksian _$KesaksianFromJson(Map<String, dynamic> json) {
  return _Kesaksian.fromJson(json);
}

/// @nodoc
mixin _$Kesaksian {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $KesaksianCopyWith<Kesaksian> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KesaksianCopyWith<$Res> {
  factory $KesaksianCopyWith(Kesaksian value, $Res Function(Kesaksian) then) =
      _$KesaksianCopyWithImpl<$Res, Kesaksian>;
  @useResult
  $Res call({String title, String description, String url, String imageUrl});
}

/// @nodoc
class _$KesaksianCopyWithImpl<$Res, $Val extends Kesaksian>
    implements $KesaksianCopyWith<$Res> {
  _$KesaksianCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? imageUrl = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KesaksianImplCopyWith<$Res>
    implements $KesaksianCopyWith<$Res> {
  factory _$$KesaksianImplCopyWith(
          _$KesaksianImpl value, $Res Function(_$KesaksianImpl) then) =
      __$$KesaksianImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String description, String url, String imageUrl});
}

/// @nodoc
class __$$KesaksianImplCopyWithImpl<$Res>
    extends _$KesaksianCopyWithImpl<$Res, _$KesaksianImpl>
    implements _$$KesaksianImplCopyWith<$Res> {
  __$$KesaksianImplCopyWithImpl(
      _$KesaksianImpl _value, $Res Function(_$KesaksianImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? imageUrl = null,
  }) {
    return _then(_$KesaksianImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KesaksianImpl extends _Kesaksian {
  const _$KesaksianImpl(
      {required this.title,
      required this.description,
      required this.url,
      required this.imageUrl})
      : super._();

  factory _$KesaksianImpl.fromJson(Map<String, dynamic> json) =>
      _$$KesaksianImplFromJson(json);

  @override
  final String title;
  @override
  final String description;
  @override
  final String url;
  @override
  final String imageUrl;

  @override
  String toString() {
    return 'Kesaksian(title: $title, description: $description, url: $url, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KesaksianImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, title, description, url, imageUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$KesaksianImplCopyWith<_$KesaksianImpl> get copyWith =>
      __$$KesaksianImplCopyWithImpl<_$KesaksianImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KesaksianImplToJson(
      this,
    );
  }
}

abstract class _Kesaksian extends Kesaksian {
  const factory _Kesaksian(
      {required final String title,
      required final String description,
      required final String url,
      required final String imageUrl}) = _$KesaksianImpl;
  const _Kesaksian._() : super._();

  factory _Kesaksian.fromJson(Map<String, dynamic> json) =
      _$KesaksianImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get url;
  @override
  String get imageUrl;
  @override
  @JsonKey(ignore: true)
  _$$KesaksianImplCopyWith<_$KesaksianImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
