// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bcvbc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bcvbc {
  @JsonKey(name: 'b')
  String? get b;
  @JsonKey(name: 'c')
  String? get c;
  @JsonKey(name: 'v')
  String? get v;
  @JsonKey(name: 'bc')
  int? get bc;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BcvbcCopyWith<Bcvbc> get copyWith =>
      _$BcvbcCopyWithImpl<Bcvbc>(this as Bcvbc, _$identity);

  /// Serializes this Bcvbc to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Bcvbc &&
            (identical(other.b, b) || other.b == b) &&
            (identical(other.c, c) || other.c == c) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.bc, bc) || other.bc == bc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, b, c, v, bc);

  @override
  String toString() {
    return 'Bcvbc(b: $b, c: $c, v: $v, bc: $bc)';
  }
}

/// @nodoc
abstract mixin class $BcvbcCopyWith<$Res> {
  factory $BcvbcCopyWith(Bcvbc value, $Res Function(Bcvbc) _then) =
      _$BcvbcCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'b') String? b,
      @JsonKey(name: 'c') String? c,
      @JsonKey(name: 'v') String? v,
      @JsonKey(name: 'bc') int? bc});
}

/// @nodoc
class _$BcvbcCopyWithImpl<$Res> implements $BcvbcCopyWith<$Res> {
  _$BcvbcCopyWithImpl(this._self, this._then);

  final Bcvbc _self;
  final $Res Function(Bcvbc) _then;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? b = freezed,
    Object? c = freezed,
    Object? v = freezed,
    Object? bc = freezed,
  }) {
    return _then(_self.copyWith(
      b: freezed == b
          ? _self.b
          : b // ignore: cast_nullable_to_non_nullable
              as String?,
      c: freezed == c
          ? _self.c
          : c // ignore: cast_nullable_to_non_nullable
              as String?,
      v: freezed == v
          ? _self.v
          : v // ignore: cast_nullable_to_non_nullable
              as String?,
      bc: freezed == bc
          ? _self.bc
          : bc // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Bcvbc].
extension BcvbcPatterns on Bcvbc {
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
    TResult Function(_Bcvbc value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Bcvbc() when $default != null:
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
    TResult Function(_Bcvbc value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Bcvbc():
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
    TResult? Function(_Bcvbc value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Bcvbc() when $default != null:
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
            @JsonKey(name: 'b') String? b,
            @JsonKey(name: 'c') String? c,
            @JsonKey(name: 'v') String? v,
            @JsonKey(name: 'bc') int? bc)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Bcvbc() when $default != null:
        return $default(_that.b, _that.c, _that.v, _that.bc);
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
            @JsonKey(name: 'b') String? b,
            @JsonKey(name: 'c') String? c,
            @JsonKey(name: 'v') String? v,
            @JsonKey(name: 'bc') int? bc)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Bcvbc():
        return $default(_that.b, _that.c, _that.v, _that.bc);
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
            @JsonKey(name: 'b') String? b,
            @JsonKey(name: 'c') String? c,
            @JsonKey(name: 'v') String? v,
            @JsonKey(name: 'bc') int? bc)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Bcvbc() when $default != null:
        return $default(_that.b, _that.c, _that.v, _that.bc);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _Bcvbc extends Bcvbc {
  const _Bcvbc(
      {@JsonKey(name: 'b') this.b,
      @JsonKey(name: 'c') this.c,
      @JsonKey(name: 'v') this.v,
      @JsonKey(name: 'bc') this.bc})
      : super._();
  factory _Bcvbc.fromJson(Map<String, dynamic> json) => _$BcvbcFromJson(json);

  @override
  @JsonKey(name: 'b')
  final String? b;
  @override
  @JsonKey(name: 'c')
  final String? c;
  @override
  @JsonKey(name: 'v')
  final String? v;
  @override
  @JsonKey(name: 'bc')
  final int? bc;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BcvbcCopyWith<_Bcvbc> get copyWith =>
      __$BcvbcCopyWithImpl<_Bcvbc>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BcvbcToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Bcvbc &&
            (identical(other.b, b) || other.b == b) &&
            (identical(other.c, c) || other.c == c) &&
            (identical(other.v, v) || other.v == v) &&
            (identical(other.bc, bc) || other.bc == bc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, b, c, v, bc);

  @override
  String toString() {
    return 'Bcvbc(b: $b, c: $c, v: $v, bc: $bc)';
  }
}

/// @nodoc
abstract mixin class _$BcvbcCopyWith<$Res> implements $BcvbcCopyWith<$Res> {
  factory _$BcvbcCopyWith(_Bcvbc value, $Res Function(_Bcvbc) _then) =
      __$BcvbcCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'b') String? b,
      @JsonKey(name: 'c') String? c,
      @JsonKey(name: 'v') String? v,
      @JsonKey(name: 'bc') int? bc});
}

/// @nodoc
class __$BcvbcCopyWithImpl<$Res> implements _$BcvbcCopyWith<$Res> {
  __$BcvbcCopyWithImpl(this._self, this._then);

  final _Bcvbc _self;
  final $Res Function(_Bcvbc) _then;

  /// Create a copy of Bcvbc
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? b = freezed,
    Object? c = freezed,
    Object? v = freezed,
    Object? bc = freezed,
  }) {
    return _then(_Bcvbc(
      b: freezed == b
          ? _self.b
          : b // ignore: cast_nullable_to_non_nullable
              as String?,
      c: freezed == c
          ? _self.c
          : c // ignore: cast_nullable_to_non_nullable
              as String?,
      v: freezed == v
          ? _self.v
          : v // ignore: cast_nullable_to_non_nullable
              as String?,
      bc: freezed == bc
          ? _self.bc
          : bc // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

// dart format on
