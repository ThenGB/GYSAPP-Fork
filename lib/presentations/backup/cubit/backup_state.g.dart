// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BackupState _$BackupStateFromJson(Map<String, dynamic> json) => _BackupState(
  isLoading: json['isLoading'] as bool? ?? false,
  isBackuping: json['isBackuping'] as bool? ?? false,
  isSyncing: json['isSyncing'] as bool? ?? false,
  backupProgress: (json['backupProgress'] as num?)?.toDouble(),
  syncProgress: (json['syncProgress'] as num?)?.toDouble(),
  localDataSummary:
      (json['localDataSummary'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  appBackupData: json['appBackupData'] == null
      ? null
      : AppBackupData.fromJson(json['appBackupData'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BackupStateToJson(_BackupState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isBackuping': instance.isBackuping,
      'isSyncing': instance.isSyncing,
      'backupProgress': instance.backupProgress,
      'syncProgress': instance.syncProgress,
      'localDataSummary': instance.localDataSummary,
      'appBackupData': instance.appBackupData,
    };
