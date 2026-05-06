// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'song_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SongHistory {
  int get index;
  String get bookCode;
  DateTime get createdAt;

  /// Create a copy of SongHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SongHistoryCopyWith<SongHistory> get copyWith =>
      _$SongHistoryCopyWithImpl<SongHistory>(this as SongHistory, _$identity);

  /// Serializes this SongHistory to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SongHistory &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.bookCode, bookCode) ||
                other.bookCode == bookCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, index, bookCode, createdAt);

  @override
  String toString() {
    return 'SongHistory(index: $index, bookCode: $bookCode, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $SongHistoryCopyWith<$Res> {
  factory $SongHistoryCopyWith(
          SongHistory value, $Res Function(SongHistory) _then) =
      _$SongHistoryCopyWithImpl;
  @useResult
  $Res call({int index, String bookCode, DateTime createdAt});
}

/// @nodoc
class _$SongHistoryCopyWithImpl<$Res> implements $SongHistoryCopyWith<$Res> {
  _$SongHistoryCopyWithImpl(this._self, this._then);

  final SongHistory _self;
  final $Res Function(SongHistory) _then;

  /// Create a copy of SongHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? bookCode = null,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      bookCode: null == bookCode
          ? _self.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [SongHistory].
extension SongHistoryPatterns on SongHistory {
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
    TResult Function(_SongHistory value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SongHistory() when $default != null:
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
    TResult Function(_SongHistory value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongHistory():
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
    TResult? Function(_SongHistory value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongHistory() when $default != null:
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
    TResult Function(int index, String bookCode, DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SongHistory() when $default != null:
        return $default(_that.index, _that.bookCode, _that.createdAt);
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
    TResult Function(int index, String bookCode, DateTime createdAt) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongHistory():
        return $default(_that.index, _that.bookCode, _that.createdAt);
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
    TResult? Function(int index, String bookCode, DateTime createdAt)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SongHistory() when $default != null:
        return $default(_that.index, _that.bookCode, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SongHistory extends SongHistory {
  const _SongHistory(
      {required this.index, required this.bookCode, required this.createdAt})
      : super._();
  factory _SongHistory.fromJson(Map<String, dynamic> json) =>
      _$SongHistoryFromJson(json);

  @override
  final int index;
  @override
  final String bookCode;
  @override
  final DateTime createdAt;

  /// Create a copy of SongHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SongHistoryCopyWith<_SongHistory> get copyWith =>
      __$SongHistoryCopyWithImpl<_SongHistory>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SongHistoryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SongHistory &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.bookCode, bookCode) ||
                other.bookCode == bookCode) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, index, bookCode, createdAt);

  @override
  String toString() {
    return 'SongHistory(index: $index, bookCode: $bookCode, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$SongHistoryCopyWith<$Res>
    implements $SongHistoryCopyWith<$Res> {
  factory _$SongHistoryCopyWith(
          _SongHistory value, $Res Function(_SongHistory) _then) =
      __$SongHistoryCopyWithImpl;
  @override
  @useResult
  $Res call({int index, String bookCode, DateTime createdAt});
}

/// @nodoc
class __$SongHistoryCopyWithImpl<$Res> implements _$SongHistoryCopyWith<$Res> {
  __$SongHistoryCopyWithImpl(this._self, this._then);

  final _SongHistory _self;
  final $Res Function(_SongHistory) _then;

  /// Create a copy of SongHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? index = null,
    Object? bookCode = null,
    Object? createdAt = null,
  }) {
    return _then(_SongHistory(
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      bookCode: null == bookCode
          ? _self.bookCode
          : bookCode // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
