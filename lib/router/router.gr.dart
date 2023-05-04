// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    BibleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BibleView(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsView(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomeView(),
      );
    },
    LiteratureKesaksianRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LiteratureKesaksianView(),
      );
    },
    LiteratureWartaRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LiteratureWartaView(),
      );
    },
    LiteratureRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LiteratureView(),
      );
    },
    LiteraturePanduanKitabRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LiteraturePanduanKitabView(),
      );
    },
    LiteratureRenunganRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LiteratureRenunganView(),
      );
    },
    InitialRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const InitialView(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginView(),
      );
    },
    WebpageRoute.name: (routeData) {
      final args = routeData.argsAs<WebpageRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WebpageView(
          key: args.key,
          url: args.url,
        ),
      );
    },
    SongRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SongView(),
      );
    },
    SongListRoute.name: (routeData) {
      final args = routeData.argsAs<SongListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SongListView(
          key: args.key,
          books: args.books,
          currentBook: args.currentBook,
          onTapPageNumber: args.onTapPageNumber,
          onChangeBookCode: args.onChangeBookCode,
          isFavorite: args.isFavorite,
          onFavorite: args.onFavorite,
          favoriteBooks: args.favoriteBooks,
          onTapFavorite: args.onTapFavorite,
        ),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardView(),
      );
    },
    FaithRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FaithView(),
      );
    },
  };
}

/// generated route for
/// [BibleView]
class BibleRoute extends PageRouteInfo<void> {
  const BibleRoute({List<PageRouteInfo>? children})
      : super(
          BibleRoute.name,
          initialChildren: children,
        );

  static const String name = 'BibleRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsView]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomeView]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LiteratureKesaksianView]
class LiteratureKesaksianRoute extends PageRouteInfo<void> {
  const LiteratureKesaksianRoute({List<PageRouteInfo>? children})
      : super(
          LiteratureKesaksianRoute.name,
          initialChildren: children,
        );

  static const String name = 'LiteratureKesaksianRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LiteratureWartaView]
class LiteratureWartaRoute extends PageRouteInfo<void> {
  const LiteratureWartaRoute({List<PageRouteInfo>? children})
      : super(
          LiteratureWartaRoute.name,
          initialChildren: children,
        );

  static const String name = 'LiteratureWartaRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LiteratureView]
class LiteratureRoute extends PageRouteInfo<void> {
  const LiteratureRoute({List<PageRouteInfo>? children})
      : super(
          LiteratureRoute.name,
          initialChildren: children,
        );

  static const String name = 'LiteratureRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LiteraturePanduanKitabView]
class LiteraturePanduanKitabRoute extends PageRouteInfo<void> {
  const LiteraturePanduanKitabRoute({List<PageRouteInfo>? children})
      : super(
          LiteraturePanduanKitabRoute.name,
          initialChildren: children,
        );

  static const String name = 'LiteraturePanduanKitabRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LiteratureRenunganView]
class LiteratureRenunganRoute extends PageRouteInfo<void> {
  const LiteratureRenunganRoute({List<PageRouteInfo>? children})
      : super(
          LiteratureRenunganRoute.name,
          initialChildren: children,
        );

  static const String name = 'LiteratureRenunganRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [InitialView]
class InitialRoute extends PageRouteInfo<void> {
  const InitialRoute({List<PageRouteInfo>? children})
      : super(
          InitialRoute.name,
          initialChildren: children,
        );

  static const String name = 'InitialRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginView]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [WebpageView]
class WebpageRoute extends PageRouteInfo<WebpageRouteArgs> {
  WebpageRoute({
    Key? key,
    required String url,
    List<PageRouteInfo>? children,
  }) : super(
          WebpageRoute.name,
          args: WebpageRouteArgs(
            key: key,
            url: url,
          ),
          initialChildren: children,
        );

  static const String name = 'WebpageRoute';

  static const PageInfo<WebpageRouteArgs> page =
      PageInfo<WebpageRouteArgs>(name);
}

class WebpageRouteArgs {
  const WebpageRouteArgs({
    this.key,
    required this.url,
  });

  final Key? key;

  final String url;

  @override
  String toString() {
    return 'WebpageRouteArgs{key: $key, url: $url}';
  }
}

/// generated route for
/// [SongView]
class SongRoute extends PageRouteInfo<void> {
  const SongRoute({List<PageRouteInfo>? children})
      : super(
          SongRoute.name,
          initialChildren: children,
        );

  static const String name = 'SongRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SongListView]
class SongListRoute extends PageRouteInfo<SongListRouteArgs> {
  SongListRoute({
    Key? key,
    required List<SongBook> Function() books,
    required SongBook Function() currentBook,
    required dynamic Function(String) onTapPageNumber,
    required dynamic Function(String) onChangeBookCode,
    required bool Function(Song) isFavorite,
    required dynamic Function(Song) onFavorite,
    required List<SongBook> Function() favoriteBooks,
    required dynamic Function(Song) onTapFavorite,
    List<PageRouteInfo>? children,
  }) : super(
          SongListRoute.name,
          args: SongListRouteArgs(
            key: key,
            books: books,
            currentBook: currentBook,
            onTapPageNumber: onTapPageNumber,
            onChangeBookCode: onChangeBookCode,
            isFavorite: isFavorite,
            onFavorite: onFavorite,
            favoriteBooks: favoriteBooks,
            onTapFavorite: onTapFavorite,
          ),
          initialChildren: children,
        );

  static const String name = 'SongListRoute';

  static const PageInfo<SongListRouteArgs> page =
      PageInfo<SongListRouteArgs>(name);
}

class SongListRouteArgs {
  const SongListRouteArgs({
    this.key,
    required this.books,
    required this.currentBook,
    required this.onTapPageNumber,
    required this.onChangeBookCode,
    required this.isFavorite,
    required this.onFavorite,
    required this.favoriteBooks,
    required this.onTapFavorite,
  });

  final Key? key;

  final List<SongBook> Function() books;

  final SongBook Function() currentBook;

  final dynamic Function(String) onTapPageNumber;

  final dynamic Function(String) onChangeBookCode;

  final bool Function(Song) isFavorite;

  final dynamic Function(Song) onFavorite;

  final List<SongBook> Function() favoriteBooks;

  final dynamic Function(Song) onTapFavorite;

  @override
  String toString() {
    return 'SongListRouteArgs{key: $key, books: $books, currentBook: $currentBook, onTapPageNumber: $onTapPageNumber, onChangeBookCode: $onChangeBookCode, isFavorite: $isFavorite, onFavorite: $onFavorite, favoriteBooks: $favoriteBooks, onTapFavorite: $onTapFavorite}';
  }
}

/// generated route for
/// [DashboardView]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FaithView]
class FaithRoute extends PageRouteInfo<void> {
  const FaithRoute({List<PageRouteInfo>? children})
      : super(
          FaithRoute.name,
          initialChildren: children,
        );

  static const String name = 'FaithRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
