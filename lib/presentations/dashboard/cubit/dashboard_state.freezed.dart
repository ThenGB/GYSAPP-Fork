// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DashboardState {
  bool get isLoading;
  String? get ftpHost;
  String? get ftpPort;
  String? get ftpUsername;
  String? get ftpPassword;
  String? get biblePath;
  bool get isError;
  bool get isSyncing;
  Map<String, DateTime> get lastSync;
  String? get message;
  ConfigLiterature get configLiterature;
  String? get idToken;
  Account? get account;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DashboardStateCopyWith<DashboardState> get copyWith =>
      _$DashboardStateCopyWithImpl<DashboardState>(
          this as DashboardState, _$identity);

  /// Serializes this DashboardState to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DashboardState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.ftpHost, ftpHost) || other.ftpHost == ftpHost) &&
            (identical(other.ftpPort, ftpPort) || other.ftpPort == ftpPort) &&
            (identical(other.ftpUsername, ftpUsername) ||
                other.ftpUsername == ftpUsername) &&
            (identical(other.ftpPassword, ftpPassword) ||
                other.ftpPassword == ftpPassword) &&
            (identical(other.biblePath, biblePath) ||
                other.biblePath == biblePath) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            const DeepCollectionEquality().equals(other.lastSync, lastSync) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.configLiterature, configLiterature) ||
                other.configLiterature == configLiterature) &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.account, account) || other.account == account));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      ftpHost,
      ftpPort,
      ftpUsername,
      ftpPassword,
      biblePath,
      isError,
      isSyncing,
      const DeepCollectionEquality().hash(lastSync),
      message,
      configLiterature,
      idToken,
      account);

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, ftpHost: $ftpHost, ftpPort: $ftpPort, ftpUsername: $ftpUsername, ftpPassword: $ftpPassword, biblePath: $biblePath, isError: $isError, isSyncing: $isSyncing, lastSync: $lastSync, message: $message, configLiterature: $configLiterature, idToken: $idToken, account: $account)';
  }
}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res> {
  factory $DashboardStateCopyWith(
          DashboardState value, $Res Function(DashboardState) _then) =
      _$DashboardStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? ftpHost,
      String? ftpPort,
      String? ftpUsername,
      String? ftpPassword,
      String? biblePath,
      bool isError,
      bool isSyncing,
      Map<String, DateTime> lastSync,
      String? message,
      ConfigLiterature configLiterature,
      String? idToken,
      Account? account});

  $ConfigLiteratureCopyWith<$Res> get configLiterature;
  $AccountCopyWith<$Res>? get account;
}

/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? ftpHost = freezed,
    Object? ftpPort = freezed,
    Object? ftpUsername = freezed,
    Object? ftpPassword = freezed,
    Object? biblePath = freezed,
    Object? isError = null,
    Object? isSyncing = null,
    Object? lastSync = null,
    Object? message = freezed,
    Object? configLiterature = null,
    Object? idToken = freezed,
    Object? account = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      ftpHost: freezed == ftpHost
          ? _self.ftpHost
          : ftpHost // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPort: freezed == ftpPort
          ? _self.ftpPort
          : ftpPort // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpUsername: freezed == ftpUsername
          ? _self.ftpUsername
          : ftpUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPassword: freezed == ftpPassword
          ? _self.ftpPassword
          : ftpPassword // ignore: cast_nullable_to_non_nullable
              as String?,
      biblePath: freezed == biblePath
          ? _self.biblePath
          : biblePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isError: null == isError
          ? _self.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _self.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSync: null == lastSync
          ? _self.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      configLiterature: null == configLiterature
          ? _self.configLiterature
          : configLiterature // ignore: cast_nullable_to_non_nullable
              as ConfigLiterature,
      idToken: freezed == idToken
          ? _self.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      account: freezed == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as Account?,
    ));
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConfigLiteratureCopyWith<$Res> get configLiterature {
    return $ConfigLiteratureCopyWith<$Res>(_self.configLiterature, (value) {
      return _then(_self.copyWith(configLiterature: value));
    });
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountCopyWith<$Res>? get account {
    if (_self.account == null) {
      return null;
    }

    return $AccountCopyWith<$Res>(_self.account!, (value) {
      return _then(_self.copyWith(account: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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
    TResult Function(_DashboardState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
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
    TResult Function(_DashboardState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState():
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
    TResult? Function(_DashboardState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
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
            String? ftpHost,
            String? ftpPort,
            String? ftpUsername,
            String? ftpPassword,
            String? biblePath,
            bool isError,
            bool isSyncing,
            Map<String, DateTime> lastSync,
            String? message,
            ConfigLiterature configLiterature,
            String? idToken,
            Account? account)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
        return $default(
            _that.isLoading,
            _that.ftpHost,
            _that.ftpPort,
            _that.ftpUsername,
            _that.ftpPassword,
            _that.biblePath,
            _that.isError,
            _that.isSyncing,
            _that.lastSync,
            _that.message,
            _that.configLiterature,
            _that.idToken,
            _that.account);
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
            String? ftpHost,
            String? ftpPort,
            String? ftpUsername,
            String? ftpPassword,
            String? biblePath,
            bool isError,
            bool isSyncing,
            Map<String, DateTime> lastSync,
            String? message,
            ConfigLiterature configLiterature,
            String? idToken,
            Account? account)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState():
        return $default(
            _that.isLoading,
            _that.ftpHost,
            _that.ftpPort,
            _that.ftpUsername,
            _that.ftpPassword,
            _that.biblePath,
            _that.isError,
            _that.isSyncing,
            _that.lastSync,
            _that.message,
            _that.configLiterature,
            _that.idToken,
            _that.account);
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
            String? ftpHost,
            String? ftpPort,
            String? ftpUsername,
            String? ftpPassword,
            String? biblePath,
            bool isError,
            bool isSyncing,
            Map<String, DateTime> lastSync,
            String? message,
            ConfigLiterature configLiterature,
            String? idToken,
            Account? account)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DashboardState() when $default != null:
        return $default(
            _that.isLoading,
            _that.ftpHost,
            _that.ftpPort,
            _that.ftpUsername,
            _that.ftpPassword,
            _that.biblePath,
            _that.isError,
            _that.isSyncing,
            _that.lastSync,
            _that.message,
            _that.configLiterature,
            _that.idToken,
            _that.account);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DashboardState extends DashboardState {
  const _DashboardState(
      {this.isLoading = false,
      this.ftpHost,
      this.ftpPort,
      this.ftpUsername,
      this.ftpPassword,
      this.biblePath,
      this.isError = false,
      this.isSyncing = false,
      final Map<String, DateTime> lastSync = const {},
      this.message,
      this.configLiterature = const ConfigLiterature(),
      this.idToken,
      this.account})
      : _lastSync = lastSync,
        super._();
  factory _DashboardState.fromJson(Map<String, dynamic> json) =>
      _$DashboardStateFromJson(json);

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? ftpHost;
  @override
  final String? ftpPort;
  @override
  final String? ftpUsername;
  @override
  final String? ftpPassword;
  @override
  final String? biblePath;
  @override
  @JsonKey()
  final bool isError;
  @override
  @JsonKey()
  final bool isSyncing;
  final Map<String, DateTime> _lastSync;
  @override
  @JsonKey()
  Map<String, DateTime> get lastSync {
    if (_lastSync is EqualUnmodifiableMapView) return _lastSync;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_lastSync);
  }

  @override
  final String? message;
  @override
  @JsonKey()
  final ConfigLiterature configLiterature;
  @override
  final String? idToken;
  @override
  final Account? account;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DashboardStateCopyWith<_DashboardState> get copyWith =>
      __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DashboardStateToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DashboardState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.ftpHost, ftpHost) || other.ftpHost == ftpHost) &&
            (identical(other.ftpPort, ftpPort) || other.ftpPort == ftpPort) &&
            (identical(other.ftpUsername, ftpUsername) ||
                other.ftpUsername == ftpUsername) &&
            (identical(other.ftpPassword, ftpPassword) ||
                other.ftpPassword == ftpPassword) &&
            (identical(other.biblePath, biblePath) ||
                other.biblePath == biblePath) &&
            (identical(other.isError, isError) || other.isError == isError) &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            const DeepCollectionEquality().equals(other._lastSync, _lastSync) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.configLiterature, configLiterature) ||
                other.configLiterature == configLiterature) &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.account, account) || other.account == account));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      ftpHost,
      ftpPort,
      ftpUsername,
      ftpPassword,
      biblePath,
      isError,
      isSyncing,
      const DeepCollectionEquality().hash(_lastSync),
      message,
      configLiterature,
      idToken,
      account);

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, ftpHost: $ftpHost, ftpPort: $ftpPort, ftpUsername: $ftpUsername, ftpPassword: $ftpPassword, biblePath: $biblePath, isError: $isError, isSyncing: $isSyncing, lastSync: $lastSync, message: $message, configLiterature: $configLiterature, idToken: $idToken, account: $account)';
  }
}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res>
    implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(
          _DashboardState value, $Res Function(_DashboardState) _then) =
      __$DashboardStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? ftpHost,
      String? ftpPort,
      String? ftpUsername,
      String? ftpPassword,
      String? biblePath,
      bool isError,
      bool isSyncing,
      Map<String, DateTime> lastSync,
      String? message,
      ConfigLiterature configLiterature,
      String? idToken,
      Account? account});

  @override
  $ConfigLiteratureCopyWith<$Res> get configLiterature;
  @override
  $AccountCopyWith<$Res>? get account;
}

/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? ftpHost = freezed,
    Object? ftpPort = freezed,
    Object? ftpUsername = freezed,
    Object? ftpPassword = freezed,
    Object? biblePath = freezed,
    Object? isError = null,
    Object? isSyncing = null,
    Object? lastSync = null,
    Object? message = freezed,
    Object? configLiterature = null,
    Object? idToken = freezed,
    Object? account = freezed,
  }) {
    return _then(_DashboardState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      ftpHost: freezed == ftpHost
          ? _self.ftpHost
          : ftpHost // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPort: freezed == ftpPort
          ? _self.ftpPort
          : ftpPort // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpUsername: freezed == ftpUsername
          ? _self.ftpUsername
          : ftpUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPassword: freezed == ftpPassword
          ? _self.ftpPassword
          : ftpPassword // ignore: cast_nullable_to_non_nullable
              as String?,
      biblePath: freezed == biblePath
          ? _self.biblePath
          : biblePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isError: null == isError
          ? _self.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _self.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSync: null == lastSync
          ? _self._lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      message: freezed == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      configLiterature: null == configLiterature
          ? _self.configLiterature
          : configLiterature // ignore: cast_nullable_to_non_nullable
              as ConfigLiterature,
      idToken: freezed == idToken
          ? _self.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      account: freezed == account
          ? _self.account
          : account // ignore: cast_nullable_to_non_nullable
              as Account?,
    ));
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConfigLiteratureCopyWith<$Res> get configLiterature {
    return $ConfigLiteratureCopyWith<$Res>(_self.configLiterature, (value) {
      return _then(_self.copyWith(configLiterature: value));
    });
  }

  /// Create a copy of DashboardState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AccountCopyWith<$Res>? get account {
    if (_self.account == null) {
      return null;
    }

    return $AccountCopyWith<$Res>(_self.account!, (value) {
      return _then(_self.copyWith(account: value));
    });
  }
}

// dart format on
