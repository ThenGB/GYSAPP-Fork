// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bible_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BibleRef {
  @JsonKey(name: 'id')
  int? get id;
  @JsonKey(name: 'sv')
  int? get sv;
  @JsonKey(name: 'ev')
  int? get ev;

  /// Create a copy of BibleRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BibleRefCopyWith<BibleRef> get copyWith =>
      _$BibleRefCopyWithImpl<BibleRef>(this as BibleRef, _$identity);

  /// Serializes this BibleRef to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BibleRef &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sv, sv) || other.sv == sv) &&
            (identical(other.ev, ev) || other.ev == ev));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sv, ev);

  @override
  String toString() {
    return 'BibleRef(id: $id, sv: $sv, ev: $ev)';
  }
}

/// @nodoc
abstract mixin class $BibleRefCopyWith<$Res> {
  factory $BibleRefCopyWith(BibleRef value, $Res Function(BibleRef) _then) =
      _$BibleRefCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'sv') int? sv,
      @JsonKey(name: 'ev') int? ev});
}

/// @nodoc
class _$BibleRefCopyWithImpl<$Res> implements $BibleRefCopyWith<$Res> {
  _$BibleRefCopyWithImpl(this._self, this._then);

  final BibleRef _self;
  final $Res Function(BibleRef) _then;

  /// Create a copy of BibleRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? sv = freezed,
    Object? ev = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      sv: freezed == sv
          ? _self.sv
          : sv // ignore: cast_nullable_to_non_nullable
              as int?,
      ev: freezed == ev
          ? _self.ev
          : ev // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BibleRef].
extension BibleRefPatterns on BibleRef {
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
    TResult Function(_BibleRef value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BibleRef() when $default != null:
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
    TResult Function(_BibleRef value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleRef():
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
    TResult? Function(_BibleRef value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleRef() when $default != null:
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
    TResult Function(@JsonKey(name: 'id') int? id, @JsonKey(name: 'sv') int? sv,
            @JsonKey(name: 'ev') int? ev)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BibleRef() when $default != null:
        return $default(_that.id, _that.sv, _that.ev);
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
    TResult Function(@JsonKey(name: 'id') int? id, @JsonKey(name: 'sv') int? sv,
            @JsonKey(name: 'ev') int? ev)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleRef():
        return $default(_that.id, _that.sv, _that.ev);
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
    TResult? Function(@JsonKey(name: 'id') int? id,
            @JsonKey(name: 'sv') int? sv, @JsonKey(name: 'ev') int? ev)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BibleRef() when $default != null:
        return $default(_that.id, _that.sv, _that.ev);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BibleRef extends BibleRef {
  const _BibleRef(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'sv') this.sv,
      @JsonKey(name: 'ev') this.ev})
      : super._();
  factory _BibleRef.fromJson(Map<String, dynamic> json) =>
      _$BibleRefFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'sv')
  final int? sv;
  @override
  @JsonKey(name: 'ev')
  final int? ev;

  /// Create a copy of BibleRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BibleRefCopyWith<_BibleRef> get copyWith =>
      __$BibleRefCopyWithImpl<_BibleRef>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BibleRefToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BibleRef &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sv, sv) || other.sv == sv) &&
            (identical(other.ev, ev) || other.ev == ev));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, sv, ev);

  @override
  String toString() {
    return 'BibleRef(id: $id, sv: $sv, ev: $ev)';
  }
}

/// @nodoc
abstract mixin class _$BibleRefCopyWith<$Res>
    implements $BibleRefCopyWith<$Res> {
  factory _$BibleRefCopyWith(_BibleRef value, $Res Function(_BibleRef) _then) =
      __$BibleRefCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'sv') int? sv,
      @JsonKey(name: 'ev') int? ev});
}

/// @nodoc
class __$BibleRefCopyWithImpl<$Res> implements _$BibleRefCopyWith<$Res> {
  __$BibleRefCopyWithImpl(this._self, this._then);

  final _BibleRef _self;
  final $Res Function(_BibleRef) _then;

  /// Create a copy of BibleRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? sv = freezed,
    Object? ev = freezed,
  }) {
    return _then(_BibleRef(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      sv: freezed == sv
          ? _self.sv
          : sv // ignore: cast_nullable_to_non_nullable
              as int?,
      ev: freezed == ev
          ? _self.ev
          : ev // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
