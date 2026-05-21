import 'dart:developer';

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
  }

  Future<void> loginSuccessCallback(String? token) async {
    emit(state.copyWith(idToken: token));
    if (token != null) {
      await getProfile(token);
    } else {
      emit(state.copyWith(account: null));
    }
  }

  Future<void> getProfile(String token) async {
    final response = await accountRepository.getProfile(token);
    response.fold(
      (failure) {
        emit(state.copyWith(idToken: null, account: null));
      },
      (res) {
        emit(state.copyWith(account: res));
      },
    );
  }

  Future<void> setConfigLiterature() async {
    try {
      final json = await AppConfigStore.jsonConfig('config_literature');
      emit(state.copyWith(configLiterature: ConfigLiterature.fromJson(json)));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> initConfig() async {
    try {
      await setConfigLiterature();
    } catch (e) {
      log(e.toString());
    }
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
