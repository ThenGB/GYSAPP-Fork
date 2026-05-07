// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'literature_renungan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LiteratureRenunganState {
  bool get isLoading;
  List<Renungan> get items;

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LiteratureRenunganStateCopyWith<LiteratureRenunganState> get copyWith =>
      _$LiteratureRenunganStateCopyWithImpl<LiteratureRenunganState>(
          this as LiteratureRenunganState, _$identity);

  /// Serializes this LiteratureRenunganState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LiteratureRenunganState &&
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
    return 'LiteratureRenunganState(isLoading: $isLoading, items: $items)';
  }
}

/// @nodoc
abstract mixin class $LiteratureRenunganStateCopyWith<$Res> {
  factory $LiteratureRenunganStateCopyWith(LiteratureRenunganState value,
          $Res Function(LiteratureRenunganState) _then) =
      _$LiteratureRenunganStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, List<Renungan> items});
}

/// @nodoc
class _$LiteratureRenunganStateCopyWithImpl<$Res>
    implements $LiteratureRenunganStateCopyWith<$Res> {
  _$LiteratureRenunganStateCopyWithImpl(this._self, this._then);

  final LiteratureRenunganState _self;
  final $Res Function(LiteratureRenunganState) _then;

  /// Create a copy of LiteratureRenunganState
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
              as List<Renungan>,
    ));
  }
}

/// Adds pattern-matching-related methods to [LiteratureRenunganState].
extension LiteratureRenunganStatePatterns on LiteratureRenunganState {
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
    TResult Function(_LiteratureRenunganState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LiteratureRenunganState() when $default != null:
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
    TResult Function(_LiteratureRenunganState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureRenunganState():
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
    TResult? Function(_LiteratureRenunganState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureRenunganState() when $default != null:
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
    TResult Function(bool isLoading, List<Renungan> items)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LiteratureRenunganState() when $default != null:
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
    TResult Function(bool isLoading, List<Renungan> items) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureRenunganState():
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
    TResult? Function(bool isLoading, List<Renungan> items)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LiteratureRenunganState() when $default != null:
        return $default(_that.isLoading, _that.items);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LiteratureRenunganState extends LiteratureRenunganState {
  const _LiteratureRenunganState(
      {this.isLoading = false, final List<Renungan> items = const []})
      : _items = items,
        super._();
  factory _LiteratureRenunganState.fromJson(Map<String, dynamic> json) =>
      _$LiteratureRenunganStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  final List<Renungan> _items;
  @override
  @JsonKey()
  List<Renungan> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LiteratureRenunganStateCopyWith<_LiteratureRenunganState> get copyWith =>
      __$LiteratureRenunganStateCopyWithImpl<_LiteratureRenunganState>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LiteratureRenunganStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LiteratureRenunganState &&
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
    return 'LiteratureRenunganState(isLoading: $isLoading, items: $items)';
  }
}

/// @nodoc
abstract mixin class _$LiteratureRenunganStateCopyWith<$Res>
    implements $LiteratureRenunganStateCopyWith<$Res> {
  factory _$LiteratureRenunganStateCopyWith(_LiteratureRenunganState value,
          $Res Function(_LiteratureRenunganState) _then) =
      __$LiteratureRenunganStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, List<Renungan> items});
}

/// @nodoc
class __$LiteratureRenunganStateCopyWithImpl<$Res>
    implements _$LiteratureRenunganStateCopyWith<$Res> {
  __$LiteratureRenunganStateCopyWithImpl(this._self, this._then);

  final _LiteratureRenunganState _self;
  final $Res Function(_LiteratureRenunganState) _then;

  /// Create a copy of LiteratureRenunganState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? items = null,
  }) {
    return _then(_LiteratureRenunganState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<Renungan>,
    ));
  }
}

// dart format on
