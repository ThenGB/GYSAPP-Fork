// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_backup_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppBackupData _$AppBackupDataFromJson(Map<String, dynamic> json) =>
    _AppBackupData(
      bibleState: json['bible_state'] == null
          ? null
          : BibleState.fromJson(json['bible_state'] as Map<String, dynamic>),
      songState: json['song_state'] == null
          ? null
          : SongState.fromJson(json['song_state'] as Map<String, dynamic>),
      faithState: json['faith_state'] == null
          ? null
          : FaithState.fromJson(json['faith_state'] as Map<String, dynamic>),
      settingsState: json['settings_state'] == null
          ? null
          : SettingsState.fromJson(
              json['settings_state'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AppBackupDataToJson(_AppBackupData instance) =>
    <String, dynamic>{
      'bible_state': instance.bibleState,
      'song_state': instance.songState,
      'faith_state': instance.faithState,
      'settings_state': instance.settingsState,
    };
