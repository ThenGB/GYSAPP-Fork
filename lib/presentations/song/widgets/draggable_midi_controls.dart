// ignore_for_file: constant_identifier_names
// Enum values use snake_case for readability (e.g., sidebar_circle, flying_to_player)
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../cubit/song_playlist.dart';

// Animation timing
const Duration kMidiAnimationFlyDuration = Duration(milliseconds: 150);
const Duration kMidiAnimationMorphDuration = Duration(milliseconds: 150);

const double kMidiOverlayHorizontalMargin = 16;
const double kMidiOverlayBottomOffset = 0;
const double kMidiCollapsedBarHeight = 48;
const double kMidiCollapsedMaxWidth = 220;
const double kMidiExpandedMaxWidth = 460;
const double kMidiSidebarButtonSize = 56;
const double kMidiSidebarButtonMargin = 16;
const double kMidiSidebarBarWidth = 48;
const double kMidiSidebarBarHeight = 48;

// Expanded player dimensions
const double kMidiExpandedHeaderHeight = 48.0;
const double kMidiExpandedControlsHeight = 120.0;
const double kMidiExpandedTotalHeight = kMidiExpandedHeaderHeight + kMidiExpandedControlsHeight;
const double kMidiExpandedWidthRatio = 0.95;

// Collapsed (circle) dimensions
const double kMidiCircleSize = 56.0;
const double kMidiCircleMargin = 16.0;

// Dashboard navigation gap (needed for proper positioning)
const double kDashboardMiniPlayerNavGap = 0.0;

/// Animation states for the MIDI player morphing system.
/// Follows a cycle: sidebar_circle ↔ (flying) ↔ expanded_player
enum MidiPlayerAnimationState {
  /// Collapsed circle at sidebar position (left or right edge)
  sidebar_circle,

  /// Circle flying to player position (bottom center)
  flying_to_player,

  /// Circle morphing into player shape
  expanding_player,

  /// Full player visible with header + controls
  expanded_player,

  /// Player morphing back into circle (at player position)
  collapsing_player,

  /// Circle flying to sidebar snap position
  flying_to_sidebar,
}

extension MidiPlayerAnimationStateExt on MidiPlayerAnimationState {
  bool get isCircle => this == MidiPlayerAnimationState.sidebar_circle;
  bool get isExpanded => this == MidiPlayerAnimationState.expanded_player;
  bool get isAnimating =>
      this == MidiPlayerAnimationState.flying_to_player ||
      this == MidiPlayerAnimationState.expanding_player ||
      this == MidiPlayerAnimationState.collapsing_player ||
      this == MidiPlayerAnimationState.flying_to_sidebar;
  bool get isExpanding =>
      this == MidiPlayerAnimationState.flying_to_player ||
      this == MidiPlayerAnimationState.expanding_player;
  bool get isCollapsing =>
      this == MidiPlayerAnimationState.collapsing_player ||
      this == MidiPlayerAnimationState.flying_to_sidebar;
}

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
  final GlobalKey _instrumentButtonKey = GlobalKey();

  // === Animation State Machine ===
  MidiPlayerAnimationState _animationState = MidiPlayerAnimationState.expanded_player;

  // Position tracking for snap zones
  double _sidebarX = 1.0;  // 0 = left edge, 1 = right edge
  double _sidebarY = 0.5;   // 0 = top, 1 = bottom (normalized)

  // Animation controllers
  late AnimationController _flyController;      // Phase 1: fly to target
  late AnimationController _morphController;   // Phase 2: morph shape
  late AnimationController _bounceController;  // Pulse when playing (sidebar)

  // Don't remove - preparing for future position interpolation during fly animation
  // ignore: unused_field
  late Animation<double> _flyAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _bounceAnimation;

  // Drag state
  bool _isDragging = false;

  // Debounce timers
  Timer? _tempoDebounce;
  Timer? _transposeDebounce;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _flyController = AnimationController(
      duration: kMidiAnimationFlyDuration,
      vsync: this,
    );
    _morphController = AnimationController(
      duration: kMidiAnimationMorphDuration,
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Set up derived animations
    _flyAnimation = CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeOutCubic,
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    // Listeners
    _flyController.addListener(_onAnimationTick);
    _morphController.addListener(_onAnimationTick);

    // Determine initial state based on isExpanded
    final initiallyExpanded = widget.isExpanded ?? false;
    if (initiallyExpanded) {
      // Start in expanded state - set controllers to final values
      _animationState = MidiPlayerAnimationState.expanded_player;
      _flyController.value = 1.0;
      _morphController.value = 1.0;
    } else {
      _animationState = MidiPlayerAnimationState.sidebar_circle;
      _flyController.value = 0.0;
      _morphController.value = 0.0;
      // Start bounce animation if playing
      if (widget.isPlaying) {
        _bounceController.repeat(reverse: true);
      }
    }
  }

  void _onAnimationTick() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tempoDebounce?.cancel();
    _transposeDebounce?.cancel();
    _flyController.dispose();
    _morphController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DraggableMidiControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external isExpanded changes
    if (widget.isExpanded != null && oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded!) {
        expand();
      } else {
        collapse();
      }
    }

    // Handle playing state changes for bounce animation
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying && _animationState == MidiPlayerAnimationState.sidebar_circle) {
        _bounceController.repeat(reverse: true);
      } else {
        _bounceController.stop();
        _bounceController.value = 0;
      }
    }
  }

  void expand() {
    if (_animationState != MidiPlayerAnimationState.sidebar_circle) return;

    setState(() => _animationState = MidiPlayerAnimationState.flying_to_player);
    _bounceController.stop();

    // Phase 1: Fly to player position
    _flyController.forward(from: 0).then((_) {
      setState(() => _animationState = MidiPlayerAnimationState.expanding_player);

      // Phase 2: Morph into player
      _morphController.forward(from: 0).then((_) {
        setState(() => _animationState = MidiPlayerAnimationState.expanded_player);
      });
    });
  }

  void collapse() {
    if (_animationState != MidiPlayerAnimationState.expanded_player &&
        _animationState != MidiPlayerAnimationState.expanding_player) {
      return;
    }

    setState(() => _animationState = MidiPlayerAnimationState.collapsing_player);

    // Phase 1: Morph to circle
    _morphController.reverse(from: 1).then((_) {
      setState(() => _animationState = MidiPlayerAnimationState.flying_to_sidebar);

      // Phase 2: Fly to sidebar
      _flyController.reverse(from: 1).then((_) {
        setState(() => _animationState = MidiPlayerAnimationState.sidebar_circle);

        // Start bounce if playing
        if (widget.isPlaying) {
          _bounceController.repeat(reverse: true);
        }
      });
    });
  }

  // === Position Calculation Helpers ===

  double get _screenWidth => MediaQuery.sizeOf(context).width;
  double get _screenHeight => MediaQuery.sizeOf(context).height;
  double get _screenCenterX => _screenWidth / 2;
  double get _bottomInset => MediaQuery.paddingOf(context).bottom;

  /// Target snap position (0 = left, 1 = right) based on current X
  double get _targetSnapX {
    final actualLeft = kMidiCircleMargin + (_sidebarX * (_screenWidth - kMidiCircleSize - kMidiCircleMargin * 2));
    final centerX = actualLeft + (kMidiCircleSize / 2);
    return centerX < _screenCenterX ? 0.0 : 1.0;
  }

  /// Circle position when collapsed (sidebar)
  Offset get _sidebarPosition {
    final maxLeft = _screenWidth - kMidiCircleSize - kMidiCircleMargin;
    final minLeft = kMidiCircleMargin;
    final left = minLeft + (_targetSnapX * (maxLeft - minLeft));

    final maxBottom = _screenHeight * 0.75;
    final minBottom = kMidiCircleMargin + _bottomInset;
    final bottom = minBottom + (_sidebarY * (maxBottom - minBottom));

    return Offset(left, bottom);
  }

  /// Player position (centered at bottom, above nav)
  Offset get _playerPosition {
    final left = (_screenWidth * (1 - kMidiExpandedWidthRatio)) / 2;
    final bottom = _bottomInset + kDashboardMiniPlayerNavGap;
    return Offset(left, bottom);
  }

  /// Player dimensions
  Size get _playerSize {
    final width = _screenWidth * kMidiExpandedWidthRatio;
    return Size(width, kMidiExpandedTotalHeight);
  }

  /// Circle size
  Size get _circleSize => const Size(kMidiCircleSize, kMidiCircleSize);

  /// Current position based on animation state with interpolation
  Offset get _currentPosition {
    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
      case MidiPlayerAnimationState.flying_to_sidebar:
        return _sidebarPosition;
      case MidiPlayerAnimationState.flying_to_player:
        // Interpolate position during fly animation
        return Offset.lerp(_sidebarPosition, _playerPosition, _flyAnimation.value)!;
      case MidiPlayerAnimationState.expanding_player:
      case MidiPlayerAnimationState.collapsing_player:
      case MidiPlayerAnimationState.expanded_player:
        return _playerPosition;
    }
  }

  /// Current size based on animation state with interpolation
  Size get _currentSize {
    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
      case MidiPlayerAnimationState.flying_to_sidebar:
        return _circleSize;
      case MidiPlayerAnimationState.flying_to_player:
        // Interpolate size during fly animation
        return Size.lerp(_circleSize, _playerSize, _flyAnimation.value)!;
      case MidiPlayerAnimationState.expanding_player:
      case MidiPlayerAnimationState.collapsing_player:
      case MidiPlayerAnimationState.expanded_player:
        return _playerSize;
    }
  }

  /// Calculate border radius with interpolation based on animation progress
  BorderRadius get _currentBorderRadius {
    final circleRadius = kMidiCircleSize / 2;
    final expandedRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.zero,
      bottomRight: Radius.zero,
    );

    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
      case MidiPlayerAnimationState.flying_to_sidebar:
        return BorderRadius.all(Radius.circular(circleRadius));

      case MidiPlayerAnimationState.flying_to_player:
        // Stay circular during fly phase
        return BorderRadius.all(Radius.circular(circleRadius));

      case MidiPlayerAnimationState.expanding_player:
        // Interpolate from circle to header shape during morph
        return BorderRadius.lerp(
          BorderRadius.all(Radius.circular(circleRadius)),
          expandedRadius,
          _morphAnimation.value,
        )!;

      case MidiPlayerAnimationState.expanded_player:
        return expandedRadius;

      case MidiPlayerAnimationState.collapsing_player:
        // Interpolate from header to circle during morph
        return BorderRadius.lerp(
          BorderRadius.all(Radius.circular(circleRadius)),
          expandedRadius,
          1 - _morphAnimation.value,
        )!;
    }
  }

  /// Helper for lerp
  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  /// Opacity for controls (fade in during morph phase)
  double get _controlsOpacity {
    switch (_animationState) {
      case MidiPlayerAnimationState.expanding_player:
        return _morphAnimation.value;
      case MidiPlayerAnimationState.expanded_player:
        return 1.0;
      case MidiPlayerAnimationState.collapsing_player:
        return 1 - _morphAnimation.value;
      default:
        return 0.0;
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
      widget.onTranspose(_normalizeTranspose(newTranspose));
    });
    // Still show immediate visual feedback
    setState(() {});
  }

  int _normalizeTranspose(int value) {
    if (value < -11 || value > 11) return 0;
    return value;
  }

  void _showTransposeEditDialog(BuildContext context) {
    final controller = TextEditingController(
      text: widget.transposeStep.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Transpose'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(
            labelText: 'Semitone',
            hintText: 'Enter transpose (-11 to 11)',
          ),
          autofocus: true,
          onSubmitted: (value) {
            final transpose = int.tryParse(value);
            if (transpose != null) {
              widget.onTranspose(_normalizeTranspose(transpose));
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
              final transpose = int.tryParse(controller.text);
              if (transpose != null) {
                widget.onTranspose(_normalizeTranspose(transpose));
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
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

  // Reserved for future external isExpanded control integration
  // ignore: unused_element
  void _setExpanded(bool value) {
    if (widget.onExpandedChanged != null) {
      widget.onExpandedChanged!(value);
    }
    if (value) {
      expand();
    } else {
      collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Calculate positions based on animation state
    final position = _currentPosition;
    final size = _currentSize;
    final borderRadius = _currentBorderRadius;

    // Determine if showing header content
    final bool showHeader = _animationState == MidiPlayerAnimationState.expanding_player ||
                            _animationState == MidiPlayerAnimationState.expanded_player ||
                            _animationState == MidiPlayerAnimationState.collapsing_player;

    // Determine if showing controls
    final bool showControls = _animationState == MidiPlayerAnimationState.expanding_player ||
                             _animationState == MidiPlayerAnimationState.expanded_player ||
                             _animationState == MidiPlayerAnimationState.collapsing_player;

    // Controls opacity based on animation state
    final controlsOpacity = _controlsOpacity;

    return Stack(
      children: [
        // Main morphing container with header + controls in a Column
        Positioned(
          left: position.dx,
          bottom: position.dy,
          child: GestureDetector(
            onTap: () {
              if (_animationState == MidiPlayerAnimationState.sidebar_circle) {
                expand();
              }
            },
            onPanStart: (_) {
              setState(() => _isDragging = true);
            },
            onPanUpdate: (details) {
              if (_animationState == MidiPlayerAnimationState.sidebar_circle ||
                  _animationState == MidiPlayerAnimationState.flying_to_sidebar) {
                _updateDragPosition(details.delta);
              }
            },
            onPanEnd: (_) {
              setState(() => _isDragging = false);
              _snapToEdge();
            },
            child: AnimatedBuilder(
              animation: Listenable.merge([_flyController, _morphController, _bounceController]),
              builder: (context, child) {
                // Calculate scale for drag hover and bounce
                final hoverScale = _isDragging ? 1.1 : 1.0;
                final bounceScale = _animationState == MidiPlayerAnimationState.sidebar_circle
                    ? (widget.isPlaying ? 0.95 + (_bounceAnimation.value * 0.1) : 1.0)
                    : 1.0;

                return Transform.scale(
                  scale: hoverScale * bounceScale,
                  child: Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(-3, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: Material(
                        color: Colors.transparent,
                        child: showHeader
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header at top
                                  SizedBox(
                                    width: double.infinity,
                                    height: kMidiExpandedHeaderHeight,
                                    child: _buildHeader(colors),
                                  ),
                                  // Controls below header (scrollable if needed)
                                  if (showControls)
                                    Expanded(
                                      child: Opacity(
                                        opacity: controlsOpacity,
                                        child: SingleChildScrollView(
                                          child: _buildExpandedControls(context, colors),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : _buildCircleContent(colors),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _updateDragPosition(Offset delta) {
    final dx = delta.dx / (_screenWidth - kMidiCircleSize - kMidiCircleMargin * 2);
    final dy = -delta.dy / (_screenHeight * 0.75 - kMidiCircleMargin);

    setState(() {
      _sidebarX = (_sidebarX + dx).clamp(0.0, 1.0);
      _sidebarY = (_sidebarY + dy).clamp(0.0, 1.0);
    });
  }

  void _snapToEdge() {
    // Determine snap position based on current X
    final targetSnapX = _targetSnapX;

    if (targetSnapX != _sidebarX) {
      // Need to animate to new position
      setState(() {
        _sidebarX = targetSnapX;
      });
    }
  }

  Widget _buildCircleContent(ColorScheme colors) {
    // Circle content - music icon with pulse when playing
    return Center(
      child: Icon(
        Icons.queue_music_rounded,
        size: 28,
        color: colors.onPrimary,
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    // Floating header - tap to collapse
    return GestureDetector(
      onTap: () {
        if (_animationState == MidiPlayerAnimationState.expanded_player) {
          collapse();
        }
      },
      child: Container(
        width: double.infinity,
        height: kMidiExpandedHeaderHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    : widget.nowPlayingTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 12,
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 20,
              color: colors.onPrimary,
            ),
          ],
        ),
      ),
    );
  }

  
  /// Builds only the control panel (without header)
  /// Used for the part that appears below the morphed header
  Widget _buildExpandedControls(BuildContext context, ColorScheme colors) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMidiExpandedMaxWidth),
        child: Container(
          key: const ValueKey('midi-expanded'),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: ColoredBox(
                color: colors.surfaceContainerLowest.withValues(alpha: 0.82),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                            child: _MidiSeekSlider(
                              position: widget.position,
                              duration: widget.duration,
                              onSeek: widget.onSeek,
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
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 380;
                          final iconConstraints = BoxConstraints.tightFor(
                            width: compact ? 34 : 36,
                            height: compact ? 34 : 36,
                          );
                          final chordInfo =
                              (widget.runningFamilyChord
                                      ?.trim()
                                      .isNotEmpty ??
                                  false)
                                  ? widget.runningFamilyChord!.trim()
                                  : widget.currentKey;

                          Widget transposeControl = Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(8),
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
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: compact ? 120 : 150,
                                    maxWidth: compact ? 150 : 190,
                                  ),
                                  child: InkWell(
                                    key: const ValueKey(
                                      'midi-transpose-field',
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    onTap: () =>
                                        _showTransposeEditDialog(context),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compact ? 4 : 6,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${widget.transposeStep}',
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              chordInfo,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    color: colors
                                                        .onSurfaceVariant,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                  ),
                                            ),
                                          ),
                                          IconButton(
                                            constraints: iconConstraints,
                                            visualDensity:
                                                VisualDensity.compact,
                                            tooltip: 'Select key',
                                            onPressed:
                                                widget.availableKeys.isEmpty
                                                    ? null
                                                    : () => _showKeySelector(
                                                        context,
                                                      ),
                                            icon: const Icon(
                                              Icons.key_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
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
                              borderRadius: BorderRadius.circular(8),
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
                                    width: compact ? 30 : 44,
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transpose / Tempo / Instrument / Loop',
                                style: labelStyle,
                              ),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                key: const ValueKey('midi-control-row'),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    transposeControl,
                                    const SizedBox(width: 8),
                                    tempoControl,
                                    const SizedBox(width: 6),
                                    iconActions,
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Separate widget for MIDI seek slider to prevent rebuild issues.
/// This widget isolates the slider state to prevent jumping when
/// position updates from the audio engine.
class _MidiSeekSlider extends StatefulWidget {
  const _MidiSeekSlider({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  final double position;
  final double duration;
  final ValueChanged<double> onSeek;

  @override
  State<_MidiSeekSlider> createState() => _MidiSeekSliderState();
}

class _MidiSeekSliderState extends State<_MidiSeekSlider> {
  double? _dragSeekValue;
  double? _pendingSeekValue;

  @override
  void didUpdateWidget(_MidiSeekSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pending = _pendingSeekValue;
    if (pending != null &&
        (widget.duration <= 0 || (widget.position - pending).abs() <= 0.35)) {
      _pendingSeekValue = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _dragSeekValue ?? _pendingSeekValue ?? widget.position;
    final double sliderValue = widget.duration > 0
        ? value.clamp(0.0, widget.duration)
        : 0.0;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        trackHeight: 6,
      ),
      child: Slider(
        value: sliderValue,
        max: widget.duration > 0 ? widget.duration : 1,
        onChanged: widget.duration > 0
            ? (value) {
                setState(() => _dragSeekValue = value);
              }
            : null,
        onChangeEnd: widget.duration > 0
            ? (value) {
                setState(() {
                  _dragSeekValue = null;
                  _pendingSeekValue = value;
                });
                widget.onSeek(value);
              }
            : null,
      ),
    );
  }
}
