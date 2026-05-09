import 'package:flutter/material.dart';

const double kMidiOverlayHorizontalMargin = 16;
const double kMidiOverlayBottomOffset = 0;
const double kMidiCollapsedBarHeight = 48;
const double kMidiCollapsedMaxWidth = 220;

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

    return Positioned(
      left: kMidiOverlayHorizontalMargin,
      right: kMidiOverlayHorizontalMargin,
      bottom: kMidiOverlayBottomOffset,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: _expanded
            ? _buildExpandedPanel(context, colors)
            : _buildCollapsedTrigger(context, colors),
      ),
    );
  }

  Widget _buildCollapsedTrigger(BuildContext context, ColorScheme colors) {
    final title = widget.nowPlayingTitle.trim();
    return Align(
      alignment: Alignment.bottomRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMidiCollapsedMaxWidth),
        child: Material(
          key: const ValueKey('midi-collapsed'),
          color: colors.primary,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          elevation: 2,
          shadowColor: colors.primary.withValues(alpha: 0.18),
          child: InkWell(
            onTap: () => setState(() => _expanded = true),
            child: SizedBox(
              height: kMidiCollapsedBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 17,
                      color: colors.onPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title.isEmpty ? 'Now Playing' : 'Now Playing: $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      color: colors.onPrimary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedPanel(BuildContext context, ColorScheme colors) {
    return Container(
      key: const ValueKey('midi-expanded'),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            key: const ValueKey('midi-collapse-toggle'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            onTap: () => setState(() => _expanded = false),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
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
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.onPrimary,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: FilledButton(
                        onPressed: widget.isLoading ? null : widget.onPlayPause,
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
                          onChanged: widget.duration > 0 ? widget.onSeek : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatTime(widget.position)} / ${_formatTime(widget.duration)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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
                            onPressed: () =>
                                widget.onTranspose(widget.transposeStep - 1),
                            icon: const Icon(Icons.remove_rounded),
                          ),
                          SizedBox(
                            width: compact ? 22 : 24,
                            child: Text(
                              '${widget.transposeStep}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            constraints: iconConstraints,
                            visualDensity: VisualDensity.compact,
                            onPressed: () =>
                                widget.onTranspose(widget.transposeStep + 1),
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
                                    ?.copyWith(color: colors.onSurfaceVariant),
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
          ),
        ],
      ),
    );
  }
}
