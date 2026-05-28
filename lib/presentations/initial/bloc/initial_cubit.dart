
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../app.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/app_config_store.dart';
import '../../../data/services/local_asset_service.dart';
import '../../../data/repositories/theme_preferences_repository.dart';
import '../../../data/models/theme_preferences.dart';
import '../../../di/injection.dart';
import 'initial_state.dart';

export 'initial_state.dart';

const startupKrPreparationMessage =
    'Preparing Kidung Rohani for faster offline access...';

class InitialCubit extends HydratedCubit<InitialState> {
  InitialCubit() : super(const InitialState());

  Future<void> initState() async {
    emit(state.copyWith(message: 'Initiating...'));

    // Emit loaded immediately so the app navigates to Dashboard without blocking.
    // All heavy work (internet check, PDF prep, config) happens in the background.
    emit(state.copyWith(
      isFailed: false,
      isFreshInstall: false,
      isLoading: false,
      isLoaded: true,
      message: 'Ready',
    ));

    // Background initialization — does not block the UI
    _backgroundInit();
  }

  Future<void> _backgroundInit() async {
    try {
      await di.allReady();
      log('Initiating application state (background)');

      // Internet check with timeout
      try {
        final result = await internetChecker
            .isHostReachable(defaultAddress)
            .timeout(const Duration(seconds: 8));
        if (!result.isSuccess && state.isFreshInstall) {
          log('Internet check failed on fresh install');
        }
      } catch (e) {
        log('Internet check timed out or failed: $e');
      }

      // PDF preparation
      try {
        final assetService = di<LocalAssetService>();
        if (await assetService.needsPdfPreparation('KR', '001')) {
          emit(state.copyWith(
            isLoading: false,
            message: startupKrPreparationMessage,
          ));
          await assetService.getPdfPath('KR', '001');
        }
      } catch (e, st) {
        log('Startup KR preparation failed', name: 'InitialCubit', error: e, stackTrace: st);
      }

      // Config fetch policy
      try {
        final configFetchPolicy = await AppConfigStore.jsonConfig('config_fetch_policy');
        emit(state.copyWith(
          configFetchTimeoutSeconds: configFetchPolicy['fetch_timeout'] ?? state.configFetchTimeoutSeconds,
          configFetchIntervalSeconds: configFetchPolicy['fetch_interval'] ?? state.configFetchIntervalSeconds,
        ));
      } catch (e) {
        log('Failed to load config fetch policy: $e');
      }

      // Theme preferences
      await _loadThemePreferences();
    } catch (e, st) {
      log('Background init failed', name: 'InitialCubit', error: e, stackTrace: st);
    }
  }

  Future<void> _loadThemePreferences() async {
    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.init();
      final prefs = themeRepo.preferences;
      final savedThemeMode = themeRepo.themeMode;
      log('[InitialCubit] _loadThemePreferences: accentKey=${prefs.accentKey}, themeMode=$savedThemeMode');
      emit(state.copyWith(
        themePreferences: prefs,
        accentKey: prefs.accentKey,
        themeMode: savedThemeMode,
      ));
    } catch (e) {
      log('Failed to load theme preferences', name: 'InitialCubit', error: e);
      // Fallback to defaults if loading fails
      emit(state.copyWith(themePreferences: const ThemePreferences()));
    }
  }

  void toggleTheme(ThemeMode themeMode, BuildContext Function() context) {
    final themeModeStr = themeMode.toThemeString;
    emit(state.copyWith(themeMode: themeModeStr));
    _persistThemeMode(themeModeStr);
    Future.delayed(kThemeChangeDuration, () {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        SystemChrome.setSystemUIOverlayStyle(
          context().theme.appBarTheme.systemOverlayStyle!,
        );
      });
    });
  }

  void changeTextScale(double newScale) {
    emit(state.copyWith(defaultTextScale: newScale));
  }

  void changeFontStyle(String newValue) {
    emit(state.copyWith(defaultFont: newValue));
  }

  void changeAccentColor(String accentKey) {
    emit(state.copyWith(accentKey: accentKey));
    _persistAccentKey(accentKey);
  }

  void changeDensity(DisplayDensity density) {
    final updatedPrefs = state.themePreferences.copyWith(density: density);
    emit(state.copyWith(themePreferences: updatedPrefs));
    _saveThemePreferences();
  }

  void changeCornerRadius(CornerRadiusStyle style) {
    final updatedPrefs = state.themePreferences.copyWith(cornerRadius: style);
    emit(state.copyWith(themePreferences: updatedPrefs));
    _saveThemePreferences();
  }

  void changeTypographyScale(TypographyScale scale) {
    final updatedPrefs = state.themePreferences.copyWith(typographyScale: scale);
    emit(state.copyWith(themePreferences: updatedPrefs));
    _saveThemePreferences();
  }

  Future<void> _saveThemePreferences() async {
    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.savePreferences(state.themePreferences);
    } catch (e) {
      log('Failed to save theme preferences', name: 'InitialCubit', error: e);
    }
  }

  Future<void> _persistAccentKey(String accentKey) async {
    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.updateAccentKey(accentKey);
    } catch (e) {
      log('Failed to persist accent key', name: 'InitialCubit', error: e);
    }
  }

  Future<void> _persistThemeMode(String themeMode) async {
    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.saveThemeMode(themeMode);
    } catch (e) {
      log('Failed to persist theme mode', name: 'InitialCubit', error: e);
    }
  }

  void resetToDefaults() {
    emit(const InitialState());
  }

  @override
  InitialState? fromJson(Map<String, dynamic> json) {
    try {
      return InitialState.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(InitialState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}
