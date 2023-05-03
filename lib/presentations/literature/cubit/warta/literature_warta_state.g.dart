// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_warta_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LiteratureWartaState _$$_LiteratureWartaStateFromJson(
        Map<String, dynamic> json) =>
    _$_LiteratureWartaState(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Warta.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_LiteratureWartaStateToJson(
        _$_LiteratureWartaState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
