// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Verse _$VerseFromJson(Map<String, dynamic> json) {
  return _Verse.fromJson(json);
}

/// @nodoc
mixin _$Verse {
  @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
  int get bookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
  int get chapterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
  int get verseId => throw _privateConstructorUsedError;
  @JsonKey(name: 't')
  String? get verse => throw _privateConstructorUsedError;
  @JsonKey(name: 'r')
  int? get revisionId => throw _privateConstructorUsedError;
  @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
  String? get c1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
  String? get v1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color => throw _privateConstructorUsedError;

  /// Serializes this Verse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerseCopyWith<Verse> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerseCopyWith<$Res> {
  factory $VerseCopyWith(Verse value, $Res Function(Verse) then) =
      _$VerseCopyWithImpl<$Res, Verse>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
      int id,
      @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
      int bookId,
      @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
      int chapterId,
      @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
      int verseId,
      @JsonKey(name: 't') String? verse,
      @JsonKey(name: 'r') int? revisionId,
      @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
      String? c1,
      @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
      String? v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
      Color? color});
}

/// @nodoc
class _$VerseCopyWithImpl<$Res, $Val extends Verse>
    implements $VerseCopyWith<$Res> {
  _$VerseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
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
abstract class _$$VerseImplCopyWith<$Res> implements $VerseCopyWith<$Res> {
  factory _$$VerseImplCopyWith(
          _$VerseImpl value, $Res Function(_$VerseImpl) then) =
      __$$VerseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
      int id,
      @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
      int bookId,
      @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
      int chapterId,
      @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
      int verseId,
      @JsonKey(name: 't') String? verse,
      @JsonKey(name: 'r') int? revisionId,
      @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
      String? c1,
      @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
      String? v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
      Color? color});
}

/// @nodoc
class __$$VerseImplCopyWithImpl<$Res>
    extends _$VerseCopyWithImpl<$Res, _$VerseImpl>
    implements _$$VerseImplCopyWith<$Res> {
  __$$VerseImplCopyWithImpl(
      _$VerseImpl _value, $Res Function(_$VerseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
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
    return _then(_$VerseImpl(
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
class _$VerseImpl extends _Verse {
  const _$VerseImpl(
      {@JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
      required this.id,
      @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
      required this.bookId,
      @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
      required this.chapterId,
      @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
      required this.verseId,
      @JsonKey(name: 't') this.verse,
      @JsonKey(name: 'r') this.revisionId,
      @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
      this.c1,
      @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
      this.v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
      this.color})
      : super._();

  factory _$VerseImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerseImplFromJson(json);

  @override
  @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
  final int id;
  @override
  @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
  final int bookId;
  @override
  @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
  final int chapterId;
  @override
  @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
  final int verseId;
  @override
  @JsonKey(name: 't')
  final String? verse;
  @override
  @JsonKey(name: 'r')
  final int? revisionId;
  @override
  @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
  final String? c1;
  @override
  @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
  final String? v1;
  @override
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  final Color? color;

  @override
  String toString() {
    return 'Verse(id: $id, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, verse: $verse, revisionId: $revisionId, c1: $c1, v1: $v1, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerseImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, bookId, chapterId, verseId,
      verse, revisionId, c1, v1, color);

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerseImplCopyWith<_$VerseImpl> get copyWith =>
      __$$VerseImplCopyWithImpl<_$VerseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerseImplToJson(
      this,
    );
  }
}

abstract class _Verse extends Verse {
  const factory _Verse(
      {@JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
      required final int id,
      @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
      required final int bookId,
      @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
      required final int chapterId,
      @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
      required final int verseId,
      @JsonKey(name: 't') final String? verse,
      @JsonKey(name: 'r') final int? revisionId,
      @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
      final String? c1,
      @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
      final String? v1,
      @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
      final Color? color}) = _$VerseImpl;
  const _Verse._() : super._();

  factory _Verse.fromJson(Map<String, dynamic> json) = _$VerseImpl.fromJson;

  @override
  @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
  int get id;
  @override
  @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
  int get bookId;
  @override
  @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
  int get chapterId;
  @override
  @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
  int get verseId;
  @override
  @JsonKey(name: 't')
  String? get verse;
  @override
  @JsonKey(name: 'r')
  int? get revisionId;
  @override
  @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
  String? get c1;
  @override
  @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
  String? get v1;
  @override
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerseImplCopyWith<_$VerseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
