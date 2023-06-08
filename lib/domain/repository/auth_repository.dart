import 'package:dartz/dartz.dart';

import '../../data/utilities/variables/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> loginGoogle(String idToken);
  Future<Either<Failure, String>> loginApple(String idToken);
}
