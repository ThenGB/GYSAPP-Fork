import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/services/bible_tts_service.dart';
import '../../../data/utilities/extensions/context_ext.dart';
import '../../presentations.dart';
import '../cubit/bible_cubit.dart';
import '../cubit/bible_state.dart';

/// Bottom sheet with the full Bible audio-playback options:
/// - play from the start of the chapter / from the selected verse
/// - play only one verse / until the chapter ends
/// - toggle auto-continue to the next chapter
/// - engine selector (Edge TTS default, native fallback) with a note that
///   the built-in engine stays available as fallback
/// - play / pause / stop controls
class BiblePlaybackSheet extends StatefulWidget {
  const BiblePlaybackSheet({super.key});

  @override
  State<BiblePlaybackSheet> createState() => _BiblePlaybackSheetState();
}

class _BiblePlaybackSheetState extends State<BiblePlaybackSheet> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return BlocBuilder<BibleCubit, BibleState>(
      buildWhen: (prev, curr) =>
          prev.isSpeaking != curr.isSpeaking ||
          prev.isTtsPaused != curr.isTtsPaused ||
          prev.autoNextChapter != curr.autoNextChapter ||
          prev.ttsEngine != curr.ttsEngine ||
          prev.selectedVerse != curr.selectedVerse ||
          prev.currentBible != curr.currentBible,
      builder: (context, state) {
        final cubit = context.read<BibleCubit>();
        final hasSelection = state.selectedVerse.isNotEmpty;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.volume_up_rounded, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'bible_playback_title'.tr(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── Play actions ────────────────────────────────────────
                  _SectionLabel('bible_play_actions'.tr()),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ActionButton(
                        icon: Icons.play_arrow_rounded,
                        label: hasSelection
                            ? 'bible_play_from_selected'.tr()
                            : 'bible_play_from_start'.tr(),
                        onPressed: () => _startPlayback(cubit, fromStart: true),
                      ),
                      _ActionButton(
                        icon: Icons.playlist_play_rounded,
                        label: 'bible_play_from_here'.tr(),
                        onPressed: () => _startPlayback(
                          cubit,
                          fromVerseId: state.currentBible?.verseId,
                        ),
                      ),
                      if (hasSelection)
                        _ActionButton(
                          icon: Icons.format_quote_rounded,
                          label: 'bible_play_selected_only'.tr(),
                          onPressed: () => cubit.speakTheBible(
                            onlyThisVerse: true,
                          ),
                        ),
                      _ActionButton(
                        icon: Icons.stop_rounded,
                        label: 'bible_stop'.tr(),
                        onPressed: state.isSpeaking
                            ? cubit.stopSpeaking
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Now playing / pause ────────────────────────────────
                  if (state.isSpeaking) ...[
                    Row(
                      children: [
                        Icon(
                          state.isTtsPaused
                              ? Icons.pause_circle_rounded
                              : Icons.graphic_eq_rounded,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'bible_now_playing'.tr(),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => cubit.togglePauseTts(),
                          icon: Icon(
                            state.isTtsPaused
                                ? Icons.play_arrow_rounded
                                : Icons.pause_rounded,
                            size: 18,
                          ),
                          label: Text(
                            state.isTtsPaused
                                ? 'bible_resume'.tr()
                                : 'bible_pause'.tr(),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                  ],

                  // ── Auto-next chapter toggle ───────────────────────────
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('bible_auto_next_chapter'.tr()),
                    subtitle: Text('bible_auto_next_chapter_desc'.tr()),
                    value: state.autoNextChapter,
                    onChanged: (value) => cubit.setAutoNextChapter(value),
                  ),
                  const Divider(height: 12),

                  // ── Engine selector ─────────────────────────────────────
                  _SectionLabel('bible_tts_engine'.tr()),
                  const SizedBox(height: 4),
                  Text(
                    'bible_tts_engine_desc'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<BibleTtsEngine>(
                    segments: [
                      ButtonSegment(
                        value: BibleTtsEngine.edge,
                        icon: Icon(Icons.cloud_outlined, size: 18),
                        label: const Text('Edge TTS'),
                      ),
                      ButtonSegment(
                        value: BibleTtsEngine.native,
                        icon: const Icon(Icons.phonelink_ring_outlined, size: 18),
                        label: Text('bible_tts_native'.tr()),
                      ),
                    ],
                    selected: {
                      state.ttsEngine == 'native'
                          ? BibleTtsEngine.native
                          : BibleTtsEngine.edge,
                    },
                    onSelectionChanged: (selection) {
                      final engine = selection.first;
                      cubit.setTtsEngine(
                        engine == BibleTtsEngine.native ? 'native' : 'edge',
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'bible_tts_fallback_note'.tr(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startPlayback(
    BibleCubit cubit, {
    bool fromStart = false,
    int? fromVerseId,
  }) {
    final verseId = fromStart
        ? (cubit.state.verses.firstOrNull?.verseId ?? 1)
        : (fromVerseId ?? cubit.state.currentBible?.verseId);
    cubit.speakTheBible(fromVerseId: verseId);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: context.colorScheme.primary,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
