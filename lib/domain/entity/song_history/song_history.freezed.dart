// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SongHistory _$SongHistoryFromJson(Map<String, dynamic> json) {
  return _SongHistory.fromJson(json);
}

/// @nodoc
mixin _$SongHistory {
  int get index => throw _privateConstructorUsedError;
  String get bookCode => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SongHistoryCopyWith<SongHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SongHistoryCopyWith<$Res> {
  factory $SongHistoryCopyWith(
          SongHistory value, $Res Function(SongHistory) then) =
      _$SongHistoryCopyWithImpl<$Res, SongHistory>;
  @useResult
  $Res call({int index, String bookCode, DateTime createdAt});
}

/// @nodoc
class _$SongHistoryCopyWithImpl<$Res, $Val extends SongHistory>
    implements $SongHistoryCopyWith<$Res> {
  _$SongHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? bookCode = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      bookCode: null == bookCode
          ? _value.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_SongHistoryCopyWith<$Res>
    implements $SongHistoryCopyWith<$Res> {
  factory _$$_SongHistoryCopyWith(
          _$_SongHistory value, $Res Function(_$_SongHistory) then) =
      __$$_SongHistoryCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int index, String bookCode, DateTime createdAt});
}

/// @nodoc
class __$$_SongHistoryCopyWithImpl<$Res>
    extends _$SongHistoryCopyWithImpl<$Res, _$_SongHistory>
    implements _$$_SongHistoryCopyWith<$Res> {
  __$$_SongHistoryCopyWithImpl(
      _$_SongHistory _value, $Res Function(_$_SongHistory) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? bookCode = null,
    Object? createdAt = null,
  }) {
    return _then(_$_SongHistory(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      bookCode: null == bookCode
          ? _value.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_SongHistory extends _SongHistory {
  const _$_SongHistory(
      {required this.index, required this.bookCode, required this.createdAt})
      : super._();

  factory _$_SongHistory.fromJson(Map<String, dynamic> json) =>
      _$$_SongHistoryFromJson(json);

  @override
  final int index;
  @override
  final String bookCode;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SongHistory(index: $index, bookCode: $bookCode, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_SongHistory &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.bookCode, bookCode) ||
                other.bookCode == bookCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, index, bookCode, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_SongHistoryCopyWith<_$_SongHistory> get copyWith =>
      __$$_SongHistoryCopyWithImpl<_$_SongHistory>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_SongHistoryToJson(
      this,
    );
  }
}

abstract class _SongHistory extends SongHistory {
  const factory _SongHistory(
      {required final int index,
      required final String bookCode,
      required final DateTime createdAt}) = _$_SongHistory;
  const _SongHistory._() : super._();

  factory _SongHistory.fromJson(Map<String, dynamic> json) =
      _$_SongHistory.fromJson;

  @override
  int get index;
  @override
  String get bookCode;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$_SongHistoryCopyWith<_$_SongHistory> get copyWith =>
      throw _privateConstructorUsedError;
}
