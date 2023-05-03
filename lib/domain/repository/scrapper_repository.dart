import 'package:church/domain/entity/kesaksian/kesaksian_entity.dart';
import 'package:church/domain/entity/panduan/panduan_entity.dart';
import 'package:church/domain/entity/renungan/renungan_entity.dart';
import 'package:church/domain/entity/sauh/sauh_entity.dart';
import 'package:church/domain/entity/warta/warta_entity.dart';
import 'package:dartz/dartz.dart';

import '../../data/utilities/variables/failure.dart';
import '../entity/truevoice/truevoice_entity.dart';

abstract class ScrapperRepository {
  Future<Either<Failure, List<Sauh>>> getSauh();
  Future<Either<Failure, List<TrueVoice>>> getSuaraSejati();
  Future<Either<Failure, List<Kesaksian>>> getKesaksian(String selector);
  Future<Either<Failure, List<Warta>>> getWarta(String selector);
  Future<Either<Failure, List<Renungan>>> getRenungan(String selector);
  Future<Either<Failure, List<Panduan>>> getPanduan(String selector);
}
