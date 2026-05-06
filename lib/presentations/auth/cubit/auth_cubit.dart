import 'dart:convert';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../data/utilities/variables/constants.dart';
import '../../../domain/repository/auth_repository.dart';
import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit(this.authRepository) : super(const AuthState());
  final AuthRepository authRepository;
  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return AuthState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state.toJson();
  }

  Future<void> toggleLoading(bool value) async {
    if (!value) {
      await Future.delayed(Duration(seconds: 2));
    }
    emit(state.copyWith(isLoading: value));
  }

  void onProgress(int value) {
    emit(state.copyWith(progress: value));
  }

  Future<void> onGoogleLogin(
      InAppWebViewController controller, String cmd) async {
    FlutterAppAuth appAuth = const FlutterAppAuth();
    final response = await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(clientID(), redirectUrl(),
          issuer: googleIssuer,
          serviceConfiguration: const AuthorizationServiceConfiguration(
              authorizationEndpoint:
                  'https://accounts.google.com/o/oauth2/auth',
              tokenEndpoint: 'https://oauth2.googleapis.com/token'),
          scopes: [
            'https://www.googleapis.com/auth/userinfo.email',
            'https://www.googleapis.com/auth/userinfo.profile'
          ]),
    );
    emit(state.copyWith(idToken: response.idToken));
    if (response.idToken?.isNotEmpty == true) {
      var data = jsonEncode({
        '__action': cmd,
        'credential': response.idToken,
      });
      controller.evaluateJavascript(source: 'onCallbackGIS($data)');
    }
  }
}
