import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
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
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../di/injection.dart';
import '../cubit/auth_cubit.dart';

@RoutePage()
class LoginView extends StatefulWidget implements AutoRouteWrapper {
  final Function(String token) onLoggedIn;
  const LoginView({super.key, required this.onLoggedIn});

  @override
  State<LoginView> createState() => _LoginViewState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<AuthCubit>(create: (context) => di(), child: this);
  }
}

class _LoginViewState extends State<LoginView> {
  InAppWebViewController? _webViewController;
  bool _loginHandled = false;
  bool _doingOAuth = false;

  static const _serverClientId =
      '705603488262-70g3bcfan59307rrk610m32n4uhf2tge.apps.googleusercontent.com';

  void _handleToken(Map<String, dynamic> msg) {
    debugPrint('[LoginView] _handleToken msg=$msg, _loginHandled=$_loginHandled');
    debugPrint('[LoginView] CMD: ${msg['cmd']}');
    final cmd = msg['cmd'];
    if (cmd == 'googlelogin' && !_loginHandled) {
      _dispatchLogin();
      return;
    }
    if ((cmd == 'googlelogged' || cmd == 'applelogged') && !_loginHandled) {
      _loginHandled = true;
      final t = msg['token'] ?? '';
      debugPrint('[LoginView] Calling onLoggedIn with token=${t.length > 40 ? t.substring(0, 40) : t}...');
      widget.onLoggedIn(t);
    }
  }

  void _dispatchLogin() {
    if (kIsWeb) {
      // dart:io Platform throws on web — no native Google/Apple flows there.
      _handleGoogleViaWebView();
      return;
    }
    if (kDebugMode) {
      _handleGoogleViaWebView();
      return;
    }
    if (Platform.isAndroid) {
      _handleGoogleNative();
    } else if (Platform.isIOS || Platform.isMacOS) {
      _handleAppleNative();
    } else {
      _handleGoogleViaWebView();
    }
  }

  // ── Debug: redirect flow ─────────────────────────────────────────────
  void _handleGoogleViaWebView() {
    if (_doingOAuth) return;
    _doingOAuth = true;
    debugPrint('[LoginView] Navigating to /auth/google');
    _webViewController?.loadUrl(
      urlRequest: URLRequest(
        url: WebUri('https://e.gys.or.id/auth/google'),
      ),
    );
  }

  Future<void> _tryExtractToken(InAppWebViewController controller) async {
    if (_loginHandled) return;
    debugPrint('[LoginView] _tryExtractToken called, _loginHandled=$_loginHandled');

    // 1. Try localStorage/sessionStorage for a real token
    final jsToken = await controller.evaluateJavascript(source: '''
      (function() {
        try {
          var t = localStorage.getItem("token") ||
                  localStorage.getItem("access_token") ||
                  localStorage.getItem("jwt") ||
                  localStorage.getItem("id_token") ||
                  sessionStorage.getItem("token");
          if (t && t !== "null" && t !== "undefined") return t;
          if (typeof window.__TOKEN__ !== 'undefined') return window.__TOKEN__;
          return null;
        } catch(e) { return null; }
      })();
    ''');
    if (jsToken != null &&
        jsToken is String &&
        jsToken.isNotEmpty &&
        jsToken != 'null') {
      debugPrint('[LoginView] jsToken from localStorage: ${jsToken.substring(0, jsToken.length.clamp(0, 40))}...');
      debugPrint('[LoginView] Token from localStorage');
      _handleToken({'cmd': 'googlelogged', 'token': jsToken});
      return;
    }

    // 2. Check if user is actually logged in on the website
    final isLoggedIn = await controller.evaluateJavascript(source: '''
      (function() {
        try {
          // Check for logout button / user menu / profile link
          var logoutBtn = document.querySelector('a[href*="logout"], button[onclick*="logout"], .user-menu, .user-info, .profile-name, [data-user]');
          if (logoutBtn) return true;
          // Check for common logged-in indicators
          var body = document.body.innerText || '';
          if (body.indexOf('Keluar') !== -1 || body.indexOf('Logout') !== -1 || body.indexOf('Profil') !== -1) return true;
          // Check if there's no login button visible
          var loginBtn = document.querySelector('a[href*="login"], #mobile-google-signin');
          if (loginBtn && loginBtn.offsetParent !== null) return false;
          return false;
        } catch(e) { return false; }
      })();
    ''');
    debugPrint('[LoginView] Page login check: isLoggedIn=$isLoggedIn');

    // 3. Get session cookies as credential
    final cookies = await CookieManager.instance().getCookies(
      url: WebUri('https://e.gys.or.id'),
    );
    final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
    debugPrint('[LoginView] Session cookies: ${cookies.length} cookies');

    if (isLoggedIn == true && cookieHeader.isNotEmpty) {
      // Try to get a real JWT token from /users/profile using cookies
      try {
        final resp = await http.get(
          Uri.parse('https://e.gys.or.id/users/profile'),
          headers: {'Cookie': cookieHeader},
        );
        debugPrint('[LoginView] Profile API: ${resp.statusCode}');
        if (resp.statusCode == 200) {
          debugPrint('[LoginView] Profile API body preview: ${resp.body.substring(0, resp.body.length.clamp(0, 200))}');
          try {
            final data = json.decode(resp.body);
            if (data is Map && data['token'] != null && !_loginHandled) {
              debugPrint('[LoginView] Got JWT from /users/profile');
              _loginHandled = true;
              widget.onLoggedIn(data['token']);
              return;
            }
          } catch (_) {
            final tokenMatch = RegExp(r'(?:token|jwt|access_token)["\s:=]+([A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+)').firstMatch(resp.body);
            if (tokenMatch != null) {
              final token = tokenMatch.group(1)!;
              debugPrint('[LoginView] Extracted JWT from HTML response');
              _loginHandled = true;
              widget.onLoggedIn(token);
              return;
            }
          }
        }
      } catch (e) {
        debugPrint('[LoginView] Profile API error: $e');
      }

      // Fallback: pass session cookies as token (limited functionality)
      debugPrint('[LoginView] No JWT from API, passing session cookies as token');
      _loginHandled = true;
      widget.onLoggedIn(cookieHeader);
      return;
    }

    debugPrint('[LoginView] No login detected after OAuth redirect');
  }

  // ── Native Google Sign-In ────────────────────────────────────────────
  Future<void> _handleGoogleNative() async {
    debugPrint('[LoginView] Starting native GIS...');
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        serverClientId: _serverClientId,
      );
      debugPrint('[LoginView] GIS instance initialized, authenticating...');
      final account = await googleSignIn.authenticate();
      debugPrint('[LoginView] GIS account: ${account.email}');
      final auth = account.authentication;
      final idToken = auth.idToken;
      debugPrint('[LoginView] GIS idToken: ${idToken != null ? "${idToken.substring(0, 20)}..." : "null"}');
      if (idToken == null || idToken.isEmpty) {
        debugPrint('[LoginView] ERROR: idToken is null/empty, falling back to WebView');
        _handleGoogleViaWebView();
        return;
      }
      debugPrint('[LoginView] Posting to /auth/google/callbackgis...');
      final response = await http.post(
        Uri.parse('https://e.gys.or.id/auth/google/callbackgis'),
        body: {
          'credential': idToken,
          'select_by': 'btn',
          'client_id': _serverClientId,
        },
      );
      debugPrint('[LoginView] callbackgis response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final hasToken = res['token'] != null;
        debugPrint('[LoginView] callbackgis status=200, hasToken=$hasToken, _loginHandled=$_loginHandled');
        if (hasToken && !_loginHandled) {
          debugPrint('[LoginView] Got app token! Calling onLoggedIn with token=${res['token'].toString().substring(0, res['token'].toString().length.clamp(0, 40))}...');
          _loginHandled = true;
          widget.onLoggedIn(res['token']);
        } else {
          debugPrint('[LoginView] No token in response: $res');
        }
      } else {
        debugPrint('[LoginView] callbackgis failed: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('[LoginView] Google sign-in error: $e\n$st');
      debugPrint('[LoginView] Falling back to WebView');
      _handleGoogleViaWebView();
    }
  }

  // ── Native Apple Sign-In ────────────────────────────────────────────
  Future<void> _handleAppleNative() async {
    debugPrint('[LoginView] Starting native Apple Sign-In...');
    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        debugPrint('[LoginView] Apple Sign-In not available, falling back to WebView');
        _handleGoogleViaWebView();
        return;
      }
      debugPrint('[LoginView] Apple Sign-In available, requesting credentials...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = appleCredential.identityToken;
      debugPrint('[LoginView] Apple idToken: ${idToken != null ? "${idToken.substring(0, 20)}..." : "null"}');
      if (idToken == null || idToken.isEmpty) {
        debugPrint('[LoginView] ERROR: Apple idToken is null/empty, falling back to WebView');
        _handleGoogleViaWebView();
        return;
      }
      debugPrint('[LoginView] Posting to /auth/apple/callback...');
      final response = await http.post(
        Uri.parse('https://e.gys.or.id/auth/apple/callback'),
        body: {
          'identity_token': idToken,
          'code': appleCredential.authorizationCode,
          if (appleCredential.email != null) 'email': appleCredential.email,
          if (appleCredential.givenName != null) 'first_name': appleCredential.givenName,
          if (appleCredential.familyName != null) 'last_name': appleCredential.familyName,
        },
      );
      debugPrint('[LoginView] Apple callback response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final res = json.decode(response.body);
        final hasToken = res['token'] != null;
        debugPrint('[LoginView] Apple callback status=200, hasToken=$hasToken, _loginHandled=$_loginHandled');
        if (hasToken && !_loginHandled) {
          debugPrint('[LoginView] Got app token from Apple! Calling onLoggedIn');
          _loginHandled = true;
          widget.onLoggedIn(res['token']);
        } else {
          debugPrint('[LoginView] No token in Apple response: $res');
        }
      } else {
        debugPrint('[LoginView] Apple callback failed: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('[LoginView] Apple sign-in error: $e\n$st');
      debugPrint('[LoginView] Falling back to WebView');
      _handleGoogleViaWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // flutter_inappwebview has no web implementation — building the
        // webview on web throws UnsupportedError. Show a crash-free card
        // that opens the login page in a new browser tab instead.
        if (kIsWeb) {
          return _buildWebFallback(context);
        }
        return Scaffold(
        body: Stack(
          fit: StackFit.passthrough,
          children: [
            Container(
              color: context.colorScheme.surface,
              child: InAppWebView(
                onLoadStop: (controller, url) async {
                  context.read<AuthCubit>().toggleLoading(false);
                  final urlStr = url?.toString() ?? '';
                  debugPrint('[LoginView] onLoadStop: $urlStr');
                  if (_doingOAuth &&
                      urlStr.contains('e.gys.or.id') &&
                      !urlStr.contains('/auth/google') &&
                      !urlStr.contains('accounts.google.com')) {
                    _doingOAuth = false;
                    await Future.delayed(const Duration(seconds: 2));
                    await _tryExtractToken(controller);
                  }
                },
                onLoadStart: (controller, url) {
                  context.read<AuthCubit>().toggleLoading(true);
                  debugPrint('[LoginView] onLoadStart: $url');
                },
                onProgressChanged: (controller, progress) {
                  context.read<AuthCubit>().onProgress(progress);
                },
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                  cacheEnabled: true,
                  supportMultipleWindows: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  thirdPartyCookiesEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  userAgent:
                      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
                      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
                ),
                onConsoleMessage: (controller, consoleMessage) {
                  debugPrint('[WebViewConsole] ${consoleMessage.message}');
                },
                onCreateWindow: (controller, createWindowAction) async {
                  debugPrint('[LoginView] onCreateWindow: ${createWindowAction.request.url}');
                  if (mounted) {
                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      isDismissible: true,
                      builder: (sheetContext) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: InAppWebView(
                            windowId: createWindowAction.windowId,
                            initialSettings: InAppWebViewSettings(
                              userAgent:
                                  'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
                                  '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
                            ),
                            onCloseWindow: (ctrl) {
                              if (Navigator.of(sheetContext).canPop()) {
                                Navigator.of(sheetContext).pop();
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                  return true;
                },
                onCloseWindow: (controller) {},
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  _webViewController?.addJavaScriptHandler(
                    handlerName: 'mobile',
                    callback: (arguments) {
                      debugPrint('[LoginView] mobile: $arguments');
                      final json = (arguments as List).firstOrNull as Map<String, dynamic>;
                      _handleToken(json);
                    },
                  );
                },
                shouldOverrideUrlLoading:
                    (controller, navigationAction) async {
                  return NavigationActionPolicy.ALLOW;
                },
                initialUrlRequest: URLRequest(
                  url: WebUri.uri(
                    Uri.parse(
                      'https://e.gys.or.id/login?theme=${context.isDark ? 'dark' : 'light'}',
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: AnimatedCrossFade(
                duration: kThemeAnimationDuration,
                crossFadeState: state.isLoading
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                secondChild: const SizedBox(),
                alignment: Alignment.center,
                layoutBuilder:
                    (topChild, topChildKey, bottomChild, bottomChildKey) {
                      return SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: topChild,
                      );
                    },
                firstChild: Container(
                  color: context.colorScheme.surface,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator.adaptive(
                          value: (state.progress / 100).clamp(0, 1),
                        ),
                        const SizedBox(height: 16),
                        Text('${state.progress} %'),
                        Text('Loading'.tr()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                alignment: Alignment.center,
                width: double.infinity,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: const [CircleAvatar(child: BackButton())],
                ),
              ),
            ),
          ],
        ),
      );
    },
    );
  }

  /// Web fallback: opens the login page in a new browser tab. The
  /// in-app webview flow is Android/iOS/desktop only.
  Widget _buildWebFallback(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: context.appRadius(20),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login_rounded, size: 40, color: colors.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Login'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login melalui browser',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        final url =
                            'https://e.gys.or.id/login?theme=${context.isDark ? 'dark' : 'light'}';
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: Text('Buka halaman login'),
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
