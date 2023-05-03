// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_HomeState _$$_HomeStateFromJson(Map<String, dynamic> json) => _$_HomeState(
      isLoading: json['isLoading'] as bool? ?? false,
      sauhs: (json['sauhs'] as List<dynamic>?)
              ?.map((e) => Sauh.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trueVoices: (json['trueVoices'] as List<dynamic>?)
              ?.map((e) => TrueVoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      menuLinks: (json['menuLinks'] as List<dynamic>?)
              ?.map((e) => Menulink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$_HomeStateToJson(_$_HomeState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'sauhs': instance.sauhs,
      'trueVoices': instance.trueVoices,
      'menuLinks': instance.menuLinks,
    };
