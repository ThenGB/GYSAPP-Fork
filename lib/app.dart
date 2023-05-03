import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:church/components/themes/default_theme.dart';
import 'package:church/data/utilities/extensions/context_ext.dart';
import 'package:church/di/injection.dart';
import 'package:church/firebase_options.dart';
import 'package:church/presentations/initial/bloc/initial_cubit.dart';
import 'package:church/router/router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path_provider/path_provider.dart';

Future initApplication() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationSupportDirectory(),
  );
  await EasyLocalization.ensureInitialized();
  await setupInjection();
  await _setupNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseRemoteConfig.instance.ensureInitialized();
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

var defaultAddress = AddressCheckOptions(
  address: InternetAddress(
    '8.8.8.8',
    type: InternetAddressType.IPv4,
  ),
  port: 853,
  timeout: const Duration(seconds: 10),
);

var internetChecker = InternetConnectionChecker.createInstance(
  checkInterval: const Duration(seconds: 1),
  checkTimeout: const Duration(seconds: 5),
  addresses: [defaultAddress, ...InternetConnectionChecker.DEFAULT_ADDRESSES],
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
    connectivitySubscription = internetChecker.onStatusChange
        .listen((InternetConnectionStatus status) {
      log('status $status');
    });
    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Gereja Yesus Sejati',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routerConfig: router.config(),
      theme: defaultTheme(),
      builder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<InitialCubit>(
            create: (context) => di(),
          ),
        ],
        child: MediaQuery(
            data: context.mediaQuery.copyWith(textScaleFactor: 1),
            child: child!),
      ),
    );
  }
}
