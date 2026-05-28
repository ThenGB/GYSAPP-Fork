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

  Future<void> loginSuccessCallback(String? token) async {
    final short = token != null ? '${token.substring(0, token.length.clamp(0, 40))}...' : 'null';
    debugPrint('[DashboardCubit] loginSuccessCallback token=$short');
    final newState = state.copyWith(idToken: token);
    debugPrint('[DashboardCubit] idToken ${state.idToken != null} -> ${newState.idToken != null}');
    emit(newState);
    debugPrint('[DashboardCubit] state.isLoggedIn after emit: ${state.isLoggedIn}');
    if (token != null) {
      await getProfile(token);
    } else {
      emit(state.copyWith(account: null));
    }
  }

  Future<void> getProfile(String token) async {
    final short = token.substring(0, token.length.clamp(0, 40));
    debugPrint('[DashboardCubit] getProfile called with token=$short...');
    final response = await accountRepository.getProfile(token);
    response.fold(
      (failure) {
        debugPrint('[DashboardCubit] getProfile FAILED: $failure');
        emit(state.copyWith(idToken: null, account: null));
      },
      (res) {
        debugPrint('[DashboardCubit] getProfile SUCCESS: account=${res.name}');
        emit(state.copyWith(account: res));
      },
    );
  }

  Future<void> setConfigLiterature() async {
    try {
      final json = await AppConfigStore.jsonConfig('config_literature');
      emit(state.copyWith(configLiterature: ConfigLiterature.fromJson(json)));
    } catch (e) {
      debugPrint('[DashboardCubit] setConfigLiterature error: $e');
    }
  }

  Future<void> initConfig() async {
    try {
      await setConfigLiterature();
    } catch (e) {
      debugPrint('[DashboardCubit] initConfig error: $e');
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
