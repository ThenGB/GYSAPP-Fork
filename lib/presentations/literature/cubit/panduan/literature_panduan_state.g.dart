// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_panduan_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiteraturePanduanStateImpl _$$LiteraturePanduanStateImplFromJson(
        Map<String, dynamic> json) =>
    _$LiteraturePanduanStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Panduan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LiteraturePanduanStateImplToJson(
        _$LiteraturePanduanStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
