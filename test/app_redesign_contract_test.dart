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
      expect(source, contains('borderRadius: BorderRadius.circular(16)'));
    }
  });

  test('dashboard shell uses redesigned dock navigation slab', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(source, contains('DashboardNavigationDestination'));
    expect(source, contains('BorderRadius.circular(16)'));
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

    expect(section, contains('AnimatedContainer'));
    expect(designSystem, contains('static const double radiusMd = 8'));
    expect(section, contains('borderRadius: BorderRadius.circular(radius)'));
    expect(section, contains('child(innerGap)'));
  });
}
