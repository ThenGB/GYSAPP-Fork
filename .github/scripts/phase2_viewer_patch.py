from pathlib import Path


def replace(path: str, old: str, new: str, count: int = -1) -> None:
    target = Path(path)
    text = target.read_text(encoding="utf-8-sig")
    if old not in text:
        raise SystemExit(f"pattern not found in {path}: {old[:120]!r}")
    target.write_text(text.replace(old, new, count), encoding="utf-8")


# Keep adjacent PageView pages from receiving the active song's transient
# chord/PDF state. This removes stale/wrong chord flashes.
song = Path("lib/presentations/song/view/song_view.dart")
text = song.read_text(encoding="utf-8-sig")
text = text.replace(
    "                          final songChords = state.currentChords;\n                          return RepaintBoundary(\n",
    "                          final isActiveSong = index == currentPageIndex;\n                          final songChords = isActiveSong\n                              ? state.currentChords\n                              : const <int, List<ChordData>>{};\n                          return RepaintBoundary(\n",
    1,
)
text = text.replace(
    "                              pdfPath: state.currentPdfPath,\n                              showChords: shouldRenderChordForSongState(state),",
    "                              pdfPath: isActiveSong ? state.currentPdfPath : null,\n                              showChords:\n                                  isActiveSong && shouldRenderChordForSongState(state),",
    1,
)
text = text.replace("label: 'â†“',", "label: 'Vert',")

marker = "class _NoteAlignedChordLine extends StatelessWidget {"
start = text.find(marker)
if start < 0:
    raise SystemExit("NoteAlignedChordLine marker not found")
new_tail = r'''class _NoteAlignedChordLine extends StatelessWidget {
  final String text;
  final List<TextChordPlacement> placements;
  final TextStyle? lyricsStyle;
  final TextAlign textAlign;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final double textScale;

  const _NoteAlignedChordLine({
    required this.text,
    required this.placements,
    required this.lyricsStyle,
    required this.textAlign,
    required this.transposeStep,
    required this.baseTransposeOffset,
    required this.chordAccidentalMode,
    required this.textScale,
  });

  double _measure(String value, TextStyle? style) {
    if (value.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  List<_WrappedLyricRow> _wrapRows(double maxWidth) {
    if (text.isEmpty || !maxWidth.isFinite || maxWidth <= 0) {
      return [_WrappedLyricRow(text: text, start: 0, end: text.length)];
    }

    final tokens = RegExp(r'\S+\s*').allMatches(text).toList();
    if (tokens.isEmpty) {
      return [_WrappedLyricRow(text: text, start: 0, end: text.length)];
    }

    final rows = <_WrappedLyricRow>[];
    var buffer = '';
    var rowStart = tokens.first.start;
    var rowEnd = rowStart;

    void flush() {
      if (buffer.isEmpty) return;
      final visible = buffer.trimRight();
      rows.add(
        _WrappedLyricRow(
          text: visible,
          start: rowStart,
          end: rowStart + visible.length,
        ),
      );
      buffer = '';
    }

    for (final token in tokens) {
      final value = token.group(0) ?? '';
      final candidate = '$buffer$value';
      if (buffer.isNotEmpty &&
          _measure(candidate.trimRight(), lyricsStyle) > maxWidth) {
        flush();
        rowStart = token.start;
        buffer = value;
        rowEnd = token.end;
      } else {
        if (buffer.isEmpty) rowStart = token.start;
        buffer = candidate;
        rowEnd = token.end;
      }
    }
    flush();

    if (rows.isEmpty) {
      rows.add(_WrappedLyricRow(text: text, start: 0, end: rowEnd));
    }
    return rows;
  }

  int _characterOffsetFor(double position) {
    if (text.isEmpty) return 0;
    final painter = TextPainter(
      text: TextSpan(text: text, style: lyricsStyle),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    if (painter.width <= 0) return 0;
    return painter
        .getPositionForOffset(
          Offset(position.clamp(0.0, 1.0) * painter.width, 0),
        )
        .offset
        .clamp(0, text.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chordFontSize = (12 * textScale).clamp(9.0, 20.0);
    final chordHeight = chordFontSize + 7;
    final chordStyle = TextStyle(
      fontFamily: DesignSystem.fontHeading,
      fontSize: chordFontSize,
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onPrimaryContainer,
    );
    final alignment = switch (textAlign) {
      TextAlign.center => Alignment.center,
      TextAlign.right => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };

    final labels = placements
        .map(
          (placement) => _ResolvedChordPlacement(
            label: ChordService.transposeChord(
              placement.chord,
              transposeStep,
              baseTransposeOffset: baseTransposeOffset,
              accidentalMode: chordAccidentalMode,
            ),
            characterOffset: _characterOffsetFor(placement.safePosition),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth <= 0) return const SizedBox.shrink();
        final rows = _wrapRows(maxWidth);

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in rows)
              Align(
                alignment: alignment,
                child: Builder(
                  builder: (context) {
                    final rowWidth = _measure(
                      row.text,
                      lyricsStyle,
                    ).clamp(1.0, maxWidth);
                    final rowChords = labels
                        .where(
                          (placement) =>
                              placement.characterOffset >= row.start &&
                              placement.characterOffset <= row.end,
                        )
                        .map((placement) {
                          final localEnd = (placement.characterOffset - row.start)
                              .clamp(0, row.text.length);
                          final before = row.text.substring(0, localEnd);
                          final x = _measure(
                            before,
                            lyricsStyle,
                          ).clamp(0.0, rowWidth);
                          return (label: placement.label, x: x);
                        })
                        .toList();

                    var previousRight = double.negativeInfinity;
                    final resolvedLefts = <double>[];
                    for (final chord in rowChords) {
                      final labelWidth = _measure(chord.label, chordStyle) + 8;
                      var left = chord.x - (labelWidth / 2);
                      left = left.clamp(
                        0.0,
                        (rowWidth - labelWidth).clamp(0.0, rowWidth),
                      );
                      if (left < previousRight + 4) {
                        left = (previousRight + 4).clamp(
                          0.0,
                          (rowWidth - labelWidth).clamp(0.0, rowWidth),
                        );
                      }
                      previousRight = left + labelWidth;
                      resolvedLefts.add(left);
                    }

                    return SizedBox(
                      width: rowWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (rowChords.isNotEmpty)
                            SizedBox(
                              height: chordHeight,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  for (var i = 0; i < rowChords.length; i++)
                                    Positioned(
                                      left: resolvedLefts[i],
                                      top: 0,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .primaryContainer
                                              .withValues(alpha: 0.62),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          child: Text(
                                            rowChords[i].label,
                                            style: chordStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          Text(
                            row.text,
                            textAlign: textAlign,
                            style: lyricsStyle,
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WrappedLyricRow {
  final String text;
  final int start;
  final int end;

  const _WrappedLyricRow({
    required this.text,
    required this.start,
    required this.end,
  });
}

class _ResolvedChordPlacement {
  final String label;
  final int characterOffset;

  const _ResolvedChordPlacement({
    required this.label,
    required this.characterOffset,
  });
}
'''
song.write_text(text[:start] + new_tail, encoding="utf-8")

# Preserve the pdfrx instance while layout modes change.
pdf = Path("lib/presentations/song/widgets/song_pdf_viewer.dart")
text = pdf.read_text(encoding="utf-8-sig")
old = """    if (oldWidget.twoPageMode != widget.twoPageMode ||
        oldWidget.verticalScrolling != widget.verticalScrolling) {
      // Layout changed â€” PdfViewer is rebuilt via new key on assetPath,
      // but twoPageMode/verticalScrolling need a setState.
      _needsInitialFit = true;
      // Invalidate cached params so the next build creates fresh params
      // with the correct layout mode.  Without this the old params (which
      // may have different scrollPhysics or layoutPages) are reused.
      _cachedParams = null;
      setState(() {});
    }"""
new = """    if (oldWidget.twoPageMode != widget.twoPageMode ||
        oldWidget.verticalScrolling != widget.verticalScrolling) {
      _needsInitialFit = true;
      _cachedLayout = null;
      _cachedLayoutKey = null;
      _cachedParams = null;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _invalidatePdfIfReady();
        _scheduleFitWithFallback();
      });
    }"""
if old not in text:
    raise SystemExit("PDF mode update block not found")
text = text.replace(old, new, 1)
old = """    // Force recreation when the requested range OR the viewing mode changes
    // so pdfrx applies initialPageNumber, rebuilds the page layout against
    // the right pages, and re-runs the deterministic initial-fit zoom for the
    // new mode (single/two-page/vertical).  A mode switch therefore gets a
    // fresh, correctly-fitted viewer instead of pdfrx's onLayoutUpdate
    // \"preserve current zoom\" behavior fighting the new layout.
    final modeToken = widget.twoPageMode
        ? '2'
        : widget.verticalScrolling
        ? 'v'
        : '1';
    final viewerKey = ValueKey(
      '${request.sourceId}#p${request.startPage}#n${request.pageCount}#m$modeToken#v$_viewerInstance',
    );"""
new = """    // Document identity stays stable across layout-mode changes. pdfrx can
    // re-layout the same document in place, which preserves caches and avoids
    // the visible destroy/recreate flash when switching 1/2-page or vertical.
    final viewerKey = ValueKey(
      '${request.sourceId}#p${request.startPage}#n${request.pageCount}#v$_viewerInstance',
    );"""
if old not in text:
    raise SystemExit("PDF viewer key block not found")
pdf.write_text(text.replace(old, new, 1), encoding="utf-8")

# Avoid constructing a native Directory in the web DI path.
registry = Path(
    "lib/data/services/asset_distribution/installed_asset_registry.dart"
)
text = registry.read_text(encoding="utf-8-sig")
old = """  InstalledAssetRegistry({
    required Directory supportDirectory,
    InstalledAssetStore? store,
  }) : _supportDirectory = supportDirectory,
       _store = store ??
           FileSystemInstalledAssetStore(
             installedAssetsRoot:
                 '${supportDirectory.path}/installed_assets',
           );

  final Directory _supportDirectory;"""
new = """  InstalledAssetRegistry({
    Directory? supportDirectory,
    String? supportPath,
    InstalledAssetStore? store,
  }) : assert(supportDirectory != null || supportPath != null),
       _supportPath = supportPath ?? supportDirectory!.path,
       _store = store ??
           FileSystemInstalledAssetStore(
             installedAssetsRoot:
                 '${supportPath ?? supportDirectory!.path}/installed_assets',
           );

  final String _supportPath;"""
if old not in text:
    raise SystemExit("registry constructor not found")
text = text.replace(old, new, 1)
text = text.replace(
    "Directory('${_supportDirectory.path}/installed_assets')",
    "Directory('$_supportPath/installed_assets')",
)
registry.write_text(text, encoding="utf-8")

injection = Path("lib/di/injection.dart")
text = injection.read_text(encoding="utf-8-sig")
text = text.replace(
    "supportDirectory: Directory(di<AppDirectory>().support),",
    "supportPath: di<AppDirectory>().support,",
)
injection.write_text(text, encoding="utf-8")
