// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bible_ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BibleRef _$BibleRefFromJson(Map<String, dynamic> json) => _BibleRef(
  id: (json['id'] as num?)?.toInt(),
  sv: (json['sv'] as num?)?.toInt(),
  ev: (json['ev'] as num?)?.toInt(),
);

Map<String, dynamic> _$BibleRefToJson(_BibleRef instance) => <String, dynamic>{
  'id': instance.id,
  'sv': instance.sv,
  'ev': instance.ev,
};
