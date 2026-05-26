import 'package:flutter_test/flutter_test.dart';
import 'package:church/data/utilities/extensions/list_extension.dart';

void main() {
  group('ListRearrangeExtension', () {
    test('rearrangeList with valid indices', () {
      final originalList = ['A', 'B', 'C', 'D'];
      final indices = [3, 0, 2, 1];
      final result = originalList.rearrangeList(indices);
      expect(result, ['D', 'A', 'C', 'B']);
    });

    test('rearrangeList with empty index list', () {
      final originalList = ['A', 'B', 'C', 'D'];
      final indices = <int>[];
      final result = originalList.rearrangeList(indices);
      expect(result, []);
    });

    test('rearrangeList with empty original list', () {
      final originalList = <String>[];
      final indices = [0, 1, 2];
      final result = originalList.rearrangeList(indices);
      expect(result, []);
    });

    test('rearrangeList with indices exceeding list length', () {
      final originalList = ['A', 'B'];
      final indices = [0, 1, 2, 3];
      final result = originalList.rearrangeList(indices);
      expect(result, ['A', 'B']);
    });

    test('rearrangeList with duplicate indices', () {
      final originalList = ['A', 'B', 'C'];
      final indices = [0, 0, 1];
      final result = originalList.rearrangeList(indices);
      expect(result, ['A', 'A', 'B']);
    });

    test('rearrangeList with negative indices', () {
      final originalList = ['A', 'B', 'C'];
      final indices = [-1, 0, -2, 1];
      final result = originalList.rearrangeList(indices);
      expect(result, ['A', 'B']);
    });
  });
}
