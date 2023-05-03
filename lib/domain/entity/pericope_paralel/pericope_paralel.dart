import 'package:freezed_annotation/freezed_annotation.dart';

part 'pericope_paralel.freezed.dart';
part 'pericope_paralel.g.dart';

@freezed
class PericopeParalel with _$PericopeParalel {
  const PericopeParalel._();
  const factory PericopeParalel({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'id1') int? id1,
    @JsonKey(name: 'id2') int? id2,
    @JsonKey(name: 't') String? t,
  }) = _PericopeParalel;

  factory PericopeParalel.fromJson(Map<String, dynamic> json) =>
      _$PericopeParalelFromJson(json);
}
