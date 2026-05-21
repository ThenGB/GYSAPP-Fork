import 'package:dartz/dartz.dart';

import '../../domain/repository/auth_repository.dart';
import '../utilities/variables/failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  @override
  Future<Either<Failure, String>> loginApple(String idToken) async {
    return Left(
      Failure('Member login is now handled without the legacy auth bridge.'),
    );
  }

  @override
  Future<Either<Failure, String>> loginGoogle(String idToken) async {
    return Left(
      Failure('Member login is now handled without the legacy auth bridge.'),
    );
  }
}

