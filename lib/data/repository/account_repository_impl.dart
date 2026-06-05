import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entity/account/account_entity.dart';
import '../../domain/repository/account_repository.dart';
import '../utilities/variables/failure.dart';

class AccountRepositoryImpl implements AccountRepository {
  final Dio http;

  AccountRepositoryImpl(this.http);
  @override
  Future<Either<Failure, Account>> getProfile(String token) async {
    bool hasError = false;
    late Account data;
    late Failure failure;
    try {
      if (token.contains('=') && token.contains(';')) {
        http.options.headers.remove(HttpHeaders.authorizationHeader);
        http.options.headers[HttpHeaders.cookieHeader] = token;
        debugPrint('[AccountRepository] Using Cookie auth method');
      } else {
        http.options.headers.remove(HttpHeaders.cookieHeader);
        http.options.headers[HttpHeaders.authorizationHeader] = 'bearer $token';
        debugPrint('[AccountRepository] Using Bearer auth method');
      }
      final url = '${http.options.baseUrl}/users/profile';
      debugPrint('[AccountRepository] GET $url');
      final response = await http.get('/users/profile');
      final responseData = response.data.toString();
      debugPrint('[AccountRepository] Response status: ${response.statusCode}');
      debugPrint('[AccountRepository] Response data: ${responseData.length > 200 ? responseData.substring(0, 200) : responseData}');
      if (!response.data['error']) {
        final dataMap = (response.data['data'] as List<dynamic>).first as Map<String, dynamic>;
        debugPrint('[AccountRepository] Full profile data: $dataMap');
        data = Account.fromJson(dataMap);
        debugPrint('[AccountRepository] Account parsed: name=${data.name}, type=${data.type}, status=${data.status}, branchId=${data.branchId}, branchName=${data.branchName}');
        // Scrape profile page for member type and wilayah
        try {
          final profileResp = await http.get('/u/profile');
          debugPrint('[AccountRepository] Profile page status: ${profileResp.statusCode}');
          if (profileResp.statusCode == 200) {
            final html = profileResp.data.toString();
            debugPrint('[AccountRepository] Profile page length: ${html.length}');
            final memberType = _extractMemberType(html);
            final wilayah = _extractWilayah(html);
            debugPrint('[AccountRepository] Extracted memberType=$memberType, wilayah=$wilayah');
            if (memberType != null) data = data.copyWith(memberType: memberType);
            if (wilayah != null) data = data.copyWith(wilayah: wilayah);
          }
        } catch (e) {
          debugPrint('[AccountRepository] Profile page scrape error: $e');
        }
      } else {
        var err = response.data['errors'];
        throw "${err['type'] ?? 'Unknown'}: ${err['message']}";
      }
    } catch (e) {
      debugPrint('[AccountRepository] Error: $e');
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  String? _extractMemberType(String html) {
    // Look for baptism-related content in the profile page
    // Jemaat = baptized, Simpatisan = not baptized
    final baptizedPatterns = [
      RegExp(r'[\s>](?:Sudah|sudah|SUDAH)\s+(?:Baptis|baptis|BAPTIS)', caseSensitive: false),
      RegExp(r'[\s>](?:Baptis|baptis|BAPTIS)\s+(?:Sudah|sudah|SUDAH)', caseSensitive: false),
      RegExp(r'dibaptis', caseSensitive: false),
      RegExp(r'baptized', caseSensitive: false),
    ];
    for (final pattern in baptizedPatterns) {
      if (pattern.hasMatch(html)) return 'Jemaat';
    }
    
    final simpatisanPatterns = [
      RegExp(r'[\s>](?:Belum|belum|BELUM)\s+(?:Baptis|baptis|BAPTIS)', caseSensitive: false),
      RegExp(r'[\s>](?:Baptis|baptis|BAPTIS)\s+(?:Belum|belum|BELUM)', caseSensitive: false),
      RegExp(r'belum\s+dibaptis', caseSensitive: false),
      RegExp(r'not\s+baptized', caseSensitive: false),
    ];
    for (final pattern in simpatisanPatterns) {
      if (pattern.hasMatch(html)) return 'Simpatisan';
    }
    
    return null;
  }

  String? _extractWilayah(String html) {
    // Look for Wilayah/Region in the profile page
    final wilayahPatterns = [
      RegExp(r'[\s>](?:Wilayah|wilayah|WILAYAH)\s*[:\-]?\s*([^<\n]+)', caseSensitive: false),
      RegExp(r'[\s>](?:Region|region)\s*[:\-]?\s*([^<\n]+)', caseSensitive: false),
      RegExp(r'[\s>](?:Cabang|cabang)\s*[:\-]?\s*([^<\n]+)', caseSensitive: false),
      RegExp(r'[\s>](?:Branch|branch)\s*[:\-]?\s*([^<\n]+)', caseSensitive: false),
    ];
    for (final pattern in wilayahPatterns) {
      final match = pattern.firstMatch(html);
      if (match != null && match.group(1) != null) {
        final value = match.group(1)!.trim();
        if (value.isNotEmpty) return value;
      }
    }
    return null;
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

