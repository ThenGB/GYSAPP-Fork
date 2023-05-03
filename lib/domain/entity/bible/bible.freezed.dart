// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Bible _$BibleFromJson(Map<String, dynamic> json) {
  return _Bible.fromJson(json);
}

/// @nodoc
mixin _$Bible {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'b')
  int get bookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'c')
  int get chapterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'v')
  int get verseId => throw _privateConstructorUsedError;
  @JsonKey(name: 't')
  String? get verse => throw _privateConstructorUsedError;
  @JsonKey(name: 'r')
  int? get revisionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'c1')
  String? get c1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'v1')
  String? get v1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BibleCopyWith<Bible> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleCopyWith<$Res> {
  factory $BibleCopyWith(Bible value, $Res Function(Bible) then) =
      _$BibleCopyWithImpl<$Res, Bible>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id')
          int id,
      @JsonKey(name: 'b')
          int bookId,
      @JsonKey(name: 'c')
          int chapterId,
      @JsonKey(name: 'v')
          int verseId,
      @JsonKey(name: 't')
          String? verse,
      @JsonKey(name: 'r')
          int? revisionId,
      @JsonKey(name: 'c1')
          String? c1,
      @JsonKey(name: 'v1')
          String? v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
          Color? color});
}

/// @nodoc
class _$BibleCopyWithImpl<$Res, $Val extends Bible>
    implements $BibleCopyWith<$Res> {
  _$BibleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? chapterId = null,
    Object? verseId = null,
    Object? verse = freezed,
    Object? revisionId = freezed,
    Object? c1 = freezed,
    Object? v1 = freezed,
    Object? color = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterId: null == chapterId
          ? _value.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      verseId: null == verseId
          ? _value.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int,
      verse: freezed == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as String?,
      revisionId: freezed == revisionId
          ? _value.revisionId
          : revisionId // ignore: cast_nullable_to_non_nullable
              as int?,
      c1: freezed == c1
          ? _value.c1
          : c1 // ignore: cast_nullable_to_non_nullable
              as String?,
      v1: freezed == v1
          ? _value.v1
          : v1 // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_BibleCopyWith<$Res> implements $BibleCopyWith<$Res> {
  factory _$$_BibleCopyWith(_$_Bible value, $Res Function(_$_Bible) then) =
      __$$_BibleCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id')
          int id,
      @JsonKey(name: 'b')
          int bookId,
      @JsonKey(name: 'c')
          int chapterId,
      @JsonKey(name: 'v')
          int verseId,
      @JsonKey(name: 't')
          String? verse,
      @JsonKey(name: 'r')
          int? revisionId,
      @JsonKey(name: 'c1')
          String? c1,
      @JsonKey(name: 'v1')
          String? v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
          Color? color});
}

/// @nodoc
class __$$_BibleCopyWithImpl<$Res> extends _$BibleCopyWithImpl<$Res, _$_Bible>
    implements _$$_BibleCopyWith<$Res> {
  __$$_BibleCopyWithImpl(_$_Bible _value, $Res Function(_$_Bible) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? chapterId = null,
    Object? verseId = null,
    Object? verse = freezed,
    Object? revisionId = freezed,
    Object? c1 = freezed,
    Object? v1 = freezed,
    Object? color = freezed,
  }) {
    return _then(_$_Bible(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterId: null == chapterId
          ? _value.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      verseId: null == verseId
          ? _value.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int,
      verse: freezed == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as String?,
      revisionId: freezed == revisionId
          ? _value.revisionId
          : revisionId // ignore: cast_nullable_to_non_nullable
              as int?,
      c1: freezed == c1
          ? _value.c1
          : c1 // ignore: cast_nullable_to_non_nullable
              as String?,
      v1: freezed == v1
          ? _value.v1
          : v1 // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Bible extends _Bible {
  const _$_Bible(
      {@JsonKey(name: 'id')
          required this.id,
      @JsonKey(name: 'b')
          required this.bookId,
      @JsonKey(name: 'c')
          required this.chapterId,
      @JsonKey(name: 'v')
          required this.verseId,
      @JsonKey(name: 't')
          this.verse,
      @JsonKey(name: 'r')
          this.revisionId,
      @JsonKey(name: 'c1')
          this.c1,
      @JsonKey(name: 'v1')
          this.v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
          this.color})
      : super._();

  factory _$_Bible.fromJson(Map<String, dynamic> json) =>
      _$$_BibleFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'b')
  final int bookId;
  @override
  @JsonKey(name: 'c')
  final int chapterId;
  @override
  @JsonKey(name: 'v')
  final int verseId;
  @override
  @JsonKey(name: 't')
  final String? verse;
  @override
  @JsonKey(name: 'r')
  final int? revisionId;
  @override
  @JsonKey(name: 'c1')
  final String? c1;
  @override
  @JsonKey(name: 'v1')
  final String? v1;
  @override
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  final Color? color;

  @override
  String toString() {
    return 'Bible(id: $id, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, verse: $verse, revisionId: $revisionId, c1: $c1, v1: $v1, color: $color)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Bible &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.verseId, verseId) || other.verseId == verseId) &&
            (identical(other.verse, verse) || other.verse == verse) &&
            (identical(other.revisionId, revisionId) ||
                other.revisionId == revisionId) &&
            (identical(other.c1, c1) || other.c1 == c1) &&
            (identical(other.v1, v1) || other.v1 == v1) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, bookId, chapterId, verseId,
      verse, revisionId, c1, v1, color);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BibleCopyWith<_$_Bible> get copyWith =>
      __$$_BibleCopyWithImpl<_$_Bible>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BibleToJson(
      this,
    );
  }
}

abstract class _Bible extends Bible {
  const factory _Bible(
      {@JsonKey(name: 'id')
          required final int id,
      @JsonKey(name: 'b')
          required final int bookId,
      @JsonKey(name: 'c')
          required final int chapterId,
      @JsonKey(name: 'v')
          required final int verseId,
      @JsonKey(name: 't')
          final String? verse,
      @JsonKey(name: 'r')
          final int? revisionId,
      @JsonKey(name: 'c1')
          final String? c1,
      @JsonKey(name: 'v1')
          final String? v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
          final Color? color}) = _$_Bible;
  const _Bible._() : super._();

  factory _Bible.fromJson(Map<String, dynamic> json) = _$_Bible.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'b')
  int get bookId;
  @override
  @JsonKey(name: 'c')
  int get chapterId;
  @override
  @JsonKey(name: 'v')
  int get verseId;
  @override
  @JsonKey(name: 't')
  String? get verse;
  @override
  @JsonKey(name: 'r')
  int? get revisionId;
  @override
  @JsonKey(name: 'c1')
  String? get c1;
  @override
  @JsonKey(name: 'v1')
  String? get v1;
  @override
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color;
  @override
  @JsonKey(ignore: true)
  _$$_BibleCopyWith<_$_Bible> get copyWith =>
      throw _privateConstructorUsedError;
}
