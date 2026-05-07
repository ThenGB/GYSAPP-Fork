import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/services/midi_engine_service.dart';

/// Hidden InAppWebView widget that hosts the FluidSynth WASM MIDI engine.
/// This widget should be placed in the widget tree but made invisible.
class MidiEngineWebView extends StatefulWidget {
  final MidiEngineService service;

  const MidiEngineWebView({
    super.key,
    required this.service,
  });

  @override
  State<MidiEngineWebView> createState() => _MidiEngineWebViewState();
}

class _MidiEngineWebViewState extends State<MidiEngineWebView> {
  @override
  Widget build(BuildContext context) {
    // Hidden webview (50x50 pixel with transparent background and IgnorePointer)
    // A slightly larger size ensures the WebView is not aggressively throttled by the OS.
    return IgnorePointer(
      child: SizedBox(
        width: 50,
        height: 50,
        child: InAppWebView(
          initialFile: 'assets/web/midi_engine.html',
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
          onWebViewCreated: (controller) {
            widget.service.onWebViewCreated(controller);
          },
          onConsoleMessage: (controller, consoleMessage) {
            log('MIDI Engine: ${consoleMessage.message}', name: 'MidiEngine');
          },
          onLoadStop: (controller, url) {
            log('MIDI engine loaded: $url', name: 'MidiEngine');
            _initEngine();
          },
          onReceivedError: (controller, request, error) {
            log('MIDI engine error [${error.type}]: ${error.description}',
                name: 'MidiEngine');
          },
        ),
      ),
    );
  }

  Future<void> _initEngine() async {
    try {
      // Use relative path since the HTML is loaded from assets/web/midi_engine.html
      // This circumvents modern Android restrictions on file:// cross-origin fetching.
      final sfUrl = '../data/soundfont/GeneralUser-GS.sf2';

      await widget.service.initializeWebEngine(sfUrl);
      log('SoundFont initialized: $sfUrl', name: 'MidiEngine');
    } catch (e) {
      log('Failed to init engine: $e', name: 'MidiEngine');
    }
  }
}

