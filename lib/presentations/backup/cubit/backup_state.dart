import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/entities.dart';

part 'backup_state.freezed.dart';
part 'backup_state.g.dart';

@freezed
class BackupState with _$BackupState {
  const BackupState._();
  const factory BackupState({
    @Default(false) bool isLoading,
    @Default(false) bool isBackuping,
    @Default(false) bool isSyncing,
    double? backupProgress,
    double? syncProgress,
    @Default([]) List<String> localDataSummary,
    AppBackupData? appBackupData,
  }) = _BackupState;

  factory BackupState.fromJson(Map<String, dynamic> json) =>
      _$BackupStateFromJson(json);
}
