import 'package:church/components/widgets/font_setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('font settings sheet ignores measurement after dispose', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: FontSettingWidget(
          availableFonts: const ['Roboto', 'Arial'],
          selectedFont: 'Roboto',
          textHeight: 1.5,
          textScale: 1.2,
          getTextStyle: (_) => const TextStyle(),
          onFontSelected: (_) {},
          onTextHeightChanged: (_) {},
          onTextScaleChanged: (_) {},
        ),
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
