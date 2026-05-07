import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/services/chord_service.dart';

/// PDF.js-backed viewer that renders bundled PDF assets inside a WebView.
class SongPdfViewer extends StatefulWidget {
  final String? pdfPath;
  final bool showChord;
  final Map<int, List<ChordData>>? chords;
  final int transposeStep;
  final String chordAccidentalMode;
  final VoidCallback? onPageChanged;

  const SongPdfViewer({
    super.key,
    this.pdfPath,
    this.showChord = false,
    this.chords,
    this.transposeStep = 0,
    this.chordAccidentalMode = ChordService.accidentalSharp,
    this.onPageChanged,
  });

  @override
  State<SongPdfViewer> createState() => _SongPdfViewerState();
}

class _SongPdfViewerState extends State<SongPdfViewer> {
  InAppWebViewController? _controller;
  String? _pdfBase64;
  String? _errorMessage;
  bool _isWebViewLoaded = false;

  @override
  void didUpdateWidget(SongPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfPath != widget.pdfPath) {
      _loadPdf();
    }
    if (oldWidget.showChord != widget.showChord ||
        oldWidget.chords != widget.chords ||
        oldWidget.transposeStep != widget.transposeStep ||
        oldWidget.chordAccidentalMode != widget.chordAccidentalMode) {
      _syncChords();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    if (widget.pdfPath == null) {
      setState(() {
        _pdfBase64 = null;
        _errorMessage = null;
      });
      return;
    }

    try {
      final data = await rootBundle.load(widget.pdfPath!);
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final pdfBase64 = base64Encode(bytes);

      setState(() {
        _pdfBase64 = pdfBase64;
        _errorMessage = null;
      });
      await _renderPdf();
    } catch (e) {
      log('Error loading PDF: $e');
      setState(() {
        _pdfBase64 = null;
        _errorMessage = 'Failed to load PDF';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    return Stack(
      children: [
        InAppWebView(
          initialFile: 'assets/web/pdf_viewer.html',
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            supportZoom: true,
            builtInZoomControls: true,
            displayZoomControls: false,
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
            controller.addJavaScriptHandler(
              handlerName: 'pdfRendered',
              callback: (args) {
                log('PDF rendered: ${args.isEmpty ? 0 : args.first} pages');
                _syncChords();
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'pdfPageChanged',
              callback: (args) {
                if (args.isEmpty) return;
                final page = (args.first as num?)?.toInt();
                if (page == null || !mounted) return;
                widget.onPageChanged?.call();
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'pdfError',
              callback: (args) {
                log('PDF.js error: ${args.join(' ')}');
                if (!mounted) return;
                setState(() {
                  _errorMessage = 'Failed to render PDF';
                });
              },
            );
          },
          onLoadStop: (controller, url) {
            _isWebViewLoaded = true;
            _renderPdf();
            _syncChords();
          },
          onConsoleMessage: (controller, consoleMessage) {
            log('PDF.js: ${consoleMessage.message}', name: 'SongPdfViewer');
          },
        ),
        if (_pdfBase64 == null)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Future<void> _renderPdf() async {
    final controller = _controller;
    final pdfBase64 = _pdfBase64;
    if (controller == null || pdfBase64 == null || !_isWebViewLoaded) return;

    await controller.evaluateJavascript(
      source:
          'if (window.loadPdfBase64) { window.loadPdfBase64(${jsonEncode(pdfBase64)}); }',
    );
  }

  Future<void> _syncChords() async {
    final controller = _controller;
    if (controller == null || !_isWebViewLoaded) return;

    final chordPayload = _buildChordPayload();
    await controller.evaluateJavascript(
      source:
          'if (window.setChordData) { window.setChordData(${jsonEncode(widget.showChord)}, ${jsonEncode(chordPayload)}); }',
    );
  }

  Map<String, List<Map<String, Object>>> _buildChordPayload() {
    final chords = widget.chords;
    if (chords == null || chords.isEmpty) return {};

    return chords.map(
      (page, pageChords) => MapEntry(
        page.toString(),
        pageChords
            .map(
              (chord) => {
                'noteIdx': chord.noteIdx,
                'chord': ChordService.transposeChord(
                  chord.chord,
                  widget.transposeStep,
                  accidentalMode: widget.chordAccidentalMode,
                ),
              },
            )
            .toList(),
      ),
    );
  }
}
