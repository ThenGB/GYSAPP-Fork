import 'package:church/presentations/auth/auth_flow_policy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthFlowPolicy', () {
    test('web always uses provider-specific web flow', () {
      for (final platform in TargetPlatform.values) {
        expect(
          AuthFlowPolicy.resolve(
            provider: AuthProvider.google,
            isWeb: true,
            isDebug: true,
            platform: platform,
          ),
          AuthFlow.googleWeb,
        );
        expect(
          AuthFlowPolicy.resolve(
            provider: AuthProvider.apple,
            isWeb: true,
            isDebug: false,
            platform: platform,
          ),
          AuthFlow.appleWeb,
        );
      }
    });

    test('all native debug builds use hosted web auth', () {
      for (final platform in TargetPlatform.values) {
        for (final provider in AuthProvider.values) {
          expect(
            AuthFlowPolicy.resolve(
              provider: provider,
              isWeb: false,
              isDebug: true,
              platform: platform,
            ),
            AuthFlow.hostedWeb,
          );
        }
      }
    });

    test('Android release uses native Google and hosted Apple', () {
      expect(
        AuthFlowPolicy.resolve(
          provider: AuthProvider.google,
          isWeb: false,
          isDebug: false,
          platform: TargetPlatform.android,
        ),
        AuthFlow.googleNative,
      );
      expect(
        AuthFlowPolicy.resolve(
          provider: AuthProvider.apple,
          isWeb: false,
          isDebug: false,
          platform: TargetPlatform.android,
        ),
        AuthFlow.hostedWeb,
      );
    });

    test('Apple release platforms use native Apple', () {
      for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
        expect(
          AuthFlowPolicy.resolve(
            provider: AuthProvider.apple,
            isWeb: false,
            isDebug: false,
            platform: platform,
          ),
          AuthFlow.appleNative,
        );
      }
    });

    test('Windows release uses hosted provider flows', () {
      for (final provider in AuthProvider.values) {
        expect(
          AuthFlowPolicy.resolve(
            provider: provider,
            isWeb: false,
            isDebug: false,
            platform: TargetPlatform.windows,
          ),
          AuthFlow.hostedWeb,
        );
      }
    });
  });
}
