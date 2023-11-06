import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/data.dart';
import '../../../router/router.dart';

@RoutePage()
class WebpageView extends StatefulWidget {
  final String url;
  final FutureOr<Color?> Function(InAppWebViewController controller)?
      getNavColor;
  const WebpageView({super.key, required this.url, this.getNavColor});

  @override
  State<WebpageView> createState() => _WebpageViewState();
}

class _WebpageViewState extends State<WebpageView> {
  final GlobalKey key = GlobalKey();

  late Brightness initialBrightness = context.brightness;
  late Brightness currentBrightness = initialBrightness;
  @override
  void initState() {
    super.initState();
  }

  late ValueNotifier<double> progress = ValueNotifier(0);

  InAppWebViewController? controller;

  @override
  void dispose() {
    progress.dispose();
    Future.delayed(Duration.zero, () {
      var context = router.navigatorKey.currentContext!;
      SystemChrome.setSystemUIOverlayStyle(context
          .theme.appBarTheme.systemOverlayStyle!
          .copyWith(statusBarBrightness: initialBrightness));
    });
    super.dispose();
  }

  bool forceClose = false;

  Color? navColor;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (forceClose) return true;
        if ((await controller?.canGoBack()) == true) {
          controller?.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: navColor,
          systemOverlayStyle: context.theme.appBarTheme.systemOverlayStyle!
              .copyWith(statusBarBrightness: currentBrightness),
          foregroundColor: navColor == null
              ? null
              : () {
                  var luminance = navColor!.computeLuminance();

                  return luminance > 0.5;
                }()
                  ? Colors.black
                  : Colors.white,
          leading: BackButton(
            onPressed: () {
              router.pop();
            },
          ),
          actions: [
            CloseButton(
              onPressed: () {
                forceClose = true;
                router.pop();
              },
            )
          ],
          title: FutureBuilder(
            future: controller?.getTitle(),
            initialData: 'GYS',
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? '',
                style: TextStyle(
                  color: navColor == null
                      ? null
                      : () {
                          var luminance = navColor!.computeLuminance();
                          return luminance > 0.5;
                        }()
                          ? Colors.black
                          : Colors.white,
                ),
              );
            },
          ),
        ),
        body: Stack(
          children: [
            InAppWebView(
              key: key,
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  mediaPlaybackRequiresUserGesture: false,
                  useShouldOverrideUrlLoading: true,
                ),
                ios: IOSInAppWebViewOptions(allowsInlineMediaPlayback: true),
              ),
              onWebViewCreated: (c) {
                controller = c;
              },
              onLoadStop: (controller, url) async {
                navColor = await widget.getNavColor?.call(controller);
                var luminance = navColor!.computeLuminance();
                currentBrightness =
                    luminance > 0.5 ? Brightness.light : Brightness.dark;
                setState(() {});
              },
              onLoadStart: (controller, url) {
                setState(() {});
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  this.progress.value = progress / 100;
                });
              },
            ),
            ValueListenableBuilder(
              valueListenable: progress,
              builder: (context, value, child) {
                if (value == 1 || value == 0) {
                  return Container();
                }
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 2,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
