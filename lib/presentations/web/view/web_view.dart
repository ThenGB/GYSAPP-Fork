import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../router/router.dart';

@RoutePage()
class WebpageView extends StatefulWidget {
  final String url;
  const WebpageView({super.key, required this.url});

  @override
  State<WebpageView> createState() => _WebpageViewState();
}

class _WebpageViewState extends State<WebpageView> {
  final GlobalKey key = GlobalKey();
  @override
  void initState() {
    super.initState();
  }

  late ValueNotifier<double> progress = ValueNotifier(0);

  InAppWebViewController? controller;

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }

  bool forceClose = false;

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
              return Text(snapshot.data ?? '');
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
              onLoadStop: (controller, url) {
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
