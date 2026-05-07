// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_panduan_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiteraturePanduanState _$LiteraturePanduanStateFromJson(
  Map<String, dynamic> json,
) => _LiteraturePanduanState(
  isLoading: json['isLoading'] as bool? ?? false,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Panduan.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LiteraturePanduanStateToJson(
  _LiteraturePanduanState instance,
) => <String, dynamic>{
  'isLoading': instance.isLoading,
  'items': instance.items,
};
