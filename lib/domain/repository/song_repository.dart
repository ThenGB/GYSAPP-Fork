import 'package:dartz/dartz.dart';

import '../../data/utilities/variables/failure.dart';
import '../entity/song/song_entity.dart';

abstract class SongRepository {
  Future<Either<Failure, List<SongBook>>> getData();
}

