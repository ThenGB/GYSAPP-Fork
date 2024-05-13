// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthStateImpl _$$AuthStateImplFromJson(Map<String, dynamic> json) =>
    _$AuthStateImpl(
      idToken: json['idToken'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
    );

Map<String, dynamic> _$$AuthStateImplToJson(_$AuthStateImpl instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'isLoading': instance.isLoading,
      'progress': instance.progress,
    };
