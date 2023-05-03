// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'truevoice_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TrueVoice _$TrueVoiceFromJson(Map<String, dynamic> json) {
  return _TrueVoice.fromJson(json);
}

/// @nodoc
mixin _$TrueVoice {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrueVoiceCopyWith<TrueVoice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrueVoiceCopyWith<$Res> {
  factory $TrueVoiceCopyWith(TrueVoice value, $Res Function(TrueVoice) then) =
      _$TrueVoiceCopyWithImpl<$Res, TrueVoice>;
  @useResult
  $Res call({String title, String description, String url, String imageUrl});
}

/// @nodoc
class _$TrueVoiceCopyWithImpl<$Res, $Val extends TrueVoice>
    implements $TrueVoiceCopyWith<$Res> {
  _$TrueVoiceCopyWithImpl(this._value, this._then);

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
abstract class _$$_TrueVoiceCopyWith<$Res> implements $TrueVoiceCopyWith<$Res> {
  factory _$$_TrueVoiceCopyWith(
          _$_TrueVoice value, $Res Function(_$_TrueVoice) then) =
      __$$_TrueVoiceCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String description, String url, String imageUrl});
}

/// @nodoc
class __$$_TrueVoiceCopyWithImpl<$Res>
    extends _$TrueVoiceCopyWithImpl<$Res, _$_TrueVoice>
    implements _$$_TrueVoiceCopyWith<$Res> {
  __$$_TrueVoiceCopyWithImpl(
      _$_TrueVoice _value, $Res Function(_$_TrueVoice) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? imageUrl = null,
  }) {
    return _then(_$_TrueVoice(
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
class _$_TrueVoice extends _TrueVoice {
  const _$_TrueVoice(
      {required this.title,
      required this.description,
      required this.url,
      required this.imageUrl})
      : super._();

  factory _$_TrueVoice.fromJson(Map<String, dynamic> json) =>
      _$$_TrueVoiceFromJson(json);

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
    return 'TrueVoice(title: $title, description: $description, url: $url, imageUrl: $imageUrl)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TrueVoice &&
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
  _$$_TrueVoiceCopyWith<_$_TrueVoice> get copyWith =>
      __$$_TrueVoiceCopyWithImpl<_$_TrueVoice>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TrueVoiceToJson(
      this,
    );
  }
}

abstract class _TrueVoice extends TrueVoice {
  const factory _TrueVoice(
      {required final String title,
      required final String description,
      required final String url,
      required final String imageUrl}) = _$_TrueVoice;
  const _TrueVoice._() : super._();

  factory _TrueVoice.fromJson(Map<String, dynamic> json) =
      _$_TrueVoice.fromJson;

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
  _$$_TrueVoiceCopyWith<_$_TrueVoice> get copyWith =>
      throw _privateConstructorUsedError;
}
