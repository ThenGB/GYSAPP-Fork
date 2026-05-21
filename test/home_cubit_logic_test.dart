import 'package:church/domain/entity/sauh/sauh_entity.dart';
import 'package:church/presentations/home/bloc/home_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('drops stale cached sauh when a new day starts', () {
    final result = freshSauhCacheForToday([
      const Sauh(
        title: 'Merasa Cukup',
        description: 'Roma 8:11',
        url: 'https://tjc.org/id/gerakan-baca-alkitab/sbj260520/',
        imageUrl: 'https://tjc.org/example.jpg',
      ),
    ], now: DateTime(2026, 5, 21));

    expect(result, isEmpty);
  });

  test('keeps cached sauh when it already matches todays slug', () {
    final result = freshSauhCacheForToday([
      const Sauh(
        title: 'Kita adalah Orang yang Berhutang',
        description: 'Roma 8:12',
        url: 'https://tjc.org/id/gerakan-baca-alkitab/sbj260521/',
        imageUrl: 'https://tjc.org/example.jpg',
      ),
    ], now: DateTime(2026, 5, 21));

    expect(result, hasLength(1));
    expect(result.first.title, 'Kita adalah Orang yang Berhutang');
  });
}
