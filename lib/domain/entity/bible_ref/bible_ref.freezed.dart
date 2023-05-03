// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BibleRef _$BibleRefFromJson(Map<String, dynamic> json) {
  return _BibleRef.fromJson(json);
}

/// @nodoc
mixin _$BibleRef {
  @JsonKey(name: 'id')
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'sv')
  int? get sv => throw _privateConstructorUsedError;
  @JsonKey(name: 'ev')
  int? get ev => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BibleRefCopyWith<BibleRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleRefCopyWith<$Res> {
  factory $BibleRefCopyWith(BibleRef value, $Res Function(BibleRef) then) =
      _$BibleRefCopyWithImpl<$Res, BibleRef>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'sv') int? sv,
      @JsonKey(name: 'ev') int? ev});
}

/// @nodoc
class _$BibleRefCopyWithImpl<$Res, $Val extends BibleRef>
    implements $BibleRefCopyWith<$Res> {
  _$BibleRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sv = freezed,
    Object? ev = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      sv: freezed == sv
          ? _value.sv
          : sv // ignore: cast_nullable_to_non_nullable
              as int?,
      ev: freezed == ev
          ? _value.ev
          : ev // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BibleRefCopyWith<$Res> implements $BibleRefCopyWith<$Res> {
  factory _$$_BibleRefCopyWith(
          _$_BibleRef value, $Res Function(_$_BibleRef) then) =
      __$$_BibleRefCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'sv') int? sv,
      @JsonKey(name: 'ev') int? ev});
}

/// @nodoc
class __$$_BibleRefCopyWithImpl<$Res>
    extends _$BibleRefCopyWithImpl<$Res, _$_BibleRef>
    implements _$$_BibleRefCopyWith<$Res> {
  __$$_BibleRefCopyWithImpl(
      _$_BibleRef _value, $Res Function(_$_BibleRef) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sv = freezed,
    Object? ev = freezed,
  }) {
    return _then(_$_BibleRef(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      sv: freezed == sv
          ? _value.sv
          : sv // ignore: cast_nullable_to_non_nullable
              as int?,
      ev: freezed == ev
          ? _value.ev
          : ev // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BibleRef extends _BibleRef {
  const _$_BibleRef(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'sv') this.sv,
      @JsonKey(name: 'ev') this.ev})
      : super._();

  factory _$_BibleRef.fromJson(Map<String, dynamic> json) =>
      _$$_BibleRefFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'sv')
  final int? sv;
  @override
  @JsonKey(name: 'ev')
  final int? ev;

  @override
  String toString() {
    return 'BibleRef(id: $id, sv: $sv, ev: $ev)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BibleRef &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sv, sv) || other.sv == sv) &&
            (identical(other.ev, ev) || other.ev == ev));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, sv, ev);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BibleRefCopyWith<_$_BibleRef> get copyWith =>
      __$$_BibleRefCopyWithImpl<_$_BibleRef>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BibleRefToJson(
      this,
    );
  }
}

abstract class _BibleRef extends BibleRef {
  const factory _BibleRef(
      {@JsonKey(name: 'id') final int? id,
      @JsonKey(name: 'sv') final int? sv,
      @JsonKey(name: 'ev') final int? ev}) = _$_BibleRef;
  const _BibleRef._() : super._();

  factory _BibleRef.fromJson(Map<String, dynamic> json) = _$_BibleRef.fromJson;

  @override
  @JsonKey(name: 'id')
  int? get id;
  @override
  @JsonKey(name: 'sv')
  int? get sv;
  @override
  @JsonKey(name: 'ev')
  int? get ev;
  @override
  @JsonKey(ignore: true)
  _$$_BibleRefCopyWith<_$_BibleRef> get copyWith =>
      throw _privateConstructorUsedError;
}
