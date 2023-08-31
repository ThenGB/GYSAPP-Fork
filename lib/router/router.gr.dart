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
    BibleSearchRoute.name: (routeData) {
      final args = routeData.argsAs<BibleSearchRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleSearchView(
          key: args.key,
          cubit: args.cubit,
          onTap: args.onTap,
        ),
      );
    },
    BibleVersionRoute.name: (routeData) {
      final args = routeData.argsAs<BibleVersionRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleVersionView(
          key: args.key,
          dashboardCubit: args.dashboardCubit,
        ),
      );
    },
    BibleRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BibleView(),
      );
    },
    BibleNoteListRoute.name: (routeData) {
      final args = routeData.argsAs<BibleNoteListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleNoteListView(
          key: args.key,
          cubit: args.cubit,
          initialSearch: args.initialSearch,
        ),
      );
    },
    BibleSearchFilterRoute.name: (routeData) {
      final args = routeData.argsAs<BibleSearchFilterRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleSearchFilterView(
          key: args.key,
          allBooks: args.allBooks,
          initialValues: args.initialValues,
          onFiltered: args.onFiltered,
          textScale: args.textScale,
          bibleCode: args.bibleCode,
        ),
      );
    },
    BibleAudioSettingRoute.name: (routeData) {
      final args = routeData.argsAs<BibleAudioSettingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleAudioSettingView(
          key: args.key,
          initialVoices: args.initialVoices,
          initialPitchRate: args.initialPitchRate,
          initialSpeedRate: args.initialSpeedRate,
          onSave: args.onSave,
        ),
      );
    },
    BibleNoteRoute.name: (routeData) {
      final args = routeData.argsAs<BibleNoteRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleNoteView(
          key: args.key,
          initialData: args.initialData,
          cubit: args.cubit,
          mode: args.mode,
          onSave: args.onSave,
        ),
      );
    },
    BibleListRoute.name: (routeData) {
      final args = routeData.argsAs<BibleListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BibleListView(
          key: args.key,
          books: args.books,
          getBibles: args.getBibles,
          onSelected: args.onSelected,
          textScale: args.textScale,
          bibleCode: args.bibleCode,
        ),
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
      final args = routeData.argsAs<LoginRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: WrappedRoute(
            child: LoginView(
          key: args.key,
          onLoggedIn: args.onLoggedIn,
        )),
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
    SongNotesListRoute.name: (routeData) {
      final args = routeData.argsAs<SongNotesListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SongNotesListView(
          key: args.key,
          cubit: args.cubit,
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
          initialSearchText: args.initialSearchText,
          onSearchTermsChanged: args.onSearchTermsChanged,
        ),
      );
    },
    SongNoteRoute.name: (routeData) {
      final args = routeData.argsAs<SongNoteRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SongNoteView(
          key: args.key,
          initialData: args.initialData,
          cubit: args.cubit,
          mode: args.mode,
          onSave: args.onSave,
        ),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardView(),
      );
    },
    FontSettingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FontSettingView(),
      );
    },
    ReportRoute.name: (routeData) {
      final args = routeData.argsAs<ReportRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ReportView(
          key: args.key,
          account: args.account,
          onLoggedIn: args.onLoggedIn,
        ),
      );
    },
    FaithNoteListRoute.name: (routeData) {
      final args = routeData.argsAs<FaithNoteListRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FaithNoteListView(
          key: args.key,
          cubit: args.cubit,
        ),
      );
    },
    FaithNoteRoute.name: (routeData) {
      final args = routeData.argsAs<FaithNoteRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FaithNoteView(
          key: args.key,
          initialData: args.initialData,
          cubit: args.cubit,
          mode: args.mode,
          onSave: args.onSave,
        ),
      );
    },
    FaithRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FaithView(),
      );
    },
    BackupRoute.name: (routeData) {
      final args = routeData.argsAs<BackupRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BackupView(
          key: args.key,
          data: args.data,
          onSynced: args.onSynced,
        ),
      );
    },
  };
}

/// generated route for
/// [BibleSearchView]
class BibleSearchRoute extends PageRouteInfo<BibleSearchRouteArgs> {
  BibleSearchRoute({
    Key? key,
    required BibleCubit cubit,
    required dynamic Function(Verse) onTap,
    List<PageRouteInfo>? children,
  }) : super(
          BibleSearchRoute.name,
          args: BibleSearchRouteArgs(
            key: key,
            cubit: cubit,
            onTap: onTap,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleSearchRoute';

  static const PageInfo<BibleSearchRouteArgs> page =
      PageInfo<BibleSearchRouteArgs>(name);
}

class BibleSearchRouteArgs {
  const BibleSearchRouteArgs({
    this.key,
    required this.cubit,
    required this.onTap,
  });

  final Key? key;

  final BibleCubit cubit;

  final dynamic Function(Verse) onTap;

  @override
  String toString() {
    return 'BibleSearchRouteArgs{key: $key, cubit: $cubit, onTap: $onTap}';
  }
}

/// generated route for
/// [BibleVersionView]
class BibleVersionRoute extends PageRouteInfo<BibleVersionRouteArgs> {
  BibleVersionRoute({
    Key? key,
    required DashboardCubit dashboardCubit,
    List<PageRouteInfo>? children,
  }) : super(
          BibleVersionRoute.name,
          args: BibleVersionRouteArgs(
            key: key,
            dashboardCubit: dashboardCubit,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleVersionRoute';

  static const PageInfo<BibleVersionRouteArgs> page =
      PageInfo<BibleVersionRouteArgs>(name);
}

class BibleVersionRouteArgs {
  const BibleVersionRouteArgs({
    this.key,
    required this.dashboardCubit,
  });

  final Key? key;

  final DashboardCubit dashboardCubit;

  @override
  String toString() {
    return 'BibleVersionRouteArgs{key: $key, dashboardCubit: $dashboardCubit}';
  }
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
/// [BibleNoteListView]
class BibleNoteListRoute extends PageRouteInfo<BibleNoteListRouteArgs> {
  BibleNoteListRoute({
    Key? key,
    required BibleCubit cubit,
    String? initialSearch,
    List<PageRouteInfo>? children,
  }) : super(
          BibleNoteListRoute.name,
          args: BibleNoteListRouteArgs(
            key: key,
            cubit: cubit,
            initialSearch: initialSearch,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleNoteListRoute';

  static const PageInfo<BibleNoteListRouteArgs> page =
      PageInfo<BibleNoteListRouteArgs>(name);
}

class BibleNoteListRouteArgs {
  const BibleNoteListRouteArgs({
    this.key,
    required this.cubit,
    this.initialSearch,
  });

  final Key? key;

  final BibleCubit cubit;

  final String? initialSearch;

  @override
  String toString() {
    return 'BibleNoteListRouteArgs{key: $key, cubit: $cubit, initialSearch: $initialSearch}';
  }
}

/// generated route for
/// [BibleSearchFilterView]
class BibleSearchFilterRoute extends PageRouteInfo<BibleSearchFilterRouteArgs> {
  BibleSearchFilterRoute({
    Key? key,
    required List<BibleBook> allBooks,
    required List<BibleBook> initialValues,
    required dynamic Function(List<BibleBook>) onFiltered,
    required double textScale,
    required String bibleCode,
    List<PageRouteInfo>? children,
  }) : super(
          BibleSearchFilterRoute.name,
          args: BibleSearchFilterRouteArgs(
            key: key,
            allBooks: allBooks,
            initialValues: initialValues,
            onFiltered: onFiltered,
            textScale: textScale,
            bibleCode: bibleCode,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleSearchFilterRoute';

  static const PageInfo<BibleSearchFilterRouteArgs> page =
      PageInfo<BibleSearchFilterRouteArgs>(name);
}

class BibleSearchFilterRouteArgs {
  const BibleSearchFilterRouteArgs({
    this.key,
    required this.allBooks,
    required this.initialValues,
    required this.onFiltered,
    required this.textScale,
    required this.bibleCode,
  });

  final Key? key;

  final List<BibleBook> allBooks;

  final List<BibleBook> initialValues;

  final dynamic Function(List<BibleBook>) onFiltered;

  final double textScale;

  final String bibleCode;

  @override
  String toString() {
    return 'BibleSearchFilterRouteArgs{key: $key, allBooks: $allBooks, initialValues: $initialValues, onFiltered: $onFiltered, textScale: $textScale, bibleCode: $bibleCode}';
  }
}

/// generated route for
/// [BibleAudioSettingView]
class BibleAudioSettingRoute extends PageRouteInfo<BibleAudioSettingRouteArgs> {
  BibleAudioSettingRoute({
    Key? key,
    required Map<String, Map<dynamic, dynamic>> initialVoices,
    required double initialPitchRate,
    required double initialSpeedRate,
    required dynamic Function(
      Map<String, Map<dynamic, dynamic>>,
      double,
      double,
    ) onSave,
    List<PageRouteInfo>? children,
  }) : super(
          BibleAudioSettingRoute.name,
          args: BibleAudioSettingRouteArgs(
            key: key,
            initialVoices: initialVoices,
            initialPitchRate: initialPitchRate,
            initialSpeedRate: initialSpeedRate,
            onSave: onSave,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleAudioSettingRoute';

  static const PageInfo<BibleAudioSettingRouteArgs> page =
      PageInfo<BibleAudioSettingRouteArgs>(name);
}

class BibleAudioSettingRouteArgs {
  const BibleAudioSettingRouteArgs({
    this.key,
    required this.initialVoices,
    required this.initialPitchRate,
    required this.initialSpeedRate,
    required this.onSave,
  });

  final Key? key;

  final Map<String, Map<dynamic, dynamic>> initialVoices;

  final double initialPitchRate;

  final double initialSpeedRate;

  final dynamic Function(
    Map<String, Map<dynamic, dynamic>>,
    double,
    double,
  ) onSave;

  @override
  String toString() {
    return 'BibleAudioSettingRouteArgs{key: $key, initialVoices: $initialVoices, initialPitchRate: $initialPitchRate, initialSpeedRate: $initialSpeedRate, onSave: $onSave}';
  }
}

/// generated route for
/// [BibleNoteView]
class BibleNoteRoute extends PageRouteInfo<BibleNoteRouteArgs> {
  BibleNoteRoute({
    Key? key,
    required BibleNote initialData,
    required BibleCubit cubit,
    required NoteMode mode,
    required dynamic Function(BibleNote) onSave,
    List<PageRouteInfo>? children,
  }) : super(
          BibleNoteRoute.name,
          args: BibleNoteRouteArgs(
            key: key,
            initialData: initialData,
            cubit: cubit,
            mode: mode,
            onSave: onSave,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleNoteRoute';

  static const PageInfo<BibleNoteRouteArgs> page =
      PageInfo<BibleNoteRouteArgs>(name);
}

class BibleNoteRouteArgs {
  const BibleNoteRouteArgs({
    this.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  final Key? key;

  final BibleNote initialData;

  final BibleCubit cubit;

  final NoteMode mode;

  final dynamic Function(BibleNote) onSave;

  @override
  String toString() {
    return 'BibleNoteRouteArgs{key: $key, initialData: $initialData, cubit: $cubit, mode: $mode, onSave: $onSave}';
  }
}

/// generated route for
/// [BibleListView]
class BibleListRoute extends PageRouteInfo<BibleListRouteArgs> {
  BibleListRoute({
    Key? key,
    required List<BibleBook> books,
    required Future<List<Verse>> Function(
      int?,
      int?,
    ) getBibles,
    required dynamic Function(Verse) onSelected,
    required double textScale,
    required String bibleCode,
    List<PageRouteInfo>? children,
  }) : super(
          BibleListRoute.name,
          args: BibleListRouteArgs(
            key: key,
            books: books,
            getBibles: getBibles,
            onSelected: onSelected,
            textScale: textScale,
            bibleCode: bibleCode,
          ),
          initialChildren: children,
        );

  static const String name = 'BibleListRoute';

  static const PageInfo<BibleListRouteArgs> page =
      PageInfo<BibleListRouteArgs>(name);
}

class BibleListRouteArgs {
  const BibleListRouteArgs({
    this.key,
    required this.books,
    required this.getBibles,
    required this.onSelected,
    required this.textScale,
    required this.bibleCode,
  });

  final Key? key;

  final List<BibleBook> books;

  final Future<List<Verse>> Function(
    int?,
    int?,
  ) getBibles;

  final dynamic Function(Verse) onSelected;

  final double textScale;

  final String bibleCode;

  @override
  String toString() {
    return 'BibleListRouteArgs{key: $key, books: $books, getBibles: $getBibles, onSelected: $onSelected, textScale: $textScale, bibleCode: $bibleCode}';
  }
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
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    required dynamic Function(String) onLoggedIn,
    List<PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(
            key: key,
            onLoggedIn: onLoggedIn,
          ),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<LoginRouteArgs> page = PageInfo<LoginRouteArgs>(name);
}

class LoginRouteArgs {
  const LoginRouteArgs({
    this.key,
    required this.onLoggedIn,
  });

  final Key? key;

  final dynamic Function(String) onLoggedIn;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onLoggedIn: $onLoggedIn}';
  }
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
/// [SongNotesListView]
class SongNotesListRoute extends PageRouteInfo<SongNotesListRouteArgs> {
  SongNotesListRoute({
    Key? key,
    required SongCubit cubit,
    List<PageRouteInfo>? children,
  }) : super(
          SongNotesListRoute.name,
          args: SongNotesListRouteArgs(
            key: key,
            cubit: cubit,
          ),
          initialChildren: children,
        );

  static const String name = 'SongNotesListRoute';

  static const PageInfo<SongNotesListRouteArgs> page =
      PageInfo<SongNotesListRouteArgs>(name);
}

class SongNotesListRouteArgs {
  const SongNotesListRouteArgs({
    this.key,
    required this.cubit,
  });

  final Key? key;

  final SongCubit cubit;

  @override
  String toString() {
    return 'SongNotesListRouteArgs{key: $key, cubit: $cubit}';
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
    required String initialSearchText,
    required dynamic Function(String) onSearchTermsChanged,
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
            initialSearchText: initialSearchText,
            onSearchTermsChanged: onSearchTermsChanged,
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
    required this.initialSearchText,
    required this.onSearchTermsChanged,
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

  final String initialSearchText;

  final dynamic Function(String) onSearchTermsChanged;

  @override
  String toString() {
    return 'SongListRouteArgs{key: $key, books: $books, currentBook: $currentBook, onTapPageNumber: $onTapPageNumber, onChangeBookCode: $onChangeBookCode, isFavorite: $isFavorite, onFavorite: $onFavorite, favoriteBooks: $favoriteBooks, onTapFavorite: $onTapFavorite, initialSearchText: $initialSearchText, onSearchTermsChanged: $onSearchTermsChanged}';
  }
}

/// generated route for
/// [SongNoteView]
class SongNoteRoute extends PageRouteInfo<SongNoteRouteArgs> {
  SongNoteRoute({
    Key? key,
    required SongNote initialData,
    required SongCubit cubit,
    required NoteMode mode,
    required dynamic Function(SongNote) onSave,
    List<PageRouteInfo>? children,
  }) : super(
          SongNoteRoute.name,
          args: SongNoteRouteArgs(
            key: key,
            initialData: initialData,
            cubit: cubit,
            mode: mode,
            onSave: onSave,
          ),
          initialChildren: children,
        );

  static const String name = 'SongNoteRoute';

  static const PageInfo<SongNoteRouteArgs> page =
      PageInfo<SongNoteRouteArgs>(name);
}

class SongNoteRouteArgs {
  const SongNoteRouteArgs({
    this.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  final Key? key;

  final SongNote initialData;

  final SongCubit cubit;

  final NoteMode mode;

  final dynamic Function(SongNote) onSave;

  @override
  String toString() {
    return 'SongNoteRouteArgs{key: $key, initialData: $initialData, cubit: $cubit, mode: $mode, onSave: $onSave}';
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
/// [FontSettingView]
class FontSettingRoute extends PageRouteInfo<void> {
  const FontSettingRoute({List<PageRouteInfo>? children})
      : super(
          FontSettingRoute.name,
          initialChildren: children,
        );

  static const String name = 'FontSettingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ReportView]
class ReportRoute extends PageRouteInfo<ReportRouteArgs> {
  ReportRoute({
    Key? key,
    Account? account,
    required Future<Account?> Function(String) onLoggedIn,
    List<PageRouteInfo>? children,
  }) : super(
          ReportRoute.name,
          args: ReportRouteArgs(
            key: key,
            account: account,
            onLoggedIn: onLoggedIn,
          ),
          initialChildren: children,
        );

  static const String name = 'ReportRoute';

  static const PageInfo<ReportRouteArgs> page = PageInfo<ReportRouteArgs>(name);
}

class ReportRouteArgs {
  const ReportRouteArgs({
    this.key,
    this.account,
    required this.onLoggedIn,
  });

  final Key? key;

  final Account? account;

  final Future<Account?> Function(String) onLoggedIn;

  @override
  String toString() {
    return 'ReportRouteArgs{key: $key, account: $account, onLoggedIn: $onLoggedIn}';
  }
}

/// generated route for
/// [FaithNoteListView]
class FaithNoteListRoute extends PageRouteInfo<FaithNoteListRouteArgs> {
  FaithNoteListRoute({
    Key? key,
    required FaithCubit cubit,
    List<PageRouteInfo>? children,
  }) : super(
          FaithNoteListRoute.name,
          args: FaithNoteListRouteArgs(
            key: key,
            cubit: cubit,
          ),
          initialChildren: children,
        );

  static const String name = 'FaithNoteListRoute';

  static const PageInfo<FaithNoteListRouteArgs> page =
      PageInfo<FaithNoteListRouteArgs>(name);
}

class FaithNoteListRouteArgs {
  const FaithNoteListRouteArgs({
    this.key,
    required this.cubit,
  });

  final Key? key;

  final FaithCubit cubit;

  @override
  String toString() {
    return 'FaithNoteListRouteArgs{key: $key, cubit: $cubit}';
  }
}

/// generated route for
/// [FaithNoteView]
class FaithNoteRoute extends PageRouteInfo<FaithNoteRouteArgs> {
  FaithNoteRoute({
    Key? key,
    required FaithNote initialData,
    required FaithCubit cubit,
    required NoteMode mode,
    required dynamic Function(FaithNote) onSave,
    List<PageRouteInfo>? children,
  }) : super(
          FaithNoteRoute.name,
          args: FaithNoteRouteArgs(
            key: key,
            initialData: initialData,
            cubit: cubit,
            mode: mode,
            onSave: onSave,
          ),
          initialChildren: children,
        );

  static const String name = 'FaithNoteRoute';

  static const PageInfo<FaithNoteRouteArgs> page =
      PageInfo<FaithNoteRouteArgs>(name);
}

class FaithNoteRouteArgs {
  const FaithNoteRouteArgs({
    this.key,
    required this.initialData,
    required this.cubit,
    required this.mode,
    required this.onSave,
  });

  final Key? key;

  final FaithNote initialData;

  final FaithCubit cubit;

  final NoteMode mode;

  final dynamic Function(FaithNote) onSave;

  @override
  String toString() {
    return 'FaithNoteRouteArgs{key: $key, initialData: $initialData, cubit: $cubit, mode: $mode, onSave: $onSave}';
  }
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

/// generated route for
/// [BackupView]
class BackupRoute extends PageRouteInfo<BackupRouteArgs> {
  BackupRoute({
    Key? key,
    required AppBackupData data,
    required dynamic Function(AppBackupData) onSynced,
    List<PageRouteInfo>? children,
  }) : super(
          BackupRoute.name,
          args: BackupRouteArgs(
            key: key,
            data: data,
            onSynced: onSynced,
          ),
          initialChildren: children,
        );

  static const String name = 'BackupRoute';

  static const PageInfo<BackupRouteArgs> page = PageInfo<BackupRouteArgs>(name);
}

class BackupRouteArgs {
  const BackupRouteArgs({
    this.key,
    required this.data,
    required this.onSynced,
  });

  final Key? key;

  final AppBackupData data;

  final dynamic Function(AppBackupData) onSynced;

  @override
  String toString() {
    return 'BackupRouteArgs{key: $key, data: $data, onSynced: $onSynced}';
  }
}
