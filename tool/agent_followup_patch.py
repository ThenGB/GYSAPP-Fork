from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def replace_once(path: str, old: str, new: str) -> None:
    file = ROOT / path
    text = file.read_text(encoding="utf-8-sig")
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{path}: expected one exact match, found {count}")
    file.write_text(text.replace(old, new, 1), encoding="utf-8")
    print(f"patched {path}")


# ---------------------------------------------------------------------------
# Hymn viewer menu: expose accidental mode explicitly and keep menu reactive.
# ---------------------------------------------------------------------------
replace_once(
    "lib/presentations/song/view/song_view.dart",
    """              prev.pdfVerticalScrolling != curr.pdfVerticalScrolling ||\n              prev.bookCode != curr.bookCode,""",
    """              prev.pdfVerticalScrolling != curr.pdfVerticalScrolling ||\n              prev.chordAccidentalMode != curr.chordAccidentalMode ||\n              prev.bookCode != curr.bookCode,""",
)
replace_once(
    "lib/presentations/song/view/song_view.dart",
    """    final isText = state.isImageMode;\n    final showAudio = state.showAudio;""",
    """    final isText = state.isImageMode;\n    final showAudio = state.showAudio;\n    final isFlat = state.chordAccidentalMode == ChordService.accidentalFlat;""",
)
replace_once(
    "lib/presentations/song/view/song_view.dart",
    """              // Row 4 â€” chord overlay settings (only for chord-enabled books).\n              Row(\n                mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n                children: [\n                  _ModeButton(\n                    icon: Icons.tune_rounded,\n                    label: 'Chord',\n                    tooltip: 'chord_settings_title'.tr(),\n                    selected: false,\n                    onTap: () {\n                      onClose();\n                      widget.onOpenChordSettings();\n                    },\n                  ),\n                ],\n              ),""",
    """              // Row 4 — notation + chord overlay settings.\n              Row(\n                mainAxisAlignment: MainAxisAlignment.spaceEvenly,\n                children: [\n                  _ModeButton(\n                    icon: Icons.music_note_rounded,\n                    label: isFlat ? '♭' : '♯',\n                    tooltip: isFlat\n                        ? 'Notasi chord: Flat (♭)'\n                        : 'Notasi chord: Sharp (♯)',\n                    selected: true,\n                    onTap: widget.cubit.toggleAccidentalMode,\n                  ),\n                  _ModeButton(\n                    icon: Icons.tune_rounded,\n                    label: 'Chord',\n                    tooltip: 'chord_settings_title'.tr(),\n                    selected: false,\n                    onTap: () {\n                      onClose();\n                      widget.onOpenChordSettings();\n                    },\n                  ),\n                ],\n              ),""",
)
replace_once(
    "lib/presentations/song/view/song_view.dart",
    """              cubit.openSong(song);""",
    """              cubit.openSongFromLibrary(song);""",
)
replace_once(
    "lib/presentations/song/view/song_view.dart",
    """            cubit.openSong(\n              song,\n              autoplay:\n                  cubit.state.isPlaylistLoopModeActive &&\n                  cubit.isSongInActivePlaylist(song),\n            );""",
    """            final activePlaylist = cubit.activePlaylist;\n            final inActivePlaylist = activePlaylist?.songs.any(\n                  (item) => item.matches(song),\n                ) ??\n                false;\n            if (activePlaylist != null && inActivePlaylist) {\n              cubit.openSongFromPlaylist(\n                song,\n                activePlaylist.id,\n                autoplay: cubit.state.isPlaylistLoopModeActive,\n              );\n            } else {\n              cubit.openSongFromLibrary(song);\n            }""",
)

# ---------------------------------------------------------------------------
# MIDI: move the accidental switch out of the cramped transpose pill and make
# it a visible dedicated player action.
# ---------------------------------------------------------------------------
replace_once(
    "lib/presentations/song/widgets/draggable_midi_controls.dart",
    """    final isFlat = widget.chordAccidentalMode == ChordService.accidentalFlat;\n    return _Pill(""",
    """    return _Pill(""",
)
replace_once(
    "lib/presentations/song/widgets/draggable_midi_controls.dart",
    """        // ♯ / ♭ accidental toggle (mirrors gyschordweb's\n        // transpose-accidental switch).\n        GestureDetector(\n          key: const ValueKey('midi-accidental-toggle'),\n          onTap: widget.onToggleAccidental,\n          child: Container(\n            width: 20,\n            alignment: Alignment.center,\n            child: Text(\n              isFlat ? '♭' : '♯',\n              style: TextStyle(\n                fontSize: 12,\n                fontWeight: FontWeight.w900,\n                color: isFlat\n                    ? colors.onPrimaryContainer\n                    : colors.onSurfaceVariant,\n              ),\n            ),\n          ),\n        ),\n""",
    """""",
)
replace_once(
    "lib/presentations/song/widgets/draggable_midi_controls.dart",
    """        if (widget.onToggleChord != null && widget.chordToggleEnabled)\n          _AnimatedIconButton(\n            onPressed: widget.onToggleChord,\n            icon: widget.showChord\n                ? Icons.music_note_rounded\n                : Icons.music_off_rounded,\n            color: widget.showChord ? colors.primary : colors.onSurfaceVariant,\n            tooltip: widget.showChord ? 'Sembunyikan chord' : 'Tampilkan chord',\n          ),\n        _AnimatedIconButton(""",
    """        if (widget.onToggleChord != null && widget.chordToggleEnabled)\n          _AnimatedIconButton(\n            onPressed: widget.onToggleChord,\n            icon: widget.showChord\n                ? Icons.music_note_rounded\n                : Icons.music_off_rounded,\n            color: widget.showChord ? colors.primary : colors.onSurfaceVariant,\n            tooltip: widget.showChord ? 'Sembunyikan chord' : 'Tampilkan chord',\n          ),\n        if (widget.onToggleAccidental != null && widget.chordToggleEnabled)\n          _AccidentalActionButton(\n            isFlat: widget.chordAccidentalMode == ChordService.accidentalFlat,\n            onPressed: widget.onToggleAccidental!,\n            colors: colors,\n          ),\n        _AnimatedIconButton(""",
)
replace_once(
    "lib/presentations/song/widgets/draggable_midi_controls.dart",
    """/// The morphing surface that interpolates between the sidebar circle""",
    """class _AccidentalActionButton extends StatelessWidget {\n  const _AccidentalActionButton({\n    required this.isFlat,\n    required this.onPressed,\n    required this.colors,\n  });\n\n  final bool isFlat;\n  final VoidCallback onPressed;\n  final ColorScheme colors;\n\n  @override\n  Widget build(BuildContext context) {\n    return Tooltip(\n      message: isFlat ? 'Notasi Chord: Flat (♭)' : 'Notasi Chord: Sharp (♯)',\n      child: InkResponse(\n        key: const ValueKey('midi-accidental-toggle'),\n        onTap: onPressed,\n        radius: 20,\n        child: SizedBox.square(\n          dimension: 32,\n          child: Center(\n            child: Text(\n              isFlat ? '♭' : '♯',\n              style: Theme.of(context).textTheme.titleMedium?.copyWith(\n                    color: colors.primary,\n                    fontWeight: FontWeight.w900,\n                    height: 1,\n                  ),\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}\n\n/// The morphing surface that interpolates between the sidebar circle""",
)

# ---------------------------------------------------------------------------
# PDF viewer: invalidate stale fit callbacks on every mode change and prompt
# portrait users to rotate for a useful two-page spread.
# ---------------------------------------------------------------------------
replace_once(
    "lib/presentations/song/widgets/song_pdf_viewer.dart",
    """    if (oldWidget.twoPageMode != widget.twoPageMode ||\n        oldWidget.verticalScrolling != widget.verticalScrolling) {\n      _needsInitialFit = true;\n      _cachedLayout = null;\n      _cachedLayoutKey = null;\n      _cachedParams = null;\n      setState(() {});\n      WidgetsBinding.instance.addPostFrameCallback((_) {\n        if (!mounted) return;\n        _invalidatePdfIfReady();\n        _scheduleFitWithFallback();\n      });\n    }""",
    """    if (oldWidget.twoPageMode != widget.twoPageMode ||\n        oldWidget.verticalScrolling != widget.verticalScrolling) {\n      // Treat a layout mode change as a new fit generation. Async fit work\n      // from the previous mode now fails its generation check instead of\n      // applying a stale single-page matrix after two-page mode was selected.\n      _pathGeneration++;\n      final generation = _pathGeneration;\n      _viewerReadyGeneration = null;\n      _viewerReadyWatchdog?.cancel();\n      _needsInitialFit = true;\n      _cachedLayout = null;\n      _cachedLayoutKey = null;\n      _cachedParams = null;\n      setState(() {});\n      WidgetsBinding.instance.addPostFrameCallback((_) {\n        if (!mounted || generation != _pathGeneration) return;\n        _invalidatePdfIfReady();\n        _scheduleFitWithFallback();\n        _scheduleViewerReadyWatchdog(generation);\n      });\n    }""",
)
replace_once(
    "lib/presentations/song/widgets/song_pdf_viewer.dart",
    """  /// * **two-page** — autofit the whole spread: both pages fit fully inside\n  ///   the viewport (portrait or landscape), no rotate-to-landscape prompt.""",
    """  /// * **two-page** — autofit the whole spread. Portrait remains usable,\n  ///   but the UI recommends landscape for a readable side-by-side spread.""",
)
replace_once(
    "lib/presentations/song/widgets/song_pdf_viewer.dart",
    """              // Two-page mode works in BOTH orientations: the layout places\n              // the two pages side by side and the initial fit scales the\n              // whole spread into the viewport, so no rotate-to-landscape\n              // prompt is needed (previously shown in portrait).\n\n""",
    """""",
)
replace_once(
    "lib/presentations/song/widgets/song_pdf_viewer.dart",
    """                    Positioned(\n                      bottom: 12,\n                      right: 12,\n                      child: _PdfPageNavigator(""",
    """                    if (widget.twoPageMode &&\n                        orientation == Orientation.portrait)\n                      const Positioned(\n                        top: 12,\n                        left: 12,\n                        right: 12,\n                        child: _RotateLandscapeHint(),\n                      ),\n                    Positioned(\n                      bottom: 12,\n                      right: 12,\n                      child: _PdfPageNavigator(""",
)
replace_once(
    "lib/presentations/song/widgets/song_pdf_viewer.dart",
    """/// Compact floating navigator rendered at the bottom-right corner of""",
    """class _RotateLandscapeHint extends StatelessWidget {\n  const _RotateLandscapeHint();\n\n  @override\n  Widget build(BuildContext context) {\n    final colors = Theme.of(context).colorScheme;\n    final isIndonesian =\n        Localizations.localeOf(context).languageCode.toLowerCase() == 'id';\n    return Center(\n      child: Material(\n        color: colors.inverseSurface.withValues(alpha: 0.90),\n        borderRadius: context.appRadius(999),\n        child: Padding(\n          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),\n          child: Row(\n            mainAxisSize: MainAxisSize.min,\n            children: [\n              Icon(\n                Icons.screen_rotation_alt_rounded,\n                size: 17,\n                color: colors.onInverseSurface,\n              ),\n              const SizedBox(width: 7),\n              Flexible(\n                child: Text(\n                  isIndonesian\n                      ? 'Putar ke landscape untuk 2 halaman'\n                      : 'Rotate to landscape for two pages',\n                  maxLines: 1,\n                  overflow: TextOverflow.ellipsis,\n                  style: Theme.of(context).textTheme.labelMedium?.copyWith(\n                        color: colors.onInverseSurface,\n                        fontWeight: FontWeight.w700,\n                      ),\n                ),\n              ),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n}\n\n/// Compact floating navigator rendered at the bottom-right corner of""",
)

# ---------------------------------------------------------------------------
# Bible Audio range: three compact destination modes always fit one row.
# ---------------------------------------------------------------------------
replace_once(
    "lib/presentations/bible/widgets/bible_audio_sidebar.dart",
    """    final isChapterEnd = !hasEnd && !state.autoNextChapter;\n\n    return Container(""",
    """    final isChapterEnd = !hasEnd && !state.autoNextChapter;\n    final isIndonesian =\n        Localizations.localeOf(context).languageCode.toLowerCase() == 'id';\n\n    return Container(""",
)
replace_once(
    "lib/presentations/bible/widgets/bible_audio_sidebar.dart",
    """          Wrap(\n            spacing: 7,\n            runSpacing: 7,\n            children: [\n              ChoiceChip(\n                label: Text('bible_range_chapter_end'.tr()),\n                selected: isChapterEnd,\n                showCheckmark: false,\n                onSelected: (_) => onChapterEnd(),\n              ),\n              ChoiceChip(\n                label: Text('bible_range_continue'.tr()),\n                selected: isContinueOn,\n                showCheckmark: false,\n                onSelected: (_) => onContinueOn(),\n              ),\n              ChoiceChip(\n                label: Text('bible_range_to_verse'.tr()),\n                selected: hasEnd,\n                showCheckmark: false,\n                onSelected: (_) {\n                  final base = state.ttsPlayRangeStart ?? state.currentBible;\n                  if (base != null) onEndChanged(base);\n                },\n              ),\n            ],\n          ),""",
    """          Row(\n            children: [\n              Expanded(\n                child: _RangeModeButton(\n                  label: isIndonesian ? 'Akhir Pasal' : 'Chapter End',\n                  selected: isChapterEnd,\n                  onTap: onChapterEnd,\n                ),\n              ),\n              const SizedBox(width: 5),\n              Expanded(\n                child: _RangeModeButton(\n                  label: isIndonesian ? 'Lanjut' : 'Continue',\n                  selected: isContinueOn,\n                  onTap: onContinueOn,\n                ),\n              ),\n              const SizedBox(width: 5),\n              Expanded(\n                child: _RangeModeButton(\n                  label: isIndonesian ? 'Ayat' : 'Verse',\n                  selected: hasEnd,\n                  onTap: () {\n                    final base = state.ttsPlayRangeStart ?? state.currentBible;\n                    if (base != null) onEndChanged(base);\n                  },\n                ),\n              ),\n            ],\n          ),""",
)
replace_once(
    "lib/presentations/bible/widgets/bible_audio_sidebar.dart",
    """class _RangePointPicker extends StatelessWidget {""",
    """class _RangeModeButton extends StatelessWidget {\n  const _RangeModeButton({\n    required this.label,\n    required this.selected,\n    required this.onTap,\n  });\n\n  final String label;\n  final bool selected;\n  final VoidCallback onTap;\n\n  @override\n  Widget build(BuildContext context) {\n    final colors = context.colorScheme;\n    return Material(\n      color: selected\n          ? colors.primaryContainer\n          : colors.surfaceContainerLowest.withValues(alpha: 0.72),\n      borderRadius: context.appRadius(9),\n      child: InkWell(\n        onTap: onTap,\n        borderRadius: context.appRadius(9),\n        child: Container(\n          height: 34,\n          padding: const EdgeInsets.symmetric(horizontal: 4),\n          alignment: Alignment.center,\n          decoration: BoxDecoration(\n            borderRadius: context.appRadius(9),\n            border: Border.all(\n              color: selected\n                  ? colors.primary.withValues(alpha: 0.55)\n                  : colors.outlineVariant.withValues(alpha: 0.45),\n            ),\n          ),\n          child: FittedBox(\n            fit: BoxFit.scaleDown,\n            child: Text(\n              label,\n              maxLines: 1,\n              style: context.textTheme.labelSmall?.copyWith(\n                color: selected\n                    ? colors.onPrimaryContainer\n                    : colors.onSurfaceVariant,\n                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,\n              ),\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}\n\nclass _RangePointPicker extends StatelessWidget {""",
)

# ---------------------------------------------------------------------------
# Suara Sejati: show the actual description and shrink it instead of ellipsis.
# ---------------------------------------------------------------------------
replace_once(
    "lib/presentations/home/view/home_view.dart",
    """      child: (gap) => SizedBox(\n        height: 186,""",
    """      child: (gap) => SizedBox(\n        height: 198,""",
)
replace_once(
    "lib/presentations/home/view/home_view.dart",
    """            final item = trueVoices[index];\n            return Padding(""",
    """            final item = trueVoices[index];\n            final description = item.description.trim().isNotEmpty\n                ? item.description.trim()\n                : item.creator.trim();\n            return Padding(""",
)
replace_once(
    "lib/presentations/home/view/home_view.dart",
    """                                  if (item.creator.trim().isNotEmpty) ...[\n                                    const SizedBox(height: 3),\n                                    Text(\n                                      item.creator.trim(),\n                                      maxLines: 2,\n                                      overflow: TextOverflow.ellipsis,\n                                      style: context.textTheme.bodySmall\n                                          ?.copyWith(\n                                            color: colors.onSurfaceVariant,\n                                            height: 1.2,\n                                          ),\n                                    ),\n                                  ],""",
    """                                  if (description.isNotEmpty) ...[\n                                    const SizedBox(height: 3),\n                                    Expanded(\n                                      child: AutoSizeText(\n                                        description,\n                                        maxLines: 2,\n                                        minFontSize: 7,\n                                        maxFontSize: 12,\n                                        stepGranularity: 0.5,\n                                        overflow: TextOverflow.visible,\n                                        style: context.textTheme.bodySmall\n                                            ?.copyWith(\n                                              color: colors.onSurfaceVariant,\n                                              height: 1.15,\n                                            ),\n                                      ),\n                                    ),\n                                  ],""",
)

# ---------------------------------------------------------------------------
# Faith selection: lower, rounded and compact; also remove async BuildContext
# lint by resolving locale before the await.
# ---------------------------------------------------------------------------
replace_once(
    "lib/presentations/faith/view/faith_view.dart",
    """    final colors = context.colorScheme;\n    final bottom = MediaQuery.viewPaddingOf(context).bottom;\n    final sorted = [...indexes]..sort();\n\n    return Material(\n      color: colors.surfaceContainerHigh,\n      elevation: 0,\n      child: SafeArea(\n        top: false,\n        child: Container(\n          padding: EdgeInsets.fromLTRB(14, 10, 8, 10 + bottom * 0.08),\n          decoration: BoxDecoration(\n            border: Border(\n              top: BorderSide(color: colors.primary.withValues(alpha: 0.18)),\n            ),\n          ),\n          child: Row(""",
    """    final colors = context.colorScheme;\n    final sorted = [...indexes]..sort();\n\n    return SafeArea(\n      top: false,\n      minimum: const EdgeInsets.fromLTRB(10, 0, 10, 86),\n      child: Material(\n        elevation: 8,\n        shadowColor: colors.shadow.withValues(alpha: 0.22),\n        color: colors.surfaceContainerHigh,\n        shape: RoundedRectangleBorder(\n          borderRadius: context.appRadius(18),\n          side: BorderSide(color: colors.primary.withValues(alpha: 0.16)),\n        ),\n        clipBehavior: Clip.antiAlias,\n        child: Padding(\n          padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),\n          child: Row(""",
)
replace_once(
    "lib/presentations/faith/view/faith_view.dart",
    """            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  void _openNote(BuildContext context, int index) {""",
    """            ],\n          ),\n        ),\n      ),\n    );\n  }\n\n  void _openNote(BuildContext context, int index) {""",
)
replace_once(
    "lib/presentations/faith/view/faith_view.dart",
    """  final buffer = StringBuffer(title);\n  for (final index in indexes) {""",
    """  final languageCode = Localizations.localeOf(context).languageCode;\n  final buffer = StringBuffer(title);\n  for (final index in indexes) {""",
)
replace_once(
    "lib/presentations/faith/view/faith_view.dart",
    """    final footer = json[Localizations.localeOf(context).languageCode];""",
    """    final footer = json[languageCode];""",
)

# ---------------------------------------------------------------------------
# Menu-label capitalization audit (Indonesian labels, not sentence copy).
# ---------------------------------------------------------------------------
for old, new in [
    ('\"Link lainnya\": \"Link lainnya\"', '\"Link lainnya\": \"Link Lainnya\"'),
    ('\"Perjanjian lama\": \"Perjanjian lama\"', '\"Perjanjian lama\": \"Perjanjian Lama\"'),
    ('\"Perjanjian baru\": \"Perjanjian baru\"', '\"Perjanjian baru\": \"Perjanjian Baru\"'),
    ('\"Hapus playlist\": \"Hapus playlist\"', '\"Hapus playlist\": \"Hapus Playlist\"'),
    ('\"Jadikan aktif\": \"Jadikan aktif\"', '\"Jadikan aktif\": \"Jadikan Aktif\"'),
    ('\"Playlist kosong\": \"Playlist kosong\"', '\"Playlist kosong\": \"Playlist Kosong\"'),
    ('\"Ibadah online\": \"Ibadah online\"', '\"Ibadah online\": \"Ibadah Online\"'),
]:
    replace_once("assets/translations/id.json", old, new)

print("all deterministic follow-up patches applied")
