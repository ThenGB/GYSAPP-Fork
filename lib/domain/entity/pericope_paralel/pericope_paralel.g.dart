// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pericope_paralel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PericopeParalel _$PericopeParalelFromJson(Map<String, dynamic> json) =>
    _PericopeParalel(
      id: (json['id'] as num?)?.toInt(),
      id1: (json['id1'] as num?)?.toInt(),
      id2: (json['id2'] as num?)?.toInt(),
      t: json['t'] as String?,
    );

Map<String, dynamic> _$PericopeParalelToJson(_PericopeParalel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'id1': instance.id1,
      'id2': instance.id2,
      't': instance.t,
    };
