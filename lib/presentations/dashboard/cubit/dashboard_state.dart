import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/account/account_entity.dart';
import '../../../domain/entity/config_literature/config_literature_entity.dart';

part 'dashboard_state.freezed.dart';
part 'dashboard_state.g.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const DashboardState._();
  const factory DashboardState({
    @Default(false) bool isLoading,
    String? ftpHost,
    String? ftpPort,
    String? ftpUsername,
    String? ftpPassword,
    String? biblePath,
    @Default(false) bool isError,
    @Default(false) bool isSyncing,
    @Default({}) Map<String, DateTime> lastSync,
    String? message,
    @Default(ConfigLiterature()) ConfigLiterature configLiterature,
    String? idToken,
    Account? account,
  }) = _DashboardState;

  bool get isLoggedIn {
    if (idToken == null || idToken!.isEmpty) return false;
    if (isSessionCookie(idToken!) && account == null) return false;
    return true;
  }

  static bool isSessionCookie(String token) =>
      token.contains('=') && token.contains(';');

  factory DashboardState.fromJson(Map<String, dynamic> json) =>
      _$DashboardStateFromJson(json);
}
