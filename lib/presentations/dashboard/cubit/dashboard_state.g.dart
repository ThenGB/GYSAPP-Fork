// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DashboardState _$DashboardStateFromJson(Map<String, dynamic> json) =>
    _DashboardState(
      isLoading: json['isLoading'] as bool? ?? false,
      ftpHost: json['ftpHost'] as String?,
      ftpPort: json['ftpPort'] as String?,
      ftpUsername: json['ftpUsername'] as String?,
      ftpPassword: json['ftpPassword'] as String?,
      biblePath: json['biblePath'] as String?,
      isError: json['isError'] as bool? ?? false,
      isSyncing: json['isSyncing'] as bool? ?? false,
      lastSync:
          (json['lastSync'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
      message: json['message'] as String?,
      configLiterature: json['configLiterature'] == null
          ? const ConfigLiterature()
          : ConfigLiterature.fromJson(
              json['configLiterature'] as Map<String, dynamic>,
            ),
      idToken: json['idToken'] as String?,
      account: json['account'] == null
          ? null
          : Account.fromJson(json['account'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardStateToJson(
  _DashboardState instance,
) => <String, dynamic>{
  'isLoading': instance.isLoading,
  'ftpHost': instance.ftpHost,
  'ftpPort': instance.ftpPort,
  'ftpUsername': instance.ftpUsername,
  'ftpPassword': instance.ftpPassword,
  'biblePath': instance.biblePath,
  'isError': instance.isError,
  'isSyncing': instance.isSyncing,
  'lastSync': instance.lastSync.map((k, e) => MapEntry(k, e.toIso8601String())),
  'message': instance.message,
  'configLiterature': instance.configLiterature,
  'idToken': instance.idToken,
  'account': instance.account,
};
