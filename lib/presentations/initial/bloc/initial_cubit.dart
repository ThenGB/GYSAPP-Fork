import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../app.dart';
import '../../../components/themes/app_accent.dart';
import '../../../data/models/theme_preferences.dart';
import '../../../data/repositories/theme_preferences_repository.dart';
import '../../../data/services/local_asset_service.dart';
import '../../../data/utilities/app_config_store.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../di/injection.dart';
import 'initial_state.dart';

export 'initial_state.dart';

const startupKrPreparationMessage =
    'Preparing Kidung Rohani for faster offline access...';

class InitialCubit extends HydratedCubit<InitialState> {
  InitialCubit() : super(const InitialState());

  Future<void> initState() async {
    // Startup flags are deliberately reset on every process start. A previous
    // build persisted isLoaded=true, which meant the splash listener never saw
    // a false -> true transition on the second launch and could stay forever.
    emit(
      state.copyWith(
        isLoading: true,
        isLoaded: false,
        isFailed: false,
        message: '',
      ),
    );

    // Appearance is tiny local state. Never let platform preference I/O hold
    // the splash indefinitely: HydratedBloc is the durable source after the
    // first successful launch, while SharedPreferences remains a migration /
    // compatibility copy.
    await _loadThemePreferences();
    if (isClosed) return;

    emit(
      state.copyWith(
        isFailed: false,
        isFreshInstall: false,
        isLoading: false,
        isLoaded: true,
        message: '',
      ),
    );

    // Heavy/optional work remains non-blocking after navigation.
    unawaited(_backgroundInit());
  }

  Future<void> _backgroundInit() async {
    try {
      await di.allReady();
      log('Initiating application state (background)');

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

      try {
        final assetService = di<LocalAssetService>();
        if (await assetService.needsPdfPreparation('KR', '001')) {
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

      try {
        final configFetchPolicy = await AppConfigStore.jsonConfig(
          'config_fetch_policy',
        );
        if (!isClosed) {
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
        }
      } catch (e) {
        log('Failed to load config fetch policy: $e');
      }
    } catch (e, st) {
      log(
        'Background init failed',
        name: 'InitialCubit',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _loadThemePreferences() async {
    final hydratedPreferences = state.themePreferences;
    final hydratedThemeMode = state.themeMode;
    final hydratedAccentKey = state.accentKey;
    final hasHydratedAppearance = !state.isFreshInstall;

    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.init().timeout(const Duration(seconds: 2));

      // From the second successful launch onward, HydratedBloc is the primary
      // source. This prevents a stale SharedPreferences write (for example if
      // Android killed the process immediately after a setting changed) from
      // overwriting the newer hydrated state during startup.
      if (hasHydratedAppearance) {
        unawaited(themeRepo.savePreferences(hydratedPreferences));
        unawaited(themeRepo.saveThemeMode(hydratedThemeMode));
        return;
      }

      // First launch / migration path: import an existing platform preference
      // copy if one exists, then HydratedBloc will persist it with the rest of
      // InitialState.
      final prefs = themeRepo.preferences;
      final savedThemeMode = themeRepo.themeMode;
      if (isClosed) return;
      emit(
        state.copyWith(
          themePreferences: prefs,
          accentKey: prefs.accentKey,
          themeMode: savedThemeMode,
        ),
      );
    } on TimeoutException catch (e) {
      log(
        'Theme preference load timed out; using hydrated appearance',
        name: 'InitialCubit',
        error: e,
      );
      if (!isClosed && hasHydratedAppearance) {
        emit(
          state.copyWith(
            themePreferences: hydratedPreferences,
            accentKey: hydratedAccentKey,
            themeMode: hydratedThemeMode,
          ),
        );
      }
    } catch (e) {
      log('Failed to load theme preferences', name: 'InitialCubit', error: e);
      // Keep the hydrated values instead of overwriting them with defaults.
      // This provides a second recovery path if platform preferences are
      // temporarily unavailable.
    }
  }

  void toggleTheme(ThemeMode themeMode, BuildContext Function() context) {
    final themeModeStr = themeMode.toThemeString;
    emit(state.copyWith(themeMode: themeModeStr));
    unawaited(_persistThemeMode(themeModeStr));
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

  void changeTextHeight(double newHeight) {
    emit(state.copyWith(defaultTextHeight: newHeight));
  }

  void changeFontStyle(String newValue) {
    emit(state.copyWith(defaultFont: newValue));
  }

  void changeAccentColor(String accentKey) {
    final updatedPrefs = state.themePreferences.copyWith(accentKey: accentKey);
    emit(state.copyWith(accentKey: accentKey, themePreferences: updatedPrefs));
    unawaited(_saveThemePreferences(updatedPrefs));
  }

  void changeCustomAccentColor(Color color) {
    final updatedPrefs = state.themePreferences.copyWith(
      accentKey: customAccentKey,
      customAccentSeed: color.toARGB32(),
    );
    emit(
      state.copyWith(
        accentKey: customAccentKey,
        themePreferences: updatedPrefs,
      ),
    );
    unawaited(_saveThemePreferences(updatedPrefs));
  }

  void changeDensity(DisplayDensity density) {
    final updatedPrefs = state.themePreferences.copyWith(density: density);
    emit(state.copyWith(themePreferences: updatedPrefs));
    unawaited(_saveThemePreferences(updatedPrefs));
  }

  void changeSurfaceTone(SurfaceTone tone) {
    final updatedPrefs = state.themePreferences.copyWith(surfaceTone: tone);
    emit(state.copyWith(themePreferences: updatedPrefs));
    unawaited(_saveThemePreferences(updatedPrefs));
  }

  void changeCornerRadius(CornerRadiusStyle style) {
    final updatedPrefs = state.themePreferences.copyWith(cornerRadius: style);
    emit(state.copyWith(themePreferences: updatedPrefs));
    unawaited(_saveThemePreferences(updatedPrefs));
  }

  void changeTypographyScale(TypographyScale scale) {
    final updatedPrefs = state.themePreferences.copyWith(
      typographyScale: scale,
    );
    emit(state.copyWith(themePreferences: updatedPrefs));
    unawaited(_saveThemePreferences(updatedPrefs));
  }

  Future<void> _saveThemePreferences(ThemePreferences preferences) async {
    try {
      final themeRepo = di<ThemePreferencesRepository>();
      await themeRepo.savePreferences(preferences);
    } catch (e) {
      log('Failed to save theme preferences', name: 'InitialCubit', error: e);
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

  Future<void> resetToDefaults() async {
    // The Settings screen reroutes immediately after requesting a reset and
    // does not await this Future. Apply the visible/default state first so the
    // new splash cannot momentarily inherit the old appearance while platform
    // preference keys are being removed asynchronously.
    emit(const InitialState(isLoaded: true, isFreshInstall: false));
    final themeRepo = di<ThemePreferencesRepository>();
    await themeRepo.reset();
  }

  @override
  InitialState? fromJson(Map<String, dynamic> json) {
    try {
      final restored = InitialState.fromJson(json);
      // Runtime startup status must never survive a process restart.
      return restored.copyWith(
        isLoading: false,
        isLoaded: false,
        isFailed: false,
        message: '',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(InitialState state) {
    try {
      // Keep appearance/readability preferences as a recovery copy while
      // deliberately serializing startup flags in their neutral state.
      return state
          .copyWith(
            isLoading: false,
            isLoaded: false,
            isFailed: false,
            message: '',
          )
          .toJson();
    } catch (e) {
      return null;
    }
  }
}
