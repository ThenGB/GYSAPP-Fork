import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../data/services/chord_service.dart';

/// Controller for programmatic zoom control on the active PDF viewer.
class PdfViewerController {
  VoidCallback? zoomIn;
  VoidCallback? zoomOut;
  VoidCallback? fitToPage;
}

/// PDF.js-backed viewer that renders bundled PDF assets inside a WebView.
class SongPdfViewer extends StatefulWidget {
  final String? pdfPath;
  final bool showChord;
  final Map<int, List<ChordData>>? chords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final bool twoPageMode;
  final bool verticalScrolling;
  final int chordFontSizePercent;
  final int chordFillOpacityPercent;
  final int chordPaddingPercent;
  final PdfViewerController? viewerController;
  final ValueChanged<String?>? onPdfKeyDetected;
  final ValueChanged<double>? onPdfTempoDetected;
  final VoidCallback? onPageChanged;
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;

  const SongPdfViewer({
    super.key,
    this.pdfPath,
    this.showChord = false,
    this.chords,
    this.transposeStep = 0,
    this.baseTransposeOffset = 0,
    this.chordAccidentalMode = ChordService.accidentalSharp,
    this.twoPageMode = false,
    this.verticalScrolling = false,
    this.chordFontSizePercent = 100,
    this.chordFillOpacityPercent = 94,
    this.chordPaddingPercent = 100,
    this.viewerController,
    this.onPdfKeyDetected,
    this.onPdfTempoDetected,
    this.onPageChanged,
    this.onPreviousSong,
    this.onNextSong,
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
  void initState() {
    super.initState();
    _wireController();
    _loadPdf();
  }

  @override
  void didUpdateWidget(SongPdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.viewerController != oldWidget.viewerController) {
      _wireController();
    }
    if (oldWidget.pdfPath != widget.pdfPath) {
      _loadPdf();
    }
    if (oldWidget.showChord != widget.showChord ||
        oldWidget.chords != widget.chords ||
        oldWidget.transposeStep != widget.transposeStep ||
        oldWidget.baseTransposeOffset != widget.baseTransposeOffset ||
        oldWidget.chordAccidentalMode != widget.chordAccidentalMode) {
      _syncChords();
    }
    if (oldWidget.twoPageMode != widget.twoPageMode ||
        oldWidget.verticalScrolling != widget.verticalScrolling) {
      _syncViewOptions();
    }
    if (oldWidget.chordFontSizePercent != widget.chordFontSizePercent ||
        oldWidget.chordFillOpacityPercent != widget.chordFillOpacityPercent ||
        oldWidget.chordPaddingPercent != widget.chordPaddingPercent) {
      _syncChordUiPrefs();
    }
  }

  void _wireController() {
    final ctrl = widget.viewerController;
    if (ctrl == null) return;
    ctrl.zoomIn = _zoomIn;
    ctrl.zoomOut = _zoomOut;
    ctrl.fitToPage = _fitToPage;
  }

  Future<void> _zoomIn() async {
    final controller = _controller;
    if (controller == null || !_isWebViewLoaded) return;
    await controller.evaluateJavascript(
      source:
          'if (window.getZoom) { window.setZoom(window.getZoom() + 0.15); }',
    );
  }

  Future<void> _zoomOut() async {
    final controller = _controller;
    if (controller == null || !_isWebViewLoaded) return;
    await controller.evaluateJavascript(
      source:
          'if (window.getZoom) { window.setZoom(Math.max(window.getZoom() - 0.15, 1)); }',
    );
  }

  Future<void> _fitToPage() async {
    final controller = _controller;
    if (controller == null || !_isWebViewLoaded) return;
    await controller.evaluateJavascript(
      source: 'if (window.fitToPage) { window.fitToPage(); }',
    );
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
              handlerName: 'pdfSwipeSong',
              callback: (args) {
                final direction = args.isEmpty ? null : args.first?.toString();
                if (direction == 'previous') {
                  widget.onPreviousSong?.call();
                } else if (direction == 'next') {
                  widget.onNextSong?.call();
                }
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'pdfKeyDetected',
              callback: (args) {
                final key = args.isEmpty ? null : args.first?.toString();
                widget.onPdfKeyDetected
                    ?.call(key?.isEmpty == true ? null : key);
              },
            );
            controller.addJavaScriptHandler(
              handlerName: 'pdfTempoDetected',
              callback: (args) {
                if (args.isEmpty) return;
                final tempo = (args.first as num?)?.toDouble();
                if (tempo != null && tempo > 0) {
                  widget.onPdfTempoDetected?.call(tempo);
                }
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
            _syncViewOptions();
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

  Future<void> _syncViewOptions() async {
    final controller = _controller;
    if (controller == null || !_isWebViewLoaded) return;

    await controller.evaluateJavascript(
      source:
          'if (window.setPdfViewOptions) { window.setPdfViewOptions({ twoPageMode: ${jsonEncode(widget.twoPageMode)}, verticalScrolling: ${jsonEncode(widget.verticalScrolling)} }); }',
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

  Future<void> _syncChordUiPrefs() async {
    final controller = _controller;
    if (controller == null || !_isWebViewLoaded) return;

    await controller.evaluateJavascript(source: '''
      if (window.setChordUiPrefs) {
        window.setChordUiPrefs({
          fontSizePercent: ${widget.chordFontSizePercent},
          fillOpacityPercent: ${widget.chordFillOpacityPercent},
          paddingPercent: ${widget.chordPaddingPercent}
        });
      }
    ''');
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
                  baseTransposeOffset: widget.baseTransposeOffset,
                  accidentalMode: widget.chordAccidentalMode,
                ),
              },
            )
            .toList(),
      ),
    );
  }
}
