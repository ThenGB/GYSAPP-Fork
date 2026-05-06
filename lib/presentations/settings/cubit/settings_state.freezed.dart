// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SettingsState {
  bool get isSabatNotificationActive;
  bool get isBibleReminderNotificationActive;
  Map<int, DateTime> get bibleReminders;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      _$SettingsStateCopyWithImpl<SettingsState>(
          this as SettingsState, _$identity);

  /// Serializes this SettingsState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SettingsState &&
            (identical(other.isSabatNotificationActive,
                    isSabatNotificationActive) ||
                other.isSabatNotificationActive == isSabatNotificationActive) &&
            (identical(other.isBibleReminderNotificationActive,
                    isBibleReminderNotificationActive) ||
                other.isBibleReminderNotificationActive ==
                    isBibleReminderNotificationActive) &&
            const DeepCollectionEquality()
                .equals(other.bibleReminders, bibleReminders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSabatNotificationActive,
      isBibleReminderNotificationActive,
      const DeepCollectionEquality().hash(bibleReminders));

  @override
  String toString() {
    return 'SettingsState(isSabatNotificationActive: $isSabatNotificationActive, isBibleReminderNotificationActive: $isBibleReminderNotificationActive, bibleReminders: $bibleReminders)';
  }
}

/// @nodoc
abstract mixin class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) _then) =
      _$SettingsStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isSabatNotificationActive,
      bool isBibleReminderNotificationActive,
      Map<int, DateTime> bibleReminders});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._self, this._then);

  final SettingsState _self;
  final $Res Function(SettingsState) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSabatNotificationActive = null,
    Object? isBibleReminderNotificationActive = null,
    Object? bibleReminders = null,
  }) {
    return _then(_self.copyWith(
      isSabatNotificationActive: null == isSabatNotificationActive
          ? _self.isSabatNotificationActive
          : isSabatNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isBibleReminderNotificationActive: null ==
              isBibleReminderNotificationActive
          ? _self.isBibleReminderNotificationActive
          : isBibleReminderNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      bibleReminders: null == bibleReminders
          ? _self.bibleReminders
          : bibleReminders // ignore: cast_nullable_to_non_nullable
              as Map<int, DateTime>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SettingsState].
extension SettingsStatePatterns on SettingsState {
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
    TResult Function(_SettingsState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsState() when $default != null:
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
    TResult Function(_SettingsState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsState():
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
    TResult? Function(_SettingsState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsState() when $default != null:
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
            bool isSabatNotificationActive,
            bool isBibleReminderNotificationActive,
            Map<int, DateTime> bibleReminders)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SettingsState() when $default != null:
        return $default(_that.isSabatNotificationActive,
            _that.isBibleReminderNotificationActive, _that.bibleReminders);
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
            bool isSabatNotificationActive,
            bool isBibleReminderNotificationActive,
            Map<int, DateTime> bibleReminders)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsState():
        return $default(_that.isSabatNotificationActive,
            _that.isBibleReminderNotificationActive, _that.bibleReminders);
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
            bool isSabatNotificationActive,
            bool isBibleReminderNotificationActive,
            Map<int, DateTime> bibleReminders)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SettingsState() when $default != null:
        return $default(_that.isSabatNotificationActive,
            _that.isBibleReminderNotificationActive, _that.bibleReminders);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SettingsState extends SettingsState {
  const _SettingsState(
      {this.isSabatNotificationActive = false,
      this.isBibleReminderNotificationActive = false,
      final Map<int, DateTime> bibleReminders = const {}})
      : _bibleReminders = bibleReminders,
        super._();
  factory _SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);

  @override
  @JsonKey()
  final bool isSabatNotificationActive;
  @override
  @JsonKey()
  final bool isBibleReminderNotificationActive;
  final Map<int, DateTime> _bibleReminders;
  @override
  @JsonKey()
  Map<int, DateTime> get bibleReminders {
    if (_bibleReminders is EqualUnmodifiableMapView) return _bibleReminders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_bibleReminders);
  }

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SettingsStateCopyWith<_SettingsState> get copyWith =>
      __$SettingsStateCopyWithImpl<_SettingsState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SettingsStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SettingsState &&
            (identical(other.isSabatNotificationActive,
                    isSabatNotificationActive) ||
                other.isSabatNotificationActive == isSabatNotificationActive) &&
            (identical(other.isBibleReminderNotificationActive,
                    isBibleReminderNotificationActive) ||
                other.isBibleReminderNotificationActive ==
                    isBibleReminderNotificationActive) &&
            const DeepCollectionEquality()
                .equals(other._bibleReminders, _bibleReminders));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSabatNotificationActive,
      isBibleReminderNotificationActive,
      const DeepCollectionEquality().hash(_bibleReminders));

  @override
  String toString() {
    return 'SettingsState(isSabatNotificationActive: $isSabatNotificationActive, isBibleReminderNotificationActive: $isBibleReminderNotificationActive, bibleReminders: $bibleReminders)';
  }
}

/// @nodoc
abstract mixin class _$SettingsStateCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$SettingsStateCopyWith(
          _SettingsState value, $Res Function(_SettingsState) _then) =
      __$SettingsStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isSabatNotificationActive,
      bool isBibleReminderNotificationActive,
      Map<int, DateTime> bibleReminders});
}

/// @nodoc
class __$SettingsStateCopyWithImpl<$Res>
    implements _$SettingsStateCopyWith<$Res> {
  __$SettingsStateCopyWithImpl(this._self, this._then);

  final _SettingsState _self;
  final $Res Function(_SettingsState) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isSabatNotificationActive = null,
    Object? isBibleReminderNotificationActive = null,
    Object? bibleReminders = null,
  }) {
    return _then(_SettingsState(
      isSabatNotificationActive: null == isSabatNotificationActive
          ? _self.isSabatNotificationActive
          : isSabatNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isBibleReminderNotificationActive: null ==
              isBibleReminderNotificationActive
          ? _self.isBibleReminderNotificationActive
          : isBibleReminderNotificationActive // ignore: cast_nullable_to_non_nullable
              as bool,
      bibleReminders: null == bibleReminders
          ? _self._bibleReminders
          : bibleReminders // ignore: cast_nullable_to_non_nullable
              as Map<int, DateTime>,
    ));
  }
}

// dart format on
