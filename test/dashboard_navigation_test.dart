import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:church/presentations/dashboard/view/dashboard_view.dart';

void main() {
  test('main dashboard navigation follows stitch tab structure', () {
    final labels = dashboardNavigationDestinations
        .map((destination) => destination.label)
        .toList();

    expect(labels, ['Dashboard', 'Bible', 'Hymnal', 'Beliefs', 'Settings']);
  });

  test(
    'bottom navigation omits settings because settings lives in sidebar',
    () {
      final labels = dashboardBottomNavigationDestinations
          .map((destination) => destination.label)
          .toList();

      expect(labels, ['Dashboard', 'Bible', 'Hymnal', 'Beliefs']);
    },
  );

  test(
    'dashboard mini player is an overlay instead of reserved content space',
    () {
      expect(kDashboardExtendsBodyForMiniPlayerOverlay, isTrue);
    },
  );

  test(
    'dashboard collapsed mini player stays docked instead of jumping upward',
    () {
      expect(
        dashboardMiniPlayerBottomOffset(isExpanded: false),
        dashboardMiniPlayerBottomOffset(isExpanded: true),
      );
    },
  );

  test('bottom navigation content fits inside reserved safe-area height', () {
    expect(dashboardBottomNavContentHeight(navHeight: 72, bottomInset: 8), 64);
    expect(dashboardBottomNavContentHeight(navHeight: 72, bottomInset: 34), 38);
  });

  test('landscape bottom navigation item fits its compact height', () {
    final itemHeight = dashboardBottomNavItemHeight(
      outerVerticalPadding: kDashboardCompactNavOuterVerticalPadding,
      innerVerticalPadding: kDashboardCompactNavInnerVerticalPadding,
      iconSize: kDashboardCompactNavIconSize,
      labelFontSize: kDashboardCompactNavLabelFontSize,
      iconLabelGap: kDashboardCompactNavIconLabelGap,
    );

    expect(itemHeight, lessThanOrEqualTo(kDashboardLandscapeBottomNavHeight));
  });

  test('icon-only bottom nav uses ergonomic touch target sizing', () {
    final iconOnlyHeight = dashboardBottomNavItemHeight(
      outerVerticalPadding: 0,
      innerVerticalPadding: 0,
      iconSize: 16.5,
      labelFontSize: 0,
      iconLabelGap: 0,
    );

    expect(iconOnlyHeight, greaterThanOrEqualTo(48));
  });

  test('dashboard drawer navigation is not blocked by root PopScope', () {
    final source = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(source, contains('WillPopScope('));
    expect(source, isNot(contains('child: PopScope(')));
  });
}
