import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/entity/kesaksian/kesaksian_entity.dart';

part 'literature_kesaksian_state.freezed.dart';
part 'literature_kesaksian_state.g.dart';

@freezed
class LiteratureKesaksianState with _$LiteratureKesaksianState {
  const LiteratureKesaksianState._();
  const factory LiteratureKesaksianState({
    @Default(false) bool isLoading,
    @Default([]) List<Kesaksian> items,
  }) = _LiteratureKesaksianState;

  factory LiteratureKesaksianState.fromJson(Map<String, dynamic> json) =>
      _$LiteratureKesaksianStateFromJson(json);
}
