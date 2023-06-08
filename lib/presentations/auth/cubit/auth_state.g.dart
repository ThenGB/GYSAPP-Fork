// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_AuthState _$$_AuthStateFromJson(Map<String, dynamic> json) => _$_AuthState(
      idToken: json['idToken'] as String?,
      isLoading: json['isLoading'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
    );

Map<String, dynamic> _$$_AuthStateToJson(_$_AuthState instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'isLoading': instance.isLoading,
      'progress': instance.progress,
    };
