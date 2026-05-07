// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_warta_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LiteratureWartaState _$LiteratureWartaStateFromJson(
  Map<String, dynamic> json,
) => _LiteratureWartaState(
  isLoading: json['isLoading'] as bool? ?? false,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => Warta.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$LiteratureWartaStateToJson(
  _LiteratureWartaState instance,
) => <String, dynamic>{
  'isLoading': instance.isLoading,
  'items': instance.items,
};
