import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/menulink/menulink_entity.dart';
import '../../../domain/entity/sauh/sauh_entity.dart';
import '../../../domain/entity/truevoice/truevoice_entity.dart';

part 'home_state.freezed.dart';
part 'home_state.g.dart';

@freezed
class HomeState with _$HomeState {
  const HomeState._();
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default([]) List<Sauh> sauhs,
    @Default([]) List<TrueVoice> trueVoices,
    @Default([]) List<Menulink> menuLinks,
    @Default(false) bool isSuaraSejatiEnabled,
    @Default(false) bool isSauhEnabled,
  }) = _HomeState;

  bool get isSauhEmpty => sauhs.isEmpty;

  factory HomeState.fromJson(Map<String, dynamic> json) =>
      _$HomeStateFromJson(json);
}
