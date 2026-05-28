import 'dart:collection';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

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
    debugPrint('[LoginView] CMD: ${msg['cmd']}');
    final cmd = msg['cmd'];
    if (cmd == 'googlelogin' && !_loginHandled) {
      if (kDebugMode) {
        _handleGoogleViaWebView();
      } else {
        _handleGoogleNative();
      }
      return;
    }
    if ((cmd == 'googlelogged' || cmd == 'applelogged') && !_loginHandled) {
      _loginHandled = true;
      widget.onLoggedIn(msg['token'] ?? '');
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
    debugPrint('[LoginView] Checking login status after OAuth redirect...');

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
      debugPrint('[LoginView] User is logged in on website, passing session cookies as token');
      _loginHandled = true;
      widget.onLoggedIn(cookieHeader);
      return;
    }

    // 4. Fallback: try /users/profile with cookies (the actual API endpoint)
    try {
      final resp = await http.get(
        Uri.parse('https://e.gys.or.id/users/profile'),
        headers: {'Cookie': cookieHeader},
      );
      debugPrint('[LoginView] Profile API: ${resp.statusCode}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data['token'] != null) {
          _handleToken({'cmd': 'googlelogged', 'token': data['token']});
          return;
        }
      }
    } catch (e) {
      debugPrint('[LoginView] Profile API error: $e');
    }

    debugPrint('[LoginView] No login detected after OAuth redirect');
  }

  // ── Native Google Sign-In ────────────────────────────────────────────
  Future<void> _handleGoogleNative() async {
    debugPrint('[LoginView] Starting native GIS...');
    try {
      await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
      debugPrint('[LoginView] GIS initialized, authenticating...');
      final account = await GoogleSignIn.instance.authenticate();
      debugPrint('[LoginView] GIS account: ${account.email}');
      final auth = await account.authentication;
      final idToken = auth.idToken;
      debugPrint('[LoginView] GIS idToken: ${idToken != null ? "${idToken.substring(0, 20)}..." : "null"}');
      if (idToken == null || idToken.isEmpty) {
        debugPrint('[LoginView] ERROR: idToken is null/empty');
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
        if (res['token'] != null && !_loginHandled) {
          debugPrint('[LoginView] Got app token! Calling onLoggedIn');
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => Scaffold(
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
                  debugPrint('[WebViewConsole] consoleMessage.message');
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
                      final json =
                          (arguments as List).firstOrNull
                              as Map<String, dynamic>;
                      if (json != null) _handleToken(json);
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
      ),
    );
  }
}
