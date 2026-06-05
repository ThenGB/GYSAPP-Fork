import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/theme_preferences.dart';

part 'initial_state.freezed.dart';
part 'initial_state.g.dart';

@freezed
abstract class InitialState with _$InitialState {
  const InitialState._();
  const factory InitialState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoaded,
    @Default(false) bool isFailed,
    @Default('') String message,
    @Default(true) bool isFreshInstall,
    @Default('light') String themeMode,
    @Default(5) int configFetchTimeoutSeconds,
    @Default(10) int configFetchIntervalSeconds,
    @Default(1.0) double defaultTextScale,
    @Default(1.5) double defaultTextHeight,
    @Default('Roboto') String defaultFont,
    @Default('skyBlue') String accentKey,
    @Default(ThemePreferences()) ThemePreferences themePreferences,
  }) = _InitialState;

  factory InitialState.fromJson(Map<String, dynamic> json) =>
      _$InitialStateFromJson(json);
}

extension ThemeString on String {
  ThemeMode get toThemeMode {
    switch (this) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

extension ThemeToString on ThemeMode {
  String get toThemeString {
    switch (this) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
