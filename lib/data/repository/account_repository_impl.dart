import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entity/account/account_entity.dart';
import '../../domain/repository/account_repository.dart';
import '../services/auth_session_credential.dart';
import '../utilities/variables/failure.dart';

class AccountRepositoryImpl implements AccountRepository {
  final Dio http;

  AccountRepositoryImpl(this.http);

  void _debug(String message) {
    if (kDebugMode) debugPrint('[AccountRepository] $message');
  }

  @override
  Future<Either<Failure, Account>> getProfile(String token) async {
    try {
      _applyAuthentication(token);
      final response = await http.get('/users/profile');
      _debug('Profile response status: ${response.statusCode}');

      final payload = _normalizeProfilePayload(_profilePayload(response.data));
      var account = Account.fromJson(payload);

      // The JSON endpoint is authoritative when it contains semantic member
      // data. Older responses often contain only generic account status such
      // as ACTIVE; Account.resolvedMemberType deliberately treats those as
      // unknown so this enrichment path can recover Jemaat/Simpatisan.
      if (account.resolvedMemberType == null ||
          account.resolvedBranchName == null) {
        account = await _enrichFromLegacyProfile(account);
      }

      _debug('Profile parsed successfully');
      return Right(account);
    } catch (error) {
      _debug('Profile request failed (${error.runtimeType})');
      return Left(Failure.fromError(error));
    }
  }

  void _applyAuthentication(String token) {
    const authorizationHeader = 'Authorization';
    const cookieHeader = 'Cookie';

    final sessionCookie = decodeHostedSessionCredential(token);
    if (sessionCookie != null) {
      http.options.headers.remove(authorizationHeader);
      http.options.headers[cookieHeader] = sessionCookie;
      _debug('Using hosted-session authentication');
    } else {
      http.options.headers.remove(cookieHeader);
      http.options.headers[authorizationHeader] = 'Bearer $token';
      _debug('Using bearer authentication');
    }
  }

  Map<String, dynamic> _profilePayload(dynamic body) {
    if (body is! Map) {
      throw const FormatException('Unexpected profile response');
    }
    final map = body.cast<String, dynamic>();
    if (map['error'] == true) {
      final errors = map['errors'];
      if (errors is Map) {
        final err = errors.cast<dynamic, dynamic>();
        throw StateError(
          '${err['type'] ?? 'Profile'}: ${err['message'] ?? 'request failed'}',
        );
      }
      throw StateError('Profile request failed');
    }

    final data = map['data'];
    if (data is List && data.isNotEmpty && data.first is Map) {
      return (data.first as Map).cast<String, dynamic>();
    }
    if (data is Map) return data.cast<String, dynamic>();

    if (map.containsKey('id') || map.containsKey('email')) return map;
    throw const FormatException('Profile payload is empty');
  }

  Map<String, dynamic> _normalizeProfilePayload(
    Map<String, dynamic> payload,
  ) {
    final normalized = Map<String, dynamic>.from(payload);

    // Some e-GYS revisions wrap account metadata one level deeper. Merge only
    // missing values so the top-level API contract remains authoritative.
    for (final key in ['profile', 'user', 'membership', 'account']) {
      final nested = payload[key];
      if (nested is! Map) continue;
      for (final entry in nested.entries) {
        normalized.putIfAbsent(entry.key.toString(), () => entry.value);
      }
    }

    void alias(String target, List<String> candidates) {
      if (_isMeaningfulScalar(normalized[target])) return;
      for (final candidate in candidates) {
        final value = normalized[candidate];
        if (_isMeaningfulScalar(value)) {
          normalized[target] = value;
          return;
        }
      }
    }

    alias('member_type', [
      'memberType',
      'membership_type',
      'membershipType',
      'jenisAnggota',
      'jenis_anggota',
      'member_status',
      'memberStatus',
    ]);
    alias('baptized', [
      'is_baptized',
      'isBaptized',
      'baptism_status',
      'baptismStatus',
      'baptized_status',
      'baptizedStatus',
    ]);
    alias('branchname', [
      'branchName',
      'branch_name',
      'churchName',
      'church_name',
      'congregationName',
      'congregation_name',
    ]);
    alias('wilayah', [
      'region',
      'regionName',
      'region_name',
      'wilayahName',
      'wilayah_name',
      'congregation',
    ]);
    alias('profilepicture', [
      'profilePicture',
      'profile_picture',
      'avatar',
      'avatarUrl',
      'avatar_url',
      'photoUrl',
      'photo_url',
    ]);
    alias('mobilephone', ['mobilePhone', 'mobile_phone', 'phone', 'phoneNumber']);

    return normalized;
  }

  bool _isMeaningfulScalar(dynamic value) {
    if (value == null || value is Map || value is Iterable) return false;
    final text = value.toString().trim().toLowerCase();
    return text.isNotEmpty && text != 'null' && text != '-';
  }

  Future<Account> _enrichFromLegacyProfile(Account account) async {
    try {
      final response = await http.get('/u/profile');
      _debug('Legacy profile response status: ${response.statusCode}');
      if (response.statusCode != 200) return account;

      final plainText = _htmlToPlainText(response.data.toString());
      final memberType =
          account.resolvedMemberType ?? _extractMemberType(plainText);
      final branchName =
          account.resolvedBranchName ?? _extractBranchName(plainText);
      return account.copyWith(
        memberType: memberType ?? account.memberType,
        branchName: branchName ?? account.branchName,
      );
    } catch (error) {
      _debug('Legacy profile enrichment skipped (${error.runtimeType})');
      return account;
    }
  }

  String _htmlToPlainText(String html) {
    return html
        .replaceAll(
          RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style\b[^>]*>[\s\S]*?</style>', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _extractMemberType(String text) {
    final normalized = text.toLowerCase();
    if (RegExp(
      r'\b(simpatisan|belum\s+(?:di)?baptis|(?:di)?baptis\s+belum|not\s+baptized|unbaptized|(?:status\s+)?baptis(?:an)?\s*[:\-]?\s*(?:belum|tidak|no))\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return 'Simpatisan';
    }
    if (RegExp(
      r'\b(jemaat|sudah\s+(?:di)?baptis|(?:di)?baptis\s+sudah|baptized|(?:status\s+)?baptis(?:an)?\s*[:\-]?\s*(?:sudah|ya|yes))\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return 'Jemaat';
    }
    return null;
  }

  String? _extractBranchName(String text) {
    final match = RegExp(
      r'\b(?:wilayah|region|cabang|branch|jemaat)\s*[:\-]?\s*([^|•;,]{2,80})',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;

    final value = match.group(1)?.trim() ?? '';
    if (value.isEmpty) return null;
    return value
        .split(
          RegExp(
            r'\s+(?:email|telepon|phone|status|jenis\s+anggota|baptis)\s*[:\-]',
            caseSensitive: false,
          ),
        )
        .first
        .trim();
  }

  @override
  Future<Either<Failure, Account>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    return Left(
      Failure('Profile updates are unavailable in the legacy offline build.'),
    );
  }
}
