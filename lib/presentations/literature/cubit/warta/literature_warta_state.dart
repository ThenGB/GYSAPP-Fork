import 'package:church/domain/entity/warta/warta_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'literature_warta_state.freezed.dart';
part 'literature_warta_state.g.dart';

@freezed
class LiteratureWartaState with _$LiteratureWartaState {
  const LiteratureWartaState._();
  const factory LiteratureWartaState({
    @Default(false) bool isLoading,
    @Default([]) List<Warta> items,
  }) = _LiteratureWartaState;

  factory LiteratureWartaState.fromJson(Map<String, dynamic> json) =>
      _$LiteratureWartaStateFromJson(json);
}
