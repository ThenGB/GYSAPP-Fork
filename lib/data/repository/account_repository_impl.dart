import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  Future<Either<Failure, Account>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    bool hasError = false;
    late Account data;
    late Failure failure;
    try {
      // Get Firebase Auth token
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'User not authenticated. Please sign in again.';
      }

      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw 'Failed to get authentication token';
      }

      // Prepare update data
      final updateData = <String, dynamic>{};
      if (displayName != null) {
        updateData['name'] = displayName;
      }
      if (photoUrl != null) {
        updateData['profilepicture'] = photoUrl;
      }

      // Call backend API to update profile
      http.options.headers[HttpHeaders.authorizationHeader] = 'bearer $idToken';
      final response = await http.post(
        '/users/profile',
        data: updateData,
      );

      if (!response.data['error']) {
        data = Account.fromJson(response.data['data'] as Map<String, dynamic>);
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
}

