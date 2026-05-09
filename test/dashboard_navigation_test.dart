import 'package:flutter_test/flutter_test.dart';
import 'package:church/presentations/dashboard/view/dashboard_view.dart';

void main() {
  test('main dashboard navigation follows stitch tab structure', () {
    final labels = dashboardNavigationDestinations
        .map((destination) => destination.label)
        .toList();

    expect(labels, ['Dashboard', 'Bible', 'Hymnal', 'Beliefs', 'Settings']);
  });
}
