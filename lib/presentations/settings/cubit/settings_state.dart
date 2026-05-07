import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
abstract class SettingsState with _$SettingsState {
  const SettingsState._();
  const factory SettingsState({
    @Default(false) bool isSabatNotificationActive,
    @Default(false) bool isBibleReminderNotificationActive,
    @Default({}) Map<int, DateTime> bibleReminders,
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, dynamic> json) =>
      _$SettingsStateFromJson(json);
}

