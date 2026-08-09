import 'dart:async';
import 'dart:developer';
import 'dart:io' show Directory, File, Platform;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

import 'components/themes/dark_theme.dart';
import 'components/themes/default_theme.dart';
import 'data/data.dart';
import 'data/services/fast_hydrated_storage.dart';
import 'di/injection.dart';
import 'domain/entity/appconfig/appconfig.dart';
import 'presentations/presentations.dart';
import 'router/router.dart';

Future<void> initApplication() async {
  final initStopwatch = Stopwatch()..start();
  void initLog(String message) {
    if (kDebugMode) {
      debugPrint('[initApplication +${initStopwatch.elapsed}] $message');
    }
  }

  initLog('starting');
  final appConfig = AppConfig(
    appName: 'GYS APP',
    baseUrlApi: 'https://e.gys.or.id/api/v1',
  );

  // A single Flutter binding is used for every build mode. Debug tooling must
  // not replace the application binding or add work to the production app.
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Native splash is useful on mobile only. Desktop renders the first frame
  // immediately to avoid hit testing an unlaid-out preserved surface.
  final preserveNativeSplash =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  if (preserveNativeSplash) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }

  // Select the SQLite backend before any database-backed feature is created.
  initLog('sqlite init begin');
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (!Platform.isAndroid && !Platform.isIOS) {
    try {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfiNoIsolate;
    } catch (e, st) {
      log(
        'sqflite FFI init failed, continuing: $e',
        error: e,
        stackTrace: st,
        name: 'App',
      );
    }
  }
  initLog('sqlite init done');

  // PDF runtime initialization is already guarded and non-blocking.
  if (!kIsWeb) _initializePdfRuntime();

  // One-time migration for pre-2.1 Android data. Keep it isolated from other
  // platforms because the path below is Android application-private storage.
  if (!kIsWeb && Platform.isAndroid) {
    try {
      final versionFile = File('/data/data/id.sch.kanaan.egys/cache/app_version');
      const currentMigrationVersion = '2.1.0';
      var storedVersion = '0.0.0';
      if (await versionFile.exists()) {
        storedVersion = (await versionFile.readAsString()).trim();
      }

      bool isOlderThan2_1(String version) {
        final parts = version.split('.');
        if (parts.length < 2) return true;
        final major = int.tryParse(parts[0]) ?? 0;
        final minor = int.tryParse(parts[1]) ?? 0;
        return major < 2 || (major == 2 && minor < 1);
      }

      if (isOlderThan2_1(storedVersion)) {
        initLog('Applying pre-2.1 storage migration');
        final dataDir = Directory('/data/data/id.sch.kanaan.egys');
        if (await dataDir.exists()) {
          await for (final entity in dataDir.list()) {
            final name = entity.path.split('/').last;
            if (name == 'code_cache') continue;
            await entity.delete(recursive: true);
          }
        }
        await Directory('/data/data/id.sch.kanaan.egys/code_cache')
            .create(recursive: true);
      }

      if (storedVersion != currentMigrationVersion) {
        await versionFile.parent.create(recursive: true);
        await versionFile.writeAsString(currentMigrationVersion, flush: false);
      }
    } catch (e, st) {
      log('Migration check failed', error: e, stackTrace: st, name: 'App');
    }
  }

  HydratedBloc.storage = FastFileStorage();
  await (HydratedBloc.storage as FastFileStorage).init();
  initLog('hydrated storage ready');

  try {
    await EasyLocalization.ensureInitialized().timeout(
      const Duration(seconds: 5),
    );
    initLog('localization ready');
  } catch (e) {
    initLog('EasyLocalization failed or timed out: $e');
  }

  // DI registration is required by App/MaterialApp. Unlike optional startup
  // services, do not silently continue with an incomplete dependency graph.
  await setupInjection(appConfig).timeout(const Duration(seconds: 10));
  initLog('dependency injection ready');

  if (isNotificationConfiguredForCurrentPlatform) {
    unawaited(
      _setupNotification()
          .then((_) => initLog('notifications ready'))
          .catchError((Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          log(
            'Notification setup failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }),
    );
  }

  FlutterError.onError = FlutterError.presentError;
  AppConfigStore.useFallbackConfig();

  if (preserveNativeSplash || kIsWeb) {
    FlutterNativeSplash.remove();
  }
  initLog('done');
}

void _initializePdfRuntime() {
  if (Platform.isWindows) {
    final runnerDll = File(
      '${File(Platform.resolvedExecutable).parent.path}\\pdfium.dll',
    );
    if (runnerDll.existsSync()) {
      Pdfrx.pdfiumModulePath = runnerDll.path;
    }
  }
  unawaited(
    pdfrxFlutterInitialize().catchError((Object e, StackTrace st) {
      log('pdfrx init failed', error: e, stackTrace: st, name: 'App');
    }),
  );
}

Future<void> _setupNotification() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'gys',
        channelName: 'gys_channel',
        channelDescription: 'GYS Notification',
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'gys_group',
        channelGroupName: 'GYS Notification Group',
      ),
    ],
    debug: kDebugMode,
  );
}

final defaultAddress = AddressCheckOption(
  uri: Uri.parse('https://e.gys.or.id/api/v1/users/profile'),
  timeout: const Duration(seconds: 3),
);

final internetChecker = InternetConnectionChecker.createInstance(
  // The app performs explicit reachability checks. A one-second recurring
  // interval is unnecessarily aggressive if a listener is attached later.
  checkInterval: const Duration(seconds: 30),
  checkTimeout: const Duration(seconds: 5),
  addresses: [defaultAddress],
);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InitialCubit>(create: (context) => di()),
        BlocProvider<BackupCubit>(create: (context) => di()),
        BlocProvider<SongCubit>(create: (context) => di()),
      ],
      child: BlocBuilder<InitialCubit, InitialState>(
        buildWhen: (prev, curr) =>
            prev.defaultFont != curr.defaultFont ||
            prev.accentKey != curr.accentKey ||
            prev.themeMode != curr.themeMode ||
            prev.themePreferences != curr.themePreferences,
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Gereja Yesus Sejati',
            scrollBehavior: const _SmoothScrollBehavior(),
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router.config(),
            theme: defaultTheme(
              state.defaultFont,
              accentKey: state.accentKey,
              customSeed: state.themePreferences.customAccentColor,
              density: state.themePreferences.density,
              cornerRadius: state.themePreferences.cornerRadius,
              typographyScale: state.themePreferences.typographyScale,
            ),
            debugShowCheckedModeBanner: false,
            darkTheme: darkTheme(
              state.defaultFont,
              accentKey: state.accentKey,
              customSeed: state.themePreferences.customAccentColor,
              density: state.themePreferences.density,
              cornerRadius: state.themePreferences.cornerRadius,
              typographyScale: state.themePreferences.typographyScale,
            ),
            themeMode: state.themeMode.toThemeMode,
            builder: (context, child) {
              return BlocBuilder<InitialCubit, InitialState>(
                buildWhen: (prev, curr) =>
                    prev.defaultTextScale != curr.defaultTextScale ||
                    prev.themeMode != curr.themeMode,
                builder: (context, state) {
                  return MediaQuery(
                    data: context.mediaQuery.copyWith(
                      alwaysUse24HourFormat: true,
                      textScaler: TextScaler.linear(state.defaultTextScale),
                      platformBrightness:
                          state.themeMode.toThemeMode == ThemeMode.dark
                          ? Brightness.dark
                          : Brightness.light,
                    ),
                    child: child!,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.invertedStylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.android:
        return const ClampingScrollPhysics();
      case TargetPlatform.iOS:
        return const BouncingScrollPhysics();
      default:
        return const AlwaysScrollableScrollPhysics(
          parent: ClampingScrollPhysics(),
        );
    }
  }
}
