import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../components/widgets/web_fallback_view.dart';
import '../../../router/router.dart';

@RoutePage()
class LiteraturePujianView extends StatefulWidget {
  final String url;
  const LiteraturePujianView({super.key, required this.url});

  @override
  State<LiteraturePujianView> createState() => _LiteraturePujianViewState();
}

class _LiteraturePujianViewState extends State<LiteraturePujianView> {
  late ValueNotifier<double> progress = ValueNotifier(0);
  InAppWebViewController? controller;
  bool forceClose = false;

  @override
  void dispose() {
    progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // flutter_inappwebview has no web implementation — don't build it.
    if (kIsWeb) {
      return WebFallbackView(title: 'Kidung Rohani', url: widget.url);
    }
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        leading: BackButton(
          onPressed: () {
            router.maybePop();
          },
        ),
        title: const Text('Kidung Rohani'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(Uri.parse(widget.url)),
            ),
            initialSettings: InAppWebViewSettings(
              mediaPlaybackRequiresUserGesture: false,
              useShouldOverrideUrlLoading: true,
              allowsInlineMediaPlayback: true,
            ),
            onWebViewCreated: (c) {
              controller = c;
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
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
              return LinearProgressIndicator(value: value, minHeight: 2);
            },
          ),
        ],
      ),
    );
  }
}
