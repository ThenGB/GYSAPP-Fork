// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BibleBook _$BibleBookFromJson(Map<String, dynamic> json) {
  return _BibleBook.fromJson(json);
}

/// @nodoc
mixin _$BibleBook {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'bs')
  String? get shortName => throw _privateConstructorUsedError;
  @JsonKey(name: 'bl')
  String? get longName => throw _privateConstructorUsedError;
  @JsonKey(name: 'c')
  int? get chapterCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BibleBookCopyWith<BibleBook> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleBookCopyWith<$Res> {
  factory $BibleBookCopyWith(BibleBook value, $Res Function(BibleBook) then) =
      _$BibleBookCopyWithImpl<$Res, BibleBook>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'bs') String? shortName,
      @JsonKey(name: 'bl') String? longName,
      @JsonKey(name: 'c') int? chapterCount});
}

/// @nodoc
class _$BibleBookCopyWithImpl<$Res, $Val extends BibleBook>
    implements $BibleBookCopyWith<$Res> {
  _$BibleBookCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shortName = freezed,
    Object? longName = freezed,
    Object? chapterCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      longName: freezed == longName
          ? _value.longName
          : longName // ignore: cast_nullable_to_non_nullable
              as String?,
      chapterCount: freezed == chapterCount
          ? _value.chapterCount
          : chapterCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BibleBookImplCopyWith<$Res>
    implements $BibleBookCopyWith<$Res> {
  factory _$$BibleBookImplCopyWith(
          _$BibleBookImpl value, $Res Function(_$BibleBookImpl) then) =
      __$$BibleBookImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'bs') String? shortName,
      @JsonKey(name: 'bl') String? longName,
      @JsonKey(name: 'c') int? chapterCount});
}

/// @nodoc
class __$$BibleBookImplCopyWithImpl<$Res>
    extends _$BibleBookCopyWithImpl<$Res, _$BibleBookImpl>
    implements _$$BibleBookImplCopyWith<$Res> {
  __$$BibleBookImplCopyWithImpl(
      _$BibleBookImpl _value, $Res Function(_$BibleBookImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? shortName = freezed,
    Object? longName = freezed,
    Object? chapterCount = freezed,
  }) {
    return _then(_$BibleBookImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      longName: freezed == longName
          ? _value.longName
          : longName // ignore: cast_nullable_to_non_nullable
              as String?,
      chapterCount: freezed == chapterCount
          ? _value.chapterCount
          : chapterCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BibleBookImpl extends _BibleBook {
  const _$BibleBookImpl(
      {required this.id,
      @JsonKey(name: 'bs') this.shortName,
      @JsonKey(name: 'bl') this.longName,
      @JsonKey(name: 'c') this.chapterCount})
      : super._();

  factory _$BibleBookImpl.fromJson(Map<String, dynamic> json) =>
      _$$BibleBookImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'bs')
  final String? shortName;
  @override
  @JsonKey(name: 'bl')
  final String? longName;
  @override
  @JsonKey(name: 'c')
  final int? chapterCount;

  @override
  String toString() {
    return 'BibleBook(id: $id, shortName: $shortName, longName: $longName, chapterCount: $chapterCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BibleBookImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.longName, longName) ||
                other.longName == longName) &&
            (identical(other.chapterCount, chapterCount) ||
                other.chapterCount == chapterCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, shortName, longName, chapterCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BibleBookImplCopyWith<_$BibleBookImpl> get copyWith =>
      __$$BibleBookImplCopyWithImpl<_$BibleBookImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BibleBookImplToJson(
      this,
    );
  }
}

abstract class _BibleBook extends BibleBook {
  const factory _BibleBook(
      {required final int id,
      @JsonKey(name: 'bs') final String? shortName,
      @JsonKey(name: 'bl') final String? longName,
      @JsonKey(name: 'c') final int? chapterCount}) = _$BibleBookImpl;
  const _BibleBook._() : super._();

  factory _BibleBook.fromJson(Map<String, dynamic> json) =
      _$BibleBookImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'bs')
  String? get shortName;
  @override
  @JsonKey(name: 'bl')
  String? get longName;
  @override
  @JsonKey(name: 'c')
  int? get chapterCount;
  @override
  @JsonKey(ignore: true)
  _$$BibleBookImplCopyWith<_$BibleBookImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
