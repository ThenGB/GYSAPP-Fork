import 'package:flutter_test/flutter_test.dart';
import 'package:church/data/utilities/string_utils.dart'; // Assuming the app name is church from pubspec.yaml

void main() {
  group('StringUtil', () {
    group('toInt', () {
      test('returns 0 when given an invalid string', () {
        expect(StringUtil.toInt('invalid_string'), 0);
      });

      test('returns the integer when given a valid integer string', () {
        expect(StringUtil.toInt('42'), 42);
      });

      test('returns the truncated integer when given a valid double string', () {
        expect(StringUtil.toInt('42.8'), 42);
      });

      test('returns 0 when given an empty string', () {
        expect(StringUtil.toInt(''), 0);
      });

      test('returns 0 when given a string with only spaces', () {
        expect(StringUtil.toInt('   '), 0);
      });

      test('handles strings with thousands separators', () {
        // StringUtil.toDouble removes commas, so '1,000' becomes 1000.0, then truncated to 1000
        expect(StringUtil.toInt('1,000'), 1000);
      });

      test('returns negative integer when given a negative integer string', () {
        expect(StringUtil.toInt('-42'), -42);
      });

      test('returns negative truncated integer when given a negative double string', () {
        expect(StringUtil.toInt('-42.8'), -42);
      });
    });
  });
}
