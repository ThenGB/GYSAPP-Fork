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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrueVoice _$TrueVoiceFromJson(Map<String, dynamic> json) {
  return _TrueVoice.fromJson(json);
}

/// @nodoc
mixin _$TrueVoice {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;

  /// Serializes this TrueVoice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrueVoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of TrueVoice
  /// with the given fields replaced by the non-null parameter values.
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
abstract class _$$TrueVoiceImplCopyWith<$Res>
    implements $TrueVoiceCopyWith<$Res> {
  factory _$$TrueVoiceImplCopyWith(
          _$TrueVoiceImpl value, $Res Function(_$TrueVoiceImpl) then) =
      __$$TrueVoiceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String description, String url, String imageUrl});
}

/// @nodoc
class __$$TrueVoiceImplCopyWithImpl<$Res>
    extends _$TrueVoiceCopyWithImpl<$Res, _$TrueVoiceImpl>
    implements _$$TrueVoiceImplCopyWith<$Res> {
  __$$TrueVoiceImplCopyWithImpl(
      _$TrueVoiceImpl _value, $Res Function(_$TrueVoiceImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrueVoice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? url = null,
    Object? imageUrl = null,
  }) {
    return _then(_$TrueVoiceImpl(
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
class _$TrueVoiceImpl extends _TrueVoice {
  const _$TrueVoiceImpl(
      {required this.title,
      required this.description,
      required this.url,
      required this.imageUrl})
      : super._();

  factory _$TrueVoiceImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrueVoiceImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrueVoiceImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, title, description, url, imageUrl);

  /// Create a copy of TrueVoice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrueVoiceImplCopyWith<_$TrueVoiceImpl> get copyWith =>
      __$$TrueVoiceImplCopyWithImpl<_$TrueVoiceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrueVoiceImplToJson(
      this,
    );
  }
}

abstract class _TrueVoice extends TrueVoice {
  const factory _TrueVoice(
      {required final String title,
      required final String description,
      required final String url,
      required final String imageUrl}) = _$TrueVoiceImpl;
  const _TrueVoice._() : super._();

  factory _TrueVoice.fromJson(Map<String, dynamic> json) =
      _$TrueVoiceImpl.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get url;
  @override
  String get imageUrl;

  /// Create a copy of TrueVoice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrueVoiceImplCopyWith<_$TrueVoiceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
