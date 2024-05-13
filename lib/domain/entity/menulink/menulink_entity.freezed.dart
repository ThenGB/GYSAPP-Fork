// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'menulink_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Menulink _$MenulinkFromJson(Map<String, dynamic> json) {
  return _Menulink.fromJson(json);
}

/// @nodoc
mixin _$Menulink {
  String get label => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  bool get enabled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MenulinkCopyWith<Menulink> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MenulinkCopyWith<$Res> {
  factory $MenulinkCopyWith(Menulink value, $Res Function(Menulink) then) =
      _$MenulinkCopyWithImpl<$Res, Menulink>;
  @useResult
  $Res call({String label, String icon, String url, bool enabled});
}

/// @nodoc
class _$MenulinkCopyWithImpl<$Res, $Val extends Menulink>
    implements $MenulinkCopyWith<$Res> {
  _$MenulinkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? icon = null,
    Object? url = null,
    Object? enabled = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MenulinkImplCopyWith<$Res>
    implements $MenulinkCopyWith<$Res> {
  factory _$$MenulinkImplCopyWith(
          _$MenulinkImpl value, $Res Function(_$MenulinkImpl) then) =
      __$$MenulinkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String icon, String url, bool enabled});
}

/// @nodoc
class __$$MenulinkImplCopyWithImpl<$Res>
    extends _$MenulinkCopyWithImpl<$Res, _$MenulinkImpl>
    implements _$$MenulinkImplCopyWith<$Res> {
  __$$MenulinkImplCopyWithImpl(
      _$MenulinkImpl _value, $Res Function(_$MenulinkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? icon = null,
    Object? url = null,
    Object? enabled = null,
  }) {
    return _then(_$MenulinkImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      enabled: null == enabled
          ? _value.enabled
          : enabled // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MenulinkImpl extends _Menulink {
  const _$MenulinkImpl(
      {required this.label,
      required this.icon,
      required this.url,
      required this.enabled})
      : super._();

  factory _$MenulinkImpl.fromJson(Map<String, dynamic> json) =>
      _$$MenulinkImplFromJson(json);

  @override
  final String label;
  @override
  final String icon;
  @override
  final String url;
  @override
  final bool enabled;

  @override
  String toString() {
    return 'Menulink(label: $label, icon: $icon, url: $url, enabled: $enabled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MenulinkImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.enabled, enabled) || other.enabled == enabled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, label, icon, url, enabled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MenulinkImplCopyWith<_$MenulinkImpl> get copyWith =>
      __$$MenulinkImplCopyWithImpl<_$MenulinkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MenulinkImplToJson(
      this,
    );
  }
}

abstract class _Menulink extends Menulink {
  const factory _Menulink(
      {required final String label,
      required final String icon,
      required final String url,
      required final bool enabled}) = _$MenulinkImpl;
  const _Menulink._() : super._();

  factory _Menulink.fromJson(Map<String, dynamic> json) =
      _$MenulinkImpl.fromJson;

  @override
  String get label;
  @override
  String get icon;
  @override
  String get url;
  @override
  bool get enabled;
  @override
  @JsonKey(ignore: true)
  _$$MenulinkImplCopyWith<_$MenulinkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
