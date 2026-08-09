from pathlib import Path

path = Path('lib/presentations/auth/view/login_view.dart')
text = path.read_text(encoding='utf-8-sig')

if "../auth_flow_policy.dart" not in text:
    text = text.replace(
        "import '../cubit/auth_cubit.dart';\n",
        "import '../auth_flow_policy.dart';\nimport '../cubit/auth_cubit.dart';\n",
        1,
    )

old_google = '''  void _dispatchGoogleLogin() {
    // Debug deliberately exercises the hosted browser flow on every native
    // platform, as requested. Web itself uses the official GIS button.
    if (kDebugMode && !kIsWeb) {
      _startHostedOAuth('/auth/google');
      return;
    }

    if (kIsWeb) return;
    if (defaultTargetPlatform == TargetPlatform.android) {
      unawaited(_handleGoogleNative());
    } else {
      // iOS/macOS/Windows keep Google available through the same e-GYS web
      // flow without requiring a second native Google client configuration.
      _startHostedOAuth('/auth/google');
    }
  }
'''
new_google = '''  void _dispatchGoogleLogin() {
    final flow = AuthFlowPolicy.resolve(
      provider: AuthProvider.google,
      isWeb: kIsWeb,
      isDebug: kDebugMode,
      platform: defaultTargetPlatform,
    );
    _authDebug('Google auth flow: ${flow.name}');

    switch (flow) {
      case AuthFlow.hostedWeb:
        _startHostedOAuth('/auth/google');
        return;
      case AuthFlow.googleNative:
        unawaited(_handleGoogleNative());
        return;
      case AuthFlow.googleWeb:
        // The official GIS button owns the interactive web sign-in.
        return;
      case AuthFlow.appleWeb:
      case AuthFlow.appleNative:
        return;
    }
  }
'''
if old_google not in text:
    raise SystemExit('Google dispatch block not found')
text = text.replace(old_google, new_google, 1)

old_apple = '''  void _dispatchAppleLogin() {
    if (kDebugMode && !kIsWeb) {
      _startHostedOAuth('/auth/apple');
      return;
    }

    if (kIsWeb) {
      unawaited(_handleAppleWeb());
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      unawaited(_handleAppleNative());
    } else {
      _startHostedOAuth('/auth/apple');
    }
  }
'''
new_apple = '''  void _dispatchAppleLogin() {
    final flow = AuthFlowPolicy.resolve(
      provider: AuthProvider.apple,
      isWeb: kIsWeb,
      isDebug: kDebugMode,
      platform: defaultTargetPlatform,
    );
    _authDebug('Apple auth flow: ${flow.name}');

    switch (flow) {
      case AuthFlow.hostedWeb:
        _startHostedOAuth('/auth/apple');
        return;
      case AuthFlow.appleNative:
        unawaited(_handleAppleNative());
        return;
      case AuthFlow.appleWeb:
        unawaited(_handleAppleWeb());
        return;
      case AuthFlow.googleWeb:
      case AuthFlow.googleNative:
        return;
    }
  }
'''
if old_apple not in text:
    raise SystemExit('Apple dispatch block not found')
text = text.replace(old_apple, new_apple, 1)

path.write_text(text, encoding='utf-8')
