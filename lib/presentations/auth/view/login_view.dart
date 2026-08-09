import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/components.dart';
import '../../../data/services/auth_session_credential.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../di/injection.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/google_web_button.dart';

void _authDebug(String message) {
  if (kDebugMode) debugPrint('[LoginView] $message');
}

@RoutePage()
class LoginView extends StatefulWidget implements AutoRouteWrapper {
  final Function(String token) onLoggedIn;

  const LoginView({super.key, required this.onLoggedIn});

  @override
  State<LoginView> createState() => _LoginViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (_) => di(), child: this);
  }
}

class _LoginViewState extends State<LoginView> {
  static const _serverClientId =
      '705603488262-70g3bcfan59307rrk610m32n4uhf2tge.apps.googleusercontent.com';
  static const _appleWebClientId = String.fromEnvironment(
    'APPLE_WEB_CLIENT_ID',
  );
  static const _appleWebRedirectUri = String.fromEnvironment(
    'APPLE_WEB_REDIRECT_URI',
  );
  static const _authBaseUrl = 'https://e.gys.or.id';

  InAppWebViewController? _webViewController;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;
  bool _loginHandled = false;
  bool _doingOAuth = false;
  bool _webGoogleReady = false;
  bool _webBusy = false;
  String? _webAuthError;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) unawaited(_initializeGoogleWeb());
  }

  @override
  void dispose() {
    _googleAuthSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeGoogleWeb() async {
    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(clientId: _serverClientId);
      await _googleAuthSubscription?.cancel();
      _googleAuthSubscription = signIn.authenticationEvents.listen(
        (event) {
          if (event is GoogleSignInAuthenticationEventSignIn) {
            unawaited(_exchangeGoogleAccount(event.user));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          _authDebug('Google web auth event failed (${error.runtimeType})');
          if (mounted) {
            setState(() => _webAuthError = 'Google Sign-In gagal. Coba lagi.');
          }
        },
      );
      signIn.attemptLightweightAuthentication();
      if (mounted) setState(() => _webGoogleReady = true);
    } catch (error) {
      _authDebug('Google web initialization failed (${error.runtimeType})');
      if (mounted) {
        setState(() => _webAuthError = 'Google Sign-In belum dapat dimuat.');
      }
    }
  }

  void _completeLogin(Object? token) {
    if (_loginHandled) return;
    final value = token?.toString().trim() ?? '';
    if (value.isEmpty || value == 'null') return;
    _loginHandled = true;
    widget.onLoggedIn(value);
  }

  void _handleToken(Map<String, dynamic> message) {
    if (_loginHandled) return;
    final command = message['cmd']?.toString().toLowerCase();
    switch (command) {
      case 'googlelogin':
        _dispatchGoogleLogin();
        return;
      case 'applelogin':
        _dispatchAppleLogin();
        return;
      case 'googlelogged':
      case 'applelogged':
        _completeLogin(message['token']);
        return;
    }
  }

  void _dispatchGoogleLogin() {
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

  void _dispatchAppleLogin() {
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

  void _startHostedOAuth(String path) {
    if (_doingOAuth || _webViewController == null) return;
    _doingOAuth = true;
    _authDebug('Starting hosted OAuth flow: $path');
    unawaited(
      _webViewController!.loadUrl(
        urlRequest: URLRequest(url: WebUri('$_authBaseUrl$path')),
      ),
    );
  }

  Future<void> _tryExtractHostedSession(
    InAppWebViewController controller,
  ) async {
    if (_loginHandled) return;

    final jsToken = await controller.evaluateJavascript(
      source: '''
      (function() {
        try {
          const keys = ["token", "access_token", "jwt", "id_token"];
          for (const key of keys) {
            const value = localStorage.getItem(key) || sessionStorage.getItem(key);
            if (value && value !== "null" && value !== "undefined") return value;
          }
          return (typeof window.__TOKEN__ !== 'undefined') ? window.__TOKEN__ : null;
        } catch (_) { return null; }
      })();
    ''',
    );
    if (jsToken is String && jsToken.trim().isNotEmpty && jsToken != 'null') {
      _completeLogin(jsToken);
      return;
    }

    final isLoggedIn = await controller.evaluateJavascript(
      source: '''
      (function() {
        try {
          if (document.querySelector('a[href*="logout"], .user-menu, .user-info, .profile-name, [data-user]')) return true;
          const body = document.body && document.body.innerText || '';
          return body.includes('Keluar') || body.includes('Logout') || body.includes('Profil');
        } catch (_) { return false; }
      })();
    ''',
    );
    if (isLoggedIn != true) return;

    final cookies = await CookieManager.instance().getCookies(
      url: WebUri(_authBaseUrl),
    );
    final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    if (cookieHeader.isEmpty) return;

    // Prefer an application token when the backend exposes one. The session
    // cookie is retained only as a compatibility fallback for hosted debug
    // auth; it is never printed to logs.
    try {
      final response = await http
          .get(
            Uri.parse('$_authBaseUrl/users/profile'),
            headers: {'Cookie': cookieHeader},
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is Map && body['token'] != null) {
          _completeLogin(body['token']);
          return;
        }
      }
    } catch (_) {
      // Session fallback below keeps older backend deployments usable.
    }
    _completeLogin(encodeHostedSessionCredential(cookieHeader));
  }

  Future<void> _handleGoogleNative() async {
    try {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(serverClientId: _serverClientId);
      if (!signIn.supportsAuthenticate()) {
        _startHostedOAuth('/auth/google');
        return;
      }
      final account = await signIn.authenticate();
      await _exchangeGoogleAccount(account);
    } catch (error) {
      _authDebug('Native Google sign-in failed (${error.runtimeType})');
      _startHostedOAuth('/auth/google');
    }
  }

  Future<void> _exchangeGoogleAccount(GoogleSignInAccount account) async {
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      if (mounted) {
        setState(() => _webAuthError = 'Google tidak mengembalikan ID token.');
      }
      return;
    }
    await _exchangeGoogleIdToken(idToken);
  }

  Future<void> _exchangeGoogleIdToken(String idToken) async {
    if (_loginHandled) return;
    _setWebBusy(true);
    try {
      final response = await http
          .post(
            Uri.parse('$_authBaseUrl/auth/google/callbackgis'),
            body: {
              'credential': idToken,
              'select_by': 'btn',
              'client_id': _serverClientId,
            },
          )
          .timeout(const Duration(seconds: 20));
      _completeBackendToken(response, provider: 'Google');
    } catch (error) {
      _setWebError('Google Sign-In gagal tersambung ke e-GYS.');
      _authDebug('Google token exchange failed (${error.runtimeType})');
    } finally {
      _setWebBusy(false);
    }
  }

  Future<void> _handleAppleNative() async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        _startHostedOAuth('/auth/apple');
        return;
      }
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      await _exchangeAppleCredential(credential);
    } catch (error) {
      _authDebug('Native Apple sign-in failed (${error.runtimeType})');
      _startHostedOAuth('/auth/apple');
    }
  }

  Future<void> _handleAppleWeb() async {
    if (_appleWebClientId.isEmpty || _appleWebRedirectUri.isEmpty) {
      _setWebError(
        'Apple Web Sign-In belum dikonfigurasi untuk deployment ini.',
      );
      return;
    }
    _setWebBusy(true);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: _appleWebClientId,
          redirectUri: Uri.parse(_appleWebRedirectUri),
        ),
      );
      await _exchangeAppleCredential(credential);
    } catch (error) {
      _setWebError('Apple Sign-In gagal. Coba lagi.');
      _authDebug('Apple web sign-in failed (${error.runtimeType})');
    } finally {
      _setWebBusy(false);
    }
  }

  Future<void> _exchangeAppleCredential(
    AuthorizationCredentialAppleID credential,
  ) async {
    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      _setWebError('Apple tidak mengembalikan identity token.');
      return;
    }

    final response = await http
        .post(
          Uri.parse('$_authBaseUrl/auth/apple/callback'),
          body: {
            'identity_token': idToken,
            'code': credential.authorizationCode,
            if (credential.email != null) 'email': credential.email!,
            if (credential.givenName != null)
              'first_name': credential.givenName!,
            if (credential.familyName != null)
              'last_name': credential.familyName!,
          },
        )
        .timeout(const Duration(seconds: 20));
    _completeBackendToken(response, provider: 'Apple');
  }

  void _completeBackendToken(
    http.Response response, {
    required String provider,
  }) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _setWebError('$provider Sign-In ditolak oleh e-GYS.');
      return;
    }
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['token'] != null) {
        _completeLogin(body['token']);
        return;
      }
    } catch (_) {}
    _setWebError(
      '$provider Sign-In selesai, tetapi token aplikasi tidak tersedia.',
    );
  }

  void _setWebBusy(bool value) {
    if (!mounted || _webBusy == value) return;
    setState(() => _webBusy = value);
  }

  void _setWebError(String message) {
    if (!mounted) return;
    setState(() => _webAuthError = message);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (kIsWeb) return _buildWebLogin(context);
        return _buildHostedLogin(context, state);
      },
    );
  }

  Widget _buildHostedLogin(BuildContext context, AuthState state) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: context.colorScheme.surface,
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  '$_authBaseUrl/login?theme=${context.isDark ? 'dark' : 'light'}',
                ),
              ),
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
                cacheEnabled: true,
                supportMultipleWindows: true,
                javaScriptCanOpenWindowsAutomatically: true,
                thirdPartyCookiesEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
                controller.addJavaScriptHandler(
                  handlerName: 'mobile',
                  callback: (arguments) {
                    if (arguments.isEmpty || arguments.first is! Map) return;
                    _handleToken(
                      (arguments.first as Map).cast<String, dynamic>(),
                    );
                  },
                );
              },
              onLoadStart: (_, url) {
                context.read<AuthCubit>().toggleLoading(true);
                _authDebug('Hosted page loading: ${url?.host ?? ''}');
              },
              onLoadStop: (controller, url) async {
                context.read<AuthCubit>().toggleLoading(false);
                final urlString = url?.toString() ?? '';
                if (_doingOAuth &&
                    urlString.contains('e.gys.or.id') &&
                    !urlString.contains('/auth/google') &&
                    !urlString.contains('/auth/apple') &&
                    !urlString.contains('accounts.google.com')) {
                  _doingOAuth = false;
                  await _tryExtractHostedSession(controller);
                }
              },
              onProgressChanged: (_, progress) {
                context.read<AuthCubit>().onProgress(progress);
              },
              onCreateWindow: (_, action) async {
                if (!mounted) return false;
                await showModalBottomSheet<void>(
                  context: context,
                  useSafeArea: true,
                  isScrollControlled: true,
                  builder: (sheetContext) => SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.85,
                    child: InAppWebView(
                      windowId: action.windowId,
                      onCloseWindow: (_) =>
                          Navigator.of(sheetContext).maybePop(),
                    ),
                  ),
                );
                return true;
              },
            ),
          ),
          if (state.isLoading)
            ColoredBox(
              color: context.colorScheme.surface.withValues(alpha: 0.94),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator.adaptive(
                      value: state.progress > 0 && state.progress < 100
                          ? state.progress / 100
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text('${state.progress}% · ${'Loading'.tr()}'),
                  ],
                ),
              ),
            ),
          const SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircleAvatar(child: BackButton()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLogin(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final appleConfigured =
        _appleWebClientId.isNotEmpty && _appleWebRedirectUri.isNotEmpty;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              elevation: 0,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: context.appRadius(22),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: context.appRadius(18),
                      ),
                      child: Icon(
                        Icons.account_circle_rounded,
                        size: 34,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Login GYS',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gunakan akun Google atau Apple. Token provider langsung ditukar dengan sesi e-GYS dan tidak dicetak ke log.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: !_webGoogleReady
                          ? const SizedBox(
                              key: ValueKey('google-loading'),
                              height: 44,
                              child: Center(
                                child: CircularProgressIndicator.adaptive(),
                              ),
                            )
                          : Center(
                              key: const ValueKey('google-ready'),
                              child: buildGoogleWebSignInButton(),
                            ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _webBusy || !appleConfigured
                            ? null
                            : _handleAppleWeb,
                        icon: const Icon(Icons.apple_rounded),
                        label: const Text('Continue with Apple'),
                      ),
                    ),
                    if (!appleConfigured) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Apple Web memerlukan APPLE_WEB_CLIENT_ID dan APPLE_WEB_REDIRECT_URI pada build release.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (_webBusy) ...[
                      const SizedBox(height: 18),
                      const LinearProgressIndicator(),
                    ],
                    if (_webAuthError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: context.appRadius(12),
                        ),
                        child: Text(
                          _webAuthError!,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('$_authBaseUrl/login'),
                        mode: LaunchMode.platformDefault,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: const Text('Buka login e-GYS'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
