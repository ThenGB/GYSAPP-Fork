import 'dart:async';
import 'dart:developer';
import 'dart:io' show Directory, File, Platform;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pdfrx/pdfrx.dart';
import 'components/themes/dark_theme.dart';
import 'components/themes/default_theme.dart';
import 'data/data.dart';
import 'data/services/fast_hydrated_storage.dart';
import 'di/injection.dart';
import 'domain/entity/appconfig/appconfig.dart';
import 'presentations/presentations.dart';
import 'router/router.dart';

Future initApplication() async {
  final initStopwatch = Stopwatch()..start();
  void initLog(String message) {
    if (kDebugMode) {
      debugPrint('[initApplication +${initStopwatch.elapsed}] $message');
    }
  }

  initLog('starting');
  var appConfig = AppConfig(
    appName: 'GYS APP',
    baseUrlApi: 'https://e.gys.or.id/api/v1',
  );
  final isFlutterTest = Platform.environment.containsKey('FLUTTER_TEST');

  // Only initialize MarionetteBinding on native platforms in debug mode
  // Web platforms don't fully support MarionetteBinding
  WidgetsBinding widgetsBinding;
  if (kDebugMode && !isFlutterTest && !kIsWeb) {
    try {
      MarionetteBinding.ensureInitialized();
      widgetsBinding = MarionetteBinding.instance;
    } catch (e) {
      // Fallback if Marionette fails
      log('MarionetteBinding init failed, using default: $e', name: 'App');
      widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    }
  } else {
    widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  }
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  _initializePdfRuntime();
  initLog('flutter binding ready');

  try {
    // Use native File I/O instead of SharedPreferences (avoids platform channel hang)
    final versionFile = File('/data/data/id.sch.kanaan.egys/cache/app_version');
    // Hardcoded version to avoid PackageInfo platform channel call
    const currentAppVersion = '2.0.30';
    String storedAppVersion = '0.0.0';
    if (await versionFile.exists()) {
      storedAppVersion = (await versionFile.readAsString()).trim();
    }

    bool isOlderThan2_1(String v) {
      final parts = v.split('.');
      if (parts.length < 2) return true;
      final major = int.tryParse(parts[0]) ?? 0;
      final minor = int.tryParse(parts[1]) ?? 0;
      if (major < 2) return true;
      if (major == 2 && minor < 1) return true;
      return false;
    }

    if (currentAppVersion != storedAppVersion) {
      if (isOlderThan2_1(storedAppVersion)) {
        initLog('Updating from older version (< 2.1). Wiping app data...');
        // Wipe app data but preserve essential Android directories
        Future<void> _wipeDir(String p) async {
          final dir = Directory(p);
          if (await dir.exists()) {
            // Delete contents but not the directory itself
            await for (final entity in dir.list()) {
              final name = entity.path.split('/').last;
              // Skip code_cache — Flutter DevFS needs it
              if (name == 'code_cache') continue;
              await entity.delete(recursive: true);
            }
          }
        }
        await _wipeDir('/data/data/id.sch.kanaan.egys');
        // Ensure code_cache exists for Flutter DevFS
        await Directory('/data/data/id.sch.kanaan.egys/code_cache').create(recursive: true);
      }
      await versionFile.parent.create(recursive: true);
      await versionFile.writeAsString(currentAppVersion);
    }
  } catch (e, st) {
    log('Migration check failed', error: e, stackTrace: st, name: 'App');
  }

  HydratedBloc.storage = FastFileStorage();
  await (HydratedBloc.storage as FastFileStorage).init();
  initLog('hydrated storage ready');
  initLog('about to call EasyLocalization.ensureInitialized');
  try {
    await EasyLocalization.ensureInitialized().timeout(const Duration(seconds: 5));
    initLog('localization ready');
  } catch (e) {
    initLog('EasyLocalization failed or timed out: $e — continuing without it');
  }
  initLog('about to call setupInjection');
  try {
    await setupInjection(appConfig).timeout(const Duration(seconds: 10));
    initLog('dependency injection ready');
  } catch (e) {
    initLog('setupInjection failed or timed out: $e — continuing anyway');
  }

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
  initLog('using bundled app config');

  FlutterNativeSplash.remove();
  initLog('done');
  log('App Initialization DONE');
}

void _initializePdfRuntime() {
  if (Platform.isWindows) {
    final executableDir = File(Platform.resolvedExecutable).parent.path;
    Pdfrx.pdfiumModulePath = '$executableDir\\pdfium.dll';
  }
  pdfrxFlutterInitialize();
}

Future _setupNotification() async {
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

var defaultAddress = AddressCheckOption(
  ////8.8.8.8 and 8.8.4.4 are Google's public DNS servers
  uri: Uri.parse('https://e.gys.or.id/api/v1/users/profile'),
  timeout: const Duration(seconds: 3),
);

var internetChecker = InternetConnectionChecker.createInstance(
  checkInterval: const Duration(seconds: 1),
  checkTimeout: const Duration(seconds: 5),
  addresses: [defaultAddress],
);

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription<InternetConnectionStatus>? connectivitySubscription;
  @override
  void initState() {
    // connectivitySubscription = internetChecker.onStatusChange
    //     .listen((InternetConnectionStatus status) {
    //   log('status $status');
    // });
    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InitialCubit>(create: (context) => di()),
        BlocProvider<BackupCubit>(create: (context) => di()),
        BlocProvider<SongCubit>(create: (context) => di()),
      ],
      child: BlocBuilder<InitialCubit, InitialState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Gereja Yesus Sejati',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router.config(),
            theme: defaultTheme(state.defaultFont, accentKey: state.accentKey),
            debugShowCheckedModeBanner: false,
            darkTheme: darkTheme(state.defaultFont, accentKey: state.accentKey),
            themeMode: state.themeMode.toThemeMode,
            builder: (context, child) {
              return BlocBuilder<InitialCubit, InitialState>(
                builder: (context, state) => MediaQuery(
                  data: context.mediaQuery.copyWith(
                    alwaysUse24HourFormat: true,
                    textScaler: TextScaler.linear(state.defaultTextScale),
                    // Force brightness based on theme mode to prevent system dark mode override
                    platformBrightness: state.themeMode.toThemeMode == ThemeMode.dark
                        ? Brightness.dark
                        : Brightness.light,
                  ),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
