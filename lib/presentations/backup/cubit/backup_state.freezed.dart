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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

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

  /// Serializes this BackupState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
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
abstract class _$$BackupStateImplCopyWith<$Res>
    implements $BackupStateCopyWith<$Res> {
  factory _$$BackupStateImplCopyWith(
          _$BackupStateImpl value, $Res Function(_$BackupStateImpl) then) =
      __$$BackupStateImplCopyWithImpl<$Res>;
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
class __$$BackupStateImplCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$BackupStateImpl>
    implements _$$BackupStateImplCopyWith<$Res> {
  __$$BackupStateImplCopyWithImpl(
      _$BackupStateImpl _value, $Res Function(_$BackupStateImpl) _then)
      : super(_value, _then);

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
    return _then(_$BackupStateImpl(
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
class _$BackupStateImpl extends _BackupState {
  const _$BackupStateImpl(
      {this.isLoading = false,
      this.isBackuping = false,
      this.isSyncing = false,
      this.backupProgress,
      this.syncProgress,
      final List<String> localDataSummary = const [],
      this.appBackupData})
      : _localDataSummary = localDataSummary,
        super._();

  factory _$BackupStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$BackupStateImplFromJson(json);

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
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BackupStateImpl &&
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

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BackupStateImplCopyWith<_$BackupStateImpl> get copyWith =>
      __$$BackupStateImplCopyWithImpl<_$BackupStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BackupStateImplToJson(
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
      final AppBackupData? appBackupData}) = _$BackupStateImpl;
  const _BackupState._() : super._();

  factory _BackupState.fromJson(Map<String, dynamic> json) =
      _$BackupStateImpl.fromJson;

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

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BackupStateImplCopyWith<_$BackupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
