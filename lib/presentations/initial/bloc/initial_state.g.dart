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
      themeMode: json['themeMode'] as String? ?? 'light',
      configFetchTimeoutSeconds: json['configFetchTimeoutSeconds'] as int? ?? 5,
      configFetchIntervalSeconds:
          json['configFetchIntervalSeconds'] as int? ?? 10,
      defaultTextScale: (json['defaultTextScale'] as num?)?.toDouble() ?? 1.2,
      defaultFont: json['defaultFont'] as String? ?? 'Roboto',
    );

Map<String, dynamic> _$$_InitialStateToJson(_$_InitialState instance) =>
    <String, dynamic>{
      'isLoading': instance.isLoading,
      'isLoaded': instance.isLoaded,
      'isFailed': instance.isFailed,
      'message': instance.message,
      'isFreshInstall': instance.isFreshInstall,
      'themeMode': instance.themeMode,
      'configFetchTimeoutSeconds': instance.configFetchTimeoutSeconds,
      'configFetchIntervalSeconds': instance.configFetchIntervalSeconds,
      'defaultTextScale': instance.defaultTextScale,
      'defaultFont': instance.defaultFont,
    };
