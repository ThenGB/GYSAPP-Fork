// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthState _$AuthStateFromJson(Map<String, dynamic> json) => _AuthState(
      idToken: json['idToken'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$AuthStateToJson(_AuthState instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'isLoading': instance.isLoading,
      'progress': instance.progress,
    };
