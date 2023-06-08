import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'initial_state.freezed.dart';
part 'initial_state.g.dart';

@freezed
class InitialState with _$InitialState {
  const InitialState._();
  const factory InitialState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoaded,
    @Default(false) bool isFailed,
    @Default('') String message,
    @Default(true) bool isFreshInstall,
    @Default('light') String themeMode,
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
