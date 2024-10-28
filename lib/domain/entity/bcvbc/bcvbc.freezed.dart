// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bcvbc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Bcvbc _$BcvbcFromJson(Map<String, dynamic> json) {
  return _Bcvbc.fromJson(json);
}

/// @nodoc
mixin _$Bcvbc {
  @JsonKey(name: 'b')
  String? get b => throw _privateConstructorUsedError;
  @JsonKey(name: 'c')
  String? get c => throw _privateConstructorUsedError;
  @JsonKey(name: 'v')
  String? get v => throw _privateConstructorUsedError;
  @JsonKey(name: 'bc')
  int? get bc => throw _privateConstructorUsedError;

  /// Serializes this Bcvbc to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BcvbcCopyWith<Bcvbc> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BcvbcCopyWith<$Res> {
  factory $BcvbcCopyWith(Bcvbc value, $Res Function(Bcvbc) then) =
      _$BcvbcCopyWithImpl<$Res, Bcvbc>;
  @useResult
  $Res call(
      {@JsonKey(name: 'b') String? b,
      @JsonKey(name: 'c') String? c,
      @JsonKey(name: 'v') String? v,
      @JsonKey(name: 'bc') int? bc});
}

/// @nodoc
class _$BcvbcCopyWithImpl<$Res, $Val extends Bcvbc>
    implements $BcvbcCopyWith<$Res> {
  _$BcvbcCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b = freezed,
    Object? c = freezed,
    Object? v = freezed,
    Object? bc = freezed,
  }) {
    return _then(_value.copyWith(
      b: freezed == b
          ? _value.b
          : b // ignore: cast_nullable_to_non_nullable
              as String?,
      c: freezed == c
          ? _value.c
          : c // ignore: cast_nullable_to_non_nullable
              as String?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as String?,
      bc: freezed == bc
          ? _value.bc
          : bc // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BcvbcImplCopyWith<$Res> implements $BcvbcCopyWith<$Res> {
  factory _$$BcvbcImplCopyWith(
          _$BcvbcImpl value, $Res Function(_$BcvbcImpl) then) =
      __$$BcvbcImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'b') String? b,
      @JsonKey(name: 'c') String? c,
      @JsonKey(name: 'v') String? v,
      @JsonKey(name: 'bc') int? bc});
}

/// @nodoc
class __$$BcvbcImplCopyWithImpl<$Res>
    extends _$BcvbcCopyWithImpl<$Res, _$BcvbcImpl>
    implements _$$BcvbcImplCopyWith<$Res> {
  __$$BcvbcImplCopyWithImpl(
      _$BcvbcImpl _value, $Res Function(_$BcvbcImpl) _then)
      : super(_value, _then);

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b = freezed,
    Object? c = freezed,
    Object? v = freezed,
    Object? bc = freezed,
  }) {
    return _then(_$BcvbcImpl(
      b: freezed == b
          ? _value.b
          : b // ignore: cast_nullable_to_non_nullable
              as String?,
      c: freezed == c
          ? _value.c
          : c // ignore: cast_nullable_to_non_nullable
              as String?,
      v: freezed == v
          ? _value.v
          : v // ignore: cast_nullable_to_non_nullable
              as String?,
      bc: freezed == bc
          ? _value.bc
          : bc // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BcvbcImpl extends _Bcvbc {
  const _$BcvbcImpl(
      {@JsonKey(name: 'b') this.b,
      @JsonKey(name: 'c') this.c,
      @JsonKey(name: 'v') this.v,
      @JsonKey(name: 'bc') this.bc})
      : super._();

  factory _$BcvbcImpl.fromJson(Map<String, dynamic> json) =>
      _$$BcvbcImplFromJson(json);

  @override
  @JsonKey(name: 'b')
  final String? b;
  @override
  @JsonKey(name: 'c')
  final String? c;
  @override
  @JsonKey(name: 'v')
  final String? v;
  @override
  @JsonKey(name: 'bc')
  final int? bc;

  @override
  String toString() {
    return 'Bcvbc(b: $b, c: $c, v: $v, bc: $bc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BcvbcImpl &&
            (identical(other.b, b) || other.b == b) &&
            (identical(other.c, c) || other.c == c) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.bc, bc) || other.bc == bc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, b, c, v, bc);

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BcvbcImplCopyWith<_$BcvbcImpl> get copyWith =>
      __$$BcvbcImplCopyWithImpl<_$BcvbcImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BcvbcImplToJson(
      this,
    );
  }
}

abstract class _Bcvbc extends Bcvbc {
  const factory _Bcvbc(
      {@JsonKey(name: 'b') final String? b,
      @JsonKey(name: 'c') final String? c,
      @JsonKey(name: 'v') final String? v,
      @JsonKey(name: 'bc') final int? bc}) = _$BcvbcImpl;
  const _Bcvbc._() : super._();

  factory _Bcvbc.fromJson(Map<String, dynamic> json) = _$BcvbcImpl.fromJson;

  @override
  @JsonKey(name: 'b')
  String? get b;
  @override
  @JsonKey(name: 'c')
  String? get c;
  @override
  @JsonKey(name: 'v')
  String? get v;
  @override
  @JsonKey(name: 'bc')
  int? get bc;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BcvbcImplCopyWith<_$BcvbcImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
