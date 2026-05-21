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
    await di.allReady();
    log('Initiating application state');
    var result = (await internetChecker.isHostReachable(
      defaultAddress,
    )).isSuccess;
    if (!result && state.isFreshInstall) {
      emit(
        state.copyWith(
          isFailed: true,
          message:
              'First time installation failed. Please connect to the internet and try again.',
          isLoading: false,
          isLoaded: false,
        ),
      );
    } else {
      final assetService = di<LocalAssetService>();
      try {
        if (await assetService.needsPdfPreparation('KR', '001')) {
          emit(
            state.copyWith(
              isFailed: false,
              isLoading: true,
              isLoaded: false,
              message: startupKrPreparationMessage,
            ),
          );
          await assetService.getPdfPath('KR', '001');
        }
      } catch (e, st) {
        log(
          'Startup KR preparation failed',
          name: 'InitialCubit',
          error: e,
          stackTrace: st,
        );
      }

      emit(
        state.copyWith(
          isFailed: false,
          message: 'Syncing...',
          isFreshInstall: false,
          isLoading: false,
          isLoaded: true,
        ),
      );
    }

    var configFetchPolicy = await AppConfigStore.jsonConfig(
      'config_fetch_policy',
    );
    emit(
      state.copyWith(
        configFetchTimeoutSeconds:
            configFetchPolicy['fetch_timeout'] ??
            state.configFetchTimeoutSeconds,
        configFetchIntervalSeconds:
            configFetchPolicy['fetch_interval'] ??
            state.configFetchIntervalSeconds,
      ),
    );

    // Load theme preferences
    await _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.init();
      final prefs = themeRepo.preferences;
      emit(state.copyWith(themePreferences: prefs));
    } catch (e) {
      log('Failed to load theme preferences', name: 'InitialCubit', error: e);
      // Fallback to defaults if loading fails
      emit(state.copyWith(themePreferences: const ThemePreferences()));
    }
  }

  void toggleTheme(ThemeMode themeMode, BuildContext Function() context) {
    emit(state.copyWith(themeMode: themeMode.toThemeString));
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
