import 'package:freezed_annotation/freezed_annotation.dart';

part 'initial_state.freezed.dart';
part 'initial_state.g.dart';

@freezed
class InitialState with _$InitialState {
  const InitialState._();
  const factory InitialState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoaded,
    @Default(false) bool isFailed,
    @Default('') String message,
    @Default(true) bool isFreshInstall,
  }) = _InitialState;

  factory InitialState.fromJson(Map<String, dynamic> json) =>
      _$InitialStateFromJson(json);
}
