import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../domain/entity/song/song_entity.dart';
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
        CupertinoRoute(path: '/auth', page: LoginRoute.page),
        MaterialRoute(path: '/web', page: WebpageRoute.page),
        CupertinoRoute(
          path: '/literature',
          page: LiteratureRoute.page,
        ),
        CupertinoRoute(
          path: '/literature/kesaksian',
          page: LiteratureKesaksianRoute.page,
        ),
        CupertinoRoute(
          path: '/literature/warta',
          page: LiteratureWartaRoute.page,
        ),
        CupertinoRoute(
          path: '/literature/renungan',
          page: LiteratureRenunganRoute.page,
        ),
        CupertinoRoute(
          path: '/literature/panduankitab',
          page: LiteraturePanduanKitabRoute.page,
        ),
        CupertinoRoute(
          page: SongListRoute.page,
        ),
        CupertinoRoute(
          path: '/dashboard',
          page: DashboardRoute.page,
          children: [
            CupertinoRoute(
              page: HomeRoute.page,
            ),
            CupertinoRoute(
              page: BibleRoute.page,
            ),
            CupertinoRoute(
              page: SongRoute.page,
            ),
            CupertinoRoute(
              page: FaithRoute.page,
            ),
            CupertinoRoute(
              page: SettingsRoute.page,
            ),
          ],
        ),
      ];
}
