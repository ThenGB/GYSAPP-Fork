// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_kesaksian_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LiteratureKesaksianState _$$_LiteratureKesaksianStateFromJson(
        Map<String, dynamic> json) =>
    _$_LiteratureKesaksianState(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Kesaksian.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_LiteratureKesaksianStateToJson(
        _$_LiteratureKesaksianState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
