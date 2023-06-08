import 'package:dartz/dartz.dart';

import '../../data/utilities/variables/failure.dart';
import '../entity/kesaksian/kesaksian_entity.dart';
import '../entity/panduan/panduan_entity.dart';
import '../entity/renungan/renungan_entity.dart';
import '../entity/sauh/sauh_entity.dart';
import '../entity/truevoice/truevoice_entity.dart';
import '../entity/warta/warta_entity.dart';

abstract class ScrapperRepository {
  Future<Either<Failure, List<Sauh>>> getSauh();
  Future<Either<Failure, List<TrueVoice>>> getSuaraSejati();
  Future<Either<Failure, List<Kesaksian>>> getKesaksian(String selector);
  Future<Either<Failure, List<Warta>>> getWarta(String selector);
  Future<Either<Failure, List<Renungan>>> getRenungan(String selector);
  Future<Either<Failure, List<Panduan>>> getPanduan(String selector);
}
