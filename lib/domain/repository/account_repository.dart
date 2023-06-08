import 'package:dartz/dartz.dart';

import '../../data/utilities/variables/failure.dart';
import '../entity/account/account_entity.dart';

abstract class AccountRepository {
  Future<Either<Failure, Account>> getProfile(String token);
  Future<Either<Failure, Account>> updateProfile();
}
