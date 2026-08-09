import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/services/auth_token_store.dart';
import '../../../data/utilities/app_config_store.dart';
import '../../../domain/entity/config_literature/config_literature_entity.dart';
import '../../../domain/repository/account_repository.dart';
import 'dashboard_state.dart';

export 'dashboard_state.dart';

class DashboardCubit extends HydratedCubit<DashboardState> {
  final AccountRepository accountRepository;
  final AuthTokenStore authTokenStore;

  DashboardCubit(this.accountRepository, this.authTokenStore)
      : super(const DashboardState()) {
    unawaited(initConfig());
    unawaited(_restoreSecureAuth());
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('[DashboardCubit] $message');
  }

  Future<void> loginSuccessCallback(String? token) async {
    final normalized = token?.trim() ?? '';
    if (normalized.isEmpty) {
      await authTokenStore.clear();
      emit(state.copyWith(idToken: null, account: null));
      _debug('Authentication state cleared');
      return;
    }

    await authTokenStore.write(normalized);
    emit(state.copyWith(idToken: normalized));
    _debug('Authentication state updated: signedIn=true');
    await getProfile(normalized);
  }

  Future<void> getProfile(String token) async {
    _debug('Refreshing account profile');
    final response = await accountRepository.getProfile(token);
    await response.fold(
      (failure) async {
        _debug('Profile refresh failed; clearing invalid session');
        await authTokenStore.clear();
        emit(state.copyWith(idToken: null, account: null));
      },
      (res) async {
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
      _debug('setConfigLiterature failed: ${e.runtimeType}');
    }
  }

  Future<void> initConfig() async {
    try {
      await setConfigLiterature();
    } catch (e) {
      _debug('initConfig failed: ${e.runtimeType}');
    }
  }

  Future<void> _restoreSecureAuth() async {
    try {
      final token = await authTokenStore.read();
      if (token == null || token.isEmpty || isClosed) return;
      emit(state.copyWith(idToken: token));
      await getProfile(token);
    } catch (error) {
      _debug('Secure authentication restore failed (${error.runtimeType})');
      if (!isClosed) emit(state.copyWith(idToken: null, account: null));
    }
  }

  @override
  DashboardState? fromJson(Map<String, dynamic> json) {
    // Migrate old HydratedBloc snapshots without ever restoring credentials or
    // account PII from general-purpose application storage. Authentication is
    // restored exclusively through [AuthTokenStore].
    final sanitized = Map<String, dynamic>.from(json)
      ..remove('idToken')
      ..remove('account')
      ..remove('ftpPassword')
      ..remove('ftpUsername');
    return DashboardState.fromJson(sanitized);
  }

  @override
  Map<String, dynamic>? toJson(DashboardState state) {
    final json = Map<String, dynamic>.from(state.toJson())
      ..remove('idToken')
      ..remove('account')
      ..remove('ftpPassword')
      ..remove('ftpUsername');
    return json;
  }
}
