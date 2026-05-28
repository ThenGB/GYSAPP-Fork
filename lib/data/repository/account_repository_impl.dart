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
        data = Account.fromJson((response.data['data'] as List<dynamic>).first);
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

