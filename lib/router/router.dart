import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../data/data.dart';
import '../domain/domain.dart';
import '../presentations/presentations.dart';

part 'router.gr.dart';

var router = AppRouter();

@AutoRouterConfig(
  replaceInRouteName: 'View,Route',
)
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        CupertinoRoute(path: '/', page: InitialRoute.page),
        CupertinoRoute(page: LoginRoute.page),
        MaterialRoute(page: WebpageRoute.page),
        CupertinoRoute(
          path: '/literature',
          page: LiteratureRoute.page,
        ),
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
            CupertinoRoute(page: HomeRoute.page, path: 'home-route'),
            CupertinoRoute(page: BibleRoute.page, path: 'bible-route'),
            CupertinoRoute(page: SongRoute.page, path: 'song-route'),
            CupertinoRoute(page: FaithRoute.page, path: 'faith-route'),
            CupertinoRoute(page: SettingsRoute.page, path: 'settings-route'),
          ],
        ),
      ];
}
