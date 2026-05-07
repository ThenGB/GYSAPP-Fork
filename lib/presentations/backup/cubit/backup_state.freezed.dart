// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BackupState {
  bool get isLoading;
  bool get isBackuping;
  bool get isSyncing;
  double? get backupProgress;
  double? get syncProgress;
  List<String> get localDataSummary;
  AppBackupData? get appBackupData;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BackupStateCopyWith<BackupState> get copyWith =>
      _$BackupStateCopyWithImpl<BackupState>(this as BackupState, _$identity);

  /// Serializes this BackupState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BackupState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isBackuping, isBackuping) ||
                other.isBackuping == isBackuping) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.backupProgress, backupProgress) ||
                other.backupProgress == backupProgress) &&
            (identical(other.syncProgress, syncProgress) ||
                other.syncProgress == syncProgress) &&
            const DeepCollectionEquality()
                .equals(other.localDataSummary, localDataSummary) &&
            (identical(other.appBackupData, appBackupData) ||
                other.appBackupData == appBackupData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isBackuping,
      isSyncing,
      backupProgress,
      syncProgress,
      const DeepCollectionEquality().hash(localDataSummary),
      appBackupData);

  @override
  String toString() {
    return 'BackupState(isLoading: $isLoading, isBackuping: $isBackuping, isSyncing: $isSyncing, backupProgress: $backupProgress, syncProgress: $syncProgress, localDataSummary: $localDataSummary, appBackupData: $appBackupData)';
  }
}

/// @nodoc
abstract mixin class $BackupStateCopyWith<$Res> {
  factory $BackupStateCopyWith(
          BackupState value, $Res Function(BackupState) _then) =
      _$BackupStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      bool isBackuping,
      bool isSyncing,
      double? backupProgress,
      double? syncProgress,
      List<String> localDataSummary,
      AppBackupData? appBackupData});

  $AppBackupDataCopyWith<$Res>? get appBackupData;
}

/// @nodoc
class _$BackupStateCopyWithImpl<$Res> implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._self, this._then);

  final BackupState _self;
  final $Res Function(BackupState) _then;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isBackuping = null,
    Object? isSyncing = null,
    Object? backupProgress = freezed,
    Object? syncProgress = freezed,
    Object? localDataSummary = null,
    Object? appBackupData = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isBackuping: null == isBackuping
          ? _self.isBackuping
          : isBackuping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _self.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      backupProgress: freezed == backupProgress
          ? _self.backupProgress
          : backupProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      syncProgress: freezed == syncProgress
          ? _self.syncProgress
          : syncProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      localDataSummary: null == localDataSummary
          ? _self.localDataSummary
          : localDataSummary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      appBackupData: freezed == appBackupData
          ? _self.appBackupData
          : appBackupData // ignore: cast_nullable_to_non_nullable
              as AppBackupData?,
    ));
  }

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppBackupDataCopyWith<$Res>? get appBackupData {
    if (_self.appBackupData == null) {
      return null;
    }

    return $AppBackupDataCopyWith<$Res>(_self.appBackupData!, (value) {
      return _then(_self.copyWith(appBackupData: value));
    });
  }
}

/// Adds pattern-matching-related methods to [BackupState].
extension BackupStatePatterns on BackupState {
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
    TResult Function(_BackupState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BackupState() when $default != null:
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
    TResult Function(_BackupState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupState():
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
    TResult? Function(_BackupState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupState() when $default != null:
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
            bool isLoading,
            bool isBackuping,
            bool isSyncing,
            double? backupProgress,
            double? syncProgress,
            List<String> localDataSummary,
            AppBackupData? appBackupData)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BackupState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isBackuping,
            _that.isSyncing,
            _that.backupProgress,
            _that.syncProgress,
            _that.localDataSummary,
            _that.appBackupData);
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
            bool isLoading,
            bool isBackuping,
            bool isSyncing,
            double? backupProgress,
            double? syncProgress,
            List<String> localDataSummary,
            AppBackupData? appBackupData)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupState():
        return $default(
            _that.isLoading,
            _that.isBackuping,
            _that.isSyncing,
            _that.backupProgress,
            _that.syncProgress,
            _that.localDataSummary,
            _that.appBackupData);
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
            bool isLoading,
            bool isBackuping,
            bool isSyncing,
            double? backupProgress,
            double? syncProgress,
            List<String> localDataSummary,
            AppBackupData? appBackupData)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BackupState() when $default != null:
        return $default(
            _that.isLoading,
            _that.isBackuping,
            _that.isSyncing,
            _that.backupProgress,
            _that.syncProgress,
            _that.localDataSummary,
            _that.appBackupData);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _BackupState extends BackupState {
  const _BackupState(
      {this.isLoading = false,
      this.isBackuping = false,
      this.isSyncing = false,
      this.backupProgress,
      this.syncProgress,
      final List<String> localDataSummary = const [],
      this.appBackupData})
      : _localDataSummary = localDataSummary,
        super._();
  factory _BackupState.fromJson(Map<String, dynamic> json) =>
      _$BackupStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isBackuping;
  @override
  @JsonKey()
  final bool isSyncing;
  @override
  final double? backupProgress;
  @override
  final double? syncProgress;
  final List<String> _localDataSummary;
  @override
  @JsonKey()
  List<String> get localDataSummary {
    if (_localDataSummary is EqualUnmodifiableListView)
      return _localDataSummary;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_localDataSummary);
  }

  @override
  final AppBackupData? appBackupData;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BackupStateCopyWith<_BackupState> get copyWith =>
      __$BackupStateCopyWithImpl<_BackupState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$BackupStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BackupState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isBackuping, isBackuping) ||
                other.isBackuping == isBackuping) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.backupProgress, backupProgress) ||
                other.backupProgress == backupProgress) &&
            (identical(other.syncProgress, syncProgress) ||
                other.syncProgress == syncProgress) &&
            const DeepCollectionEquality()
                .equals(other._localDataSummary, _localDataSummary) &&
            (identical(other.appBackupData, appBackupData) ||
                other.appBackupData == appBackupData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isBackuping,
      isSyncing,
      backupProgress,
      syncProgress,
      const DeepCollectionEquality().hash(_localDataSummary),
      appBackupData);

  @override
  String toString() {
    return 'BackupState(isLoading: $isLoading, isBackuping: $isBackuping, isSyncing: $isSyncing, backupProgress: $backupProgress, syncProgress: $syncProgress, localDataSummary: $localDataSummary, appBackupData: $appBackupData)';
  }
}

/// @nodoc
abstract mixin class _$BackupStateCopyWith<$Res>
    implements $BackupStateCopyWith<$Res> {
  factory _$BackupStateCopyWith(
          _BackupState value, $Res Function(_BackupState) _then) =
      __$BackupStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isBackuping,
      bool isSyncing,
      double? backupProgress,
      double? syncProgress,
      List<String> localDataSummary,
      AppBackupData? appBackupData});

  @override
  $AppBackupDataCopyWith<$Res>? get appBackupData;
}

/// @nodoc
class __$BackupStateCopyWithImpl<$Res> implements _$BackupStateCopyWith<$Res> {
  __$BackupStateCopyWithImpl(this._self, this._then);

  final _BackupState _self;
  final $Res Function(_BackupState) _then;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isBackuping = null,
    Object? isSyncing = null,
    Object? backupProgress = freezed,
    Object? syncProgress = freezed,
    Object? localDataSummary = null,
    Object? appBackupData = freezed,
  }) {
    return _then(_BackupState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isBackuping: null == isBackuping
          ? _self.isBackuping
          : isBackuping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _self.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      backupProgress: freezed == backupProgress
          ? _self.backupProgress
          : backupProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      syncProgress: freezed == syncProgress
          ? _self.syncProgress
          : syncProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      localDataSummary: null == localDataSummary
          ? _self._localDataSummary
          : localDataSummary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      appBackupData: freezed == appBackupData
          ? _self.appBackupData
          : appBackupData // ignore: cast_nullable_to_non_nullable
              as AppBackupData?,
    ));
  }

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppBackupDataCopyWith<$Res>? get appBackupData {
    if (_self.appBackupData == null) {
      return null;
    }

    return $AppBackupDataCopyWith<$Res>(_self.appBackupData!, (value) {
      return _then(_self.copyWith(appBackupData: value));
    });
  }
}

// dart format on
