// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_bookmark.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BibleBookmark _$BibleBookmarkFromJson(Map<String, dynamic> json) {
  return _BibleBookmark.fromJson(json);
}

/// @nodoc
mixin _$BibleBookmark {
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_bookmark_all')
  bool get isBookmarkAll => throw _privateConstructorUsedError;
  @JsonKey(name: 'verse')
  Verse get verse => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BibleBookmarkCopyWith<BibleBookmark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BibleBookmarkCopyWith<$Res> {
  factory $BibleBookmarkCopyWith(
          BibleBookmark value, $Res Function(BibleBookmark) then) =
      _$BibleBookmarkCopyWithImpl<$Res, BibleBookmark>;
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'is_bookmark_all') bool isBookmarkAll,
      @JsonKey(name: 'verse') Verse verse});

  $VerseCopyWith<$Res> get verse;
}

/// @nodoc
class _$BibleBookmarkCopyWithImpl<$Res, $Val extends BibleBookmark>
    implements $BibleBookmarkCopyWith<$Res> {
  _$BibleBookmarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? isBookmarkAll = null,
    Object? verse = null,
  }) {
    return _then(_value.copyWith(
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isBookmarkAll: null == isBookmarkAll
          ? _value.isBookmarkAll
          : isBookmarkAll // ignore: cast_nullable_to_non_nullable
              as bool,
      verse: null == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as Verse,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res> get verse {
    return $VerseCopyWith<$Res>(_value.verse, (value) {
      return _then(_value.copyWith(verse: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_BibleBookmarkCopyWith<$Res>
    implements $BibleBookmarkCopyWith<$Res> {
  factory _$$_BibleBookmarkCopyWith(
          _$_BibleBookmark value, $Res Function(_$_BibleBookmark) then) =
      __$$_BibleBookmarkCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'is_bookmark_all') bool isBookmarkAll,
      @JsonKey(name: 'verse') Verse verse});

  @override
  $VerseCopyWith<$Res> get verse;
}

/// @nodoc
class __$$_BibleBookmarkCopyWithImpl<$Res>
    extends _$BibleBookmarkCopyWithImpl<$Res, _$_BibleBookmark>
    implements _$$_BibleBookmarkCopyWith<$Res> {
  __$$_BibleBookmarkCopyWithImpl(
      _$_BibleBookmark _value, $Res Function(_$_BibleBookmark) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? isBookmarkAll = null,
    Object? verse = null,
  }) {
    return _then(_$_BibleBookmark(
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isBookmarkAll: null == isBookmarkAll
          ? _value.isBookmarkAll
          : isBookmarkAll // ignore: cast_nullable_to_non_nullable
              as bool,
      verse: null == verse
          ? _value.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as Verse,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BibleBookmark extends _BibleBookmark {
  const _$_BibleBookmark(
      {@JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'is_bookmark_all') required this.isBookmarkAll,
      @JsonKey(name: 'verse') required this.verse})
      : super._();

  factory _$_BibleBookmark.fromJson(Map<String, dynamic> json) =>
      _$$_BibleBookmarkFromJson(json);

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'is_bookmark_all')
  final bool isBookmarkAll;
  @override
  @JsonKey(name: 'verse')
  final Verse verse;

  @override
  String toString() {
    return 'BibleBookmark(createdAt: $createdAt, isBookmarkAll: $isBookmarkAll, verse: $verse)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BibleBookmark &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isBookmarkAll, isBookmarkAll) ||
                other.isBookmarkAll == isBookmarkAll) &&
            (identical(other.verse, verse) || other.verse == verse));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, createdAt, isBookmarkAll, verse);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BibleBookmarkCopyWith<_$_BibleBookmark> get copyWith =>
      __$$_BibleBookmarkCopyWithImpl<_$_BibleBookmark>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BibleBookmarkToJson(
      this,
    );
  }
}

abstract class _BibleBookmark extends BibleBookmark {
  const factory _BibleBookmark(
      {@JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'is_bookmark_all') required final bool isBookmarkAll,
      @JsonKey(name: 'verse') required final Verse verse}) = _$_BibleBookmark;
  const _BibleBookmark._() : super._();

  factory _BibleBookmark.fromJson(Map<String, dynamic> json) =
      _$_BibleBookmark.fromJson;

  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'is_bookmark_all')
  bool get isBookmarkAll;
  @override
  @JsonKey(name: 'verse')
  Verse get verse;
  @override
  @JsonKey(ignore: true)
  _$$_BibleBookmarkCopyWith<_$_BibleBookmark> get copyWith =>
      throw _privateConstructorUsedError;
}
