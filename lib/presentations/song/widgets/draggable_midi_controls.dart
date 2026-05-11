import 'package:flutter/material.dart';

import '../cubit/song_playlist.dart';

const double kMidiOverlayHorizontalMargin = 16;
const double kMidiOverlayBottomOffset = 0;
const double kMidiCollapsedBarHeight = 48;
const double kMidiCollapsedMaxWidth = 220;

IconData midiLoopModeIcon(String mode) {
  return switch (SongPlaylistAutoNextMode.normalize(mode)) {
    SongPlaylistAutoNextMode.one => Icons.repeat_one_rounded,
    SongPlaylistAutoNextMode.number => Icons.repeat_on_rounded,
    SongPlaylistAutoNextMode.playlist => Icons.playlist_play_rounded,
    SongPlaylistAutoNextMode.shuffleAll ||
    SongPlaylistAutoNextMode.shufflePlaylist => Icons.shuffle_rounded,
    _ => Icons.repeat_rounded,
  };
}

String midiLoopModeTooltip(String mode) {
  return switch (SongPlaylistAutoNextMode.normalize(mode)) {
    SongPlaylistAutoNextMode.one => 'Repeat one',
    SongPlaylistAutoNextMode.number => 'Auto next by number',
    SongPlaylistAutoNextMode.playlist => 'Auto next playlist',
    SongPlaylistAutoNextMode.shuffleAll => 'Shuffle all',
    SongPlaylistAutoNextMode.shufflePlaylist => 'Shuffle playlist',
    _ => 'Loop off',
  };
}

bool midiLoopModeActive(String mode) =>
    SongPlaylistAutoNextMode.normalize(mode) != SongPlaylistAutoNextMode.off;

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
  final String autoNextMode;
  final VoidCallback onPlayPause;
  final VoidCallback onLoopModeCycle;
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
    this.soundFont = 'TimGM6mb.sf2',
    this.availableSoundFonts = const ['TimGM6mb.sf2'],
    this.availableInstruments = const [],
    this.autoNextMode = SongPlaylistAutoNextMode.off,
    required this.onPlayPause,
    required this.onLoopModeCycle,
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

class _DraggableMidiControlsState extends State<DraggableMidiControls>
    with TickerProviderStateMixin {
  bool _expanded = true;
  final GlobalKey _instrumentButtonKey = GlobalKey();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  double _seekValue = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showInstrumentMenu(BuildContext context) async {
    if (widget.availableInstruments.isEmpty) return;

    final RenderBox button =
        _instrumentButtonKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final Size buttonSize = button.size;

    final selected = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        buttonPosition.dx,
        buttonPosition.dy - buttonSize.height,
        buttonPosition.dx + buttonSize.width,
        buttonPosition.dy,
      ),
      items: widget.availableInstruments.map((instrument) {
        final program = instrument[0] as int;
        final name = instrument[1] as String;
        return PopupMenuItem<int>(value: program, child: Text(name));
      }).toList(),
    );

    if (selected != null) {
      widget.onInstrument(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Positioned(
      left: kMidiOverlayHorizontalMargin,
      right: kMidiOverlayHorizontalMargin,
      bottom: kMidiOverlayBottomOffset,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _expanded
              ? _buildExpandedPanel(context, colors)
              : _buildCollapsedTrigger(context, colors),
        ),
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
            onTap: () {
              setState(() => _expanded = true);
              _animationController.forward();
            },
            child: SizedBox(
              height: kMidiCollapsedBarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.music_note_rounded,
                            size: 17,
                            color: colors.onPrimary,
                          ),
                        );
                      },
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
                    Icon(Icons.expand_more, color: colors.onPrimary, size: 22),
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
        color: colors.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(color: colors.outlineVariant),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () {
              setState(() => _expanded = false);
              _animationController.reverse();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Icon(
                          Icons.music_note_rounded,
                          size: 16,
                          color: colors.onPrimary,
                        ),
                      );
                    },
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
                  AnimatedRotation(
                    turns: _expanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(Icons.expand_more, color: colors.onPrimary),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
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
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12,
                          ),
                          trackHeight: 6,
                        ),
                        child: Slider(
                          value: _seekValue > 0
                              ? _seekValue
                              : (widget.duration > 0
                                    ? widget.position.clamp(0, widget.duration)
                                    : 0),
                          max: widget.duration > 0 ? widget.duration : 1,
                          onChanged: widget.duration > 0
                              ? (value) {
                                  setState(() {
                                    _seekValue = value;
                                  });
                                }
                              : null,
                          onChangeEnd: widget.duration > 0
                              ? (value) {
                                  widget.onSeek(value);
                                  setState(() {
                                    _seekValue = 0;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatTime(widget.position)} / ${_formatTime(widget.duration)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.1,
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
                          key: _instrumentButtonKey,
                          constraints: iconConstraints,
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showInstrumentMenu(context),
                          icon: Icon(
                            Icons.piano_rounded,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        IconButton(
                          constraints: iconConstraints,
                          visualDensity: VisualDensity.compact,
                          tooltip: midiLoopModeTooltip(widget.autoNextMode),
                          onPressed: widget.onLoopModeCycle,
                          icon: Icon(
                            midiLoopModeIcon(widget.autoNextMode),
                            color: midiLoopModeActive(widget.autoNextMode)
                                ? colors.primary
                                : colors.onSurfaceVariant,
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
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colors.onSurfaceVariant,
                                      letterSpacing: 0.1,
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
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colors.onSurfaceVariant,
                                letterSpacing: 0.1,
                              ),
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
