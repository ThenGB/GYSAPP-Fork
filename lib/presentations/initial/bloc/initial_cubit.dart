import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../app.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../data/utilities/firebase_utils.dart';
import '../../../data/utilities/variables/failure.dart';
import '../../../di/injection.dart';
import 'initial_state.dart';

export 'initial_state.dart';

class InitialCubit extends HydratedCubit<InitialState> {
  InitialCubit() : super(const InitialState());

  getRemoteConfig() async {
    try {
      FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(
              seconds: kReleaseMode ? state.configFetchTimeoutSeconds : 5),
          minimumFetchInterval: Duration(
              seconds: kReleaseMode ? state.configFetchIntervalSeconds : 1),
        ),
      );
      var isConnectedToInternet =
          (await internetChecker.isHostReachable(defaultAddress)).isSuccess;
      if (isConnectedToInternet) {
        var value = await FirebaseRemoteConfig.instance.fetchAndActivate();
        log((value).toString(), name: '[Firebase remote config]');
      }
    } catch (e) {
      log(Failure.fromError(e).message, name: 'getRemoteConfig', error: e);
    }
    FirebaseUtils.initialization.complete(FirebaseRemoteConfig.instance);
  }

  initState() async {
    await di.allReady();
    log('Initiating application state');
    await getRemoteConfig();
    var firebaseRemoteConfig =
        await FirebaseUtils.jsonConfig('firebase_remote_config');
    emit(
      state.copyWith(
        configFetchTimeoutSeconds: firebaseRemoteConfig['fetch_timeout'] ??
            state.configFetchTimeoutSeconds,
        configFetchIntervalSeconds: firebaseRemoteConfig['fetch_interval'] ??
            state.configFetchIntervalSeconds,
      ),
    );
    var result =
        (await internetChecker.isHostReachable(defaultAddress)).isSuccess;
    try {
      await FirebaseAuth.instance
          .signInAnonymously()
          .timeout(Duration(seconds: 5));
    } catch (e) {
      log('Cant log in anonymously ${e.toString()}', name: 'Firebase Auth');
    }

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
  }

  toggleTheme(ThemeMode themeMode, BuildContext Function() context) {
    emit(state.copyWith(themeMode: themeMode.toThemeString));
    Future.delayed(
      kThemeChangeDuration,
      () {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          SystemChrome.setSystemUIOverlayStyle(
              context().theme.appBarTheme.systemOverlayStyle!);
        });
      },
    );
  }

  changeTextScale(double newScale) {
    emit(state.copyWith(defaultTextScale: newScale));
  }

  changeFontStyle(String newValue) {
    emit(state.copyWith(defaultFont: newValue));
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
