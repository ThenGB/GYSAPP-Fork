import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
    return BlocProvider<AuthCubit>(
      create: (context) => di(),
      child: this,
    );
  }
}

class _LoginViewState extends State<LoginView> {
  InAppWebViewController? _webViewController;
  InAppWebViewController? _webViewPopupController;
  final GlobalKey windowKey = GlobalKey();

  channelListener(Map<String, dynamic> msg) {
    log(msg.toString(), name: 'JS Channel webview');
    var cmd = msg['cmd'];
    if (cmd == 'googlelogged' || cmd == 'applelogged') {
      if (windowKey.currentContext?.mounted == true) {
        Navigator.pop(context);
      }
      widget.onLoggedIn(msg['token'] ?? '');
    } else if (cmd == 'googlelogin' || cmd == 'google-signup') {
      context.read<AuthCubit>().onGoogleLogin(
            _webViewController!,
            msg['action'] ?? cmd,
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) => Scaffold(
        body: Stack(
          fit: StackFit.passthrough,
          children: [
            Container(
              color: context.colorScheme.background,
              child: InAppWebView(
                onLoadStop: (controller, url) {
                  context.read<AuthCubit>().toggleLoading(false);
                },
                onLoadStart: (controller, url) {
                  context.read<AuthCubit>().toggleLoading(true);
                },
                onProgressChanged: (controller, progress) {
                  context.read<AuthCubit>().onProgress(progress);
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    transparentBackground: true,
                    cacheEnabled: false,
                  ),
                  android: AndroidInAppWebViewOptions(
                    supportMultipleWindows: true,
                  ),
                ),
                onConsoleMessage: (controller, consoleMessage) {
                  log(consoleMessage.message);
                },
                onCloseWindow: (controller) {
                  log('On Close Window');
                  Navigator.pop(context);
                },
                onCreateWindow: (controller, createWindowAction) async {
                  log('On Create Window');
                  showModalBottomSheet(
                    context: context,
                    useSafeArea: true,
                    isScrollControlled: true,
                    builder: (context) {
                      return Padding(
                        padding: context.mediaQuery.viewInsets,
                        child: InAppWebView(
                          key: windowKey,
                          // Setting the windowId property is important here!
                          windowId: createWindowAction.windowId,
                          initialOptions: InAppWebViewGroupOptions(),
                          onWebViewCreated:
                              (InAppWebViewController controller) {
                            _webViewPopupController = controller;
                            _webViewPopupController?.addJavaScriptHandler(
                              handlerName: 'mobile',
                              callback: (arguments) {
                                var json = arguments.firstOrNull
                                    as Map<String, dynamic>;

                                channelListener(json);
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                  return true;
                },
                onWebViewCreated: (controller) {
                  _webViewController = controller;
                  _webViewController?.addJavaScriptHandler(
                    handlerName: 'mobile',
                    callback: (arguments) {
                      var json = arguments.firstOrNull as Map<String, dynamic>;

                      channelListener(json);
                    },
                  );
                },
                initialUrlRequest: URLRequest(
                  url: Uri.parse(
                    'https://e.gys.or.id/login?theme=${context.isDark ? 'dark' : 'light'}',
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
                secondChild: SizedBox(),
                alignment: Alignment.center,
                layoutBuilder:
                    (topChild, topChildKey, bottomChild, bottomChildKey) {
                  return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: topChild);
                },
                firstChild: Container(
                  color: context.colorScheme.background,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator.adaptive(
                          value: (state.progress / 100).clamp(0, 1),
                        ),
                        SizedBox(
                          height: 16,
                        ),
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
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: const [
                    CircleAvatar(child: BackButton()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
