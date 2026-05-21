import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'auth_state.dart';

export 'auth_state.dart';

class AuthCubit extends HydratedCubit<AuthState> {
  AuthCubit() : super(const AuthState());
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
}
