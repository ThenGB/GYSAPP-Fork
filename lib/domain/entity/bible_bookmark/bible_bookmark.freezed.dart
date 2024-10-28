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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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

  /// Serializes this BibleBookmark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
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

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res> get verse {
    return $VerseCopyWith<$Res>(_value.verse, (value) {
      return _then(_value.copyWith(verse: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BibleBookmarkImplCopyWith<$Res>
    implements $BibleBookmarkCopyWith<$Res> {
  factory _$$BibleBookmarkImplCopyWith(
          _$BibleBookmarkImpl value, $Res Function(_$BibleBookmarkImpl) then) =
      __$$BibleBookmarkImplCopyWithImpl<$Res>;
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
class __$$BibleBookmarkImplCopyWithImpl<$Res>
    extends _$BibleBookmarkCopyWithImpl<$Res, _$BibleBookmarkImpl>
    implements _$$BibleBookmarkImplCopyWith<$Res> {
  __$$BibleBookmarkImplCopyWithImpl(
      _$BibleBookmarkImpl _value, $Res Function(_$BibleBookmarkImpl) _then)
      : super(_value, _then);

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? isBookmarkAll = null,
    Object? verse = null,
  }) {
    return _then(_$BibleBookmarkImpl(
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
class _$BibleBookmarkImpl extends _BibleBookmark {
  const _$BibleBookmarkImpl(
      {@JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'is_bookmark_all') required this.isBookmarkAll,
      @JsonKey(name: 'verse') required this.verse})
      : super._();

  factory _$BibleBookmarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$BibleBookmarkImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BibleBookmarkImpl &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isBookmarkAll, isBookmarkAll) ||
                other.isBookmarkAll == isBookmarkAll) &&
            (identical(other.verse, verse) || other.verse == verse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, createdAt, isBookmarkAll, verse);

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BibleBookmarkImplCopyWith<_$BibleBookmarkImpl> get copyWith =>
      __$$BibleBookmarkImplCopyWithImpl<_$BibleBookmarkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BibleBookmarkImplToJson(
      this,
    );
  }
}

abstract class _BibleBookmark extends BibleBookmark {
  const factory _BibleBookmark(
          {@JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'is_bookmark_all') required final bool isBookmarkAll,
          @JsonKey(name: 'verse') required final Verse verse}) =
      _$BibleBookmarkImpl;
  const _BibleBookmark._() : super._();

  factory _BibleBookmark.fromJson(Map<String, dynamic> json) =
      _$BibleBookmarkImpl.fromJson;

  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'is_bookmark_all')
  bool get isBookmarkAll;
  @override
  @JsonKey(name: 'verse')
  Verse get verse;

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BibleBookmarkImplCopyWith<_$BibleBookmarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
