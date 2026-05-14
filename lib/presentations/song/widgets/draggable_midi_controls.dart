import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector4;

import '../cubit/song_playlist.dart';

const double kMidiOverlayHorizontalMargin = 16;
const double kMidiOverlayBottomOffset = 0;
const double kMidiCollapsedBarHeight = 48;
const double kMidiCollapsedMaxWidth = 220;
const double kMidiExpandedMaxWidth = 520;
const double kMidiSidebarButtonSize = 56;
const double kMidiSidebarButtonMargin = 16;
const double kMidiSidebarBarWidth = 48;
const double kMidiSidebarBarHeight = 48;

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
  final String? runningFamilyChord;

  /// When provided the panel's expand/collapse state is controlled externally
  /// (e.g. by the Dashboard which needs the height for layout calculations).
  final bool? isExpanded;
  final ValueChanged<bool>? onExpandedChanged;

  /// Optional prev/next song callbacks; shown in the expanded panel when set.
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;

  /// Whether to wrap the panel in a [Positioned] widget.  Set to `false` when
  /// the caller already handles positioning (e.g. the Dashboard).
  final bool usePositioned;
  final double leftMargin;
  final double rightMargin;
  final double bottomOffset;

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
    this.runningFamilyChord,
    this.isExpanded,
    this.onExpandedChanged,
    this.onPreviousSong,
    this.onNextSong,
    this.usePositioned = true,
    this.leftMargin = kMidiOverlayHorizontalMargin,
    this.rightMargin = kMidiOverlayHorizontalMargin,
    this.bottomOffset = kMidiOverlayBottomOffset,
  });

  @override
  State<DraggableMidiControls> createState() => _DraggableMidiControlsState();
}

class _DraggableMidiControlsState extends State<DraggableMidiControls>
    with TickerProviderStateMixin {
  bool _expanded = false;
  final GlobalKey _instrumentButtonKey = GlobalKey();
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  double _seekValue = 0;

  // Sidebar button state
  double _sidebarButtonY = 200; // Initial vertical position
  bool _snapRight = true; // Snap to right or left side
  double _dragX = 0; // Horizontal drag offset

  // Debounce timers for tempo and transpose to prevent spamming
  Timer? _tempoDebounce;
  Timer? _transposeDebounce;

  bool get _effectiveExpanded => widget.isExpanded ?? _expanded;

  @override
  void initState() {
    super.initState();
    final initiallyExpanded = _effectiveExpanded;
    _expanded = initiallyExpanded;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      value: initiallyExpanded ? 1.0 : 0.0,
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
    if (initiallyExpanded) {
      _animationController.forward(from: 1.0);
    }
  }

  @override
  void dispose() {
    _tempoDebounce?.cancel();
    _transposeDebounce?.cancel();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DraggableMidiControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != null &&
        oldWidget.isExpanded != widget.isExpanded) {
      final newValue = widget.isExpanded!;
      _expanded = newValue;
      if (newValue) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
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

  void _adjustTempo(double newTempo) {
    _tempoDebounce?.cancel();
    // Debounce 300ms before applying to prevent rapid updates
    _tempoDebounce = Timer(const Duration(milliseconds: 300), () {
      widget.onTempo(newTempo);
    });
    // Still show immediate visual feedback
    setState(() {});
  }

  void _adjustTranspose(int newTranspose) {
    _transposeDebounce?.cancel();
    // Debounce 300ms before applying to prevent rapid updates
    _transposeDebounce = Timer(const Duration(milliseconds: 300), () {
      widget.onTranspose(newTranspose.clamp(-12, 12));
    });
    // Still show immediate visual feedback
    setState(() {});
  }

  void _showTempoEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: widget.tempoBpm.round().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Tempo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'BPM',
            hintText: 'Enter tempo (30-300)',
          ),
          autofocus: true,
          onSubmitted: (value) {
            final tempo = double.tryParse(value);
            if (tempo != null) {
              widget.onTempo(tempo.clamp(30, 300));
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final tempo = double.tryParse(controller.text);
              if (tempo != null) {
                widget.onTempo(tempo.clamp(30, 300));
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showKeySelector(BuildContext context) {
    if (widget.availableKeys.isEmpty) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Key',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.availableKeys.length,
                itemBuilder: (context, index) {
                  final key = widget.availableKeys[index];
                  final isSelected = key == widget.currentKey;
                  return ListTile(
                    title: Text(key),
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      widget.onKeySelected(key);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setExpanded(bool value) {
    if (widget.onExpandedChanged != null) {
      widget.onExpandedChanged!(value);
    } else {
      setState(() => _expanded = value);
    }
    if (value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handleSidebarPanUpdate(DragUpdateDetails details) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final barHeight = kMidiSidebarBarHeight;
    final margin = kMidiSidebarButtonMargin;

    setState(() {
      // Allow full screen vertical movement
      _sidebarButtonY = (_sidebarButtonY + details.delta.dy).clamp(
        margin,
        screenHeight - barHeight - margin,
      );
      // Update dragX for smooth horizontal movement feedback
      _dragX += details.delta.dx;
    });
  }

  void _handleSidebarPanEnd(DragEndDetails details) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    setState(() {
      final currentPos = _snapRight ? screenWidth + _dragX : _dragX;
      _snapRight = currentPos > screenWidth / 2;
      _dragX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_effectiveExpanded) {
      Widget expandedPanel = SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildExpandedPanel(context, colors),
        ),
      );

      final content = Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: Padding(
            padding: EdgeInsets.only(bottom: widget.bottomOffset),
            child: expandedPanel,
          ),
        ),
      );

      if (widget.usePositioned) {
        return Positioned(left: 0, right: 0, bottom: 0, child: content);
      }
      return content;
    }

    // Collapsed state - sidebar button
    final collapsedTrigger = Material(
      type: MaterialType.transparency,
      child: Transform.translate(
        offset: Offset(_dragX, 0),
        child: _buildCollapsedTrigger(context, colors),
      ),
    );

    if (widget.usePositioned) {
      return Positioned(
        top: _sidebarButtonY,
        left: _snapRight ? null : 0,
        right: _snapRight ? 0 : null,
        child: collapsedTrigger,
      );
    }

    return Align(
      alignment: _snapRight ? Alignment.topRight : Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(top: _sidebarButtonY),
        child: collapsedTrigger,
      ),
    );
  }

  Widget _buildCollapsedTrigger(BuildContext context, ColorScheme colors) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: _handleSidebarPanUpdate,
      onPanEnd: _handleSidebarPanEnd,
      onTap: () => _setExpanded(true),
      onDoubleTap: () {
        setState(() {
          _snapRight = !_snapRight;
        });
      },
      child: Container(
        // The trigger itself
        width: kMidiSidebarBarWidth,
        height: kMidiSidebarBarHeight,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.only(
            topLeft: _snapRight ? const Radius.circular(24) : Radius.zero,
            bottomLeft: _snapRight ? const Radius.circular(24) : Radius.zero,
            topRight: _snapRight ? Radius.zero : const Radius.circular(24),
            bottomRight: _snapRight ? Radius.zero : const Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: Offset(_snapRight ? -2 : 2, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            double scale = _pulseAnimation.value;
            double rotation = 0;
            double translationY = 0;
            double translationX = 0;

            if (widget.isPlaying) {
              // Musical rhythmic dance
              final t = (DateTime.now().millisecondsSinceEpoch % 600) / 600.0;
              final jump = (t < 0.5) ? t * 2 : (1.0 - t) * 2;
              translationY = jump * -12;
              rotation = 0.2 * (t < 0.5 ? 1 : -1) * jump;
              // Subtle horizontal vibration
              translationX = 2 * (t < 0.25 || t > 0.75 ? 1 : -1);
            }

            return Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..setTranslationRaw(translationX, translationY, 0.0)
                  ..rotateZ(rotation)
                  ..setDiagonal(Vector4(scale, scale, 1.0, 1.0)),
                alignment: Alignment.center,
                child: Icon(
                  Icons.music_note_rounded,
                  size: 32,
                  color: colors.onPrimary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedPanel(BuildContext context, ColorScheme colors) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMidiExpandedMaxWidth),
        child: Container(
          key: const ValueKey('midi-expanded'),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: ColoredBox(
                color: colors.surfaceContainerLowest.withValues(alpha: 0.82),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      key: const ValueKey('midi-collapse-toggle'),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      onTap: () => _setExpanded(false),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.nowPlayingTitle.trim().isEmpty
                                        ? 'Now Playing'
                                        : widget.nowPlayingTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: colors.onPrimary,
                                          letterSpacing: 1.3,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  if (widget.runningFamilyChord != null &&
                                      widget.runningFamilyChord!.isNotEmpty)
                                    Text(
                                      widget.runningFamilyChord!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: colors.onPrimary.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            AnimatedRotation(
                              turns: _expanded ? 0 : 0.5,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Icon(
                                Icons.expand_more,
                                color: colors.onPrimary,
                              ),
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
                                              ? widget.position.clamp(
                                                  0,
                                                  widget.duration,
                                                )
                                              : 0),
                                    max: widget.duration > 0
                                        ? widget.duration
                                        : 1,
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
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
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
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      constraints: iconConstraints,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _adjustTranspose(
                                        widget.transposeStep - 1,
                                      ),
                                      icon: const Icon(Icons.remove_rounded),
                                    ),
                                    GestureDetector(
                                      onTap: widget.availableKeys.isNotEmpty
                                          ? () => _showKeySelector(context)
                                          : null,
                                      child: SizedBox(
                                        width: compact ? 30 : 36,
                                        child: Text(
                                          '${widget.transposeStep}',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      constraints: iconConstraints,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _adjustTranspose(
                                        widget.transposeStep + 1,
                                      ),
                                      icon: const Icon(Icons.add_rounded),
                                    ),
                                  ],
                                ),
                              );

                              Widget tempoControl = Container(
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: colors.outlineVariant,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      constraints: iconConstraints,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _adjustTempo(
                                        (widget.tempoBpm - 1).clamp(30, 300),
                                      ),
                                      icon: const Icon(Icons.remove_rounded),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          _showTempoEditDialog(context),
                                      child: SizedBox(
                                        width: compact ? 34 : 48,
                                        child: Text(
                                          '${widget.tempoBpm.round()}',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      constraints: iconConstraints,
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () => _adjustTempo(
                                        (widget.tempoBpm + 1).clamp(30, 300),
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
                                    key: _instrumentButtonKey,
                                    constraints: iconConstraints,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () =>
                                        _showInstrumentMenu(context),
                                    icon: Icon(
                                      Icons.piano_rounded,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  IconButton(
                                    constraints: iconConstraints,
                                    visualDensity: VisualDensity.compact,
                                    tooltip: midiLoopModeTooltip(
                                      widget.autoNextMode,
                                    ),
                                    onPressed: widget.onLoopModeCycle,
                                    icon: Icon(
                                      midiLoopModeIcon(widget.autoNextMode),
                                      color:
                                          midiLoopModeActive(
                                            widget.autoNextMode,
                                          )
                                          ? colors.primary
                                          : colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              );

                              final labelStyle = Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colors.onSurfaceVariant,
                                    letterSpacing: 0.1,
                                  );

                              if (compact) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text('Transpose', style: labelStyle),
                                        const SizedBox(width: 8),
                                        transposeControl,
                                        const Spacer(),
                                        Text('Tempo', style: labelStyle),
                                        const SizedBox(width: 8),
                                        tempoControl,
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

                              return Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('Transpose', style: labelStyle),
                                  transposeControl,
                                  Text('Tempo', style: labelStyle),
                                  tempoControl,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
