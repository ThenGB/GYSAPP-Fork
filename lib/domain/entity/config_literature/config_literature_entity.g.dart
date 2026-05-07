// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_literature_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConfigLiterature _$ConfigLiteratureFromJson(Map<String, dynamic> json) =>
    _ConfigLiterature(
      kesaksian: json['kesaksian'] as String? ??
          '#posts-table-1 > tbody > tr > td > a',
      wartaSejati: json['wartasejati'] as String? ??
          '#posts-table-2 > tbody > tr > td > a',
      panduanAlkitab: json['panduanalkitab'] as String? ??
          'div.module.module-accordion.tb_9pdq304 > ul > li > div > div > div > table > tbody > tr > td > a',
      renungan: json['renungan'] as String? ??
          'div.module.module-accordion.tb_1uum169 > ul > li > div > div > div > table > tbody > tr > td > a',
      pelitaKecil: json['pelitakecil'] as String? ??
          '#posts-table-3 > tbody > tr > td > a',
    );

Map<String, dynamic> _$ConfigLiteratureToJson(_ConfigLiterature instance) =>
    <String, dynamic>{
      'kesaksian': instance.kesaksian,
      'wartasejati': instance.wartaSejati,
      'panduanalkitab': instance.panduanAlkitab,
      'renungan': instance.renungan,
      'pelitakecil': instance.pelitaKecil,
    };
