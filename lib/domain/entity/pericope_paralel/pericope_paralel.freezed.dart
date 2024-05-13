// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pericope_paralel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PericopeParalel _$PericopeParalelFromJson(Map<String, dynamic> json) {
  return _PericopeParalel.fromJson(json);
}

/// @nodoc
mixin _$PericopeParalel {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'id1')
  int? get id1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'id2')
  int? get id2 => throw _privateConstructorUsedError;
  @JsonKey(name: 't')
  String? get t => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PericopeParalelCopyWith<PericopeParalel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PericopeParalelCopyWith<$Res> {
  factory $PericopeParalelCopyWith(
          PericopeParalel value, $Res Function(PericopeParalel) then) =
      _$PericopeParalelCopyWithImpl<$Res, PericopeParalel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'id1') int? id1,
      @JsonKey(name: 'id2') int? id2,
      @JsonKey(name: 't') String? t});
}

/// @nodoc
class _$PericopeParalelCopyWithImpl<$Res, $Val extends PericopeParalel>
    implements $PericopeParalelCopyWith<$Res> {
  _$PericopeParalelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? id1 = freezed,
    Object? id2 = freezed,
    Object? t = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      id1: freezed == id1
          ? _value.id1
          : id1 // ignore: cast_nullable_to_non_nullable
              as int?,
      id2: freezed == id2
          ? _value.id2
          : id2 // ignore: cast_nullable_to_non_nullable
              as int?,
      t: freezed == t
          ? _value.t
          : t // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PericopeParalelImplCopyWith<$Res>
    implements $PericopeParalelCopyWith<$Res> {
  factory _$$PericopeParalelImplCopyWith(_$PericopeParalelImpl value,
          $Res Function(_$PericopeParalelImpl) then) =
      __$$PericopeParalelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'id1') int? id1,
      @JsonKey(name: 'id2') int? id2,
      @JsonKey(name: 't') String? t});
}

/// @nodoc
class __$$PericopeParalelImplCopyWithImpl<$Res>
    extends _$PericopeParalelCopyWithImpl<$Res, _$PericopeParalelImpl>
    implements _$$PericopeParalelImplCopyWith<$Res> {
  __$$PericopeParalelImplCopyWithImpl(
      _$PericopeParalelImpl _value, $Res Function(_$PericopeParalelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? id1 = freezed,
    Object? id2 = freezed,
    Object? t = freezed,
  }) {
    return _then(_$PericopeParalelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      id1: freezed == id1
          ? _value.id1
          : id1 // ignore: cast_nullable_to_non_nullable
              as int?,
      id2: freezed == id2
          ? _value.id2
          : id2 // ignore: cast_nullable_to_non_nullable
              as int?,
      t: freezed == t
          ? _value.t
          : t // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PericopeParalelImpl extends _PericopeParalel {
  const _$PericopeParalelImpl(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'id1') this.id1,
      @JsonKey(name: 'id2') this.id2,
      @JsonKey(name: 't') this.t})
      : super._();

  factory _$PericopeParalelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PericopeParalelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'id1')
  final int? id1;
  @override
  @JsonKey(name: 'id2')
  final int? id2;
  @override
  @JsonKey(name: 't')
  final String? t;

  @override
  String toString() {
    return 'PericopeParalel(id: $id, id1: $id1, id2: $id2, t: $t)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PericopeParalelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.id1, id1) || other.id1 == id1) &&
            (identical(other.id2, id2) || other.id2 == id2) &&
            (identical(other.t, t) || other.t == t));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, id1, id2, t);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PericopeParalelImplCopyWith<_$PericopeParalelImpl> get copyWith =>
      __$$PericopeParalelImplCopyWithImpl<_$PericopeParalelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PericopeParalelImplToJson(
      this,
    );
  }
}

abstract class _PericopeParalel extends PericopeParalel {
  const factory _PericopeParalel(
      {@JsonKey(name: 'id') final int? id,
      @JsonKey(name: 'id1') final int? id1,
      @JsonKey(name: 'id2') final int? id2,
      @JsonKey(name: 't') final String? t}) = _$PericopeParalelImpl;
  const _PericopeParalel._() : super._();

  factory _PericopeParalel.fromJson(Map<String, dynamic> json) =
      _$PericopeParalelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'id1')
  int? get id1;
  @override
  @JsonKey(name: 'id2')
  int? get id2;
  @override
  @JsonKey(name: 't')
  String? get t;
  @override
  @JsonKey(ignore: true)
  _$$PericopeParalelImplCopyWith<_$PericopeParalelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
