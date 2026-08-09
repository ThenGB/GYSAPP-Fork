import 'package:flutter/foundation.dart';

enum AuthProvider { google, apple }

enum AuthFlow {
  hostedWeb,
  googleWeb,
  appleWeb,
  googleNative,
  appleNative,
}

/// Single source of truth for authentication routing.
///
/// Debug native builds intentionally use the hosted e-GYS web flow so debug
/// behavior is deterministic across Android/iOS/Windows. Release builds use a
/// native provider only where the repository has a supported native flow;
/// otherwise they fall back to the hosted e-GYS flow.
abstract final class AuthFlowPolicy {
  static AuthFlow resolve({
    required AuthProvider provider,
    required bool isWeb,
    required bool isDebug,
    required TargetPlatform platform,
  }) {
    if (isWeb) {
      return switch (provider) {
        AuthProvider.google => AuthFlow.googleWeb,
        AuthProvider.apple => AuthFlow.appleWeb,
      };
    }

    if (isDebug) return AuthFlow.hostedWeb;

    return switch ((provider, platform)) {
      (AuthProvider.google, TargetPlatform.android) => AuthFlow.googleNative,
      (AuthProvider.apple, TargetPlatform.iOS) ||
      (AuthProvider.apple, TargetPlatform.macOS) => AuthFlow.appleNative,
      _ => AuthFlow.hostedWeb,
    };
  }
}
