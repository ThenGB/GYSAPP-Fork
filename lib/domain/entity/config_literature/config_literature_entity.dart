import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_literature_entity.freezed.dart';
part 'config_literature_entity.g.dart';

@freezed
class ConfigLiterature with _$ConfigLiterature {
  const ConfigLiterature._();
  const factory ConfigLiterature({
    @JsonKey(name: 'kesaksian')
    @Default('#posts-table-1 > tbody > tr > td > a')
    String kesaksian,
    @JsonKey(name: 'wartasejati')
    @Default('#posts-table-2 > tbody > tr > td > a')
    String wartaSejati,
    @JsonKey(name: 'panduanalkitab')
    @Default(
        'div.module.module-accordion.tb_9pdq304 > ul > li > div > div > div > table > tbody > tr > td > a')
    String panduanAlkitab,
    @JsonKey(name: 'renungan')
    @Default(
        'div.module.module-accordion.tb_1uum169 > ul > li > div > div > div > table > tbody > tr > td > a')
    String renungan,
    @JsonKey(name: 'pelitakecil')
    @Default('#posts-table-3 > tbody > tr > td > a')
    String pelitaKecil,
  }) = _ConfigLiterature;

  factory ConfigLiterature.fromJson(Map<String, dynamic> json) =>
      _$ConfigLiteratureFromJson(json);
}
