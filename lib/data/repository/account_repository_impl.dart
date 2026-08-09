import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entity/account/account_entity.dart';
import '../../domain/repository/account_repository.dart';
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

      final payload = _profilePayload(response.data);
      var account = Account.fromJson(payload);

      // The JSON endpoint is authoritative. Only request the HTML profile page
      // when older API payloads omit membership/branch metadata entirely.
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

    // Embedded hosted-auth debug flows can return a session cookie while the
    // native/provider exchange returns the application bearer token. Header
    // names stay literal so this repository remains web-compilable without
    // importing dart:io merely for HttpHeaders constants.
    final looksLikeCookie = token.contains('=') && token.contains(';');
    if (looksLikeCookie) {
      http.options.headers.remove(authorizationHeader);
      http.options.headers[cookieHeader] = token;
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

    // Some API revisions return the account object directly.
    if (map.containsKey('id') || map.containsKey('email')) return map;
    throw const FormatException('Profile payload is empty');
  }

  Future<Account> _enrichFromLegacyProfile(Account account) async {
    try {
      final response = await http.get('/u/profile');
      _debug('Legacy profile response status: ${response.statusCode}');
      if (response.statusCode != 200) return account;

      final plainText = _htmlToPlainText(response.data.toString());
      final memberType = account.resolvedMemberType ??
          _extractMemberType(plainText);
      final branchName = account.resolvedBranchName ??
          _extractBranchName(plainText);
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
        .replaceAll(RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<style\b[^>]*>[\s\S]*?</style>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _extractMemberType(String text) {
    // Check negative baptism wording FIRST. "belum dibaptis" also contains
    // "dibaptis"; the previous ordering therefore misclassified some
    // Simpatisan as Jemaat.
    final normalized = text.toLowerCase();
    if (RegExp(
      r'\b(belum\s+(?:di)?baptis|(?:di)?baptis\s+belum|not\s+baptized|simpatisan)\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return 'Simpatisan';
    }
    if (RegExp(
      r'\b(sudah\s+(?:di)?baptis|(?:di)?baptis\s+sudah|baptized|jemaat)\b',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return 'Jemaat';
    }
    return null;
  }

  String? _extractBranchName(String text) {
    final match = RegExp(
      r'\b(?:wilayah|region|cabang|branch)\s*[:\-]?\s*([^|•;,]{2,80})',
      caseSensitive: false,
    ).firstMatch(text);
    if (match == null) return null;

    final value = match.group(1)?.trim() ?? '';
    if (value.isEmpty) return null;
    // Stop before another common profile label when the flattened HTML has
    // placed multiple fields on the same line.
    return value
        .split(RegExp(
          r'\s+(?:email|telepon|phone|status|jenis\s+anggota|baptis)\s*[:\-]',
          caseSensitive: false,
        ))
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
