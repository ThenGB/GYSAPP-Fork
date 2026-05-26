import 'package:flutter_test/flutter_test.dart';
import 'package:church/data/utilities/app_config_store.dart';

void main() {
  group('AppConfigStore', () {
    test('jsonConfig returns valid JSON for existing key', () async {
      final config = await AppConfigStore.jsonConfig('primary_menu');
      expect(config, isNotEmpty);
      expect(config['sauh_bagi_jiwa'], isTrue);
      expect(config['suara_sejati'], isTrue);
    });

    test('jsonConfig returns empty map for missing key', () async {
      final config = await AppConfigStore.jsonConfig('nonexistent_key');
      expect(config, isEmpty);
    });

    test('jsonConfig returns empty map for malformed JSON', () async {
      // testpath contains 'asdasdasdasdasdasdasd' which is not valid JSON
      final config = await AppConfigStore.jsonConfig('testpath');
      expect(config, isEmpty);
    });

    test('listMapConfig returns list of maps for existing key', () async {
      final config = await AppConfigStore.listMapConfig('app_menu');
      expect(config, isNotEmpty);
      expect(config.first['label'], 'eRhema');
    });

    test('listMapConfig returns empty list for missing key', () async {
      final config = await AppConfigStore.listMapConfig('nonexistent_key');
      expect(config, isEmpty);
    });

    test('listMapConfig returns empty list for malformed JSON', () async {
      final config = await AppConfigStore.listMapConfig('testpath');
      expect(config, isEmpty);
    });

    test('stringConfig returns string for existing key', () async {
      final config = await AppConfigStore.stringConfig('testpath');
      expect(config, 'asdasdasdasdasdasdasd');
    });

    test('stringConfig returns empty string for missing key', () async {
      final config = await AppConfigStore.stringConfig('nonexistent_key');
      expect(config, isEmpty);
    });

    test('boolConfig returns true for existing key with value "true"', () async {
      final config = await AppConfigStore.boolConfig('enable_memberarea');
      expect(config, isTrue);
    });

    test('boolConfig returns false for missing key', () async {
      final config = await AppConfigStore.boolConfig('nonexistent_key');
      expect(config, isFalse);
    });

    test('getAllConfigs returns fallback config map', () async {
      final config = await AppConfigStore.getAllConfigs();
      expect(config, isNotEmpty);
      expect(config['testpath'], 'asdasdasdasdasdasdasd');
    });
  });
}
