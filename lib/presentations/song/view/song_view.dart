import 'dart:collection';
import 'dart:ui' as ui show TextDirection;

import '../../../components/components.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart'
    show GestureBinding, PointerScrollEvent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyEvent, KeyEventCallback;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/chord_text_layout.dart';
import '../../../data/services/pdf_note_service.dart';
import '../../../domain/entity/song/song_entity.dart';
import '../../../router/router.dart';
import '../../presentations.dart';
import '../widgets/song_pdf_viewer.dart';

const double _songTextMaxContentWidth = 920;

@RoutePage()
class SongView extends StatefulWidget {
  const SongView({super.key});

  @override
  State<SongView> createState() => _SongViewState();
}

bool shouldRenderChordForSongState(SongState state) {
  return state.bookCode != 'HYMNE' && state.showChord;
}

class _SongViewState extends State<SongView> {
  late final cubit = context.read<SongCubit>();
  late final int _initialPageIndex = _resolveInitialPageIndex();
  late final PageController pageController = PageController(
    initialPage: _initialPageIndex,
  )..addListener(pageListener);

  late int currentPageIndex = _initialPageIndex;
  int _currentVerseIndex = 0;
  bool _isChordEditMode = false;

  /// Text-mode pinch/ctrl+scroll zoom multiplier (0.5x–2.5x) applied on top of
  /// the reader's text scale. Zoom is deliberately local to this view: it
  /// never emits cubit state, so pinching cannot cause a hydration write
  /// storm, and it resets with the widget's lifecycle.
  double _textZoom = 1.0;

  /// True while a two-pointer pinch is active in the text layer. While true,
  /// the song PageView physics are disabled so a pinch can never be mistaken
  /// for a song swipe (zoom has priority over navigation).
  bool _isTextPinching = false;

  /// Tracks the Control modifier for mouse Ctrl+scroll zooming.
  bool _ctrlPressed = false;
  KeyEventCallback? _keyboardHandler;

  int _resolveInitialPageIndex() {
    try {
      final index = cubit.state.histories.last.index;
      if (cubit.state.songs.length > index) {
        return index;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  late String _currentBookCode = cubit.state.bookCode;
  final _pdfViewerController = PdfViewerController();

  void pageListener() {
    final newIndex = pageController.page?.round() ?? currentPageIndex;
    if (newIndex != currentPageIndex) {
      setState(() {
        currentPageIndex = newIndex;
        _currentVerseIndex = 0;
      });
      cubit.changePage(newIndex, 0);
      // Note: PDF/chord/MIDI loading is handled by Cubit and BlocConsumer
    }
  }

  @override
  void dispose() {
    final handler = _keyboardHandler;
    if (handler != null) {
      HardwareKeyboard.instance.removeHandler(handler);
    }
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (cubit.state.songs.isNotEmpty && cubit.state.currentPdfPath == null) {
      cubit.changePage(currentPageIndex, _currentVerseIndex);
    }
    // Chords are now managed by cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openSongSelector();
    });
    _keyboardHandler = _trackControlModifier;
    HardwareKeyboard.instance.addHandler(_trackControlModifier);
  }

  /// Keeps [_ctrlPressed] in sync with the physical Control key so
  /// Ctrl+scroll can zoom the text. Never consumes the event.
  bool _trackControlModifier(KeyEvent event) {
    final pressed = HardwareKeyboard.instance.isControlPressed;
    if (pressed != _ctrlPressed && mounted) {
      setState(() => _ctrlPressed = pressed);
    }
    return false;
  }

  /// Applies a relative zoom step (negative = smaller) to the text-mode
  /// scale, clamped to 0.5x–2.5x.
  void _applyTextZoom(double delta) {
    final next = (_textZoom + delta).clamp(0.5, 2.5);
    if ((next - _textZoom).abs() < 0.001) return;
    setState(() => _textZoom = next);
  }

  // _loadChordData removed, managed by SongCubit

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SongCubit, SongState>(
          listenWhen: (previous, current) =>
              previous.pageIndex != current.pageIndex ||
              previous.bookCode != current.bookCode ||
              previous.songBook != current.songBook ||
              previous.showChord != current.showChord ||
              previous.currentPdfPath != current.currentPdfPath ||
              (previous.songs.isEmpty && current.songs.isNotEmpty),
          listener: (context, state) {
            final safePageIndex = state.songs.isEmpty
                ? 0
                : state.pageIndex.clamp(0, state.songs.length - 1).toInt();
            final newBookCode = state.bookCode;
            final songsJustLoaded =
                state.songs.isNotEmpty && state.currentPdfPath == null;
            // True when the actual song changed
            final songChanged =
                safePageIndex != currentPageIndex ||
                newBookCode != _currentBookCode;

            setState(() {
              currentPageIndex = safePageIndex;
              _currentVerseIndex = state.verseIndex;
              _currentBookCode = newBookCode;
              if (newBookCode == 'HYMNE' && _isChordEditMode) {
                _isChordEditMode = false;
              }
            });

            // Sync the PageController so the visible page matches the state.
            if ((songsJustLoaded || songChanged) && pageController.hasClients) {
              if (pageController.page?.round() != safePageIndex) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (pageController.hasClients &&
                      pageController.page?.round() != safePageIndex) {
                    pageController.jumpToPage(safePageIndex);
                  }
                });
              }
            }
          },
        ),
        // Separate listener: when the user switches from PDF to text
        // mode the PageView is (re-)mounted but the PageController
        // still holds the position from its previous life (or
        // initialPage if never used).  Schedule a jump to the
        // current song so the text view opens at the correct hymn.
        BlocListener<SongCubit, SongState>(
          listenWhen: (previous, current) =>
              previous.isImageMode != current.isImageMode &&
              current.isImageMode,
          listener: (context, state) {
            final safePageIndex = state.songs.isEmpty
                ? 0
                : state.pageIndex.clamp(0, state.songs.length - 1).toInt();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (pageController.hasClients &&
                  pageController.page?.round() != safePageIndex) {
                pageController.jumpToPage(safePageIndex);
              }
            });
          },
        ),
      ],
      child: BlocBuilder<SongCubit, SongState>(
        buildWhen: (previous, current) =>
            previous.isImageMode != current.isImageMode ||
            previous.bookCode != current.bookCode ||
            previous.showAudio != current.showAudio,
        builder: (context, state) {
          final textMode = state.isImageMode;
          final colors = Theme.of(context).colorScheme;
          final chordToggleEnabled = state.bookCode != 'HYMNE';

          return Scaffold(
            backgroundColor: colors.surface,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: colors.surface.withValues(alpha: 0.88),
              foregroundColor: colors.onSurface,
              surfaceTintColor: Colors.transparent,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
              toolbarHeight: 60,
              leadingWidth: 40,
              leading: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.menu_outlined),
                tooltip: 'Menu',
                onPressed: openDashboardDrawer,
              ),
              titleSpacing: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.surface,
                      colors.surface.withValues(alpha: 0.94),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),
              title: Center(
                child: BlocBuilder<SongCubit, SongState>(
                  buildWhen: (prev, curr) =>
                      prev.pageIndex != curr.pageIndex ||
                      prev.bookCode != curr.bookCode ||
                      prev.songs != curr.songs,
                  builder: (context, state) => _SongHeaderTitle(
                    number: state.getSongNumberAt(currentPageIndex),
                    title: state.getSongTitleAt(currentPageIndex),
                    familyChord: state.originalFamilyChord,
                    pdfKey: state.originalPdfKey,
                    accidentalMode: state.chordAccidentalMode,
                    baseTransposeOffset: state.baseTransposeOffset,
                    canGoPrevious: currentPageIndex > 0,
                    canGoNext: currentPageIndex < state.songs.length - 1,
                    onPrevious: _goToPreviousSong,
                    onNext: _goToNextSong,
                    onTapTitle: _openSongSelector,
                    onEditTriggered: _toggleChordEditMode,
                  ),
                ),
              ),
              actions: [
                BlocSelector<
                  SongCubit,
                  SongState,
                  (bool, bool, bool, bool, bool, bool, int?)
                >(
                  selector: (state) {
                    // Parse the current PDF path to get the page count
                    // from the manifest.  This tells us whether the
                    // hymn has only 1 page â€” in which case two-page
                    // and vertical-scroll modes are meaningless and
                    // their buttons should be disabled.
                    int? pageCount;
                    final pdfPath = state.currentPdfPath;
                    if (pdfPath != null) {
                      try {
                        pageCount = PdfDocumentRequest.parse(pdfPath).pageCount;
                      } catch (_) {}
                    }
                    return (
                      state.pdfTwoPageMode,
                      state.pdfVerticalScrolling,
                      state.showChord,
                      state.bookCode != 'HYMNE',
                      state.isImageMode,
                      state.showAudio,
                      pageCount,
                    );
                  },
                  builder: (context, view) {
                    final (
                      isTwoPage,
                      isVertical,
                      showChord,
                      chordEnabled,
                      isText,
                      showAudio,
                      pageCount,
                    ) = view;
                    return _PageModeMenuButton(
                      cubit: cubit,
                      pdfTwoPageMode: isTwoPage,
                      pdfVerticalScrolling: isVertical,
                      showChord: showChord,
                      chordToggleEnabled: chordEnabled,
                      textMode: isText,
                      showAudio: showAudio,
                      pageCount: pageCount,
                      onFitPage: _fitPdfToPage,
                      onShare: () => _shareCurrentSong(cubit.state),
                      onOpenLyrics: _openLyricsSettings,
                      onOpenChordSettings: _openChordSettings,
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.surfaceContainerHighest.withValues(
                            alpha: 0.22,
                          ),
                          colors.surfaceContainerLow.withValues(alpha: 0.4),
                          colors.surface,
                        ],
                      ),
                    ),
                  ),
                ),
                // Text mode layer
                if (textMode)
                  BlocBuilder<SongCubit, SongState>(
                    buildWhen: (prev, curr) =>
                        prev.pageIndex != curr.pageIndex ||
                        prev.bookCode != curr.bookCode ||
                        prev.defaultFont != curr.defaultFont ||
                        prev.defaultTextScale != curr.defaultTextScale ||
                        prev.defaultTextHeight != curr.defaultTextHeight ||
                        prev.lyricsTextAlign != curr.lyricsTextAlign ||
                        prev.lyricsVerticalAlign != curr.lyricsVerticalAlign ||
                        prev.showChord != curr.showChord ||
                        prev.currentChords != curr.currentChords ||
                        prev.transposeStep != curr.transposeStep ||
                        prev.baseTransposeOffset != curr.baseTransposeOffset ||
                        prev.chordAccidentalMode != curr.chordAccidentalMode ||
                        prev.currentPdfPath != curr.currentPdfPath ||
                        prev.songs != curr.songs,
                    builder: (context, state) => RepaintBoundary(
                      child: Listener(
                        // Mouse: Ctrl+scroll zooms the text. The signal is
                        // claimed through the pointer-signal resolver so the
                        // underlying scrollables do not scroll at the same
                        // time.
                        onPointerSignal: (event) {
                          if (event is PointerScrollEvent && _ctrlPressed) {
                            GestureBinding.instance.pointerSignalResolver
                                .register(event, (_) {
                              _applyTextZoom(
                                -event.scrollDelta.dy / 120 * 0.1,
                              );
                            });
                          }
                        },
                        child: PageView.builder(
                          controller: pageController,
                          physics: _isTextPinching
                              ? const NeverScrollableScrollPhysics()
                              : const BouncingScrollPhysics(),
                          itemCount: state.songs.length,
                          itemBuilder: (context, index) {
                            final song = state.songs[index];
                            // Chord data is keyed by song-relative page
                            // (1-based).  The text view flattens every page's
                            // chords so lines from any verse (which may sit on
                            // any PDF page) get their notes' chords.
                            final isActiveSong = index == currentPageIndex;
                            final songChords = isActiveSong
                                ? state.currentChords
                                : const <int, List<ChordData>>{};
                            return RepaintBoundary(
                              child: _SongTextPage(
                                song: song,
                                fontFamily: state.defaultFont,
                                textScale:
                                    state.defaultTextScale * _textZoom,
                                textHeight: state.defaultTextHeight,
                                fontBold: state.fontBold,
                                textAlign: state.lyricsTextAlign,
                                verticalAlign: state.lyricsVerticalAlign,
                                verseIndex: _currentVerseIndex,
                                onPreviousVerse: _previousVerse,
                                onNextVerse: () => _nextVerse(song),
                                onPinchStart: () {
                                  if (!_isTextPinching) {
                                    setState(() => _isTextPinching = true);
                                  }
                                },
                                onPinchScale: (scale) {
                                  if (!mounted) return;
                                  final next =
                                      scale.clamp(0.5, 2.5);
                                  if ((next - _textZoom).abs() < 0.001) {
                                    return;
                                  }
                                  setState(() => _textZoom = next);
                                },
                                onPinchEnd: () {
                                  if (_isTextPinching && mounted) {
                                    setState(() => _isTextPinching = false);
                                  }
                                },
                                chords: songChords,
                                pdfPath: isActiveSong
                                    ? state.currentPdfPath
                                    : null,
                                showChords:
                                    isActiveSong &&
                                    shouldRenderChordForSongState(state),
                                transposeStep: state.transposeStep,
                                baseTransposeOffset:
                                    state.baseTransposeOffset,
                                chordAccidentalMode:
                                    state.chordAccidentalMode,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Separate PDF Viewer layer
                if (!textMode)
                  BlocBuilder<SongCubit, SongState>(
                    buildWhen: (prev, curr) =>
                        prev.currentPdfPath != curr.currentPdfPath ||
                        prev.showChord != curr.showChord ||
                        prev.currentChords != curr.currentChords ||
                        prev.transposeStep != curr.transposeStep ||
                        prev.baseTransposeOffset != curr.baseTransposeOffset ||
                        prev.chordAccidentalMode !=
                            curr.chordAccidentalMode ||
                        prev.pdfTwoPageMode != curr.pdfTwoPageMode ||
                        prev.pdfVerticalScrolling !=
                            curr.pdfVerticalScrolling ||
                        prev.chordFontSizePercent !=
                            curr.chordFontSizePercent ||
                        prev.chordFillOpacityPercent !=
                            curr.chordFillOpacityPercent ||
                        prev.chordPaddingPercent != curr.chordPaddingPercent ||
                        prev.chordOffsetPercent != curr.chordOffsetPercent,
                    builder: (context, state) {
                      if (state.currentPdfPath == null) {
                        return const SizedBox.shrink();
                      }
                      // The dashboard owns a dedicated bottom-navigation
                      // region, so the viewer can fill the remaining body
                      // without content being covered by the dock.
                      return SizedBox.expand(
                        child: RepaintBoundary(
                          child: SongPdfViewer(
                            key: const ValueKey('pdf_viewer_instance'),
                            pdfPath: state.currentPdfPath,
                            showChord: shouldRenderChordForSongState(state),
                            chords: state.currentChords,
                            transposeStep: state.transposeStep,
                            baseTransposeOffset: state.baseTransposeOffset,
                            chordAccidentalMode: state.chordAccidentalMode,
                            twoPageMode: state.pdfTwoPageMode,
                            verticalScrolling: state.pdfVerticalScrolling,
                            chordFontSizePercent: state.chordFontSizePercent,
                            chordFillOpacityPercent:
                                state.chordFillOpacityPercent,
                            chordPaddingPercent: state.chordPaddingPercent,
                            chordOffsetPercent: state.chordOffsetPercent,
                            isEditMode: chordToggleEnabled && _isChordEditMode,
                            onChordsChanged: (updatedChords) {
                              cubit.detectAndUpdateFamilyChord(updatedChords);
                            },
                            viewerController: _pdfViewerController,
                            onNextSong: _goToNextSong,
                            onPreviousSong: _goToPreviousSong,
                          ),
                        ),
                      );
                    },
                  ),

                // PDF/audio loading indicators
                BlocBuilder<SongCubit, SongState>(
                  buildWhen: (prev, curr) =>
                      prev.isAudioLoading != curr.isAudioLoading ||
                      prev.isPdfLoading != curr.isPdfLoading,
                  builder: (context, state) {
                    if (!state.isAudioLoading && !state.isPdfLoading) {
                      return const SizedBox.shrink();
                    }

                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isPdfLoading)
                            Container(
                              width: double.infinity,
                              color: colors.primaryContainer.withValues(
                                alpha: 0.88,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Text(
                                'Preparing local PDF for offline access...',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          if (state.isPdfLoading)
                            LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.primary,
                              ),
                            ),
                          if (state.isAudioLoading)
                            LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                colors.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                // MIDI player overlay is rendered globally by the
                // dashboard so it stays visible on every tab.
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _shareCurrentSong(SongState state) async {
    if (currentPageIndex >= state.songs.length) return;
    final song = state.songs[currentPageIndex];
    final text = '${song.number} - ${song.title}';
    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: song.title),
      );
    } catch (_) {
      // Share is unavailable on some platforms â€” ignore.
    }
  }

  Future<void> _openLyricsSettings() {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return BlocBuilder<SongCubit, SongState>(
          bloc: cubit,
          buildWhen: (prev, curr) =>
              prev.defaultFont != curr.defaultFont ||
              prev.defaultTextScale != curr.defaultTextScale ||
              prev.defaultTextHeight != curr.defaultTextHeight ||
              prev.lyricsTextAlign != curr.lyricsTextAlign ||
              prev.lyricsVerticalAlign != curr.lyricsVerticalAlign ||
              prev.availableFonts != curr.availableFonts,
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer.withValues(alpha: 0.55),
                        colors.surfaceContainerHighest,
                      ],
                    ),
                    borderRadius: context.appRadius(8),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    'Pengaturan lirik',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: state.availableFonts.contains(state.defaultFont)
                      ? state.defaultFont
                      : state.availableFonts.first,
                  decoration: const InputDecoration(labelText: 'Font'),
                  items: state.availableFonts
                      .map(
                        (font) => DropdownMenuItem<String>(
                          value: font,
                          child: Text(font),
                        ),
                      )
                      .toList(),
                  onChanged: (font) {
                    if (font != null) cubit.changeFont(font);
                  },
                ),
                const SizedBox(height: 16),
                _LyricsSlider(
                  label: 'Ukuran',
                  value: state.defaultTextScale,
                  min: 0.8,
                  max: 2.4,
                  divisions: 16,
                  displayValue: '${(state.defaultTextScale * 100).round()}%',
                  onChanged: cubit.changeTextScale,
                ),
                _LyricsSlider(
                  label: 'Spacing',
                  value: state.defaultTextHeight,
                  min: 1.0,
                  max: 2.4,
                  divisions: 14,
                  displayValue: state.defaultTextHeight.toStringAsFixed(1),
                  onChanged: cubit.changeTextHeight,
                ),
                const SizedBox(height: 8),
                _LyricsChoiceGroup(
                  label: 'Horizontal',
                  value: state.lyricsTextAlign,
                  options: const {
                    'left': 'Kiri',
                    'center': 'Tengah',
                    'right': 'Kanan',
                  },
                  onSelected: cubit.changeLyricsTextAlign,
                ),
                const SizedBox(height: 8),
                _LyricsChoiceGroup(
                  label: 'Vertikal',
                  value: state.lyricsVerticalAlign,
                  options: const {
                    'top': 'Atas',
                    'center': 'Tengah',
                    'bottom': 'Bawah',
                  },
                  onSelected: cubit.changeLyricsVerticalAlign,
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Chord overlay settings: font size, badge padding, and the vertical gap
  /// between the chord badge and its note number.
  Future<void> _openChordSettings() {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return BlocBuilder<SongCubit, SongState>(
          bloc: cubit,
          buildWhen: (prev, curr) =>
              prev.chordFontSizePercent != curr.chordFontSizePercent ||
              prev.chordPaddingPercent != curr.chordPaddingPercent ||
              prev.chordOffsetPercent != curr.chordOffsetPercent,
          builder: (context, state) {
            final colors = Theme.of(context).colorScheme;
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer.withValues(alpha: 0.55),
                        colors.surfaceContainerHighest,
                      ],
                    ),
                    borderRadius: context.appRadius(8),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    'chord_settings_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _LyricsSlider(
                  label: 'chord_settings_size'.tr(),
                  value: state.chordFontSizePercent.toDouble(),
                  min: 50,
                  max: 200,
                  divisions: 15,
                  displayValue: '${state.chordFontSizePercent}%',
                  onChanged: (value) =>
                      cubit.changeChordFontSizePercent(value.round()),
                ),
                _LyricsSlider(
                  label: 'chord_settings_offset'.tr(),
                  value: state.chordOffsetPercent.toDouble(),
                  min: 0,
                  max: 300,
                  divisions: 30,
                  displayValue:
                      '${(state.chordOffsetPercent <= 100 ? 'chord_settings_close' : 'chord_settings_far').tr()} (${state.chordOffsetPercent}%)',
                  onChanged: (value) =>
                      cubit.changeChordOffsetPercent(value.round()),
                ),
                _LyricsSlider(
                  label: 'chord_settings_padding'.tr(),
                  value: state.chordPaddingPercent.toDouble(),
                  min: 0,
                  max: 400,
                  divisions: 20,
                  displayValue: '${state.chordPaddingPercent}%',
                  onChanged: (value) =>
                      cubit.changeChordPaddingPercent(value.round()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSongSelector() {
    router.push(
      SongListRoute(
        books: () => cubit.state.songBook,
        currentBook: () =>
            cubit.state.currentSong ??
            SongBook(code: cubit.state.bookCode, songs: const []),
        initialSearchText: cubit.state.searchTerms,
        onSearchTermsChanged: cubit.onSearchTermsChanged,
        onChangeBookCode: (bookCode) {
          cubit.changeBookcode(bookCode);
        },
        onTapPageNumber: (pageNumber) async {
          // Find the song in the currently selected book and open it.
          final song = cubit.state.songs.firstWhereOrNull(
            (s) => s.number == pageNumber,
          );
          router.maybePop();
          if (song != null) {
            final bookCode = song.code ?? cubit.state.bookCode;
            final book = cubit.state.songBook.firstWhere(
              (book) => book.code == bookCode,
              orElse: () => SongBook(code: bookCode, songs: const []),
            );
            final index = book.songs.indexWhere(
              (item) => item.code == song.code && item.number == song.number,
            );
            if (index >= 0) {
              setState(() {
                currentPageIndex = index;
                _currentBookCode = bookCode;
              });
              if (pageController.hasClients) {
                pageController.jumpToPage(index);
              }
              cubit.openSong(song);
            }
          }
        },
        onOpenSong: (song) async {
          // Handle page jump directly to avoid BlocConsumer listener timing issues
          router.maybePop();
          final bookCode = song.code ?? cubit.state.bookCode;
          final book = cubit.state.songBook.firstWhere(
            (book) => book.code == bookCode,
            orElse: () => SongBook(code: bookCode, songs: const []),
          );
          final index = book.songs.indexWhere(
            (item) => item.code == song.code && item.number == song.number,
          );
          if (index >= 0) {
            setState(() {
              currentPageIndex = index;
              _currentBookCode = bookCode;
            });
            if (pageController.hasClients) {
              pageController.jumpToPage(index);
            }
            // When a song is opened from the active playlist (playlist mode
            // toggle on), start MIDI playback immediately so the playlist is
            // connected to the player and auto-next keeps advancing through
            // the playlist queue. Songs opened from other places (recent
            // history, "Buka" button) are not auto-played unless they are
            // members of the active playlist.
            cubit.openSong(
              song,
              autoplay:
                  cubit.state.isPlaylistLoopModeActive &&
                  cubit.isSongInActivePlaylist(song),
            );
          }
        },
        onBack: () => router.maybePop(),
      ),
    );
  }

  void _previousVerse() {
    setState(() {
      if (_currentVerseIndex > 0) _currentVerseIndex--;
    });
  }

  void _nextVerse(Song song) {
    setState(() {
      if (_currentVerseIndex < song.verses.length - 1) _currentVerseIndex++;
    });
  }

  void _goToPreviousSong() => _animateToSongIndex(currentPageIndex - 1);

  void _goToNextSong() => _animateToSongIndex(currentPageIndex + 1);

  void _animateToSongIndex(int index) async {
    if (index < 0 || index >= cubit.state.songs.length) return;
    setState(() => currentPageIndex = index);
    if (pageController.hasClients) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
    cubit.changePage(index, 0);
  }

  void _fitPdfToPage() => _pdfViewerController.fitToPage?.call();

  void _toggleChordEditMode() {
    if (cubit.state.bookCode == 'HYMNE') return;
    setState(() {
      _isChordEditMode = !_isChordEditMode;
    });
  }
}

class _SongHeaderTitle extends StatefulWidget {
  final String? number;
  final String title;
  final String? familyChord;
  final String? pdfKey;
  final String accidentalMode;
  final int baseTransposeOffset;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onTapTitle;
  final VoidCallback? onEditTriggered;

  const _SongHeaderTitle({
    required this.number,
    required this.title,
    required this.familyChord,
    required this.pdfKey,
    required this.accidentalMode,
    required this.baseTransposeOffset,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onTapTitle,
    this.onEditTriggered,
  });

  @override
  State<_SongHeaderTitle> createState() => _SongHeaderTitleState();
}

class _SongHeaderTitleState extends State<_SongHeaderTitle>
    with SingleTickerProviderStateMixin {
  /// Hold-to-enable duration for the hidden chord editor.  10 s of
  /// continuous long-press on the title chip flips [SongCubit] into
  /// chord-edit mode.
  static const Duration _holdToEditDuration = Duration(seconds: 10);

  late final AnimationController _holdAnim;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _holdAnim = AnimationController(vsync: this, duration: _holdToEditDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _holding) {
          _holding = false;
          _holdAnim.reset();
          widget.onEditTriggered?.call();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chord edit mode enabled'.tr()),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      });
  }

  @override
  void dispose() {
    _holdAnim.dispose();
    super.dispose();
  }

  void _onHoldStart() {
    if (widget.onEditTriggered == null) return;
    _holding = true;
    _holdAnim.forward(from: 0);
  }

  void _onHoldEnd() {
    if (!_holding) return;
    _holding = false;
    _holdAnim.stop();
    _holdAnim.reset();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Always reserve space for both chevrons so the title chip
        // stays centred even when only one (or neither) is visible.
        SizedBox(
          width: 48,
          child: widget.canGoPrevious
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Pujian sebelumnya',
                  onPressed: widget.onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                )
              : null,
        ),
        Flexible(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTapTitle,
            onLongPressStart: (_) => _onHoldStart(),
            onLongPressEnd: (_) => _onHoldEnd(),
            onLongPressCancel: _onHoldEnd,
            child: AnimatedBuilder(
              animation: _holdAnim,
              builder: (context, child) {
                final progress = _holdAnim.value;
                return Container(
                  key: ValueKey(widget.title),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer.withValues(alpha: 0.45),
                        colors.surfaceContainerHigh.withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: context.appRadius(16),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with a leading music note and the number as a
                      // small badge â€” keeps the title the anchor while
                      // making the header feel more complete.
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              size: 15,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              widget.title,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: context.appFontSize(15),
                                  ),
                            ),
                            if (widget.number != null &&
                                widget.number!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHigh.withValues(
                                    alpha: 0.8,
                                  ),
                                  borderRadius: context.appRadius(999),
                                ),
                                child: Text(
                                  widget.number!,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (progress > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 2,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: widget.canGoNext
              ? IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Pujian berikutnya',
                  onPressed: widget.onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                )
              : null,
        ),
      ],
    );
  }
}

class _SongTextPage extends StatefulWidget {
  final Song song;
  final String fontFamily;
  final double textScale;
  final double textHeight;
  final bool fontBold;
  final String textAlign;
  final String verticalAlign;
  final int verseIndex;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;

  /// Pinch-to-zoom callbacks. [onPinchStart] fires when a second pointer
  /// joins, [onPinchScale] reports the live scale factor, and [onPinchEnd]
  /// fires when every pointer lifts. The parent disables song-swipe physics
  /// while a pinch is active so zoom always wins over navigation.
  final VoidCallback? onPinchStart;
  final ValueChanged<double>? onPinchScale;
  final VoidCallback? onPinchEnd;

  /// All pages' chord data for the current song (song-relative page â†’ chords).
  final Map<int, List<ChordData>> chords;

  /// Current PDF path (may be null while the PDF is still loading) â€” used to
  /// load the note-aligned chord layout from the PDF text layer.
  final String? pdfPath;
  final bool showChords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;

  const _SongTextPage({
    required this.song,
    required this.fontFamily,
    required this.textScale,
    required this.textHeight,
    required this.fontBold,
    required this.textAlign,
    required this.verticalAlign,
    required this.verseIndex,
    this.onPreviousVerse,
    this.onNextVerse,
    this.onPinchStart,
    this.onPinchScale,
    this.onPinchEnd,
    this.chords = const {},
    this.pdfPath,
    this.showChords = false,
    this.transposeStep = 0,
    this.baseTransposeOffset = 0,
    this.chordAccidentalMode = ChordService.accidentalSharp,
  });

  @override
  State<_SongTextPage> createState() => _SongTextPageState();
}

class _SongTextPageState extends State<_SongTextPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _verseAnimCtrl;
  late final Animation<double> _verseFadeAnim;
  late final Animation<Offset> _verseSlideAnim;

  /// Bounded note-aligned layout cache. The chord data identity is part of
  /// the key so edits never reuse a stale gyschordweb-style projection.
  static final LinkedHashMap<String, Future<List<ChordedTextLine>>>
  _layoutCache = LinkedHashMap();
  static const int _layoutCacheLimit = 24;

  /// Source id the currently-displayed layout was computed for.
  String? _layoutSourceId;
  List<ChordedTextLine>? _layoutLines;
  bool _layoutLoading = false;

  // ---- Pinch-to-zoom tracking ---------------------------------------------
  // Raw pointer bookkeeping: a second finger switches the gesture from
  // verse-swipe to text zoom. Zoom always wins: while two pointers are down,
  // verse navigation is refused and the parent disables song-swiping.
  final Map<int, Offset> _pinchPointers = {};
  bool _pinchActive = false;
  bool _pinchSeenSinceDragStart = false;
  double _pinchStartSpan = 0;

  void _onPinchPointerDown(PointerDownEvent event) {
    _pinchPointers[event.pointer] = event.position;
    _updatePinchState();
  }

  void _onPinchPointerMove(PointerMoveEvent event) {
    _pinchPointers[event.pointer] = event.position;
    if (_pinchActive) _updatePinchState();
  }

  void _onPinchPointerUp(PointerEvent event) {
    _pinchPointers.remove(event.pointer);
    if (_pinchPointers.length < 2) {
      if (_pinchActive) {
        _pinchActive = false;
        widget.onPinchEnd?.call();
      }
    }
  }

  void _updatePinchState() {
    if (_pinchPointers.length < 2) return;
    final points = _pinchPointers.values.toList();
    final span = (points[0] - points[1]).distance;
    if (span <= 0) return;
    if (!_pinchActive) {
      _pinchActive = true;
      _pinchSeenSinceDragStart = true;
      _pinchStartSpan = span;
      widget.onPinchStart?.call();
      return;
    }
    // Incremental zoom: each move rebases the reference span so the scale
    // tracks the fingers 1:1 without drift.
    final factor = span / _pinchStartSpan;
    _pinchStartSpan = span;
    widget.onPinchScale?.call(factor);
  }

  @override
  void initState() {
    super.initState();
    _verseAnimCtrl = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    _verseFadeAnim = CurvedAnimation(
      parent: _verseAnimCtrl,
      curve: Curves.easeOut,
    );
    _verseSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(parent: _verseAnimCtrl, curve: Curves.easeOutCubic),
        );
    _verseAnimCtrl.value = 1.0;
    _startChordLayoutLoad();
  }

  @override
  void didUpdateWidget(_SongTextPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.verseIndex != widget.verseIndex) {
      _verseAnimCtrl.forward(from: 0.0);
    }
    if (oldWidget.pdfPath != widget.pdfPath ||
        oldWidget.chords != widget.chords) {
      _startChordLayoutLoad();
    }
  }

  @override
  void dispose() {
    _verseAnimCtrl.dispose();
    super.dispose();
  }

  String? _sourceIdFor(String? pdfPath) {
    if (pdfPath == null) return null;
    try {
      return PdfDocumentRequest.parse(pdfPath).sourceId;
    } catch (_) {
      return null;
    }
  }

  /// Loads the PDF-derived chord layout (note positions + lyric lines) for
  /// this song so chords land above the right syllables â€” the same placement
  /// gyschordweb uses in its lyrics view.  While loading, lyrics render
  /// without chords; if the layout cannot be built, the proportional
  /// fallback in `_buildVerseLines` takes over.
  void _startChordLayoutLoad() {
    final sourceId = _sourceIdFor(widget.pdfPath);
    if (sourceId == null || widget.chords.isEmpty) {
      _layoutSourceId = null;
      _layoutLines = null;
      _layoutLoading = false;
      return;
    }
    final layoutKey = '$sourceId#${widget.chords.hashCode}';
    if (_layoutSourceId == layoutKey && _layoutLines != null) return;
    if (!_layoutCache.containsKey(layoutKey)) {
      final path = widget.pdfPath!;
      final request = PdfDocumentRequest.parse(path);
      if (_layoutCache.length >= _layoutCacheLimit) {
        _layoutCache.remove(_layoutCache.keys.first);
      }
      _layoutCache[layoutKey] = PdfNoteService().loadChordedLines(
        pdfPath: request.assetPath,
        startPage: request.startPage,
        pageCount: request.pageCount,
        chords: widget.chords,
      );
    }
    _layoutSourceId = layoutKey;
    _layoutLoading = true;
    _layoutLines = null;
    _layoutCache[layoutKey]!.then((lines) {
      if (!mounted || _layoutSourceId != layoutKey) return;
      setState(() {
        _layoutLines = lines;
        _layoutLoading = false;
      });
    });
  }

  TextAlign _resolveTextAlign() {
    switch (widget.textAlign) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  /// Renders the current verse as lyric lines.  When chord display is
  /// enabled and chord data exists, each line gets a chord row above it
  /// (like gyschordweb's lyrics view) using the transposed chord labels.
  ///
  /// Chord placement uses the note-aligned layout derived from the PDF text
  /// layer (see [PdfNoteService.loadChordedLines]): a chord sits above the
  /// syllable its note belongs to.  While that layout is still loading the
  /// lyrics render plain; if the layout is unavailable the proportional
  /// fallback distributes the chords evenly.
  List<Widget> _buildVerseLines(
    BuildContext context,
    String verseText,
    int verseIndex,
    int totalVerses,
  ) {
    final theme = Theme.of(context);
    // Preserve blank lines (stanza breaks) so chord mode doesn't collapse
    // the verse structure; blank lines simply get no chord row.
    final lines = verseText.split('\n');
    var nonEmpty = lines.where((line) => line.trim().isNotEmpty).toList();
    if (nonEmpty.isEmpty) {
      lines
        ..clear()
        ..add(verseText);
      nonEmpty = [verseText];
    }

    final lyricsStyle = theme.textTheme.bodyLarge?.copyWith(
      fontFamily: widget.fontFamily,
      fontSize: 16 * widget.textScale,
      height: widget.textHeight,
      fontWeight: widget.fontBold ? FontWeight.w700 : FontWeight.w400,
    );

    if (!widget.showChords || widget.chords.isEmpty) {
      return [
        Text(verseText, textAlign: _resolveTextAlign(), style: lyricsStyle),
      ];
    }

    final textAlign = _resolveTextAlign();

    // NOTE-ALIGNED path: the PDF-derived layout is ready â†’ resolve each line
    // to its chorded line (text match, then per-line-index fallback).
    final layoutLines = _layoutLines;
    if (layoutLines != null && layoutLines.isNotEmpty) {
      // GYSChordWeb reuses the first successfully matched melody line for
      // the same line index across every verse. Build this fallback from all
      // verses so later stanzas receive the same accurate chord map.
      final byIndexFallback = buildVerseChordFallback(
        widget.song.verses,
        layoutLines,
      );
      final result = <Widget>[];
      var nonEmptyCursor = 0;
      for (var i = 0; i < lines.length; i++) {
        if (lines[i].trim().isEmpty) {
          result.add(Text(lines[i], textAlign: textAlign, style: lyricsStyle));
          continue;
        }
        final lineIndex = nonEmptyCursor++;
        final chorded = resolveChordedLineForVerseLine(
          lines[i],
          lineIndex,
          layoutLines,
          byIndexFallback,
        );
        if (chorded == null || chorded.chords.isEmpty) {
          result.add(Text(lines[i], textAlign: textAlign, style: lyricsStyle));
          continue;
        }
        result.add(
          _NoteAlignedChordLine(
            text: lines[i],
            placements: chorded.chords,
            lyricsStyle: lyricsStyle,
            textAlign: textAlign,
            transposeStep: widget.transposeStep,
            baseTransposeOffset: widget.baseTransposeOffset,
            chordAccidentalMode: widget.chordAccidentalMode,
            textScale: widget.textScale,
          ),
        );
      }
      return result;
    }

    // PROPORTIONAL fallback: the layout is still loading (render plain lines
    // so chords appear without flicker once ready) or could not be built.
    if (_layoutLoading) {
      return [Text(verseText, textAlign: textAlign, style: lyricsStyle)];
    }

    final verseChords = chordsForVerse(
      widget.chords.values.expand((c) => c).toList(),
      verseIndex,
      totalVerses,
    );
    // Distribute across the non-empty lines only, so blank stanza breaks
    // don't consume chord slots; map back onto the full line order below.
    final chordsByNonEmptyLine = distributeChordsToLines(
      verseChords,
      nonEmpty.length,
    );
    var nonEmptyCursor = 0;

    final result = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      final lineChords = lines[i].trim().isEmpty
          ? const <ChordData>[]
          : chordsByNonEmptyLine[nonEmptyCursor++];
      if (lineChords.isNotEmpty) {
        result.add(
          _ChordSheetLine(
            chords: lineChords,
            transposeStep: widget.transposeStep,
            baseTransposeOffset: widget.baseTransposeOffset,
            chordAccidentalMode: widget.chordAccidentalMode,
            textScale: widget.textScale,
          ),
        );
      }
      result.add(Text(lines[i], textAlign: textAlign, style: lyricsStyle));
    }
    return result;
  }

  MainAxisAlignment _resolveVerticalAlign() {
    switch (widget.verticalAlign) {
      case 'center':
        return MainAxisAlignment.center;
      case 'bottom':
        return MainAxisAlignment.end;
      default:
        return MainAxisAlignment.start;
    }
  }

  // Verse navigation by swipe must be unmistakable: it takes a fast flick
  // (>=450px/s) covering >=80px within 400ms. Plain scrolling of the verse
  // text — even a fling — never advances a verse on its own. Horizontal
  // swipes are intentionally NOT handled here: the song PageView owns
  // left/right for previous/next hymn.
  static const double _verseSwipeMinVelocity = 450;
  static const double _verseSwipeMinDistance = 80;
  static const Duration _verseSwipeMaxElapsed = Duration(milliseconds: 400);

  DateTime _verseDragStartTime = DateTime.now();
  Offset _verseDragAccumulated = Offset.zero;

  void _onVerseDragStart(DragStartDetails details) {
    _verseDragStartTime = DateTime.now();
    _verseDragAccumulated = Offset.zero;
    _pinchSeenSinceDragStart = false;
  }

  void _onVerseDragUpdate(DragUpdateDetails details) {
    _verseDragAccumulated += details.delta;
  }

  void _onVerseDragEnd(DragEndDetails details) {
    // Zoom has priority over navigation: a drag that coincided with a pinch
    // (two pointers at any point) must never advance a verse.
    if (_pinchActive || _pinchSeenSinceDragStart) return;
    final velocity = details.primaryVelocity ?? 0;
    final distance = _verseDragAccumulated.dy;
    final elapsed = DateTime.now().difference(_verseDragStartTime);
    if (distance.abs() < _verseSwipeMinDistance ||
        velocity.abs() < _verseSwipeMinVelocity ||
        elapsed > _verseSwipeMaxElapsed) {
      return;
    }
    if (velocity < 0) {
      widget.onNextVerse?.call();
    } else {
      widget.onPreviousVerse?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final verses = widget.song.verses;
    final hasVerses = verses.isNotEmpty;
    final safeIndex = hasVerses
        ? widget.verseIndex.clamp(0, verses.length - 1)
        : 0;
    final currentVerse = hasVerses ? verses[safeIndex] : null;

    return Listener(
      // Raw pointer tracking powers pinch-to-zoom: when a second finger
      // lands, the gesture becomes zoom and every navigation is suppressed.
      onPointerDown: _onPinchPointerDown,
      onPointerMove: _onPinchPointerMove,
      onPointerUp: _onPinchPointerUp,
      onPointerCancel: _onPinchPointerUp,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _onVerseDragStart,
        onVerticalDragUpdate: _onVerseDragUpdate,
        onVerticalDragEnd: _onVerseDragEnd,
        child: SelectionArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 420;
                  final horizontalPadding = compact ? 14.0 : 20.0;
                  final cardMaxWidth = constraints.maxWidth > 980
                      ? _songTextMaxContentWidth
                      : constraints.maxWidth;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20,
                      horizontalPadding,
                      8,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 28)
                            .clamp(0, double.infinity)
                            .toDouble(),
                      ),
                      child: Column(
                        mainAxisAlignment: _resolveVerticalAlign(),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: cardMaxWidth,
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  compact ? 14 : 18,
                                  compact ? 12 : 14,
                                  compact ? 14 : 18,
                                  compact ? 14 : 18,
                                ),
                                child: hasVerses
                                    ? AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 260,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        alignment: Alignment.topCenter,
                                        child: FadeTransition(
                                          opacity: _verseFadeAnim,
                                          child: SlideTransition(
                                            position: _verseSlideAnim,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                ..._buildVerseLines(
                                                  context,
                                                  currentVerse!,
                                                  safeIndex,
                                                  verses.length,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Teks lagu belum tersedia.',
                                        textAlign: _resolveTextAlign(),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (hasVerses && verses.length > 1)
              Container(
                padding: EdgeInsets.only(
                  bottom: 8,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: safeIndex > 0 ? widget.onPreviousVerse : null,
                      icon: const Icon(Icons.keyboard_arrow_up, size: 20),
                      label: Text('Atas'.tr()),
                    ),
                    Text(
                      'Bait ${safeIndex + 1} dari ${verses.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: safeIndex < verses.length - 1
                          ? widget.onNextVerse
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                      label: Text('Bawah'.tr()),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}

class _LyricsSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _LyricsSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: textTheme.bodyMedium)),
            Text(displayValue, style: textTheme.bodySmall),
          ],
        ),
        Slider(
          value: value.clamp(min, max).toDouble(),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _LyricsChoiceGroup extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onSelected;

  const _LyricsChoiceGroup({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: options.entries
              .map(
                (entry) => ChoiceChip(
                  label: Text(entry.value),
                  selected: value == entry.key,
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.65),
                  showCheckmark: false,
                  onSelected: (_) => onSelected(entry.key),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Dedicated AppBar button for the PDF viewing mode (single page,
/// two-page spread, vertical scroll).  Tapping it opens a dropdown
/// with three side-by-side mode buttons so the user can pick the
/// desired layout in one tap.  The currently-active mode is
/// highlighted on its button.
///
/// Uses [showGeneralDialog] with a fade + scale animation so the
/// dropdown has a smooth, polished open/close transition.
class _PageModeMenuButton extends StatefulWidget {
  const _PageModeMenuButton({
    required this.cubit,
    required this.pdfTwoPageMode,
    required this.pdfVerticalScrolling,
    required this.showChord,
    required this.chordToggleEnabled,
    required this.textMode,
    required this.showAudio,
    required this.pageCount,
    required this.onFitPage,
    required this.onShare,
    required this.onOpenLyrics,
    required this.onOpenChordSettings,
  });

  final SongCubit cubit;
  final bool pdfTwoPageMode;
  final bool pdfVerticalScrolling;
  final bool showChord;
  final bool chordToggleEnabled;
  final bool textMode;
  final bool showAudio;
  final int? pageCount;
  final VoidCallback onFitPage;
  final VoidCallback onShare;
  final VoidCallback onOpenLyrics;
  final VoidCallback onOpenChordSettings;

  @override
  State<_PageModeMenuButton> createState() => _PageModeMenuButtonState();
}

class _PageModeMenuButtonState extends State<_PageModeMenuButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.dashboard_rounded),
      tooltip: 'Mode halaman',
      onPressed: () => _openMenu(context),
    );
  }

  // ------------------------------------------------------------------
  // Open the menu with a fade + scale animation anchored to the button.
  // showGeneralDialog gives us full control over the transition curve,
  // duration, and alignment â€” something MenuAnchor cannot do.
  // ------------------------------------------------------------------

  void _openMenu(BuildContext btnContext) {
    final renderBox = btnContext.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(btnContext).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlayBox == null) return;

    final btnSize = renderBox.size;
    final btnPos = renderBox.localToGlobal(Offset.zero, ancestor: overlayBox);

    showGeneralDialog(
      context: btnContext,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogCtx, _, _) {
        // Wrap in BlocBuilder so the menu body rebuilds when the
        // cubit state changes (toggle MIDI, Teks, Chord, etc.)
        // without needing to close and reopen the dialog.
        return BlocBuilder<SongCubit, SongState>(
          buildWhen: (prev, curr) =>
              prev.showChord != curr.showChord ||
              prev.showAudio != curr.showAudio ||
              prev.isImageMode != curr.isImageMode ||
              prev.pdfTwoPageMode != curr.pdfTwoPageMode ||
              prev.pdfVerticalScrolling != curr.pdfVerticalScrolling ||
              prev.bookCode != curr.bookCode,
          builder: (context, state) {
            return _buildMenuBody(
              context,
              state: state,
              onClose: () => Navigator.pop(dialogCtx),
            );
          },
        );
      },
      transitionBuilder: (dialogCtx, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return Stack(
          children: [
            Positioned(
              top: btnPos.dy + btnSize.height + 4,
              right: overlayBox.size.width - btnPos.dx - btnSize.width,
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
                  alignment: Alignment.topRight,
                  child: child,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // Menu body â€” identical layout to the old MenuAnchor version but
  // every button calls Navigator.pop(dialogContext) via [onClose] to
  // dismiss the dialog before running its action.
  // ------------------------------------------------------------------

  Widget _buildMenuBody(
    BuildContext context, {
    required SongState state,
    required VoidCallback onClose,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isTwoPage = state.pdfTwoPageMode;
    final isVertical = state.pdfVerticalScrolling;
    final isSinglePage = widget.pageCount != null && widget.pageCount! <= 1;
    final showChord = state.showChord;
    final chordEnabled = state.bookCode != 'HYMNE';
    final isText = state.isImageMode;
    final showAudio = state.showAudio;

    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: context.appRadius(16),
      child: Container(
        width: 232,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: context.appRadius(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1 â€” page layout mode.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ModeButton(
                  icon: Icons.looks_one_rounded,
                  label: '1',
                  tooltip: 'Satu halaman',
                  selected: !isTwoPage && !isVertical,
                  onTap: () {
                    onClose();
                    widget.cubit.setNormalPdfMode();
                  },
                ),
                _ModeButton(
                  icon: Icons.looks_two_rounded,
                  label: '2',
                  tooltip: isSinglePage
                      ? 'Hanya 1 halaman'
                      : 'Dua halaman (putar landscape)',
                  selected: isTwoPage,
                  disabled: isSinglePage,
                  onTap: isSinglePage
                      ? null
                      : () {
                          onClose();
                          widget.cubit.setPdfTwoPageMode(!isTwoPage);
                        },
                ),
                _ModeButton(
                  icon: Icons.swap_vert_rounded,
                  label: 'Vert',
                  tooltip: isSinglePage ? 'Hanya 1 halaman' : 'Scroll vertikal',
                  selected: isVertical,
                  disabled: isSinglePage,
                  onTap: isSinglePage
                      ? null
                      : () {
                          onClose();
                          widget.cubit.setPdfVerticalScrolling(!isVertical);
                        },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 6),
            // Row 2 â€” toggle & action buttons.  Toggle buttons
            // (Chord, MIDI, Teks) do NOT close the dialog so the
            // user can tap them repeatedly without re-opening.
            // One-shot actions (Fit, Share, Lirik) close it.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ModeButton(
                  icon: showChord
                      ? Icons.music_note_rounded
                      : Icons.music_off_rounded,
                  label: 'Chord',
                  tooltip: showChord ? 'Sembunyikan chord' : 'Tampilkan chord',
                  selected: showChord,
                  disabled: !chordEnabled,
                  onTap: chordEnabled ? () => widget.cubit.toggleChord() : null,
                ),
                _ModeButton(
                  icon: Icons.fit_screen_rounded,
                  label: 'Fit',
                  tooltip: 'Fit halaman',
                  selected: false,
                  disabled: isText,
                  onTap: isText
                      ? null
                      : () {
                          onClose();
                          widget.onFitPage();
                        },
                ),
                _ModeButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  tooltip: 'Bagikan',
                  selected: false,
                  onTap: () {
                    onClose();
                    widget.onShare();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 6),
            // Row 3 â€” UI toggles (MIDI, Teks stay open; Lirik closes).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ModeButton(
                  icon: showAudio
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  label: 'MIDI',
                  tooltip: showAudio ? 'Sembunyikan MIDI' : 'Tampilkan MIDI',
                  selected: showAudio,
                  onTap: () => widget.cubit.toggleAudio(),
                ),
                _ModeButton(
                  icon: isText
                      ? Icons.picture_as_pdf_rounded
                      : Icons.article_outlined,
                  label: 'Teks',
                  tooltip: isText ? 'Mode PDF' : 'Mode teks',
                  selected: isText,
                  onTap: () => widget.cubit.changeMode(),
                ),
                _ModeButton(
                  icon: Icons.lyrics_rounded,
                  label: 'Lirik',
                  tooltip: 'Pengaturan mode teks',
                  selected: false,
                  disabled: !isText,
                  onTap: isText
                      ? () {
                          onClose();
                          widget.onOpenLyrics();
                        }
                      : null,
                ),
              ],
            ),
            if (chordEnabled) ...[
              const SizedBox(height: 6),
              Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 6),
              // Row 4 â€” chord overlay settings (only for chord-enabled books).
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ModeButton(
                    icon: Icons.tune_rounded,
                    label: 'Chord',
                    tooltip: 'chord_settings_title'.tr(),
                    selected: false,
                    onTap: () {
                      onClose();
                      widget.onOpenChordSettings();
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One of the side-by-side buttons inside the page-mode dropdown.
/// The selected mode is highlighted with the primary container
/// colour; inactive modes have an outline-only tile.  When
/// [disabled] is true the button is greyed out and does not respond
/// to taps (used for actions that are not available in the current
/// state, e.g. "Fit" in text mode or "Chord" for the HYMNE book).
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isInactive = disabled;
    final fg = isInactive
        ? colors.onSurfaceVariant.withValues(alpha: 0.3)
        : (selected ? colors.onPrimaryContainer : colors.onSurfaceVariant);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: isInactive ? null : onTap,
        borderRadius: context.appRadius(10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isInactive
                ? Colors.transparent
                : (selected
                      ? colors.primaryContainer
                      : colors.surfaceContainerLowest.withValues(alpha: 0.4)),
            borderRadius: context.appRadius(10),
            border: Border.all(
              color: isInactive
                  ? colors.outlineVariant.withValues(alpha: 0.2)
                  : (selected
                        ? colors.primary
                        : colors.outlineVariant.withValues(alpha: 0.6)),
              width: selected ? 1.5 : 0.6,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fg, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: context.appFontSize(11),
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One lyric line with its chord names rendered above the text, aligned by
/// proportional slots â€” the text-mode equivalent of gyschordweb's
/// note-aligned chord overlay.
class _ChordSheetLine extends StatelessWidget {
  final List<ChordData> chords;
  final int transposeStep;
  final int baseTransposeOffset;
  final String chordAccidentalMode;
  final double textScale;

  const _ChordSheetLine({
    required this.chords,
    required this.transposeStep,
    required this.baseTransposeOffset,
    required this.chordAccidentalMode,
    required this.textScale,
  });

  double _measure(String value, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chordFontSize = (12 * textScale).clamp(9.0, 20.0);
    final chordHeight = chordFontSize + 6;

    final placements = fallbackPlacementsForLine(chords)
        .map(
          (placement) => (
            label: ChordService.transposeChord(
              placement.chord,
              transposeStep,
              baseTransposeOffset: baseTransposeOffset,
              accidentalMode: chordAccidentalMode,
            ),
            position: placement.safePosition,
          ),
        )
        .toList();
    final chordStyle = TextStyle(
      fontFamily: DesignSystem.fontHeading,
      fontSize: chordFontSize,
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onPrimaryContainer,
    );

    return SizedBox(
      height: chordHeight + 4,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          var previousRight = double.negativeInfinity;
          final resolvedLefts = <double>[];
          for (final placement in placements) {
            final labelWidth = _measure(placement.label, chordStyle) + 8;
            var left = placement.position * width - (labelWidth / 2);
            left = left
                .clamp(0.0, (width - labelWidth).clamp(0.0, width))
                .toDouble();
            if (left < previousRight + 4) {
              left = (previousRight + 4)
                  .clamp(0.0, (width - labelWidth).clamp(0.0, width))
                  .toDouble();
            }
            previousRight = left + labelWidth;
            resolvedLefts.add(left);
          }
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < placements.length; i++)
                Positioned(
                  left: resolvedLefts[i],
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      placements[i].label,
                      style: chordStyle,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// One lyric line with its chords rendered above the text at the *note*
/// positions derived from the PDF layout (gyschordweb-style placement):
/// `left = position * lineWidth` where the lineWidth is the measured width
/// of the rendered lyric text.  Chords that would overlap are nudged to the
/// right, mirroring gyschordweb's `fixLyricsChordCollisions`.
class _NoteAlignedChordLine extends StatelessWidget {
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
                    final isLastRow = identical(row, rows.last);
                    final rowWidth = _measure(
                      row.text,
                      lyricsStyle,
                    ).clamp(1.0, maxWidth);
                    final rowChords = labels
                        .where(
                          (placement) =>
                              placement.characterOffset >= row.start &&
                              (placement.characterOffset < row.end ||
                                  (isLastRow &&
                                      placement.characterOffset == row.end)),
                        )
                        .map((placement) {
                          final localEnd =
                              (placement.characterOffset - row.start).clamp(
                                0,
                                row.text.length,
                              );
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
