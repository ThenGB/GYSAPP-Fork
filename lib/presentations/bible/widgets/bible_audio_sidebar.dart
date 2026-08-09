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

const Duration kBibleAudioExpandDuration = Duration(milliseconds: 260);
const Duration kBibleAudioSnapDuration = Duration(milliseconds: 240);
const double kBibleAudioCollapsedWidth = 64;
const double kBibleAudioCollapsedHeight = 48;
const double kBibleAudioExpandedMaxWidth = 380;
const double kBibleAudioExpandedMaxHeight = 560;
const double kBibleAudioBottomReserve = 88;
const double kBibleAudioEdgePeek = 8;
const double kBibleAudioMargin = 12;

/// Floating Bible TTS controller.
///
/// The important layout rule is that the control is moved with [Positioned]
/// instead of painting it elsewhere with [Transform.translate]. This keeps the
/// visual bounds and Flutter hit-test bounds identical after a drag.
class BibleAudioSidebar extends StatefulWidget {
  const BibleAudioSidebar({super.key});

  @override
  State<BibleAudioSidebar> createState() => _BibleAudioSidebarState();
}

class _BibleAudioSidebarState extends State<BibleAudioSidebar>
    with TickerProviderStateMixin {
  final ValueNotifier<double> _sidebarX = ValueNotifier<double>(1);
  final ValueNotifier<double> _sidebarY = ValueNotifier<double>(0.38);

  late final AnimationController _expandController;
  late final AnimationController _snapController;
  late final AnimationController _pulseController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _snapAnimation;

  double _snapFromX = 1;
  double _snapToX = 1;
  bool _isDragging = false;
  bool _expanded = false;
  bool _showExpandedContent = false;

  List<edge.Voice> _edgeVoices = const [];
  bool _voicesLoading = true;
  final Map<String, int> _verseCountCache = {};

  Verse? _titleVerse;
  Future<String?>? _titleFuture;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: kBibleAudioExpandDuration,
    );
    _snapController = AnimationController(
      vsync: this,
      duration: kBibleAudioSnapDuration,
    )..addStatusListener(_onSnapStatus);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );
    _snapAnimation = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutBack,
    );
    _loadVoices();
  }

  @override
  void dispose() {
    _snapController
      ..removeStatusListener(_onSnapStatus)
      ..dispose();
    _expandController.dispose();
    _pulseController.dispose();
    _sidebarX.dispose();
    _sidebarY.dispose();
    super.dispose();
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

  Future<String?> _titleFor(Verse? verse) {
    if (verse == null) return Future<String?>.value(null);
    if (!identical(_titleVerse, verse)) {
      _titleVerse = verse;
      _titleFuture = context
          .read<BibleCubit>()
          .getBibleTitle([verse], withVerse: true);
    }
    return _titleFuture!;
  }

  Future<int> _verseCountFor(BibleCubit cubit, int bookId, int chapterId) {
    final key = '$bookId#$chapterId';
    final cached = _verseCountCache[key];
    if (cached != null) return Future<int>.value(cached);
    return cubit.getVersesByBook(bookId, chapterId).then((verses) {
      _verseCountCache[key] = verses.length;
      return verses.length;
    });
  }

  void _onSnapStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _sidebarX.value = _snapToX;
      _snapController.value = 0;
    }
  }

  double get _effectiveSidebarX {
    if (_snapController.isAnimating) {
      return _snapFromX +
          ((_snapToX - _snapFromX) * _snapAnimation.value);
    }
    return _sidebarX.value;
  }

  Offset _sidebarPosition(Size area, EdgeInsets padding) {
    final x = _effectiveSidebarX.clamp(0.0, 1.0);
    final usableHeight = (area.height -
            padding.top -
            padding.bottom -
            kBibleAudioBottomReserve -
            kBibleAudioCollapsedHeight -
            (kBibleAudioMargin * 2))
        .clamp(0.0, double.infinity);
    final top = padding.top +
        kBibleAudioMargin +
        (_sidebarY.value.clamp(0.0, 1.0) * usableHeight);

    if (x <= 0.001) {
      return Offset(
        -kBibleAudioCollapsedWidth / 2 + kBibleAudioEdgePeek,
        top,
      );
    }
    if (x >= 0.999) {
      return Offset(
        area.width - kBibleAudioCollapsedWidth / 2 - kBibleAudioEdgePeek,
        top,
      );
    }

    final horizontalTravel = (area.width -
            kBibleAudioCollapsedWidth -
            (kBibleAudioMargin * 2))
        .clamp(1.0, double.infinity);
    return Offset(kBibleAudioMargin + (x * horizontalTravel), top);
  }

  Rect _expandedRect(Size area, EdgeInsets padding) {
    final maxWidth = (area.width - kBibleAudioMargin * 2).clamp(0.0, 10000.0);
    final width = maxWidth < kBibleAudioExpandedMaxWidth
        ? maxWidth
        : kBibleAudioExpandedMaxWidth;
    final availableHeight = (area.height -
            padding.top -
            padding.bottom -
            kBibleAudioBottomReserve -
            (kBibleAudioMargin * 2))
        .clamp(180.0, 10000.0);
    final height = availableHeight < kBibleAudioExpandedMaxHeight
        ? availableHeight
        : kBibleAudioExpandedMaxHeight;
    final left = (area.width - width) / 2;
    final top = (area.height -
            padding.bottom -
            kBibleAudioBottomReserve -
            height -
            kBibleAudioMargin)
        .clamp(padding.top + kBibleAudioMargin, area.height - height);
    return Rect.fromLTWH(left, top, width, height);
  }

  Rect _currentRect(Size area, EdgeInsets padding) {
    final collapsedPosition = _sidebarPosition(area, padding);
    final collapsed = Rect.fromLTWH(
      collapsedPosition.dx,
      collapsedPosition.dy,
      kBibleAudioCollapsedWidth,
      kBibleAudioCollapsedHeight,
    );
    final expanded = _expandedRect(area, padding);
    return Rect.lerp(collapsed, expanded, _expandAnimation.value)!;
  }

  void _handlePanStart(DragStartDetails details) {
    if (_expanded || _expandController.isAnimating) return;
    _isDragging = true;
    if (_snapController.isAnimating) {
      final visibleX = _effectiveSidebarX;
      _snapController.stop();
      _snapController.value = 0;
      _sidebarX.value = visibleX;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size area, EdgeInsets padding) {
    if (!_isDragging || _expanded) return;
    final horizontalTravel = (area.width -
            kBibleAudioCollapsedWidth -
            (kBibleAudioMargin * 2))
        .clamp(1.0, double.infinity);
    final verticalTravel = (area.height -
            padding.top -
            padding.bottom -
            kBibleAudioBottomReserve -
            kBibleAudioCollapsedHeight -
            (kBibleAudioMargin * 2))
        .clamp(1.0, double.infinity);
    _sidebarX.value =
        (_sidebarX.value + details.delta.dx / horizontalTravel).clamp(0.0, 1.0);
    _sidebarY.value =
        (_sidebarY.value + details.delta.dy / verticalTravel).clamp(0.0, 1.0);
  }

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging || _expanded) return;
    _isDragging = false;
    final velocityX = details.velocity.pixelsPerSecond.dx;
    final target = velocityX.abs() > 240
        ? (velocityX > 0 ? 1.0 : 0.0)
        : (_sidebarX.value < 0.5 ? 0.0 : 1.0);
    _snapFromX = _sidebarX.value;
    _snapToX = target;
    _snapController
      ..stop()
      ..value = 0
      ..forward();
  }

  Future<void> _expand() async {
    if (_expanded || _isDragging) return;
    setState(() => _expanded = true);
    await _expandController.forward(from: _expandController.value);
    if (!mounted || !_expanded) return;
    setState(() => _showExpandedContent = true);
  }

  Future<void> _collapse() async {
    if (!_expanded) return;
    setState(() => _showExpandedContent = false);
    await _expandController.reverse(from: _expandController.value);
    if (!mounted) return;
    setState(() => _expanded = false);
  }

  void _onPlayPause(BibleState state) {
    final cubit = context.read<BibleCubit>();
    if (!state.isSpeaking) {
      cubit.playBibleRange();
      return;
    }
    cubit.togglePauseTts();
  }

  void _syncSpeakingAnimation(BibleState state) {
    final shouldPulse = state.isSpeaking && !state.isTtsPaused && !_expanded;
    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
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

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final area = Size(constraints.maxWidth, constraints.maxHeight);
        return BlocBuilder<BibleCubit, BibleState>(
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
            _syncSpeakingAnimation(state);
            return AnimatedBuilder(
              animation: Listenable.merge([
                _sidebarX,
                _sidebarY,
                _expandController,
                _snapController,
                _pulseController,
              ]),
              builder: (context, _) {
                final rect = _currentRect(area, padding);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      key: const ValueKey('bible-audio-positioned'),
                      left: rect.left,
                      top: rect.top,
                      width: rect.width,
                      height: rect.height,
                      child: RepaintBoundary(
                        child: Material(
                          color: context.colorScheme.surfaceContainerLow,
                          elevation: 12,
                          shadowColor: context.colorScheme.shadow.withValues(
                            alpha: 0.32,
                          ),
                          borderRadius: BorderRadius.lerp(
                            BorderRadius.circular(24),
                            context.appRadius(20),
                            _expandAnimation.value,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.colorScheme.outlineVariant
                                    .withValues(alpha: 0.55),
                              ),
                              borderRadius: BorderRadius.lerp(
                                BorderRadius.circular(24),
                                context.appRadius(20),
                                _expandAnimation.value,
                              ),
                            ),
                            child: _showExpandedContent
                                ? _SidebarPanel(
                                    state: state,
                                    titleFuture: _titleFor(state.currentBible),
                                    voices: _edgeVoices,
                                    voicesLoading: _voicesLoading,
                                    onPlayPause: () => _onPlayPause(state),
                                    onStop: () => context
                                        .read<BibleCubit>()
                                        .stopSpeaking(),
                                    onClose: () => context
                                        .read<BibleCubit>()
                                        .setAudioPanelOpen(false),
                                    onMinimize: _collapse,
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
                                    onVoiceChanged: (voice) => context
                                        .read<BibleCubit>()
                                        .setEdgeVoice(voice),
                                    onOpenSettings: () =>
                                        _openSettings(context, state),
                                  )
                                : GestureDetector(
                                    key: const ValueKey(
                                      'bible-audio-collapsed-gesture',
                                    ),
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _expand,
                                    onPanStart: _handlePanStart,
                                    onPanUpdate: (details) => _handlePanUpdate(
                                      details,
                                      area,
                                      padding,
                                    ),
                                    onPanEnd: _handlePanEnd,
                                    child: _CollapsedAudioTab(
                                      state: state,
                                      pulse: _pulseController.value,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CollapsedAudioTab extends StatelessWidget {
  final BibleState state;
  final double pulse;

  const _CollapsedAudioTab({required this.state, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isActive = state.isSpeaking && !state.isTtsPaused;
    final scale = isActive ? 0.96 + pulse * 0.06 : 1.0;
    return Center(
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Icon(
              state.isSpeaking
                  ? (state.isTtsPaused
                        ? Icons.pause_circle_outline_rounded
                        : Icons.graphic_eq_rounded)
                  : Icons.headphones_rounded,
              key: ValueKey('${state.isSpeaking}-${state.isTtsPaused}'),
              color: colors.onPrimary,
              size: 24,
            ),
          ),
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
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final ValueChanged<Verse> onStartChanged;
  final ValueChanged<Verse?> onEndChanged;
  final VoidCallback onChapterEnd;
  final VoidCallback onContinueOn;
  final Future<int> Function(BibleCubit cubit, int bookId, int chapterId)
  verseCountFor;
  final ValueChanged<String> onVoiceChanged;
  final VoidCallback onOpenSettings;

  const _SidebarPanel({
    required this.state,
    required this.titleFuture,
    required this.voices,
    required this.voicesLoading,
    required this.onPlayPause,
    required this.onStop,
    required this.onClose,
    required this.onMinimize,
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 6, 6),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer,
                ),
                child: Icon(
                  Icons.headphones_rounded,
                  size: 17,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'bible_playback_title'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    FutureBuilder<String?>(
                      future: titleFuture,
                      builder: (context, snapshot) => Text(
                        snapshot.data ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'bible_playback_collapse'.tr(),
                onPressed: onMinimize,
                icon: const Icon(Icons.expand_more_rounded),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNowPlaying(context),
                const SizedBox(height: 12),
                _buildTransport(context),
                const SizedBox(height: 14),
                _buildRangeSection(context),
                const SizedBox(height: 12),
                _buildVoiceSection(context),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: onOpenSettings,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune_rounded, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'audio_settings_shortcut'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNowPlaying(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.35),
        borderRadius: context.appRadius(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              state.isSpeaking
                  ? (state.isTtsPaused
                        ? Icons.pause_rounded
                        : Icons.graphic_eq_rounded)
                  : Icons.headphones_outlined,
              key: ValueKey('playing-${state.isSpeaking}-${state.isTtsPaused}'),
              color: state.isSpeaking ? colors.primary : colors.onSurfaceVariant,
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
                    fontWeight: FontWeight.w700,
                    color: colors.onSurfaceVariant,
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
    );
  }

  Widget _buildTransport(BuildContext context) {
    final colors = context.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          tooltip: 'bible_stop'.tr(),
          onPressed: state.isSpeaking ? onStop : null,
          icon: const Icon(Icons.stop_rounded),
        ),
        const SizedBox(width: 18),
        SizedBox(
          width: 64,
          height: 64,
          child: Material(
            color: colors.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPlayPause,
              child: Icon(
                state.isSpeaking && !state.isTtsPaused
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                size: 36,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        IconButton.filledTonal(
          tooltip: 'audio_settings_shortcut'.tr(),
          onPressed: onOpenSettings,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: context.appRadius(14),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.timeline_rounded, size: 17, color: colors.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'bible_range_title'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
            ),
          const SizedBox(height: 12),
          Text(
            'bible_range_end'.tr(),
            style: context.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              ChoiceChip(
                label: Text('bible_range_chapter_end'.tr()),
                selected: isChapterEnd,
                showCheckmark: false,
                onSelected: (_) => onChapterEnd(),
              ),
              ChoiceChip(
                label: Text('bible_range_continue'.tr()),
                selected: isContinueOn,
                showCheckmark: false,
                onSelected: (_) => onContinueOn(),
              ),
              ChoiceChip(
                label: Text('bible_range_to_verse'.tr()),
                selected: hasEnd,
                showCheckmark: false,
                onSelected: (_) {
                  final base = state.ttsPlayRangeStart ?? state.currentBible;
                  if (base != null) onEndChanged(base);
                },
              ),
            ],
          ),
          if (hasEnd && state.ttsPlayRangeEnd != null) ...[
            const SizedBox(height: 9),
            _RangePointPicker(
              state: state,
              value: state.ttsPlayRangeEnd!,
              verseCountFor: verseCountFor,
              onChanged: onEndChanged,
            ),
          ],
          const SizedBox(height: 9),
          _RangeSummary(
            start: start,
            end: state.ttsPlayRangeEnd,
            continueOn: isContinueOn,
            getTitle: (verse) => cubit.getBibleTitle([verse], withVerse: true),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceSection(BuildContext context) {
    final colors = context.colorScheme;
    return Row(
      children: [
        Icon(Icons.record_voice_over_outlined, color: colors.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(child: _buildVoiceDropdown(context)),
      ],
    );
  }

  Widget _buildVoiceDropdown(BuildContext context) {
    final colors = context.colorScheme;
    if (voicesLoading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.square(
          dimension: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    final langPrefix = state.currentBibleLanguage.split('-').first;
    final matching = voices.where((v) => v.locale.startsWith('$langPrefix-')).toList();
    final pool = matching.isNotEmpty ? matching : voices;
    if (pool.isEmpty) {
      return Text(
        'bible_edge_voices_offline'.tr(),
        style: context.textTheme.bodySmall?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      );
    }
    final selected = pool.firstWhereOrNull((v) => v.shortName == state.edgeVoice) ?? pool.first;
    return DropdownButton<String>(
      isExpanded: true,
      value: selected.shortName,
      borderRadius: BorderRadius.circular(12),
      items: [
        for (final voice in pool)
          DropdownMenuItem<String>(
            value: voice.shortName,
            child: Text(
              voice.shortName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (value) {
        if (value != null) onVoiceChanged(value);
      },
    );
  }
}

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
    final book =
        books.firstWhereOrNull((b) => b.id == value.bookId) ?? books.firstOrNull;
    if (book == null) return Text('bible_range_tap_hint'.tr());

    final chapterCount = book.chapterCount ?? value.chapterId;
    final chapter = value.chapterId.clamp(1, chapterCount);
    final itemStyle = context.textTheme.bodySmall?.copyWith(
      color: colors.onSurface,
      fontWeight: FontWeight.w600,
    );

    Verse makeVerse(int bookId, int chapterId, int verseId) => Verse(
      id: bookId * 1000000 + chapterId * 1000 + verseId,
      bookId: bookId,
      chapterId: chapterId,
      verseId: verseId,
    );

    InputDecoration decoration(String label) => InputDecoration(
      isDense: true,
      labelText: label,
      labelStyle: context.textTheme.labelSmall,
      border: OutlineInputBorder(borderRadius: context.appRadius(8)),
    );

    Widget buildBookPicker() => DropdownButtonFormField<int>(
      initialValue: book.id,
      isExpanded: true,
      decoration: decoration('bible_book'.tr()),
      items: [
        for (final b in books)
          DropdownMenuItem<int>(
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
        if (bookId != null) onChanged(makeVerse(bookId, 1, 1));
      },
    );

    Widget buildChapterPicker() => DropdownButtonFormField<int>(
      initialValue: chapter,
      isExpanded: true,
      decoration: decoration('bible_chapter'.tr()),
      items: [
        for (var c = 1; c <= chapterCount; c++)
          DropdownMenuItem<int>(
            value: c,
            child: Text('$c', style: itemStyle),
          ),
      ],
      onChanged: (chapterId) {
        if (chapterId != null) {
          onChanged(makeVerse(book.id, chapterId, 1));
        }
      },
    );

    Widget buildVersePicker() => FutureBuilder<int>(
      future: verseCountFor(cubit, book.id, chapter),
      builder: (context, snapshot) {
        final count = (snapshot.data ?? value.verseId).clamp(1, 999);
        final verse = value.verseId.clamp(1, count);
        return DropdownButtonFormField<int>(
          initialValue: verse,
          isExpanded: true,
          decoration: decoration('bible_verse'.tr()),
          items: [
            for (var v = 1; v <= count; v++)
              DropdownMenuItem<int>(
                value: v,
                child: Text('$v', style: itemStyle),
              ),
          ],
          onChanged: (verseId) {
            if (verseId != null) {
              onChanged(makeVerse(book.id, chapter, verseId));
            }
          },
        );
      },
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // The expanded floating panel can be as narrow as 296px on
        // small phones. After panel/range padding, three labeled
        // dropdowns no longer fit comfortably on one row.
        if (constraints.maxWidth < 280) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildBookPicker(),
              const SizedBox(height: 6),
              buildChapterPicker(),
              const SizedBox(height: 6),
              buildVersePicker(),
            ],
          );
        }

        return Row(
          children: [
            Expanded(flex: 3, child: buildBookPicker()),
            const SizedBox(width: 6),
            Expanded(flex: 2, child: buildChapterPicker()),
            const SizedBox(width: 6),
            Expanded(flex: 2, child: buildVersePicker()),
          ],
        );
      },
    );
  }
}

class _RangeSummary extends StatelessWidget {
  final Verse? start;
  final Verse? end;
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
        color: colors.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: context.appRadius(8),
      ),
      child: FutureBuilder<String>(
        future: getTitle(start!),
        builder: (context, startSnapshot) {
          final startTitle = startSnapshot.data ?? '';
          final summary = end != null
              ? 'bible_range_summary'
              : continueOn
              ? 'bible_range_continuous_summary'
              : 'bible_range_chapter_end_summary';
          if (end == null) {
            return Text(
              summary.tr(namedArgs: {'start': startTitle}),
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            );
          }
          return FutureBuilder<String>(
            future: getTitle(end!),
            builder: (context, endSnapshot) => Text(
              summary.tr(
                namedArgs: {
                  'start': startTitle,
                  'end': endSnapshot.data ?? '',
                },
              ),
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
