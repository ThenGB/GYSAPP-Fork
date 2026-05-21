import 'package:flutter/foundation.dart';

bool get isNotificationConfiguredForCurrentPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

bool get isWebViewConfiguredForCurrentPlatform =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

bool get isTextToSpeechConfiguredForCurrentPlatform => !kIsWeb;

bool get canStopIdleTextToSpeechForCurrentPlatform =>
    defaultTargetPlatform != TargetPlatform.windows;

bool get isGoogleSignInConfiguredForCurrentPlatform =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

bool get isAppAuthConfiguredForCurrentPlatform =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

bool get isFluttertoastConfiguredForCurrentPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);
