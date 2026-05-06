import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../domain/entity/renungan/renungan_entity.dart';

part 'literature_renungan_state.freezed.dart';
part 'literature_renungan_state.g.dart';

@freezed
abstract class LiteratureRenunganState with _$LiteratureRenunganState {
  const LiteratureRenunganState._();
  const factory LiteratureRenunganState({
    @Default(false) bool isLoading,
    @Default([]) List<Renungan> items,
  }) = _LiteratureRenunganState;

  factory LiteratureRenunganState.fromJson(Map<String, dynamic> json) =>
      _$LiteratureRenunganStateFromJson(json);
}

