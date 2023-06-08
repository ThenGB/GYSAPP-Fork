import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/entity/song/song_entity.dart';
import '../../domain/repository/song_repository.dart';
import '../utilities/variables/failure.dart';

class SongRepositoryImpl implements SongRepository {
  @override
  Future<Either<Failure, List<SongBook>>> getData(Database db) async {
    bool hasError = false;
    List<SongBook> data = [];
    late Failure failure;
    try {
      // for (var row
      //     in (await db.query('sqlite_master', columns: ['type', 'name']))) {
      //   print(row.values);
      // }
      final response = await db.query(
        'lyric',
        orderBy: 'code, number, seq asc',
      );
      List<Map<String, dynamic>> temp = List.from(
        response.map(
          (e) => Map.fromEntries(e.entries),
        ),
      );
      var bookCodes = ((temp.map((e) => e['code']).toSet())
            ..removeWhere((element) => element == null))
          .toList();
      var parsed = List.generate(bookCodes.length, (index) {
        var items = temp
            .where((element) =>
                element['code'] == bookCodes[index] && element['seq'] == 0)
            .toList();
        var parsedItems = items
            .map((e) => e
              ..addAll({
                'verses': temp
                    .where((element) =>
                        element['code'] == bookCodes[index] &&
                        element['seq'] != 0 &&
                        element['number'] == e['number'])
                    .map((e) => e['lyric'])
                    .toList()
              }))
            .toList();

        return {'code': bookCodes[index], 'songs': parsedItems};
      });
      data = parsed.map((e) => SongBook.fromJson(e)).toList();
    } catch (e) {
      hasError = true;
      failure = Failure.fromError(e);
    }
    return hasError ? Left(failure) : Right(data);
  }
}
