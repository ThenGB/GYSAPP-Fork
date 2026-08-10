import 'package:church/presentations/dashboard/view/dashboard_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard destinations retain the complete navigation structure', () {
    expect(
      dashboardNavigationDestinations
          .map((destination) => destination.label)
          .toList(),
      ['Dashboard', 'Bible', 'Hymnal', 'Beliefs', 'More'],
    );
    // The bottom dock shows every destination — including "Lainnya" — so no
    // feature hides behind a drawer.
    expect(
      dashboardBottomNavigationDestinations
          .map((destination) => destination.label)
          .toList(),
      ['Dashboard', 'Bible', 'Hymnal', 'Beliefs', 'More'],
    );
  });

  test('floating navigation owns layout space and ergonomic targets', () {
    expect(kDashboardExtendsBodyForMiniPlayerOverlay, isFalse);
    expect(
      kDashboardPortraitBottomNavHeight,
      greaterThanOrEqualTo(kDashboardNavMinInteractiveExtent),
    );
    expect(
      kDashboardLandscapeBottomNavHeight,
      greaterThanOrEqualTo(kDashboardNavMinInteractiveExtent),
    );
    expect(kDashboardNavMaxWidth, greaterThan(320));
    expect(kDashboardNavHorizontalInset, greaterThan(0));
  });
}
