import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../presentations/presentations.dart';

part 'app_backup_data.freezed.dart';
part 'app_backup_data.g.dart';

@freezed
class AppBackupData with _$AppBackupData {
  const AppBackupData._();
  const factory AppBackupData({
    @JsonKey(name: 'bible_state') BibleState? bibleState,
    @JsonKey(name: 'song_state') SongState? songState,
    @JsonKey(name: 'faith_state') FaithState? faithState,
    @JsonKey(name: 'settings_state') SettingsState? settingsState,
  }) = _AppBackupData;

  factory AppBackupData.fromJson(Map<String, dynamic> json) =>
      _$AppBackupDataFromJson(json);
}
