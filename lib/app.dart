import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';
import 'components/themes/dark_theme.dart';
import 'components/themes/default_theme.dart';
import 'data/data.dart';
import 'di/injection.dart';
import 'domain/entity/appconfig/appconfig.dart';
import 'firebase_options.dart';
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
  var appConfig =
      AppConfig(appName: 'GYS APP', baseUrlApi: 'https://e.gys.or.id/api/v1');
  var widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  initLog('flutter binding ready');
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
    await _setupNotification();
    initLog('notifications ready');
  }
  if (isFirebaseCoreConfiguredForCurrentPlatform) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (isFirebaseCrashlyticsConfiguredForCurrentPlatform) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      Isolate.current.addErrorListener(RawReceivePort((pair) {
        final errorAndStackTrace = pair as List<dynamic>;
        FirebaseCrashlytics.instance.recordError(
          errorAndStackTrace.firstOrNull,
          StackTrace.fromString(errorAndStackTrace.lastOrNull ?? ''),
          fatal: true,
        );
      }).sendPort);
    } else {
      FlutterError.onError = FlutterError.presentError;
    }
    if (isFirebaseRemoteConfigConfiguredForCurrentPlatform) {
      await FirebaseRemoteConfig.instance.ensureInitialized();
      if (isFirebaseAppCheckConfiguredForCurrentPlatform) {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kReleaseMode
              ? const AndroidPlayIntegrityProvider()
              : const AndroidDebugProvider(),
          providerApple: const AppleAppAttestProvider(),
        );
      }
      initLog('firebase ready');
    } else {
      FirebaseUtils.useFallbackConfig();
      initLog('firebase core ready with fallback remote config');
    }
  } else {
    FirebaseUtils.useFallbackConfig();
    FlutterError.onError = FlutterError.presentError;
    initLog('using fallback firebase config');
  }

  await _setupLocalData();
  initLog('local data ready');
  FlutterNativeSplash.remove();
  initLog('done');
  log('App Initialization DONE');
}

Future _setupLocalData() async {
  // Static song and default Bible data are now read lazily from non-SQL
  // JSON assets, so startup no longer copies large PDFs/DB files.
  await di<LocalAssetService>().initialize();
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
    debug: true,
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
  addresses: [
    defaultAddress,
  ],
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
        BlocProvider<InitialCubit>(
          create: (context) => di(),
        ),
        BlocProvider<BackupCubit>(
          create: (context) => di(),
        ),
        BlocProvider<SongCubit>(
          create: (context) => di(),
        ),
      ],
      child: BlocBuilder<InitialCubit, InitialState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'Gereja Yesus Sejati',
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router.config(),
            theme: defaultTheme(state.defaultFont),
            debugShowCheckedModeBanner: false,
            darkTheme: darkTheme(state.defaultFont),
            themeMode: state.themeMode.toThemeMode,
            builder: (context, child) {
              // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              //   SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
              // });
              return DevicePreview.appBuilder(
                context,
                BlocBuilder<InitialCubit, InitialState>(
                  builder: (context, state) => MediaQuery(
                    data: context.mediaQuery.copyWith(
                      alwaysUse24HourFormat: true,
                      textScaler: TextScaler.linear(state.defaultTextScale),
                    ),
                    child: child!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
