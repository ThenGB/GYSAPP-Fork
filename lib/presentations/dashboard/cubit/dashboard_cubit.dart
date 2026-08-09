import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/utilities/app_config_store.dart';
import '../../../domain/entity/config_literature/config_literature_entity.dart';
import '../../../domain/repository/account_repository.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

class DashboardCubit extends HydratedCubit<DashboardState> {
  final AccountRepository accountRepository;

  DashboardCubit(this.accountRepository) : super(const DashboardState()) {
    initConfig();
    _validatePersistedAuth();
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('[DashboardCubit] $message');
  }

  Future<void> loginSuccessCallback(String? token) async {
    emit(state.copyWith(idToken: token));
    _debug('Authentication state updated: signedIn=${token != null}');
    if (token != null) {
      await getProfile(token);
    } else {
      emit(state.copyWith(account: null));
    }
  }

  Future<void> getProfile(String token) async {
    _debug('Refreshing account profile');
    final response = await accountRepository.getProfile(token);
    response.fold(
      (failure) {
        _debug('Profile refresh failed');
        emit(state.copyWith(idToken: null, account: null));
      },
      (res) {
        _debug('Profile refresh succeeded');
        emit(state.copyWith(account: res));
      },
    );
  }

  Future<void> setConfigLiterature() async {
    try {
      final json = await AppConfigStore.jsonConfig('config_literature');
      emit(state.copyWith(configLiterature: ConfigLiterature.fromJson(json)));
    } catch (e) {
      _debug('setConfigLiterature failed: $e');
    }
  }

  Future<void> initConfig() async {
    try {
      await setConfigLiterature();
    } catch (e) {
      _debug('initConfig failed: $e');
    }
  }

  Future<void> _validatePersistedAuth() async {
    if (state.idToken == null || state.idToken!.isEmpty) return;
    await getProfile(state.idToken!);
  }

  @override
  DashboardState? fromJson(Map<String, dynamic> json) {
    return DashboardState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(DashboardState state) {
    return state.toJson();
  }
}
