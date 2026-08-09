import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_entity.freezed.dart';
part 'account_entity.g.dart';

@freezed
abstract class Account with _$Account {
  const Account._();

  const factory Account({
    @JsonKey(name: 'id') @Default(0) int id,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'name') String? name,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'mobilephone') String? mobilePhone,
    @JsonKey(name: 'profilepicture') String? profilePicture,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'branchid') @Default(0) int branchId,
    @JsonKey(name: 'baptized') dynamic baptized,
    @JsonKey(name: 'member_type') String? memberType,
    @JsonKey(name: 'jenis_anggota') String? jenisAnggota,
    @JsonKey(name: 'wilayah') String? wilayah,
    @JsonKey(name: 'branchname') String? branchName,
    @JsonKey(name: 'branch') String? branch,
  }) = _Account;

  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);

  /// Canonical GYS membership label used by the UI.
  ///
  /// Older and newer e-GYS payloads use different fields, so UI code should
  /// not depend on one response shape. Explicit member labels win; baptism
  /// status is the final semantic fallback.
  String? get resolvedMemberType {
    for (final candidate in [memberType, jenisAnggota]) {
      final normalized = _normalizeMemberLabel(candidate);
      if (normalized != null) return normalized;
    }

    final baptismState = _parseBaptized(baptized);
    if (baptismState == true) return 'Jemaat';
    if (baptismState == false) return 'Simpatisan';

    for (final candidate in [type, status]) {
      final normalized = _normalizeMemberLabel(candidate);
      if (normalized != null) return normalized;
    }
    return null;
  }

  /// Canonical congregation/branch label across API response variants.
  String? get resolvedBranchName =>
      _firstMeaningful([branchName, branch, wilayah]);
}

String? _firstMeaningful(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isNotEmpty &&
        trimmed.toLowerCase() != 'null' &&
        trimmed != '-') {
      return trimmed;
    }
  }
  return null;
}

String? _normalizeMemberLabel(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final normalized = raw.toLowerCase();

  if (normalized.contains('simpatis') ||
      normalized.contains('belum baptis') ||
      normalized.contains('belum dibaptis') ||
      normalized == 'visitor') {
    return 'Simpatisan';
  }
  if (normalized.contains('jemaat') ||
      normalized.contains('sudah baptis') ||
      normalized.contains('sudah dibaptis') ||
      normalized == 'member') {
    return 'Jemaat';
  }
  return raw;
}

bool? _parseBaptized(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized = value.toString().trim().toLowerCase();
  if (normalized.isEmpty || normalized == 'null' || normalized == '-') {
    return null;
  }
  if ({
    '1',
    'true',
    'yes',
    'y',
    'sudah',
    'sudah baptis',
    'sudah dibaptis',
    'baptized',
  }.contains(normalized)) {
    return true;
  }
  if ({
    '0',
    'false',
    'no',
    'n',
    'belum',
    'belum baptis',
    'belum dibaptis',
    'not baptized',
  }.contains(normalized)) {
    return false;
  }
  return null;
}
