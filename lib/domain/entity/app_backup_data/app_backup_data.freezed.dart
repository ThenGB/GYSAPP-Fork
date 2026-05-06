// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_backup_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppBackupData {
  @JsonKey(name: 'bible_state')
  BibleState? get bibleState;
  @JsonKey(name: 'song_state')
  SongState? get songState;
  @JsonKey(name: 'faith_state')
  FaithState? get faithState;
  @JsonKey(name: 'settings_state')
  SettingsState? get settingsState;

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppBackupDataCopyWith<AppBackupData> get copyWith =>
      _$AppBackupDataCopyWithImpl<AppBackupData>(
          this as AppBackupData, _$identity);

  /// Serializes this AppBackupData to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppBackupData &&
            (identical(other.bibleState, bibleState) ||
                other.bibleState == bibleState) &&
            (identical(other.songState, songState) ||
                other.songState == songState) &&
            (identical(other.faithState, faithState) ||
                other.faithState == faithState) &&
            (identical(other.settingsState, settingsState) ||
                other.settingsState == settingsState));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, bibleState, songState, faithState, settingsState);

  @override
  String toString() {
    return 'AppBackupData(bibleState: $bibleState, songState: $songState, faithState: $faithState, settingsState: $settingsState)';
  }
}

/// @nodoc
abstract mixin class $AppBackupDataCopyWith<$Res> {
  factory $AppBackupDataCopyWith(
          AppBackupData value, $Res Function(AppBackupData) _then) =
      _$AppBackupDataCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'bible_state') BibleState? bibleState,
      @JsonKey(name: 'song_state') SongState? songState,
      @JsonKey(name: 'faith_state') FaithState? faithState,
      @JsonKey(name: 'settings_state') SettingsState? settingsState});

  $BibleStateCopyWith<$Res>? get bibleState;
  $SongStateCopyWith<$Res>? get songState;
  $FaithStateCopyWith<$Res>? get faithState;
  $SettingsStateCopyWith<$Res>? get settingsState;
}

/// @nodoc
class _$AppBackupDataCopyWithImpl<$Res>
    implements $AppBackupDataCopyWith<$Res> {
  _$AppBackupDataCopyWithImpl(this._self, this._then);

  final AppBackupData _self;
  final $Res Function(AppBackupData) _then;

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bibleState = freezed,
    Object? songState = freezed,
    Object? faithState = freezed,
    Object? settingsState = freezed,
  }) {
    return _then(_self.copyWith(
      bibleState: freezed == bibleState
          ? _self.bibleState
          : bibleState // ignore: cast_nullable_to_non_nullable
              as BibleState?,
      songState: freezed == songState
          ? _self.songState
          : songState // ignore: cast_nullable_to_non_nullable
              as SongState?,
      faithState: freezed == faithState
          ? _self.faithState
          : faithState // ignore: cast_nullable_to_non_nullable
              as FaithState?,
      settingsState: freezed == settingsState
          ? _self.settingsState
          : settingsState // ignore: cast_nullable_to_non_nullable
              as SettingsState?,
    ));
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BibleStateCopyWith<$Res>? get bibleState {
    if (_self.bibleState == null) {
      return null;
    }

    return $BibleStateCopyWith<$Res>(_self.bibleState!, (value) {
      return _then(_self.copyWith(bibleState: value));
    });
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongStateCopyWith<$Res>? get songState {
    if (_self.songState == null) {
      return null;
    }

    return $SongStateCopyWith<$Res>(_self.songState!, (value) {
      return _then(_self.copyWith(songState: value));
    });
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FaithStateCopyWith<$Res>? get faithState {
    if (_self.faithState == null) {
      return null;
    }

    return $FaithStateCopyWith<$Res>(_self.faithState!, (value) {
      return _then(_self.copyWith(faithState: value));
    });
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SettingsStateCopyWith<$Res>? get settingsState {
    if (_self.settingsState == null) {
      return null;
    }

    return $SettingsStateCopyWith<$Res>(_self.settingsState!, (value) {
      return _then(_self.copyWith(settingsState: value));
    });
  }
}

/// Adds pattern-matching-related methods to [AppBackupData].
extension AppBackupDataPatterns on AppBackupData {
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
    TResult Function(_AppBackupData value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppBackupData() when $default != null:
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
    TResult Function(_AppBackupData value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppBackupData():
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
    TResult? Function(_AppBackupData value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppBackupData() when $default != null:
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
            @JsonKey(name: 'bible_state') BibleState? bibleState,
            @JsonKey(name: 'song_state') SongState? songState,
            @JsonKey(name: 'faith_state') FaithState? faithState,
            @JsonKey(name: 'settings_state') SettingsState? settingsState)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppBackupData() when $default != null:
        return $default(_that.bibleState, _that.songState, _that.faithState,
            _that.settingsState);
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
            @JsonKey(name: 'bible_state') BibleState? bibleState,
            @JsonKey(name: 'song_state') SongState? songState,
            @JsonKey(name: 'faith_state') FaithState? faithState,
            @JsonKey(name: 'settings_state') SettingsState? settingsState)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppBackupData():
        return $default(_that.bibleState, _that.songState, _that.faithState,
            _that.settingsState);
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
            @JsonKey(name: 'bible_state') BibleState? bibleState,
            @JsonKey(name: 'song_state') SongState? songState,
            @JsonKey(name: 'faith_state') FaithState? faithState,
            @JsonKey(name: 'settings_state') SettingsState? settingsState)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppBackupData() when $default != null:
        return $default(_that.bibleState, _that.songState, _that.faithState,
            _that.settingsState);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AppBackupData extends AppBackupData {
  const _AppBackupData(
      {@JsonKey(name: 'bible_state') this.bibleState,
      @JsonKey(name: 'song_state') this.songState,
      @JsonKey(name: 'faith_state') this.faithState,
      @JsonKey(name: 'settings_state') this.settingsState})
      : super._();
  factory _AppBackupData.fromJson(Map<String, dynamic> json) =>
      _$AppBackupDataFromJson(json);

  @override
  @JsonKey(name: 'bible_state')
  final BibleState? bibleState;
  @override
  @JsonKey(name: 'song_state')
  final SongState? songState;
  @override
  @JsonKey(name: 'faith_state')
  final FaithState? faithState;
  @override
  @JsonKey(name: 'settings_state')
  final SettingsState? settingsState;

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppBackupDataCopyWith<_AppBackupData> get copyWith =>
      __$AppBackupDataCopyWithImpl<_AppBackupData>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AppBackupDataToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppBackupData &&
            (identical(other.bibleState, bibleState) ||
                other.bibleState == bibleState) &&
            (identical(other.songState, songState) ||
                other.songState == songState) &&
            (identical(other.faithState, faithState) ||
                other.faithState == faithState) &&
            (identical(other.settingsState, settingsState) ||
                other.settingsState == settingsState));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, bibleState, songState, faithState, settingsState);

  @override
  String toString() {
    return 'AppBackupData(bibleState: $bibleState, songState: $songState, faithState: $faithState, settingsState: $settingsState)';
  }
}

/// @nodoc
abstract mixin class _$AppBackupDataCopyWith<$Res>
    implements $AppBackupDataCopyWith<$Res> {
  factory _$AppBackupDataCopyWith(
          _AppBackupData value, $Res Function(_AppBackupData) _then) =
      __$AppBackupDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'bible_state') BibleState? bibleState,
      @JsonKey(name: 'song_state') SongState? songState,
      @JsonKey(name: 'faith_state') FaithState? faithState,
      @JsonKey(name: 'settings_state') SettingsState? settingsState});

  @override
  $BibleStateCopyWith<$Res>? get bibleState;
  @override
  $SongStateCopyWith<$Res>? get songState;
  @override
  $FaithStateCopyWith<$Res>? get faithState;
  @override
  $SettingsStateCopyWith<$Res>? get settingsState;
}

/// @nodoc
class __$AppBackupDataCopyWithImpl<$Res>
    implements _$AppBackupDataCopyWith<$Res> {
  __$AppBackupDataCopyWithImpl(this._self, this._then);

  final _AppBackupData _self;
  final $Res Function(_AppBackupData) _then;

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bibleState = freezed,
    Object? songState = freezed,
    Object? faithState = freezed,
    Object? settingsState = freezed,
  }) {
    return _then(_AppBackupData(
      bibleState: freezed == bibleState
          ? _self.bibleState
          : bibleState // ignore: cast_nullable_to_non_nullable
              as BibleState?,
      songState: freezed == songState
          ? _self.songState
          : songState // ignore: cast_nullable_to_non_nullable
              as SongState?,
      faithState: freezed == faithState
          ? _self.faithState
          : faithState // ignore: cast_nullable_to_non_nullable
              as FaithState?,
      settingsState: freezed == settingsState
          ? _self.settingsState
          : settingsState // ignore: cast_nullable_to_non_nullable
              as SettingsState?,
    ));
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BibleStateCopyWith<$Res>? get bibleState {
    if (_self.bibleState == null) {
      return null;
    }

    return $BibleStateCopyWith<$Res>(_self.bibleState!, (value) {
      return _then(_self.copyWith(bibleState: value));
    });
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SongStateCopyWith<$Res>? get songState {
    if (_self.songState == null) {
      return null;
    }

    return $SongStateCopyWith<$Res>(_self.songState!, (value) {
      return _then(_self.copyWith(songState: value));
    });
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FaithStateCopyWith<$Res>? get faithState {
    if (_self.faithState == null) {
      return null;
    }

    return $FaithStateCopyWith<$Res>(_self.faithState!, (value) {
      return _then(_self.copyWith(faithState: value));
    });
  }

  /// Create a copy of AppBackupData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SettingsStateCopyWith<$Res>? get settingsState {
    if (_self.settingsState == null) {
      return null;
    }

    return $SettingsStateCopyWith<$Res>(_self.settingsState!, (value) {
      return _then(_self.copyWith(settingsState: value));
    });
  }
}

// dart format on
