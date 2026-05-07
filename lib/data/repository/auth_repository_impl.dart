import 'package:dartz/dartz.dart';

import '../../domain/repository/auth_repository.dart';
import '../utilities/variables/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, String>> loginApple(String idToken) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> loginGoogle(String idToken) {
    throw UnimplementedError();
  }
}

