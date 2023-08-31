import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../data/data.dart';
import '../domain/domain.dart';
import '../presentations/presentations.dart';

part 'router.gr.dart';

var router = AppRouter();

@AutoRouterConfig(
  replaceInRouteName: 'View,Route',
)
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        CupertinoRoute(path: '/', page: InitialRoute.page),
        CupertinoRoute(page: LoginRoute.page),
        MaterialRoute(page: WebpageRoute.page),
        CupertinoRoute(page: LiteratureRoute.page),
        CupertinoRoute(page: LiteratureKesaksianRoute.page),
        CupertinoRoute(page: LiteratureWartaRoute.page),
        CupertinoRoute(page: LiteratureRenunganRoute.page),
        CupertinoRoute(page: LiteraturePanduanKitabRoute.page),
        CupertinoRoute(page: SongListRoute.page),
        CupertinoRoute(page: BibleListRoute.page),
        CupertinoRoute(page: BibleNoteRoute.page),
        CupertinoRoute(page: BibleSearchFilterRoute.page),
        CupertinoRoute(page: SongNoteRoute.page),
        CupertinoRoute(page: FaithNoteRoute.page),
        CupertinoRoute(page: BibleNoteListRoute.page),
        CupertinoRoute(page: FaithNoteListRoute.page),
        CupertinoRoute(page: SongNotesListRoute.page),
        CupertinoRoute(page: BibleSearchRoute.page),
        CupertinoRoute(page: BackupRoute.page),
        CupertinoRoute(page: ReportRoute.page),
        CupertinoRoute(page: FontSettingRoute.page),
        CupertinoRoute(page: BibleAudioSettingRoute.page),
        CupertinoRoute(page: BibleVersionRoute.page),
        CupertinoRoute(
          page: DashboardRoute.page,
          children: [
            CupertinoRoute(page: HomeRoute.page),
            CupertinoRoute(page: BibleRoute.page),
            CupertinoRoute(page: SongRoute.page),
            CupertinoRoute(page: FaithRoute.page),
            CupertinoRoute(page: SettingsRoute.page),
          ],
        ),
      ];
}
