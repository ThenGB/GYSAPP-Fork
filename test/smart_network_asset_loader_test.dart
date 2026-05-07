import 'dart:async';
import 'dart:ui';

import 'package:church/main.dart';
import 'package:flutter_test/flutter_test.dart';

class AssetFirstLoader extends SmartNetworkAssetLoader {
  AssetFirstLoader()
      : super(
          localeUrl: (_) => 'https://example.invalid/translations/',
          assetsPath: 'assets/translations',
        );

  int networkChecks = 0;

  @override
  Future<bool> localTranslationExists(
    String localeName, {
    bool ignoreCacheDuration = false,
  }) async {
    return false;
  }

  @override
  Future<bool> isInternetConnectionAvailable() async {
    networkChecks++;
    return Completer<bool>().future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads bundled translation without waiting for network', () async {
    final loader = AssetFirstLoader();

    final translation = await loader
        .load(
          'assets/translations',
          const Locale('id', 'ID'),
        )
        .timeout(const Duration(milliseconds: 100));

    expect(translation, contains('Home'));
    expect(loader.networkChecks, 1);
  });
}
