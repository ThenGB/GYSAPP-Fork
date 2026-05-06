import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/services/midi_engine_service.dart';

/// Hidden InAppWebView widget that hosts the FluidSynth WASM MIDI engine.
/// This widget should be placed in the widget tree but made invisible (1x1 size).
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
    // Hidden webview (1x1 pixel)
    return SizedBox(
      width: 1,
      height: 1,
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
    );
  }

  Future<void> _initEngine() async {
    try {
      final sfPath = await _ensureSoundFont();
      final sfUrl = Uri.file(sfPath).toString();

      await widget.service.initializeWebEngine(sfUrl);
      log('SoundFont initialized: $sfUrl', name: 'MidiEngine');
    } catch (e) {
      log('Failed to init engine: $e', name: 'MidiEngine');
    }
  }

  Future<String> _ensureSoundFont() async {
    final dir = await getApplicationDocumentsDirectory();
    final sfPath = '${dir.path}/soundfont/GeneralUser-GS.sf2';

    if (!await File(sfPath).exists()) {
      await Directory('${dir.path}/soundfont').create(recursive: true);
      final data =
          await rootBundle.load('assets/data/soundfont/GeneralUser-GS.sf2');
      final bytes = data.buffer.asUint8List();
      await File(sfPath).writeAsBytes(bytes, flush: true);
    }

    return sfPath;
  }
}
