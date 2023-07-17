import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../app.dart';
import '../../../data/utilities/firebase_utils.dart';
import '../../../data/utilities/variables/failure.dart';
import 'initial_state.dart';

export 'initial_state.dart';

class InitialCubit extends HydratedCubit<InitialState> {
  InitialCubit() : super(const InitialState());

  getRemoteConfig() async {
    try {
      FirebaseRemoteConfig.instance.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(seconds: 10),
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
    log('Initiating application state');
    await getRemoteConfig();
    var result =
        (await internetChecker.isHostReachable(defaultAddress)).isSuccess;

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

  toggleTheme(ThemeMode themeMode, BuildContext context) {
    emit(state.copyWith(themeMode: themeMode.toThemeString));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SystemChrome.setSystemUIOverlayStyle((themeMode == ThemeMode.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark)
          .copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.transparent));
    });
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
