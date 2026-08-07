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

    for (final source in [lightTheme, darkTheme]) {
      expect(source, contains('pageTransitionsTheme:'));
      expect(source, contains('NavigationBarThemeData'));
      expect(source, contains('IconButtonThemeData'));
      expect(source, contains('BottomSheetThemeData'));
      expect(source, contains("const _hymnalUiFont = 'Manrope'"));
      expect(source, contains("const _hymnalHeadingFont = 'EB Garamond'"));
      expect(source, contains('toolbarHeight: 56'));
      // Radii are now theme-driven through the r() helper so the corner
      // radius preference actually takes effect; type scale via fs().
      expect(source, contains('BorderRadius r(double base)'));
      expect(source, contains('double fs(double base)'));
      expect(source, contains('visualDensity: visualDensity'));
    }
  });

  test('dashboard shell uses redesigned dock navigation slab', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(source, contains('DashboardNavigationDestination'));
    // The dock is a custom-painted slab — check the painter itself instead
    // of a generic radius literal (the old 16px assertion was accidentally
    // satisfied by the drawer progress tile).
    expect(source, contains('_NavBarPainter'));
    expect(source, contains('CustomPaint'));
    expect(source, contains('kDashboardNavMaxWidth'));
    expect(source, contains('kDashboardExtendsBodyForMiniPlayerOverlay'));
    expect(source, contains('NavigationBar'));
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
