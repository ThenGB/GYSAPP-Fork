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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/themes/dark_theme.dart';
import 'components/themes/default_theme.dart';
import 'data/data.dart';
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
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentAppVersion = packageInfo.version;
    final storedAppVersion = prefs.getString('app_version') ?? '0.0.0';

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
        if (!kIsWeb) {
          Future<void> _resetDir(String p) async {
            final d = Directory(p);
            if (await d.exists()) {
              await d.delete(recursive: true);
              await d.create(recursive: true);
            }
          }
          await _resetDir((await getApplicationDocumentsDirectory()).path);
          await _resetDir((await getTemporaryDirectory()).path);
          await _resetDir((await getApplicationSupportDirectory()).path);
        } else {
          await prefs.clear();
        }
      }
      await prefs.setString('app_version', currentAppVersion);
    }
  } catch (e, st) {
    log('Migration check failed', error: e, stackTrace: st, name: 'App');
  }

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationSupportDirectory()).path,
    ),
  );
  initLog('hydrated storage ready');
  await EasyLocalization.ensureInitialized();
  initLog('localization ready');
  await setupInjection(appConfig);
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
              // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              // });
              return BlocBuilder<InitialCubit, InitialState>(
                builder: (context, state) => MediaQuery(
                  data: context.mediaQuery.copyWith(
                    alwaysUse24HourFormat: true,
                    textScaler: TextScaler.linear(state.defaultTextScale),
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
