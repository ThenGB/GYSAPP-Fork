import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('global theme uses redesigned app-wide chrome and motion', () {
    final lightTheme = File(
      'lib/components/themes/default_theme.dart',
    ).readAsStringSync();
    final darkTheme = File(
      'lib/components/themes/dark_theme.dart',
    ).readAsStringSync();
    final churchTheme = File(
      'lib/components/themes/church_theme.dart',
    ).readAsStringSync();

    for (final source in [lightTheme, darkTheme]) {
      expect(source, contains('pageTransitionsTheme:'));
      expect(source, contains('NavigationBarThemeData'));
      expect(source, contains('IconButtonThemeData'));
      expect(source, contains('BottomSheetThemeData'));
      expect(source, contains("const _hymnalUiFont = 'Manrope'"));
      expect(source, contains("const _hymnalHeadingFont = 'EB Garamond'"));
      expect(source, contains('toolbarHeight: 56'));
      expect(source, contains('BorderRadius r(double base)'));
      expect(source, contains('double fs(double base)'));
      expect(source, contains('visualDensity: visualDensity'));
    }

    expect(churchTheme, contains('filledButtonTheme:'));
    expect(churchTheme, contains('outlinedButtonTheme:'));
    expect(churchTheme, contains('inputDecorationTheme:'));
    expect(churchTheme, contains('switchTheme:'));
    expect(churchTheme, contains('checkboxTheme:'));
    expect(churchTheme, contains('drawerTheme:'));
  });

  test('dashboard shell uses calm theme-aware navigation dock', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(source, contains('DashboardNavigationDestination'));
    expect(source, contains('DashboardNavigationDock'));
    expect(source, contains('colors.primaryContainer'));
    expect(source, contains('kDashboardNavMaxWidth'));
    expect(source, contains('kDashboardExtendsBodyForMiniPlayerOverlay'));
    expect(source, isNot(contains('_NavBarPainter')));
    expect(source, isNot(contains('CustomPaint')));
  });

  test('shared section and card components use bold modern radii', () {
    final section = File(
      'lib/components/widgets/section.dart',
    ).readAsStringSync();
    final designSystem = File(
      'lib/components/design_system/design_system.dart',
    ).readAsStringSync();

    expect(section, contains('MediaQuery.sizeOf(context).width'));
    expect(designSystem, contains('static const double radiusMd = 8'));
    expect(section, contains('horizontalMargin'));
    expect(section, contains('child(innerGap)'));
  });
}
