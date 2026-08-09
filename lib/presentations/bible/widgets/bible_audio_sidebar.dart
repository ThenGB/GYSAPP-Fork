import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:edge_tts/edge_tts.dart' as edge;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../components/components.dart';
import '../../../data/services/bible_tts_service.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../../domain/entity/verse/verse.dart';
import '../../../router/router.dart';
import '../cubit/bible_cubit.dart';

/// Floating, draggable audio-playback sidebar for the Bible reader.
///
/// Opened from the "Audio" action in the reader's more-menu.  Like the MIDI
/// player it has two states:
///
///  * **collapsed** — a compact mini pill with now-playing title,
///    play/pause and a maximize button;
///  * **maximized** — the full details & settings panel: now-playing info,
///    transport controls, the playback RANGE ("Mulai dari" book/chapter/
///    verse and "Sampai" end target or "lanjut terus"), voice picker and the
///    TTS settings shortcut.
///
/// The playback range is the single control for the old auto-next-chapter
/// toggle: "Lanjut terus" means the reading continues automatically through
/// the following chapters/books, while a specific end verse stops playback
/// exactly there.
class BibleAudioSidebar extends StatefulWidget {
  const BibleAudioSidebar({super.key});

  @override
  State<BibleAudioSidebar> createState() => _BibleAudioSidebarState();
}

class _BibleAudioSidebarState extends State<BibleAudioSidebar> {
  /// Wide layouts (>= [kWideWidth]) dock the panel on the right edge.
  static const double kWideWidth = 720;
  static const double _panelMaxWidth = 340;

  final GlobalKey _panelKey = GlobalKey();
  Offset _drag = Offset.zero;
  Size _panelSize = Size.zero;
  bool _expanded = false;

  List<edge.Voice> _edgeVoices = const [];
  bool _voicesLoading = true;

  /// Cached verse counts per (book, chapter) for the range pickers.
  final Map<String, int> _verseCountCache = {};

  // Memoized now-playing title: only re-queried when the verse changes,
  // not on every play/pause state rebuild.
  Verse? _titleVerse;
  Future<String?>? _titleFuture;

  Future<String?> _titleFor(Verse? verse) {
    if (verse == null) return Future.value(null);
    if (!identical(_titleVerse, verse)) {
      _titleVerse = verse;
      _titleFuture = context
          .read<BibleCubit>()
          .getBibleTitle([verse], withVerse: true);
    }
    return _titleFuture!;
  }

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    try {
      final voices = await BibleTtsService.fetchEdgeVoices();
      if (!mounted) return;
      setState(() {
        _edgeVoices = voices;
        _voicesLoading = false;
      });
    } catch (e) {
      log('Audio sidebar voice fetch failed: $e', name: 'AudioSidebar');
      if (!mounted) return;
      setState(() => _voicesLoading = false);
    }
  }

  void _measurePanel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = _panelKey.currentContext?.size;
      if (size != null && size != _panelSize) {
        setState(() => _panelSize = size);
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details, Size area) {
    if (_panelSize.isEmpty) return;
    final isWide = area.width >= kWideWidth;
    final margin = 16.0;
    double minDx;
    double maxDx;
    double minDy;
    double maxDy;
    if (isWide) {
      // Anchored right-center: drag left/up/down keeps it inside the area.
      minDx = -(area.width - _panelSize.width - margin);
      maxDx = 0;
      minDy = -(area.height - _panelSize.height) / 2;
      maxDy = (area.height - _panelSize.height) / 2;
    } else {
      // Anchored bottom-center: drag right/left/up keeps it inside.
      minDx = -(area.width - _panelSize.width) / 2;
      maxDx = (area.width - _panelSize.width) / 2;
      minDy = -(area.height - _panelSize.height - margin);
      maxDy = 0;
    }
    setState(() {
      _drag = Offset(
        (_drag.dx + details.delta.dx).clamp(minDx, maxDx),
        (_drag.dy + details.delta.dy).clamp(minDy, maxDy),
      );
    });
  }

  /// Verse count for the (book, chapter) — cached, used by the range
  /// pickers' verse dropdown.
  Future<int> _verseCountFor(BibleCubit cubit, int bookId, int chapterId) {
    final key = '$bookId#$chapterId';
    final cached = _verseCountCache[key];
    if (cached != null) return Future.value(cached);
    return cubit.getVersesByBook(bookId, chapterId).then((verses) {
      _verseCountCache[key] = verses.length;
      return verses.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        final isWide = area.width >= kWideWidth;
        return Align(
          alignment: isWide
              ? const Alignment(1.0, 0.0)
              : const Alignment(0, 1.0),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanUpdate: _expanded
                ? null // expanded panel drags via its header handle
                : (details) => _onPanUpdate(details, area),
            child: Transform.translate(
              offset: _drag,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _panelMaxWidth),
                child: BlocBuilder<BibleCubit, BibleState>(
                  buildWhen: (prev, curr) =>
                      prev.isSpeaking != curr.isSpeaking ||
                      prev.isTtsPaused != curr.isTtsPaused ||
                      prev.currentBible != curr.currentBible ||
                      prev.autoNextChapter != curr.autoNextChapter ||
                      prev.ttsPlayRangeStart != curr.ttsPlayRangeStart ||
                      prev.ttsPlayRangeEnd != curr.ttsPlayRangeEnd ||
                      prev.books != curr.books ||
                      prev.edgeVoice != curr.edgeVoice ||
                      prev.ttsEngine != curr.ttsEngine ||
                      prev.enableAudio != curr.enableAudio,
                  builder: (context, state) {
                    _measurePanel();
                    if (_expanded) {
                      return _SidebarPanel(
                        key: _panelKey,
                        state: state,
                        titleFuture: _titleFor(state.currentBible),
                        voices: _edgeVoices,
                        voicesLoading: _voicesLoading,
                        isWide: isWide,
                        onPlayPause: () => _onPlayPause(state),
                        onStop: () =>
                            context.read<BibleCubit>().stopSpeaking(),
                        onClose: () =>
                            context.read<BibleCubit>().setAudioPanelOpen(false),
                        onMinimize: () => setState(() => _expanded = false),
                        onDragUpdate: (details) => _onPanUpdate(details, area),
                        onStartChanged: (verse) => context
                            .read<BibleCubit>()
                            .setTtsPlayRangeStart(verse),
                        onEndChanged: (verse) => context
                            .read<BibleCubit>()
                            .setTtsPlayRangeEnd(verse),
                        onChapterEnd: () => context
                            .read<BibleCubit>()
                            .setPlayRangeToChapterEnd(),
                        onContinueOn: () => context
                            .read<BibleCubit>()
                            .setPlayRangeContinueOn(),
                        verseCountFor: _verseCountFor,
                        onVoiceChanged: (voice) =>
                            context.read<BibleCubit>().setEdgeVoice(voice),
                        onOpenSettings: () => _openSettings(context, state),
                      );
                    }
                    return _MiniPill(
                      key: _panelKey,
                      state: state,
                      titleFuture: _titleFor(state.currentBible),
                      onPlayPause: () => _onPlayPause(state),
                      onClose: () =>
                          context.read<BibleCubit>().setAudioPanelOpen(false),
                      onMaximize: () => setState(() => _expanded = true),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onPlayPause(BibleState state) {
    final cubit = context.read<BibleCubit>();
    if (!state.isSpeaking) {
      cubit.playBibleRange();
      return;
    }
    cubit.togglePauseTts();
  }

  void _openSettings(BuildContext context, BibleState state) {
    final cubit = context.read<BibleCubit>();
    router.push(
      BibleAudioSettingRoute(
        initialState: state,
        onSave: (s) {
          cubit.applyTtsSetting(s.voices, s.pitchRate, s.speedRate);
          cubit.setTtsEngine(s.ttsEngine);
          cubit.setAutoNextChapter(s.autoNextChapter);
          cubit.setEdgeVoice(s.edgeVoice);
          cubit.setEdgeRate(s.edgeRate);
          cubit.setEdgePitch(s.edgePitch);
          cubit.setEdgeVolume(s.edgeVolume);
          cubit.initTts();
        },
      ),
    );
  }
}

/// Compact collapsed pill: play/pause, now-playing title, maximize and
/// close.  The whole pill is draggable.
class _MiniPill extends StatelessWidget {
  final BibleState state;
  final Future<String?>? titleFuture;
  final VoidCallback onPlayPause;
  final VoidCallback onClose;
  final VoidCallback onMaximize;

  const _MiniPill({
    super.key,
    required this.state,
    required this.titleFuture,
    required this.onPlayPause,
    required this.onClose,
    required this.onMaximize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      elevation: 10,
      shadowColor: colors.shadow.withValues(alpha: 0.35),
      borderRadius: context.appRadius(999),
      clipBehavior: Clip.antiAlias,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: context.appRadius(999),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: colors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPlayPause,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    state.isSpeaking
                        ? (state.isTtsPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded)
                        : Icons.play_arrow_rounded,
                    size: 22,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: FutureBuilder<String?>(
                future: titleFuture,
                builder: (context, snapshot) => Text(
                  snapshot.data ?? 'bible_playback_title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'bible_playback_expand'.tr(),
              onPressed: onMaximize,
              icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarPanel extends StatelessWidget {
  final BibleState state;
  final Future<String?>? titleFuture;
  final List<edge.Voice> voices;
  final bool voicesLoading;
  final bool isWide;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final DragUpdateCallback onDragUpdate;
  final ValueChanged<Verse> onStartChanged;
  final ValueChanged<Verse?> onEndChanged;
  final VoidCallback onChapterEnd;
  final VoidCallback onContinueOn;
  final Future<int> Function(BibleCubit cubit, int bookId, int chapterId)
  verseCountFor;
  final ValueChanged<String> onVoiceChanged;
  final VoidCallback onOpenSettings;

  const _SidebarPanel({
    super.key,
    required this.state,
    required this.titleFuture,
    required this.voices,
    required this.voicesLoading,
    required this.isWide,
    required this.onPlayPause,
    required this.onStop,
    required this.onClose,
    required this.onMinimize,
    required this.onDragUpdate,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.onChapterEnd,
    required this.onContinueOn,
    required this.verseCountFor,
    required this.onVoiceChanged,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      elevation: 12,
      shadowColor: colors.shadow.withValues(alpha: 0.35),
      borderRadius: context.appRadius(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        decoration: BoxDecoration(
          borderRadius: context.appRadius(20),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Drag handle + title + actions ────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: onDragUpdate,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.drag_indicator_rounded,
                          size: 20,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.volume_up_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'bible_playback_title'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'bible_playback_collapse'.tr(),
                      onPressed: onMinimize,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Close',
                      onPressed: onClose,
                      icon: const Icon(Icons.close_rounded, size: 20),
                    ),
                  ],
                ),

                // ── Now playing ─────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: context.appRadius(12),
                    color: colors.primaryContainer.withValues(alpha: 0.35),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: kThemeAnimationDuration,
                        child: state.isSpeaking
                            ? Icon(
                                state.isTtsPaused
                                    ? Icons.pause_rounded
                                    : Icons.graphic_eq_rounded,
                                key: ValueKey(
                                  'eq-${state.isTtsPaused}-${state.isSpeaking}',
                                ),
                                color: colors.primary,
                                size: 20,
                              )
                            : Icon(
                                Icons.headphones_outlined,
                                key: const ValueKey('idle'),
                                color: colors.onSurfaceVariant,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.isSpeaking
                                  ? 'bible_now_playing'.tr()
                                  : 'bible_playback_title'.tr(),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FutureBuilder<String?>(
                              future: titleFuture,
                              builder: (context, snapshot) => Text(
                                snapshot.data ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Transport controls ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      tooltip: 'bible_stop'.tr(),
                      onPressed: state.isSpeaking ? onStop : null,
                      icon: Icon(
                        Icons.stop_rounded,
                        color: state.isSpeaking
                            ? colors.error
                            : colors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Material(
                        color: colors.primary,
                        shape: const CircleBorder(),
                        elevation: 4,
                        shadowColor: colors.primary.withValues(alpha: 0.4),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: onPlayPause,
                          child: Icon(
                            state.isSpeaking
                                ? (state.isTtsPaused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded)
                                : Icons.play_arrow_rounded,
                            size: 34,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Drag'.tr(),
                      onPressed: null,
                      icon: Icon(
                        Icons.drag_indicator_rounded,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Playback range (Mulai dari → Sampai) ────────────────
                _buildRangeSection(context),

                // ── Voice picker ─────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      Icons.record_voice_over_outlined,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _buildVoiceDropdown(context)),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Settings shortcut ────────────────────────────────────
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: context.appRadius(12),
                    ),
                  ),
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text('audio_settings_shortcut'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRangeSection(BuildContext context) {
    final colors = context.colorScheme;
    final cubit = context.read<BibleCubit>();
    final start = state.ttsPlayRangeStart ?? state.currentBible;
    final hasEnd = state.ttsPlayRangeEnd != null;
    final isContinueOn = !hasEnd && state.autoNextChapter;
    final isChapterEnd = !hasEnd && !state.autoNextChapter;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: context.appRadius(12),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Text(
                'bible_range_title'.tr(),
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Mulai dari — book / chapter / verse
          Text(
            'bible_range_start'.tr(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          if (start != null)
            _RangePointPicker(
              state: state,
              value: start,
              verseCountFor: verseCountFor,
              onChanged: onStartChanged,
            )
          else
            Text(
              'bible_range_tap_hint'.tr(),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'bible_range_tap_hint'.tr(),
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),

          // Sampai — "akhir pasal" (default) / "lanjut terus" / specific verse
          Text(
            'bible_range_end'.tr(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: Text('bible_range_chapter_end'.tr()),
                tooltip: 'bible_range_chapter_end_desc'.tr(),
                selected: isChapterEnd,
                showCheckmark: false,
                selectedColor: colors.primaryContainer,
                onSelected: (_) => onChapterEnd(),
              ),
              ChoiceChip(
                label: Text('bible_range_continue'.tr()),
                tooltip: 'bible_range_continue_desc'.tr(),
                selected: isContinueOn,
                showCheckmark: false,
                selectedColor: colors.primaryContainer,
                onSelected: (_) => onContinueOn(),
              ),
              ChoiceChip(
                label: Text('bible_range_to_verse'.tr()),
                selected: hasEnd,
                showCheckmark: false,
                selectedColor: colors.primaryContainer,
                onSelected: (_) {
                  // Default the end target to the start position; the user
                  // can then adjust book/chapter/verse below.
                  final base = state.ttsPlayRangeStart ?? state.currentBible;
                  if (base != null) onEndChanged(base);
                },
              ),
            ],
          ),
          if (hasEnd && state.ttsPlayRangeEnd != null) ...[
            const SizedBox(height: 8),
            _RangePointPicker(
              state: state,
              value: state.ttsPlayRangeEnd!,
              verseCountFor: verseCountFor,
              onChanged: onEndChanged,
            ),
          ],
          const SizedBox(height: 8),

          // Range summary: "Dari X sampai akhir pasal" / "Dari X, lanjut
          // terus" / "Dari X sampai Y".
          _RangeSummary(
            start: state.ttsPlayRangeStart ?? state.currentBible,
            end: state.ttsPlayRangeEnd,
            continueOn: isContinueOn,
            getTitle: (v) => cubit.getBibleTitle([v], withVerse: true),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceDropdown(BuildContext context) {
    final colors = context.colorScheme;
    if (voicesLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
        ),
      );
    }
    final langPrefix = state.currentBibleLanguage.split('-').first;
    final matching = voices
        .where((v) => v.locale.startsWith('$langPrefix-'))
        .toList();
    final pool = matching.isNotEmpty ? matching : voices;
    if (pool.isEmpty) {
      return Text(
        'bible_edge_voices_offline'.tr(),
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }
    final selected = pool.firstWhereOrNull(
          (v) => v.shortName == state.edgeVoice,
        ) ??
        pool.first;
    return DropdownButton<edge.Voice>(
      isExpanded: true,
      value: selected,
      underline: Container(
        height: 1,
        color: colors.outlineVariant.withValues(alpha: 0.6),
      ),
      borderRadius: BorderRadius.circular(12),
      items: [
        for (final v in pool)
          DropdownMenuItem(value: v, child: Text(v.shortName)),
      ],
      onChanged: (v) {
        if (v != null) onVoiceChanged(v.shortName);
      },
    );
  }
}

/// Book + chapter + verse dropdowns for one endpoint of the playback range.
/// Changing any part immediately reports the new [Verse] through
/// [onChanged].
class _RangePointPicker extends StatelessWidget {
  final BibleState state;
  final Verse value;
  final Future<int> Function(BibleCubit cubit, int bookId, int chapterId)
  verseCountFor;
  final ValueChanged<Verse> onChanged;

  const _RangePointPicker({
    required this.state,
    required this.value,
    required this.verseCountFor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final cubit = context.read<BibleCubit>();
    final books = state.books;
    final book = books.firstWhereOrNull((b) => b.id == value.bookId) ??
        books.firstOrNull;
    if (book == null) {
      return Text(
        'bible_range_tap_hint'.tr(),
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }
    final chapterCount = book.chapterCount ?? value.chapterId;
    final chapter = value.chapterId.clamp(1, chapterCount);

    Verse makeVerse(int b, int c, int v) => Verse(
      id: b * 1000000 + c * 1000 + v,
      bookId: b,
      chapterId: c,
      verseId: v,
    );

    final itemStyle = context.textTheme.bodySmall?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w600,
    );

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<int>(
            initialValue: book.id,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'bible_book'.tr(),
              labelStyle: context.textTheme.labelSmall,
              border: OutlineInputBorder(
                borderRadius: context.appRadius(8),
              ),
            ),
            items: [
              for (final b in books)
                DropdownMenuItem(
                  value: b.id,
                  child: Text(
                    b.shortName ?? 'B${b.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: itemStyle,
                  ),
                ),
            ],
            onChanged: (bookId) {
              if (bookId == null) return;
              onChanged(makeVerse(bookId, 1, 1));
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<int>(
            initialValue: chapter,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'bible_chapter'.tr(),
              labelStyle: context.textTheme.labelSmall,
              border: OutlineInputBorder(
                borderRadius: context.appRadius(8),
              ),
            ),
            items: [
              for (var c = 1; c <= chapterCount; c++)
                DropdownMenuItem(
                  value: c,
                  child: Text('$c', style: itemStyle),
                ),
            ],
            onChanged: (chapterId) {
              if (chapterId == null) return;
              onChanged(makeVerse(book.id, chapterId, 1));
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 2,
          child: FutureBuilder<int>(
            future: verseCountFor(cubit, book.id, chapter),
            builder: (context, snapshot) {
              final verseCount = snapshot.data ?? value.verseId;
              final verse = value.verseId.clamp(1, verseCount);
              return DropdownButtonFormField<int>(
                initialValue: verse,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'bible_verse'.tr(),
                  labelStyle: context.textTheme.labelSmall,
                  border: OutlineInputBorder(
                    borderRadius: context.appRadius(8),
                  ),
                ),
                items: [
                  for (var v = 1; v <= verseCount; v++)
                    DropdownMenuItem(
                      value: v,
                      child: Text('$v', style: itemStyle),
                    ),
                ],
                onChanged: (verseId) {
                  if (verseId == null) return;
                  onChanged(makeVerse(book.id, chapter, verseId));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// "Dari {start} sampai akhir pasal" / "Dari {start}, lanjut terus" /
/// "Dari {start} sampai {end}" summary line with the localized
/// book/chapter/verse titles.
class _RangeSummary extends StatelessWidget {
  final Verse? start;
  final Verse? end;

  /// True when the range mode is "lanjut terus" (continues through the
  /// following chapters/books).
  final bool continueOn;
  final Future<String> Function(Verse verse) getTitle;

  const _RangeSummary({
    required this.start,
    required this.end,
    required this.continueOn,
    required this.getTitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    if (start == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: context.appRadius(8),
        color: colors.surfaceContainerLow.withValues(alpha: 0.7),
      ),
      child: FutureBuilder<String>(
        future: getTitle(start!),
        builder: (context, startSnapshot) {
          final startTitle = startSnapshot.data ?? '';
          final String summary;
          if (end != null) {
            summary = 'bible_range_summary'; // "Dari {start} sampai {end}"
          } else if (continueOn) {
            summary = 'bible_range_continuous_summary'; // "Dari {start}, lanjut terus"
          } else {
            summary = 'bible_range_chapter_end_summary'; // "Dari {start} sampai akhir pasal"
          }
          if (end == null) {
            return Row(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: colors.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    summary.tr(namedArgs: {'start': startTitle}),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            );
          }
          return FutureBuilder<String>(
            future: getTitle(end!),
            builder: (context, endSnapshot) {
              final endTitle = endSnapshot.data ?? '';
              return Row(
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      summary.tr(
                        namedArgs: {'start': startTitle, 'end': endTitle},
                      ),
                      style: context.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
