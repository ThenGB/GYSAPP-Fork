// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pericope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Pericope {
  int get id;
  @JsonKey(name: 's')
  int? get s;
  @JsonKey(name: 'b')
  int? get bookId;
  @JsonKey(name: 'c')
  int? get chapterId;
  @JsonKey(name: 'v')
  int? get verseId;
  @JsonKey(name: 't')
  String? get title;

  /// Create a copy of Pericope
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PericopeCopyWith<Pericope> get copyWith =>
      _$PericopeCopyWithImpl<Pericope>(this as Pericope, _$identity);

  /// Serializes this Pericope to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Pericope &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.s, s) || other.s == s) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.verseId, verseId) || other.verseId == verseId) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, s, bookId, chapterId, verseId, title);

  @override
  String toString() {
    return 'Pericope(id: $id, s: $s, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, title: $title)';
  }
}

/// @nodoc
abstract mixin class $PericopeCopyWith<$Res> {
  factory $PericopeCopyWith(Pericope value, $Res Function(Pericope) _then) =
      _$PericopeCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 's') int? s,
      @JsonKey(name: 'b') int? bookId,
      @JsonKey(name: 'c') int? chapterId,
      @JsonKey(name: 'v') int? verseId,
      @JsonKey(name: 't') String? title});
}

/// @nodoc
class _$PericopeCopyWithImpl<$Res> implements $PericopeCopyWith<$Res> {
  _$PericopeCopyWithImpl(this._self, this._then);

  final Pericope _self;
  final $Res Function(Pericope) _then;

  /// Create a copy of Pericope
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? s = freezed,
    Object? bookId = freezed,
    Object? chapterId = freezed,
    Object? verseId = freezed,
    Object? title = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      s: freezed == s
          ? _self.s
          : s // ignore: cast_nullable_to_non_nullable
              as int?,
      bookId: freezed == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int?,
      chapterId: freezed == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int?,
      verseId: freezed == verseId
          ? _self.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Pericope].
extension PericopePatterns on Pericope {
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
    TResult Function(_Pericope value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pericope() when $default != null:
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
    TResult Function(_Pericope value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pericope():
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
    TResult? Function(_Pericope value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pericope() when $default != null:
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
            int id,
            @JsonKey(name: 's') int? s,
            @JsonKey(name: 'b') int? bookId,
            @JsonKey(name: 'c') int? chapterId,
            @JsonKey(name: 'v') int? verseId,
            @JsonKey(name: 't') String? title)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Pericope() when $default != null:
        return $default(_that.id, _that.s, _that.bookId, _that.chapterId,
            _that.verseId, _that.title);
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
            int id,
            @JsonKey(name: 's') int? s,
            @JsonKey(name: 'b') int? bookId,
            @JsonKey(name: 'c') int? chapterId,
            @JsonKey(name: 'v') int? verseId,
            @JsonKey(name: 't') String? title)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pericope():
        return $default(_that.id, _that.s, _that.bookId, _that.chapterId,
            _that.verseId, _that.title);
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
            int id,
            @JsonKey(name: 's') int? s,
            @JsonKey(name: 'b') int? bookId,
            @JsonKey(name: 'c') int? chapterId,
            @JsonKey(name: 'v') int? verseId,
            @JsonKey(name: 't') String? title)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Pericope() when $default != null:
        return $default(_that.id, _that.s, _that.bookId, _that.chapterId,
            _that.verseId, _that.title);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Pericope extends Pericope {
  const _Pericope(
      {required this.id,
      @JsonKey(name: 's') this.s,
      @JsonKey(name: 'b') this.bookId,
      @JsonKey(name: 'c') this.chapterId,
      @JsonKey(name: 'v') this.verseId,
      @JsonKey(name: 't') this.title})
      : super._();
  factory _Pericope.fromJson(Map<String, dynamic> json) =>
      _$PericopeFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 's')
  final int? s;
  @override
  @JsonKey(name: 'b')
  final int? bookId;
  @override
  @JsonKey(name: 'c')
  final int? chapterId;
  @override
  @JsonKey(name: 'v')
  final int? verseId;
  @override
  @JsonKey(name: 't')
  final String? title;

  /// Create a copy of Pericope
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PericopeCopyWith<_Pericope> get copyWith =>
      __$PericopeCopyWithImpl<_Pericope>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PericopeToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Pericope &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.s, s) || other.s == s) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.chapterId, chapterId) ||
                other.chapterId == chapterId) &&
            (identical(other.verseId, verseId) || other.verseId == verseId) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, s, bookId, chapterId, verseId, title);

  @override
  String toString() {
    return 'Pericope(id: $id, s: $s, bookId: $bookId, chapterId: $chapterId, verseId: $verseId, title: $title)';
  }
}

/// @nodoc
abstract mixin class _$PericopeCopyWith<$Res>
    implements $PericopeCopyWith<$Res> {
  factory _$PericopeCopyWith(_Pericope value, $Res Function(_Pericope) _then) =
      __$PericopeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 's') int? s,
      @JsonKey(name: 'b') int? bookId,
      @JsonKey(name: 'c') int? chapterId,
      @JsonKey(name: 'v') int? verseId,
      @JsonKey(name: 't') String? title});
}

/// @nodoc
class __$PericopeCopyWithImpl<$Res> implements _$PericopeCopyWith<$Res> {
  __$PericopeCopyWithImpl(this._self, this._then);

  final _Pericope _self;
  final $Res Function(_Pericope) _then;

  /// Create a copy of Pericope
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? s = freezed,
    Object? bookId = freezed,
    Object? chapterId = freezed,
    Object? verseId = freezed,
    Object? title = freezed,
  }) {
    return _then(_Pericope(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      s: freezed == s
          ? _self.s
          : s // ignore: cast_nullable_to_non_nullable
              as int?,
      bookId: freezed == bookId
          ? _self.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as int?,
      chapterId: freezed == chapterId
          ? _self.chapterId
          : chapterId // ignore: cast_nullable_to_non_nullable
              as int?,
      verseId: freezed == verseId
          ? _self.verseId
          : verseId // ignore: cast_nullable_to_non_nullable
              as int?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
