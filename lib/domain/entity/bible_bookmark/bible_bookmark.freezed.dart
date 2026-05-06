// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_bookmark.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BibleBookmark {
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @JsonKey(name: 'is_bookmark_all')
  bool get isBookmarkAll;
  @JsonKey(name: 'verse')
  Verse get verse;

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BibleBookmarkCopyWith<BibleBookmark> get copyWith =>
      _$BibleBookmarkCopyWithImpl<BibleBookmark>(
          this as BibleBookmark, _$identity);

  /// Serializes this BibleBookmark to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BibleBookmark &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isBookmarkAll, isBookmarkAll) ||
                other.isBookmarkAll == isBookmarkAll) &&
            (identical(other.verse, verse) || other.verse == verse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, createdAt, isBookmarkAll, verse);

  @override
  String toString() {
    return 'BibleBookmark(createdAt: $createdAt, isBookmarkAll: $isBookmarkAll, verse: $verse)';
  }
}

/// @nodoc
abstract mixin class $BibleBookmarkCopyWith<$Res> {
  factory $BibleBookmarkCopyWith(
          BibleBookmark value, $Res Function(BibleBookmark) _then) =
      _$BibleBookmarkCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'is_bookmark_all') bool isBookmarkAll,
      @JsonKey(name: 'verse') Verse verse});

  $VerseCopyWith<$Res> get verse;
}

/// @nodoc
class _$BibleBookmarkCopyWithImpl<$Res>
    implements $BibleBookmarkCopyWith<$Res> {
  _$BibleBookmarkCopyWithImpl(this._self, this._then);

  final BibleBookmark _self;
  final $Res Function(BibleBookmark) _then;

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? createdAt = null,
    Object? isBookmarkAll = null,
    Object? verse = null,
  }) {
    return _then(_self.copyWith(
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isBookmarkAll: null == isBookmarkAll
          ? _self.isBookmarkAll
          : isBookmarkAll // ignore: cast_nullable_to_non_nullable
              as bool,
      verse: null == verse
          ? _self.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as Verse,
    ));
  }

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res> get verse {
    return $VerseCopyWith<$Res>(_self.verse, (value) {
      return _then(_self.copyWith(verse: value));
    });
  }
}

/// Adds pattern-matching-related methods to [BibleBookmark].
extension BibleBookmarkPatterns on BibleBookmark {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BibleBookmark value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BibleBookmark() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BibleBookmark value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleBookmark():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BibleBookmark value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleBookmark() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'is_bookmark_all') bool isBookmarkAll,
            @JsonKey(name: 'verse') Verse verse)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BibleBookmark() when $default != null:
        return $default(_that.createdAt, _that.isBookmarkAll, _that.verse);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'is_bookmark_all') bool isBookmarkAll,
            @JsonKey(name: 'verse') Verse verse)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleBookmark():
        return $default(_that.createdAt, _that.isBookmarkAll, _that.verse);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(name: 'created_at') DateTime createdAt,
            @JsonKey(name: 'is_bookmark_all') bool isBookmarkAll,
            @JsonKey(name: 'verse') Verse verse)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleBookmark() when $default != null:
        return $default(_that.createdAt, _that.isBookmarkAll, _that.verse);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BibleBookmark extends BibleBookmark {
  const _BibleBookmark(
      {@JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'is_bookmark_all') required this.isBookmarkAll,
      @JsonKey(name: 'verse') required this.verse})
      : super._();
  factory _BibleBookmark.fromJson(Map<String, dynamic> json) =>
      _$BibleBookmarkFromJson(json);

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'is_bookmark_all')
  final bool isBookmarkAll;
  @override
  @JsonKey(name: 'verse')
  final Verse verse;

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BibleBookmarkCopyWith<_BibleBookmark> get copyWith =>
      __$BibleBookmarkCopyWithImpl<_BibleBookmark>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BibleBookmarkToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BibleBookmark &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isBookmarkAll, isBookmarkAll) ||
                other.isBookmarkAll == isBookmarkAll) &&
            (identical(other.verse, verse) || other.verse == verse));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, createdAt, isBookmarkAll, verse);

  @override
  String toString() {
    return 'BibleBookmark(createdAt: $createdAt, isBookmarkAll: $isBookmarkAll, verse: $verse)';
  }
}

/// @nodoc
abstract mixin class _$BibleBookmarkCopyWith<$Res>
    implements $BibleBookmarkCopyWith<$Res> {
  factory _$BibleBookmarkCopyWith(
          _BibleBookmark value, $Res Function(_BibleBookmark) _then) =
      __$BibleBookmarkCopyWithImpl;
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
class __$BibleBookmarkCopyWithImpl<$Res>
    implements _$BibleBookmarkCopyWith<$Res> {
  __$BibleBookmarkCopyWithImpl(this._self, this._then);

  final _BibleBookmark _self;
  final $Res Function(_BibleBookmark) _then;

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? createdAt = null,
    Object? isBookmarkAll = null,
    Object? verse = null,
  }) {
    return _then(_BibleBookmark(
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isBookmarkAll: null == isBookmarkAll
          ? _self.isBookmarkAll
          : isBookmarkAll // ignore: cast_nullable_to_non_nullable
              as bool,
      verse: null == verse
          ? _self.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as Verse,
    ));
  }

  /// Create a copy of BibleBookmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VerseCopyWith<$Res> get verse {
    return $VerseCopyWith<$Res>(_self.verse, (value) {
      return _then(_self.copyWith(verse: value));
    });
  }
}

// dart format on
