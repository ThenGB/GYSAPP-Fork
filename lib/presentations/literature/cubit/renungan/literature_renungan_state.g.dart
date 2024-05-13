// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_renungan_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiteratureRenunganStateImpl _$$LiteratureRenunganStateImplFromJson(
        Map<String, dynamic> json) =>
    _$LiteratureRenunganStateImpl(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Renungan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LiteratureRenunganStateImplToJson(
        _$LiteratureRenunganStateImpl instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
