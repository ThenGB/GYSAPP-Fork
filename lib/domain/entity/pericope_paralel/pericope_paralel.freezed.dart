// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pericope_paralel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PericopeParalel {
  @JsonKey(name: 'id')
  int? get id;
  @JsonKey(name: 'id1')
  int? get id1;
  @JsonKey(name: 'id2')
  int? get id2;
  @JsonKey(name: 't')
  String? get t;

  /// Create a copy of PericopeParalel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PericopeParalelCopyWith<PericopeParalel> get copyWith =>
      _$PericopeParalelCopyWithImpl<PericopeParalel>(
          this as PericopeParalel, _$identity);

  /// Serializes this PericopeParalel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PericopeParalel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.id1, id1) || other.id1 == id1) &&
            (identical(other.id2, id2) || other.id2 == id2) &&
            (identical(other.t, t) || other.t == t));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, id1, id2, t);

  @override
  String toString() {
    return 'PericopeParalel(id: $id, id1: $id1, id2: $id2, t: $t)';
  }
}

/// @nodoc
abstract mixin class $PericopeParalelCopyWith<$Res> {
  factory $PericopeParalelCopyWith(
          PericopeParalel value, $Res Function(PericopeParalel) _then) =
      _$PericopeParalelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'id1') int? id1,
      @JsonKey(name: 'id2') int? id2,
      @JsonKey(name: 't') String? t});
}

/// @nodoc
class _$PericopeParalelCopyWithImpl<$Res>
    implements $PericopeParalelCopyWith<$Res> {
  _$PericopeParalelCopyWithImpl(this._self, this._then);

  final PericopeParalel _self;
  final $Res Function(PericopeParalel) _then;

  /// Create a copy of PericopeParalel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? id1 = freezed,
    Object? id2 = freezed,
    Object? t = freezed,
  }) {
    return _then(_self.copyWith(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      id1: freezed == id1
          ? _self.id1
          : id1 // ignore: cast_nullable_to_non_nullable
              as int?,
      id2: freezed == id2
          ? _self.id2
          : id2 // ignore: cast_nullable_to_non_nullable
              as int?,
      t: freezed == t
          ? _self.t
          : t // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [PericopeParalel].
extension PericopeParalelPatterns on PericopeParalel {
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
    TResult Function(_PericopeParalel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PericopeParalel() when $default != null:
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
    TResult Function(_PericopeParalel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PericopeParalel():
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
    TResult? Function(_PericopeParalel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PericopeParalel() when $default != null:
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
            @JsonKey(name: 'id') int? id,
            @JsonKey(name: 'id1') int? id1,
            @JsonKey(name: 'id2') int? id2,
            @JsonKey(name: 't') String? t)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PericopeParalel() when $default != null:
        return $default(_that.id, _that.id1, _that.id2, _that.t);
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
            @JsonKey(name: 'id') int? id,
            @JsonKey(name: 'id1') int? id1,
            @JsonKey(name: 'id2') int? id2,
            @JsonKey(name: 't') String? t)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PericopeParalel():
        return $default(_that.id, _that.id1, _that.id2, _that.t);
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
            @JsonKey(name: 'id') int? id,
            @JsonKey(name: 'id1') int? id1,
            @JsonKey(name: 'id2') int? id2,
            @JsonKey(name: 't') String? t)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PericopeParalel() when $default != null:
        return $default(_that.id, _that.id1, _that.id2, _that.t);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _PericopeParalel extends PericopeParalel {
  const _PericopeParalel(
      {@JsonKey(name: 'id') this.id,
      @JsonKey(name: 'id1') this.id1,
      @JsonKey(name: 'id2') this.id2,
      @JsonKey(name: 't') this.t})
      : super._();
  factory _PericopeParalel.fromJson(Map<String, dynamic> json) =>
      _$PericopeParalelFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int? id;
  @override
  @JsonKey(name: 'id1')
  final int? id1;
  @override
  @JsonKey(name: 'id2')
  final int? id2;
  @override
  @JsonKey(name: 't')
  final String? t;

  /// Create a copy of PericopeParalel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PericopeParalelCopyWith<_PericopeParalel> get copyWith =>
      __$PericopeParalelCopyWithImpl<_PericopeParalel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$PericopeParalelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PericopeParalel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.id1, id1) || other.id1 == id1) &&
            (identical(other.id2, id2) || other.id2 == id2) &&
            (identical(other.t, t) || other.t == t));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, id1, id2, t);

  @override
  String toString() {
    return 'PericopeParalel(id: $id, id1: $id1, id2: $id2, t: $t)';
  }
}

/// @nodoc
abstract mixin class _$PericopeParalelCopyWith<$Res>
    implements $PericopeParalelCopyWith<$Res> {
  factory _$PericopeParalelCopyWith(
          _PericopeParalel value, $Res Function(_PericopeParalel) _then) =
      __$PericopeParalelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int? id,
      @JsonKey(name: 'id1') int? id1,
      @JsonKey(name: 'id2') int? id2,
      @JsonKey(name: 't') String? t});
}

/// @nodoc
class __$PericopeParalelCopyWithImpl<$Res>
    implements _$PericopeParalelCopyWith<$Res> {
  __$PericopeParalelCopyWithImpl(this._self, this._then);

  final _PericopeParalel _self;
  final $Res Function(_PericopeParalel) _then;

  /// Create a copy of PericopeParalel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = freezed,
    Object? id1 = freezed,
    Object? id2 = freezed,
    Object? t = freezed,
  }) {
    return _then(_PericopeParalel(
      id: freezed == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      id1: freezed == id1
          ? _self.id1
          : id1 // ignore: cast_nullable_to_non_nullable
              as int?,
      id2: freezed == id2
          ? _self.id2
          : id2 // ignore: cast_nullable_to_non_nullable
              as int?,
      t: freezed == t
          ? _self.t
          : t // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
