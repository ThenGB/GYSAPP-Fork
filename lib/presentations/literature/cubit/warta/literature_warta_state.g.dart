// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_warta_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiteratureWartaStateImpl _$$LiteratureWartaStateImplFromJson(
        Map<String, dynamic> json) =>
    _$LiteratureWartaStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Warta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LiteratureWartaStateImplToJson(
        _$LiteratureWartaStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
