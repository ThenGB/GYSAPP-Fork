// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verse.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Verse {
  @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
  int get id;
  @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
  int get bookId;
  @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
  int get chapterId;
  @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
  int get verseId;
  @JsonKey(name: 't')
  String? get verse;
  @JsonKey(name: 'r')
  int? get revisionId;
  @JsonKey(name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
  String? get c1;
  @JsonKey(name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
  String? get v1;
  @JsonKey(name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
  Color? get color;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VerseCopyWith<Verse> get copyWith =>
      _$VerseCopyWithImpl<Verse>(this as Verse, _$identity);

  /// Serializes this Verse to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Verse &&
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

  @override
  String toString() {
    return 'Verse(id: $id, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, verse: $verse, revisionId: $revisionId, c1: $c1, v1: $v1, color: $color)';
  }
}

/// @nodoc
abstract mixin class $VerseCopyWith<$Res> {
  factory $VerseCopyWith(Verse value, $Res Function(Verse) _then) =
      _$VerseCopyWithImpl;
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
class _$VerseCopyWithImpl<$Res> implements $VerseCopyWith<$Res> {
  _$VerseCopyWithImpl(this._self, this._then);

  final Verse _self;
  final $Res Function(Verse) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      verseId: null == verseId
          ? _self.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int,
      verse: freezed == verse
          ? _self.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as String?,
      revisionId: freezed == revisionId
          ? _self.revisionId
          : revisionId // ignore: cast_nullable_to_non_nullable
              as int?,
      c1: freezed == c1
          ? _self.c1
          : c1 // ignore: cast_nullable_to_non_nullable
              as String?,
      v1: freezed == v1
          ? _self.v1
          : v1 // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Verse].
extension VersePatterns on Verse {
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
    TResult Function(_Verse value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
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
    TResult Function(_Verse value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse():
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
    TResult? Function(_Verse value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
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
            @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
            int id,
            @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
            int bookId,
            @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
            int chapterId,
            @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
            int verseId,
            @JsonKey(name: 't') String? verse,
            @JsonKey(name: 'r') int? revisionId,
            @JsonKey(
                name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
            String? c1,
            @JsonKey(
                name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
            String? v1,
            @JsonKey(
                name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
            Color? color)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
        return $default(_that.id, _that.bookId, _that.chapterId, _that.verseId,
            _that.verse, _that.revisionId, _that.c1, _that.v1, _that.color);
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
            @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
            int id,
            @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
            int bookId,
            @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
            int chapterId,
            @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
            int verseId,
            @JsonKey(name: 't') String? verse,
            @JsonKey(name: 'r') int? revisionId,
            @JsonKey(
                name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
            String? c1,
            @JsonKey(
                name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
            String? v1,
            @JsonKey(
                name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
            Color? color)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse():
        return $default(_that.id, _that.bookId, _that.chapterId, _that.verseId,
            _that.verse, _that.revisionId, _that.c1, _that.v1, _that.color);
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
            @JsonKey(name: 'id', fromJson: dynamicToInt, toJson: intToDynamic)
            int id,
            @JsonKey(name: 'b', fromJson: dynamicToInt, toJson: intToDynamic)
            int bookId,
            @JsonKey(name: 'c', fromJson: dynamicToInt, toJson: intToDynamic)
            int chapterId,
            @JsonKey(name: 'v', fromJson: dynamicToInt, toJson: intToDynamic)
            int verseId,
            @JsonKey(name: 't') String? verse,
            @JsonKey(name: 'r') int? revisionId,
            @JsonKey(
                name: 'c1', fromJson: dynamicToString, toJson: stringToDynamic)
            String? c1,
            @JsonKey(
                name: 'v1', fromJson: dynamicToString, toJson: stringToDynamic)
            String? v1,
            @JsonKey(
                name: 'color', fromJson: _colorFromJson, toJson: _colorToJson)
            Color? color)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Verse() when $default != null:
        return $default(_that.id, _that.bookId, _that.chapterId, _that.verseId,
            _that.verse, _that.revisionId, _that.c1, _that.v1, _that.color);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Verse extends Verse {
  const _Verse(
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
  factory _Verse.fromJson(Map<String, dynamic> json) => _$VerseFromJson(json);

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

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VerseCopyWith<_Verse> get copyWith =>
      __$VerseCopyWithImpl<_Verse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VerseToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Verse &&
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

  @override
  String toString() {
    return 'Verse(id: $id, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, verse: $verse, revisionId: $revisionId, c1: $c1, v1: $v1, color: $color)';
  }
}

/// @nodoc
abstract mixin class _$VerseCopyWith<$Res> implements $VerseCopyWith<$Res> {
  factory _$VerseCopyWith(_Verse value, $Res Function(_Verse) _then) =
      __$VerseCopyWithImpl;
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
class __$VerseCopyWithImpl<$Res> implements _$VerseCopyWith<$Res> {
  __$VerseCopyWithImpl(this._self, this._then);

  final _Verse _self;
  final $Res Function(_Verse) _then;

  /// Create a copy of Verse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_Verse(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      bookId: null == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int,
      chapterId: null == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int,
      verseId: null == verseId
          ? _self.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int,
      verse: freezed == verse
          ? _self.verse
          : verse // ignore: cast_nullable_to_non_nullable
              as String?,
      revisionId: freezed == revisionId
          ? _self.revisionId
          : revisionId // ignore: cast_nullable_to_non_nullable
              as int?,
      c1: freezed == c1
          ? _self.c1
          : c1 // ignore: cast_nullable_to_non_nullable
              as String?,
      v1: freezed == v1
          ? _self.v1
          : v1 // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as Color?,
    ));
  }
}

// dart format on
