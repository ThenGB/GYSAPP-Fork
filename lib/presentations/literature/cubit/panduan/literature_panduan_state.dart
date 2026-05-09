import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/entity/panduan/panduan_entity.dart';

part 'literature_panduan_state.freezed.dart';
part 'literature_panduan_state.g.dart';

@freezed
abstract class LiteraturePanduanState with _$LiteraturePanduanState {
  const LiteraturePanduanState._();
  const factory LiteraturePanduanState({
    @Default(false) bool isLoading,
    @Default([]) List<Panduan> items,
  }) = _LiteraturePanduanState;

  factory LiteraturePanduanState.fromJson(Map<String, dynamic> json) =>
      _$LiteraturePanduanStateFromJson(json);
}
