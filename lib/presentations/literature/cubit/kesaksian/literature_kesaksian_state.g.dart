// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_kesaksian_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiteratureKesaksianStateImpl _$$LiteratureKesaksianStateImplFromJson(
        Map<String, dynamic> json) =>
    _$LiteratureKesaksianStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Kesaksian.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LiteratureKesaksianStateImplToJson(
        _$LiteratureKesaksianStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
