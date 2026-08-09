import 'package:church/data/services/auth_session_credential.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hosted session credentials round-trip without exposing raw cookies', () {
    const cookie = 'session=abc123; Path=/; HttpOnly';
    final credential = encodeHostedSessionCredential(cookie);

    expect(credential, startsWith(hostedSessionCredentialPrefix));
    expect(credential, isNot(contains('abc123')));
    expect(isHostedSessionCredential(credential), isTrue);
    expect(decodeHostedSessionCredential(credential), cookie);
  });

  test('ordinary bearer tokens are never mistaken for hosted sessions', () {
    const token = 'opaque.jwt.or-provider-token';
    expect(isHostedSessionCredential(token), isFalse);
    expect(decodeHostedSessionCredential(token), isNull);
  });

  test('invalid encoded session credentials are rejected', () {
    expect(
      decodeHostedSessionCredential('$hostedSessionCredentialPrefix%%%'),
      isNull,
    );
  });
}
