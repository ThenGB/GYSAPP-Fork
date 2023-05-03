import 'package:auto_route/auto_route.dart';

part 'router.gr.dart';

var router = AppRouter();

@AutoRouterConfig(
  replaceInRouteName: 'View,Route',
)
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        CupertinoRoute(path: '/', name: InitialRoute),
        CupertinoRoute(path: '/auth', name: LoginRoute),
        MaterialRoute(path: '/web', page: WebpageRoute.page),
        CupertinoRoute(
          path: '/literature',
          name: LiteratureRoute,
        ),
        CupertinoRoute(
          path: '/literature/kesaksian',
          name: LiteratureKesaksianRoute,
        ),
        CupertinoRoute(
          path: '/literature/warta',
          name: LiteratureWartaRoute,
        ),
        CupertinoRoute(
          path: '/literature/renungan',
          name: LiteratureRenunganRoute,
        ),
        CupertinoRoute(
          path: '/literature/panduankitab',
          name: LiteraturePanduanKitabRoute,
        ),
        // CupertinoRoute(
        //   name: SonglistRoute,
        // ),
        CupertinoRoute(
          path: '/dashboard',
          name: DashboardRoute,
          children: [
            CupertinoRoute(
              name: HomeRoute,
            ),
            CupertinoRoute(
              name: BibleRoute,
            ),
            CupertinoRoute(
              name: SongRoute,
            ),
            CupertinoRoute(
              name: FaithRoute,
            ),
            CupertinoRoute(
              name: SettingsRoute,
            ),
          ],
        ),
      ];
}
