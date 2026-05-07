import 'package:church/data/services/local_asset_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('resolves indexed midi path to bundled asset path', () async {
    final service = LocalAssetService();

    final path = await service.getMidiPath('KR', '011');

    expect(path, 'assets/data/midi/kr/011_Gembira di Dalam Tuhan.mid');
    final data = await rootBundle.load(path!);
    expect(data.lengthInBytes, greaterThan(0));
  });
}
