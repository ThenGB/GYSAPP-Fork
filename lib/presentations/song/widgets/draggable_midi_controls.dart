import 'package:flutter/material.dart';

/// Fixed-bottom MIDI control panel styled to match the Stitch reference.
class DraggableMidiControls extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final double position;
  final double duration;
  final int transposeStep;
  final String currentKey;
  final List<String> availableKeys;
  final double tempoBpm;
  final int? midiInstrument;
  final String soundFont;
  final List<String> availableSoundFonts;
  final List<List<dynamic>> availableInstruments;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;
  final ValueChanged<int> onTranspose;
  final ValueChanged<String> onKeySelected;
  final ValueChanged<double> onTempo;
  final ValueChanged<int?> onInstrument;
  final ValueChanged<String> onSoundFont;
  final String nowPlayingTitle;

  const DraggableMidiControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.transposeStep,
    this.currentKey = '-',
    this.availableKeys = const [],
    required this.tempoBpm,
    this.midiInstrument,
    this.soundFont = 'GeneralUser-GS.sf2',
    this.availableSoundFonts = const ['GeneralUser-GS.sf2', 'TimGM6mb.sf2'],
    this.availableInstruments = const [],
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
    required this.onTranspose,
    required this.onKeySelected,
    required this.onTempo,
    required this.onInstrument,
    required this.onSoundFont,
    this.nowPlayingTitle = '',
  });

  @override
  State<DraggableMidiControls> createState() => _DraggableMidiControlsState();
}

class _DraggableMidiControlsState extends State<DraggableMidiControls> {
  bool _expanded = true;

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 74 + bottomSafe,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.14),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.vertical(
                    top: const Radius.circular(24),
                    bottom: Radius.circular(_expanded ? 0 : 24),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 16,
                      color: colors.onPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.nowPlayingTitle.trim().isEmpty
                            ? 'Now Playing'
                            : 'Now Playing: ${widget.nowPlayingTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 240),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: FilledButton(
                            onPressed: widget.isLoading
                                ? null
                                : widget.onPlayPause,
                            style: FilledButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: EdgeInsets.zero,
                              backgroundColor: colors.primary,
                            ),
                            child: widget.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        colors.onPrimary,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    widget.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: colors.onPrimary,
                                    size: 28,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 0,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0,
                              ),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: widget.duration > 0
                                  ? widget.position.clamp(0, widget.duration)
                                  : 0,
                              max: widget.duration > 0 ? widget.duration : 1,
                              onChanged: widget.duration > 0
                                  ? widget.onSeek
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatTime(widget.position)} / ${_formatTime(widget.duration)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 340;
                        final iconConstraints = BoxConstraints.tightFor(
                          width: compact ? 36 : 40,
                          height: compact ? 36 : 40,
                        );

                        Widget transposeControl = Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                constraints: iconConstraints,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => widget.onTranspose(
                                  widget.transposeStep - 1,
                                ),
                                icon: const Icon(Icons.remove_rounded),
                              ),
                              SizedBox(
                                width: compact ? 22 : 24,
                                child: Text(
                                  '${widget.transposeStep}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              IconButton(
                                constraints: iconConstraints,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => widget.onTranspose(
                                  widget.transposeStep + 1,
                                ),
                                icon: const Icon(Icons.add_rounded),
                              ),
                            ],
                          ),
                        );

                        Widget iconActions = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              constraints: iconConstraints,
                              visualDensity: VisualDensity.compact,
                              onPressed: () =>
                                  widget.onInstrument(widget.midiInstrument),
                              icon: Icon(
                                Icons.piano_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            IconButton(
                              constraints: iconConstraints,
                              visualDensity: VisualDensity.compact,
                              onPressed: widget.onStop,
                              icon: Icon(
                                Icons.repeat_rounded,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );

                        if (compact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Transpose',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(width: 8),
                                  transposeControl,
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: iconActions,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Text(
                              'Transpose',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 10),
                            transposeControl,
                            const Spacer(),
                            iconActions,
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
