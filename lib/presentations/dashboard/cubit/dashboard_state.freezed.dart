// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

DashboardState _$DashboardStateFromJson(Map<String, dynamic> json) {
  return _DashboardState.fromJson(json);
}

/// @nodoc
mixin _$DashboardState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get ftpHost => throw _privateConstructorUsedError;
  String? get ftpPort => throw _privateConstructorUsedError;
  String? get ftpUsername => throw _privateConstructorUsedError;
  String? get ftpPassword => throw _privateConstructorUsedError;
  String? get biblePath => throw _privateConstructorUsedError;
  bool get isError => throw _privateConstructorUsedError;
  bool get isSyncing => throw _privateConstructorUsedError;
  DateTime? get lastSync => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  ConfigLiterature get configLiterature => throw _privateConstructorUsedError;
  String? get idToken => throw _privateConstructorUsedError;
  Account? get account => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardStateCopyWith<DashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStateCopyWith<$Res> {
  factory $DashboardStateCopyWith(
          DashboardState value, $Res Function(DashboardState) then) =
      _$DashboardStateCopyWithImpl<$Res, DashboardState>;
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
      DateTime? lastSync,
      String? message,
      ConfigLiterature configLiterature,
      String? idToken,
      Account? account});

  $ConfigLiteratureCopyWith<$Res> get configLiterature;
  $AccountCopyWith<$Res>? get account;
}

/// @nodoc
class _$DashboardStateCopyWithImpl<$Res, $Val extends DashboardState>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    Object? lastSync = freezed,
    Object? message = freezed,
    Object? configLiterature = null,
    Object? idToken = freezed,
    Object? account = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      ftpHost: freezed == ftpHost
          ? _value.ftpHost
          : ftpHost // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPort: freezed == ftpPort
          ? _value.ftpPort
          : ftpPort // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpUsername: freezed == ftpUsername
          ? _value.ftpUsername
          : ftpUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPassword: freezed == ftpPassword
          ? _value.ftpPassword
          : ftpPassword // ignore: cast_nullable_to_non_nullable
              as String?,
      biblePath: freezed == biblePath
          ? _value.biblePath
          : biblePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSync: freezed == lastSync
          ? _value.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      configLiterature: null == configLiterature
          ? _value.configLiterature
          : configLiterature // ignore: cast_nullable_to_non_nullable
              as ConfigLiterature,
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as Account?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ConfigLiteratureCopyWith<$Res> get configLiterature {
    return $ConfigLiteratureCopyWith<$Res>(_value.configLiterature, (value) {
      return _then(_value.copyWith(configLiterature: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $AccountCopyWith<$Res>? get account {
    if (_value.account == null) {
      return null;
    }

    return $AccountCopyWith<$Res>(_value.account!, (value) {
      return _then(_value.copyWith(account: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_DashboardStateCopyWith<$Res>
    implements $DashboardStateCopyWith<$Res> {
  factory _$$_DashboardStateCopyWith(
          _$_DashboardState value, $Res Function(_$_DashboardState) then) =
      __$$_DashboardStateCopyWithImpl<$Res>;
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
      DateTime? lastSync,
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
class __$$_DashboardStateCopyWithImpl<$Res>
    extends _$DashboardStateCopyWithImpl<$Res, _$_DashboardState>
    implements _$$_DashboardStateCopyWith<$Res> {
  __$$_DashboardStateCopyWithImpl(
      _$_DashboardState _value, $Res Function(_$_DashboardState) _then)
      : super(_value, _then);

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
    Object? lastSync = freezed,
    Object? message = freezed,
    Object? configLiterature = null,
    Object? idToken = freezed,
    Object? account = freezed,
  }) {
    return _then(_$_DashboardState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      ftpHost: freezed == ftpHost
          ? _value.ftpHost
          : ftpHost // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPort: freezed == ftpPort
          ? _value.ftpPort
          : ftpPort // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpUsername: freezed == ftpUsername
          ? _value.ftpUsername
          : ftpUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      ftpPassword: freezed == ftpPassword
          ? _value.ftpPassword
          : ftpPassword // ignore: cast_nullable_to_non_nullable
              as String?,
      biblePath: freezed == biblePath
          ? _value.biblePath
          : biblePath // ignore: cast_nullable_to_non_nullable
              as String?,
      isError: null == isError
          ? _value.isError
          : isError // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSync: freezed == lastSync
          ? _value.lastSync
          : lastSync // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      configLiterature: null == configLiterature
          ? _value.configLiterature
          : configLiterature // ignore: cast_nullable_to_non_nullable
              as ConfigLiterature,
      idToken: freezed == idToken
          ? _value.idToken
          : idToken // ignore: cast_nullable_to_non_nullable
              as String?,
      account: freezed == account
          ? _value.account
          : account // ignore: cast_nullable_to_non_nullable
              as Account?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_DashboardState extends _DashboardState {
  const _$_DashboardState(
      {this.isLoading = false,
      this.ftpHost,
      this.ftpPort,
      this.ftpUsername,
      this.ftpPassword,
      this.biblePath,
      this.isError = false,
      this.isSyncing = false,
      this.lastSync,
      this.message,
      this.configLiterature = const ConfigLiterature(),
      this.idToken,
      this.account})
      : super._();

  factory _$_DashboardState.fromJson(Map<String, dynamic> json) =>
      _$$_DashboardStateFromJson(json);

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
  @override
  final DateTime? lastSync;
  @override
  final String? message;
  @override
  @JsonKey()
  final ConfigLiterature configLiterature;
  @override
  final String? idToken;
  @override
  final Account? account;

  @override
  String toString() {
    return 'DashboardState(isLoading: $isLoading, ftpHost: $ftpHost, ftpPort: $ftpPort, ftpUsername: $ftpUsername, ftpPassword: $ftpPassword, biblePath: $biblePath, isError: $isError, isSyncing: $isSyncing, lastSync: $lastSync, message: $message, configLiterature: $configLiterature, idToken: $idToken, account: $account)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_DashboardState &&
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
            (identical(other.lastSync, lastSync) ||
                other.lastSync == lastSync) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.configLiterature, configLiterature) ||
                other.configLiterature == configLiterature) &&
            (identical(other.idToken, idToken) || other.idToken == idToken) &&
            (identical(other.account, account) || other.account == account));
  }

  @JsonKey(ignore: true)
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
      lastSync,
      message,
      configLiterature,
      idToken,
      account);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_DashboardStateCopyWith<_$_DashboardState> get copyWith =>
      __$$_DashboardStateCopyWithImpl<_$_DashboardState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_DashboardStateToJson(
      this,
    );
  }
}

abstract class _DashboardState extends DashboardState {
  const factory _DashboardState(
      {final bool isLoading,
      final String? ftpHost,
      final String? ftpPort,
      final String? ftpUsername,
      final String? ftpPassword,
      final String? biblePath,
      final bool isError,
      final bool isSyncing,
      final DateTime? lastSync,
      final String? message,
      final ConfigLiterature configLiterature,
      final String? idToken,
      final Account? account}) = _$_DashboardState;
  const _DashboardState._() : super._();

  factory _DashboardState.fromJson(Map<String, dynamic> json) =
      _$_DashboardState.fromJson;

  @override
  bool get isLoading;
  @override
  String? get ftpHost;
  @override
  String? get ftpPort;
  @override
  String? get ftpUsername;
  @override
  String? get ftpPassword;
  @override
  String? get biblePath;
  @override
  bool get isError;
  @override
  bool get isSyncing;
  @override
  DateTime? get lastSync;
  @override
  String? get message;
  @override
  ConfigLiterature get configLiterature;
  @override
  String? get idToken;
  @override
  Account? get account;
  @override
  @JsonKey(ignore: true)
  _$$_DashboardStateCopyWith<_$_DashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}
