import 'package:flutter/foundation.dart';

bool get isNotificationConfiguredForCurrentPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

bool get isTextToSpeechConfiguredForCurrentPlatform => !kIsWeb;

bool get canStopIdleTextToSpeechForCurrentPlatform =>
    defaultTargetPlatform != TargetPlatform.windows;

bool get isFluttertoastConfiguredForCurrentPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);
