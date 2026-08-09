import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Faith explanations open inside the app and remember reading page', () {
    final faithView = File(
      'lib/presentations/faith/view/faith_view.dart',
    ).readAsStringSync();
    final reader = File(
      'lib/presentations/faith/view/faith_pdf_viewer.dart',
    ).readAsStringSync();

    expect(faithView, contains('FaithPdfViewerPage'));
    expect(faithView, isNot(contains('launchUrl(')));
    expect(reader, contains('PdfViewer.uri'));
    expect(reader, contains('faith_pdf_last_page_v1_'));
    expect(reader, contains('Kembali ke halaman terakhir dibuka?'));
    expect(reader, contains('SharedPreferences.getInstance'));
    expect(reader, contains('_controller.goToPage'));
  });

  test('drawer keeps account actions at top and app exit beside version', () {
    final drawer = File(
      'lib/presentations/dashboard/widgets/dashboard_drawer.dart',
    ).readAsStringSync();

    expect(drawer, contains('_AccountPanel'));
    expect(drawer, contains("label: Text('logout'.tr())"));
    expect(drawer, contains('LoginRoute('));
    expect(drawer, contains('_DrawerFooter'));
    expect(drawer, contains("'GYS App · v\$version'"));
    expect(drawer, contains('Icons.power_settings_new_rounded'));
  });

  test('dashboard navigation no longer uses custom painted notch chrome', () {
    final dashboard = File(
      'lib/presentations/dashboard/view/dashboard_view.dart',
    ).readAsStringSync();

    expect(dashboard, contains('DashboardNavigationDock'));
    expect(dashboard, isNot(contains('_NavBarPainter')));
    expect(dashboard, isNot(contains('CustomPaint')));
  });
}
