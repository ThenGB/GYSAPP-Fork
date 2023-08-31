import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

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
      http.options.headers[HttpHeaders.authorizationHeader] = 'bearer $token';
      final response = await http.get('/users/profile');
      if (!response.data['error']) {
        data = Account.fromJson((response.data['data'] as List<dynamic>).first);
      } else {
        var err = response.data['errors'];
        throw "${err['type'] ?? 'Unknown'}: ${err['message']}";
      }
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }

  @override
  Future<Either<Failure, Account>> updateProfile() {
    throw UnimplementedError();
  }
}
