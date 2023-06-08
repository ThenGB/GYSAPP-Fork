// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_SettingsState _$$_SettingsStateFromJson(Map<String, dynamic> json) =>
    _$_SettingsState(
      isSabatNotificationActive:
          json['isSabatNotificationActive'] as bool? ?? false,
      isBibleReminderNotificationActive:
          json['isBibleReminderNotificationActive'] as bool? ?? false,
      bibleReminders: (json['bibleReminders'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), DateTime.parse(e as String)),
          ) ??
          const {},
    );

Map<String, dynamic> _$$_SettingsStateToJson(_$_SettingsState instance) =>
    <String, dynamic>{
      'isSabatNotificationActive': instance.isSabatNotificationActive,
      'isBibleReminderNotificationActive':
          instance.isBibleReminderNotificationActive,
      'bibleReminders': instance.bibleReminders
          .map((k, e) => MapEntry(k.toString(), e.toIso8601String())),
    };
