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

  test('drawer removed; account actions live in the More hub', () {
    final drawerFile = File(
      'lib/presentations/dashboard/widgets/dashboard_drawer.dart',
    );
    final moreView = File(
      'lib/presentations/more/view/more_view.dart',
    ).readAsStringSync();

    expect(drawerFile.existsSync(), isFalse);
    expect(moreView, contains('LoginRoute('));
    expect(moreView, contains("'logout'.tr()"));
    expect(moreView, contains('_MoreAccountPanel'));
    expect(moreView, contains('SettingsRoute('));
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
