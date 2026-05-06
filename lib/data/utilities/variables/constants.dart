import 'dart:io' show Platform;

const refreshTokenKey = 'refresh_token';
const backendTokenKey = 'backend_token';
const googleIssuer = 'https://accounts.google.com';
String get googleClientIdIos =>
    '705603488262-ac8j11n290iu5nu6fg1nmca3o1jmml30.apps.googleusercontent.com';
String get googleRedirectUriIos =>
    '${googleClientIdIos.split('.').reversed.join('.')}:/oauthredirect';
String get googleClientIdAndroid =>
    '705603488262-nngndk9jgsqjtn9uaadg5aqmtrcl5l5h.apps.googleusercontent.com';
String get googleRedirectUriAndroid =>
    '${googleClientIdAndroid.split('.').reversed.join('.')}:/oauthredirect';

String clientID() {
  late String result;
  if (Platform.isAndroid) {
    result = googleClientIdAndroid;
  } else if (Platform.isIOS) {
    result = googleClientIdIos;
  } else {
    result = '';
  }
  return result;
}

String redirectUrl() {
  if (Platform.isAndroid) {
    return googleRedirectUriAndroid;
  } else if (Platform.isIOS) {
    return googleRedirectUriIos;
  }
  return '';
}

