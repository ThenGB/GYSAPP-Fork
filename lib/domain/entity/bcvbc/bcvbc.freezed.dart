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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

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

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
abstract class _$$_BcvbcCopyWith<$Res> implements $BcvbcCopyWith<$Res> {
  factory _$$_BcvbcCopyWith(_$_Bcvbc value, $Res Function(_$_Bcvbc) then) =
      __$$_BcvbcCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'b') String? b,
      @JsonKey(name: 'c') String? c,
      @JsonKey(name: 'v') String? v,
      @JsonKey(name: 'bc') int? bc});
}

/// @nodoc
class __$$_BcvbcCopyWithImpl<$Res> extends _$BcvbcCopyWithImpl<$Res, _$_Bcvbc>
    implements _$$_BcvbcCopyWith<$Res> {
  __$$_BcvbcCopyWithImpl(_$_Bcvbc _value, $Res Function(_$_Bcvbc) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b = freezed,
    Object? c = freezed,
    Object? v = freezed,
    Object? bc = freezed,
  }) {
    return _then(_$_Bcvbc(
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
class _$_Bcvbc extends _Bcvbc {
  const _$_Bcvbc(
      {@JsonKey(name: 'b') this.b,
      @JsonKey(name: 'c') this.c,
      @JsonKey(name: 'v') this.v,
      @JsonKey(name: 'bc') this.bc})
      : super._();

  factory _$_Bcvbc.fromJson(Map<String, dynamic> json) =>
      _$$_BcvbcFromJson(json);

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
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Bcvbc &&
            (identical(other.b, b) || other.b == b) &&
            (identical(other.c, c) || other.c == c) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.bc, bc) || other.bc == bc));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, b, c, v, bc);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BcvbcCopyWith<_$_Bcvbc> get copyWith =>
      __$$_BcvbcCopyWithImpl<_$_Bcvbc>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BcvbcToJson(
      this,
    );
  }
}

abstract class _Bcvbc extends Bcvbc {
  const factory _Bcvbc(
      {@JsonKey(name: 'b') final String? b,
      @JsonKey(name: 'c') final String? c,
      @JsonKey(name: 'v') final String? v,
      @JsonKey(name: 'bc') final int? bc}) = _$_Bcvbc;
  const _Bcvbc._() : super._();

  factory _Bcvbc.fromJson(Map<String, dynamic> json) = _$_Bcvbc.fromJson;

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
  @override
  @JsonKey(ignore: true)
  _$$_BcvbcCopyWith<_$_Bcvbc> get copyWith =>
      throw _privateConstructorUsedError;
}
