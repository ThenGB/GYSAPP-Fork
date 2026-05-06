// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_kesaksian_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiteratureKesaksianState {
  bool get isLoading;
  List<Kesaksian> get items;

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LiteratureKesaksianStateCopyWith<LiteratureKesaksianState> get copyWith =>
      _$LiteratureKesaksianStateCopyWithImpl<LiteratureKesaksianState>(
          this as LiteratureKesaksianState, _$identity);

  /// Serializes this LiteratureKesaksianState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LiteratureKesaksianState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other.items, items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, const DeepCollectionEquality().hash(items));

  @override
  String toString() {
    return 'LiteratureKesaksianState(isLoading: $isLoading, items: $items)';
  }
}

/// @nodoc
abstract mixin class $LiteratureKesaksianStateCopyWith<$Res> {
  factory $LiteratureKesaksianStateCopyWith(LiteratureKesaksianState value,
          $Res Function(LiteratureKesaksianState) _then) =
      _$LiteratureKesaksianStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, List<Kesaksian> items});
}

/// @nodoc
class _$LiteratureKesaksianStateCopyWithImpl<$Res>
    implements $LiteratureKesaksianStateCopyWith<$Res> {
  _$LiteratureKesaksianStateCopyWithImpl(this._self, this._then);

  final LiteratureKesaksianState _self;
  final $Res Function(LiteratureKesaksianState) _then;

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Kesaksian>,
    ));
  }
}

/// Adds pattern-matching-related methods to [LiteratureKesaksianState].
extension LiteratureKesaksianStatePatterns on LiteratureKesaksianState {
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
    TResult Function(_LiteratureKesaksianState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LiteratureKesaksianState() when $default != null:
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
    TResult Function(_LiteratureKesaksianState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureKesaksianState():
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
    TResult? Function(_LiteratureKesaksianState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureKesaksianState() when $default != null:
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
    TResult Function(bool isLoading, List<Kesaksian> items)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LiteratureKesaksianState() when $default != null:
        return $default(_that.isLoading, _that.items);
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
    TResult Function(bool isLoading, List<Kesaksian> items) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureKesaksianState():
        return $default(_that.isLoading, _that.items);
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
    TResult? Function(bool isLoading, List<Kesaksian> items)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureKesaksianState() when $default != null:
        return $default(_that.isLoading, _that.items);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LiteratureKesaksianState extends LiteratureKesaksianState {
  const _LiteratureKesaksianState(
      {this.isLoading = false, final List<Kesaksian> items = const []})
      : _items = items,
        super._();
  factory _LiteratureKesaksianState.fromJson(Map<String, dynamic> json) =>
      _$LiteratureKesaksianStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Kesaksian> _items;
  @override
  @JsonKey()
  List<Kesaksian> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LiteratureKesaksianStateCopyWith<_LiteratureKesaksianState> get copyWith =>
      __$LiteratureKesaksianStateCopyWithImpl<_LiteratureKesaksianState>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LiteratureKesaksianStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LiteratureKesaksianState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, const DeepCollectionEquality().hash(_items));

  @override
  String toString() {
    return 'LiteratureKesaksianState(isLoading: $isLoading, items: $items)';
  }
}

/// @nodoc
abstract mixin class _$LiteratureKesaksianStateCopyWith<$Res>
    implements $LiteratureKesaksianStateCopyWith<$Res> {
  factory _$LiteratureKesaksianStateCopyWith(_LiteratureKesaksianState value,
          $Res Function(_LiteratureKesaksianState) _then) =
      __$LiteratureKesaksianStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, List<Kesaksian> items});
}

/// @nodoc
class __$LiteratureKesaksianStateCopyWithImpl<$Res>
    implements _$LiteratureKesaksianStateCopyWith<$Res> {
  __$LiteratureKesaksianStateCopyWithImpl(this._self, this._then);

  final _LiteratureKesaksianState _self;
  final $Res Function(_LiteratureKesaksianState) _then;

  /// Create a copy of LiteratureKesaksianState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_LiteratureKesaksianState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Kesaksian>,
    ));
  }
}

// dart format on
