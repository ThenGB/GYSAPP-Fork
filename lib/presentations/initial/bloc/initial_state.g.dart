// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_InitialState _$$_InitialStateFromJson(Map<String, dynamic> json) =>
    _$_InitialState(
      isLoading: json['isLoading'] as bool? ?? false,
      isLoaded: json['isLoaded'] as bool? ?? false,
      isFailed: json['isFailed'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      isFreshInstall: json['isFreshInstall'] as bool? ?? true,
    );

Map<String, dynamic> _$$_InitialStateToJson(_$_InitialState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isLoaded': instance.isLoaded,
      'isFailed': instance.isFailed,
      'message': instance.message,
      'isFreshInstall': instance.isFreshInstall,
    };
