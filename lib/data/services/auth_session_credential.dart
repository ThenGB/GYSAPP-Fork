import 'dart:convert';

const String hostedSessionCredentialPrefix = 'gys-cookie-v1:';

String encodeHostedSessionCredential(String cookieHeader) {
  final normalized = cookieHeader.trim();
  if (normalized.isEmpty) return '';
  final payload = base64Url.encode(utf8.encode(normalized));
  return '$hostedSessionCredentialPrefix$payload';
}

String? decodeHostedSessionCredential(String credential) {
  if (!credential.startsWith(hostedSessionCredentialPrefix)) return null;
  final payload = credential.substring(hostedSessionCredentialPrefix.length);
  if (payload.isEmpty) return null;
  try {
    return utf8.decode(base64Url.decode(payload));
  } catch (_) {
    return null;
  }
}

bool isHostedSessionCredential(String credential) =>
    credential.startsWith(hostedSessionCredentialPrefix) &&
    decodeHostedSessionCredential(credential) != null;
