// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsStateImpl _$$SettingsStateImplFromJson(Map<String, dynamic> json) =>
    _$SettingsStateImpl(
      isSabatNotificationActive:
          json['isSabatNotificationActive'] as bool? ?? false,
      isBibleReminderNotificationActive:
          json['isBibleReminderNotificationActive'] as bool? ?? false,
      bibleReminders: (json['bibleReminders'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(int.parse(k), DateTime.parse(e as String)),
          ) ??
          const {},
    );

Map<String, dynamic> _$$SettingsStateImplToJson(_$SettingsStateImpl instance) =>
    <String, dynamic>{
      'isSabatNotificationActive': instance.isSabatNotificationActive,
      'isBibleReminderNotificationActive':
          instance.isBibleReminderNotificationActive,
      'bibleReminders': instance.bibleReminders
          .map((k, e) => MapEntry(k.toString(), e.toIso8601String())),
    };
