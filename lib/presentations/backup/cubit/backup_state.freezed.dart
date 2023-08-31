// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

BackupState _$BackupStateFromJson(Map<String, dynamic> json) {
  return _BackupState.fromJson(json);
}

/// @nodoc
mixin _$BackupState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isBackuping => throw _privateConstructorUsedError;
  bool get isSyncing => throw _privateConstructorUsedError;
  double? get backupProgress => throw _privateConstructorUsedError;
  double? get syncProgress => throw _privateConstructorUsedError;
  List<String> get localDataSummary => throw _privateConstructorUsedError;
  AppBackupData? get appBackupData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BackupStateCopyWith<BackupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupStateCopyWith<$Res> {
  factory $BackupStateCopyWith(
          BackupState value, $Res Function(BackupState) then) =
      _$BackupStateCopyWithImpl<$Res, BackupState>;
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
class _$BackupStateCopyWithImpl<$Res, $Val extends BackupState>
    implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isBackuping: null == isBackuping
          ? _value.isBackuping
          : isBackuping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      backupProgress: freezed == backupProgress
          ? _value.backupProgress
          : backupProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      syncProgress: freezed == syncProgress
          ? _value.syncProgress
          : syncProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      localDataSummary: null == localDataSummary
          ? _value.localDataSummary
          : localDataSummary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      appBackupData: freezed == appBackupData
          ? _value.appBackupData
          : appBackupData // ignore: cast_nullable_to_non_nullable
              as AppBackupData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AppBackupDataCopyWith<$Res>? get appBackupData {
    if (_value.appBackupData == null) {
      return null;
    }

    return $AppBackupDataCopyWith<$Res>(_value.appBackupData!, (value) {
      return _then(_value.copyWith(appBackupData: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_BackupStateCopyWith<$Res>
    implements $BackupStateCopyWith<$Res> {
  factory _$$_BackupStateCopyWith(
          _$_BackupState value, $Res Function(_$_BackupState) then) =
      __$$_BackupStateCopyWithImpl<$Res>;
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
class __$$_BackupStateCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$_BackupState>
    implements _$$_BackupStateCopyWith<$Res> {
  __$$_BackupStateCopyWithImpl(
      _$_BackupState _value, $Res Function(_$_BackupState) _then)
      : super(_value, _then);

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
    return _then(_$_BackupState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isBackuping: null == isBackuping
          ? _value.isBackuping
          : isBackuping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSyncing: null == isSyncing
          ? _value.isSyncing
          : isSyncing // ignore: cast_nullable_to_non_nullable
              as bool,
      backupProgress: freezed == backupProgress
          ? _value.backupProgress
          : backupProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      syncProgress: freezed == syncProgress
          ? _value.syncProgress
          : syncProgress // ignore: cast_nullable_to_non_nullable
              as double?,
      localDataSummary: null == localDataSummary
          ? _value._localDataSummary
          : localDataSummary // ignore: cast_nullable_to_non_nullable
              as List<String>,
      appBackupData: freezed == appBackupData
          ? _value.appBackupData
          : appBackupData // ignore: cast_nullable_to_non_nullable
              as AppBackupData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_BackupState extends _BackupState {
  const _$_BackupState(
      {this.isLoading = false,
      this.isBackuping = false,
      this.isSyncing = false,
      this.backupProgress,
      this.syncProgress,
      final List<String> localDataSummary = const [],
      this.appBackupData})
      : _localDataSummary = localDataSummary,
        super._();

  factory _$_BackupState.fromJson(Map<String, dynamic> json) =>
      _$$_BackupStateFromJson(json);

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

  @override
  String toString() {
    return 'BackupState(isLoading: $isLoading, isBackuping: $isBackuping, isSyncing: $isSyncing, backupProgress: $backupProgress, syncProgress: $syncProgress, localDataSummary: $localDataSummary, appBackupData: $appBackupData)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_BackupState &&
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

  @JsonKey(ignore: true)
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

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_BackupStateCopyWith<_$_BackupState> get copyWith =>
      __$$_BackupStateCopyWithImpl<_$_BackupState>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_BackupStateToJson(
      this,
    );
  }
}

abstract class _BackupState extends BackupState {
  const factory _BackupState(
      {final bool isLoading,
      final bool isBackuping,
      final bool isSyncing,
      final double? backupProgress,
      final double? syncProgress,
      final List<String> localDataSummary,
      final AppBackupData? appBackupData}) = _$_BackupState;
  const _BackupState._() : super._();

  factory _BackupState.fromJson(Map<String, dynamic> json) =
      _$_BackupState.fromJson;

  @override
  bool get isLoading;
  @override
  bool get isBackuping;
  @override
  bool get isSyncing;
  @override
  double? get backupProgress;
  @override
  double? get syncProgress;
  @override
  List<String> get localDataSummary;
  @override
  AppBackupData? get appBackupData;
  @override
  @JsonKey(ignore: true)
  _$$_BackupStateCopyWith<_$_BackupState> get copyWith =>
      throw _privateConstructorUsedError;
}
