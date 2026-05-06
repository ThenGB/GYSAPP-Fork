// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BibleNote {
  int get id;
  List<Verse> get verses;
  String? get text;
  DateTime get createdDate;
  DateTime get updatedDate;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BibleNoteCopyWith<BibleNote> get copyWith =>
      _$BibleNoteCopyWithImpl<BibleNote>(this as BibleNote, _$identity);

  /// Serializes this BibleNote to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BibleNote &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other.verses, verses) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.updatedDate, updatedDate) ||
                other.updatedDate == updatedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(verses),
      text,
      createdDate,
      updatedDate);

  @override
  String toString() {
    return 'BibleNote(id: $id, verses: $verses, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
  }
}

/// @nodoc
abstract mixin class $BibleNoteCopyWith<$Res> {
  factory $BibleNoteCopyWith(BibleNote value, $Res Function(BibleNote) _then) =
      _$BibleNoteCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      List<Verse> verses,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});
}

/// @nodoc
class _$BibleNoteCopyWithImpl<$Res> implements $BibleNoteCopyWith<$Res> {
  _$BibleNoteCopyWithImpl(this._self, this._then);

  final BibleNote _self;
  final $Res Function(BibleNote) _then;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? verses = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verses: null == verses
          ? _self.verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: null == createdDate
          ? _self.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedDate: null == updatedDate
          ? _self.updatedDate
          : updatedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [BibleNote].
extension BibleNotePatterns on BibleNote {
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
    TResult Function(_BibleNote value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BibleNote() when $default != null:
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
    TResult Function(_BibleNote value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleNote():
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
    TResult? Function(_BibleNote value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleNote() when $default != null:
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
    TResult Function(int id, List<Verse> verses, String? text,
            DateTime createdDate, DateTime updatedDate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BibleNote() when $default != null:
        return $default(_that.id, _that.verses, _that.text, _that.createdDate,
            _that.updatedDate);
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
    TResult Function(int id, List<Verse> verses, String? text,
            DateTime createdDate, DateTime updatedDate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleNote():
        return $default(_that.id, _that.verses, _that.text, _that.createdDate,
            _that.updatedDate);
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
    TResult? Function(int id, List<Verse> verses, String? text,
            DateTime createdDate, DateTime updatedDate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleNote() when $default != null:
        return $default(_that.id, _that.verses, _that.text, _that.createdDate,
            _that.updatedDate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BibleNote extends BibleNote {
  const _BibleNote(
      {required this.id,
      required final List<Verse> verses,
      this.text,
      required this.createdDate,
      required this.updatedDate})
      : _verses = verses,
        super._();
  factory _BibleNote.fromJson(Map<String, dynamic> json) =>
      _$BibleNoteFromJson(json);

  @override
  final int id;
  final List<Verse> _verses;
  @override
  List<Verse> get verses {
    if (_verses is EqualUnmodifiableListView) return _verses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_verses);
  }

  @override
  final String? text;
  @override
  final DateTime createdDate;
  @override
  final DateTime updatedDate;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BibleNoteCopyWith<_BibleNote> get copyWith =>
      __$BibleNoteCopyWithImpl<_BibleNote>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BibleNoteToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BibleNote &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._verses, _verses) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdDate, createdDate) ||
                other.createdDate == createdDate) &&
            (identical(other.updatedDate, updatedDate) ||
                other.updatedDate == updatedDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_verses),
      text,
      createdDate,
      updatedDate);

  @override
  String toString() {
    return 'BibleNote(id: $id, verses: $verses, text: $text, createdDate: $createdDate, updatedDate: $updatedDate)';
  }
}

/// @nodoc
abstract mixin class _$BibleNoteCopyWith<$Res>
    implements $BibleNoteCopyWith<$Res> {
  factory _$BibleNoteCopyWith(
          _BibleNote value, $Res Function(_BibleNote) _then) =
      __$BibleNoteCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      List<Verse> verses,
      String? text,
      DateTime createdDate,
      DateTime updatedDate});
}

/// @nodoc
class __$BibleNoteCopyWithImpl<$Res> implements _$BibleNoteCopyWith<$Res> {
  __$BibleNoteCopyWithImpl(this._self, this._then);

  final _BibleNote _self;
  final $Res Function(_BibleNote) _then;

  /// Create a copy of BibleNote
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? verses = null,
    Object? text = freezed,
    Object? createdDate = null,
    Object? updatedDate = null,
  }) {
    return _then(_BibleNote(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      verses: null == verses
          ? _self._verses
          : verses // ignore: cast_nullable_to_non_nullable
              as List<Verse>,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      createdDate: null == createdDate
          ? _self.createdDate
          : createdDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedDate: null == updatedDate
          ? _self.updatedDate
          : updatedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
