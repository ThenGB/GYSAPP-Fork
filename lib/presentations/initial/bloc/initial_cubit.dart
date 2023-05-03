import 'dart:developer';

import 'package:church/app.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'initial_state.dart';

export 'initial_state.dart';

class InitialCubit extends HydratedCubit<InitialState> {
  InitialCubit() : super(const InitialState()) {
    initState();
  }

  initState() async {
    log('Initiating application state');
    var result =
        (await internetChecker.isHostReachable(defaultAddress)).isSuccess;
    if (!result && state.isFreshInstall) {
      await Future.delayed(const Duration(seconds: 2));
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
