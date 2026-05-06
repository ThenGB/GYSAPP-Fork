import 'package:dartz/dartz.dart';

import '../../domain/entity/song/song_entity.dart';
import '../../domain/repository/song_repository.dart';
import '../services/local_asset_service.dart';
import '../utilities/variables/failure.dart';

class SongRepositoryImpl implements SongRepository {
  final LocalAssetService _assetService;

  SongRepositoryImpl(this._assetService);

  @override
  Future<Either<Failure, List<SongBook>>> getData() async {
    bool hasError = false;
    List<SongBook> data = [];
    late Failure failure;
    try {
      await _assetService.initialize();
      data = await _assetService.loadSongBooks();
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }
}

