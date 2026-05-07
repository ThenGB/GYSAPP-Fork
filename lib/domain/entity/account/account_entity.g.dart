// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  id: (json['id'] as num?)?.toInt() ?? 0,
  email: json['email'] as String?,
  name: json['name'] as String?,
  type: json['type'] as String?,
  mobilePhone: json['mobilephone'] as String?,
  profilePicture: json['profilepicture'] as String?,
  status: json['status'] as String?,
  branchId: (json['branchid'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
  'type': instance.type,
  'mobilephone': instance.mobilePhone,
  'profilepicture': instance.profilePicture,
  'status': instance.status,
  'branchid': instance.branchId,
};
