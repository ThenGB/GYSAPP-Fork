// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeState _$HomeStateFromJson(Map<String, dynamic> json) => _HomeState(
  isLoading: json['isLoading'] as bool? ?? false,
  sauhs:
      (json['sauhs'] as List<dynamic>?)
          ?.map((e) => Sauh.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  trueVoices:
      (json['trueVoices'] as List<dynamic>?)
          ?.map((e) => TrueVoice.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  menuLinks:
      (json['menuLinks'] as List<dynamic>?)
          ?.map((e) => Menulink.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  isSuaraSejatiEnabled: json['isSuaraSejatiEnabled'] as bool? ?? false,
  isSauhEnabled: json['isSauhEnabled'] as bool? ?? false,
);

Map<String, dynamic> _$HomeStateToJson(_HomeState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'sauhs': instance.sauhs,
      'trueVoices': instance.trueVoices,
      'menuLinks': instance.menuLinks,
      'isSuaraSejatiEnabled': instance.isSuaraSejatiEnabled,
      'isSauhEnabled': instance.isSauhEnabled,
    };
