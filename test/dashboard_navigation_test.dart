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
}
