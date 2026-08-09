import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthTokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureAuthTokenStore implements AuthTokenStore {
  SecureAuthTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              webOptions: WebOptions(useSessionStorage: true),
            );

  static const _tokenKey = 'gys_auth_token_v1';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() async {
    final value = await _storage.read(key: _tokenKey);
    final token = value?.trim() ?? '';
    return token.isEmpty ? null : token;
  }

  @override
  Future<void> write(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      await clear();
      return;
    }
    await _storage.write(key: _tokenKey, value: normalized);
  }

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}
