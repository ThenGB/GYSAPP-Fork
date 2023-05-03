// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'literature_renungan_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_LiteratureRenunganState _$$_LiteratureRenunganStateFromJson(
        Map<String, dynamic> json) =>
    _$_LiteratureRenunganState(
      isLoading: json['isLoading'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => Renungan.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_LiteratureRenunganStateToJson(
        _$_LiteratureRenunganState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'items': instance.items,
    };
