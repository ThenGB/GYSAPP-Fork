// ignore_for_file: constant_identifier_names
// Enum values use snake_case for readability (e.g., sidebar_circle, flying_to_player)
import 'dart:async';

import 'package:flutter/material.dart';

import '../cubit/song_playlist.dart';

// Animation timing
const Duration kMidiAnimationFlyDuration = Duration(milliseconds: 240);
const Duration kMidiAnimationMorphDuration = Duration(milliseconds: 240);
const Duration kMidiSnapDuration = Duration(milliseconds: 260);
const Duration kMidiDragPopDuration = Duration(milliseconds: 180);

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
const double kMidiExpandedHeaderHeight = 32.0;
const double kMidiExpandedControlsHeight = 88.0;
const double kMidiExpandedTotalHeight =
    kMidiExpandedHeaderHeight + kMidiExpandedControlsHeight + 2;
const double kMidiExpandedWidthRatio = 0.95;

// Collapsed (circle) dimensions
const double kMidiCircleSize = 48.0;
const double kMidiCircleMargin = 8.0;

// Drag pop-up scale when the user grabs the circle.
const double kMidiDragPopScale = 1.18;

/// Animation states for the MIDI player morphing system.
/// Follows a cycle:
///   sidebar_circle ↔ (flying_to_player) ↔ expanding_player ↔ expanded_player
///   expanded_player ↔ collapsing_player ↔ (flying_to_sidebar) ↔ sidebar_circle
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
  final String autoNextMode;
  final VoidCallback onPlayPause;
  final VoidCallback onLoopModeCycle;
  final ValueChanged<double> onSeek;
  final ValueChanged<int> onTranspose;
  final ValueChanged<String> onKeySelected;
  final ValueChanged<double> onTempo;
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
    this.autoNextMode = SongPlaylistAutoNextMode.off,
    required this.onPlayPause,
    required this.onLoopModeCycle,
    required this.onSeek,
    required this.onTranspose,
    required this.onKeySelected,
    required this.onTempo,
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
  MidiPlayerAnimationState _animationState =
      MidiPlayerAnimationState.expanded_player;

  // Position tracking for snap zones.  ValueNotifiers so drag updates
  // only rebuild the position-dependent parts of the widget tree (via
  // ValueListenableBuilder) instead of triggering a full State rebuild
  // on every pointer event.  This is what keeps the drag feeling smooth.
  final ValueNotifier<double> _sidebarX =
      ValueNotifier<double>(1.0); // 0 = left, 1 = right edge
  final ValueNotifier<double> _sidebarY =
      ValueNotifier<double>(0.5); // 0 = top, 1 = bottom (normalised)

  // Animation controllers
  late final AnimationController _flyController; // fly between sidebar ↔ player
  late final AnimationController _morphController; // morph circle ↔ player
  late final AnimationController _bounceController; // pulse when playing
  late final AnimationController _dragPopController; // pop-up while dragging

  late final Animation<double> _flyAnimation;
  late final Animation<double> _morphAnimation;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _dragPopAnimation;
  late final AnimationController _snapController;
  late final Animation<double> _snapAnimation;

  // Cached layout — recomputed only when MediaQuery or state changes, not per
  // animation frame.
  double _screenWidth = 0;
  double _screenHeight = 0;
  double _bottomInset = 0;
  double _playerLeft = 0;
  double _playerWidth = 0;

  // Drag state
  bool _isDragging = false;
  double _snapFromX = 0;
  double _snapFromY = 0;
  double _snapToX = 0;
  double _snapToY = 0;

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
    _dragPopController = AnimationController(
      duration: kMidiDragPopDuration,
      vsync: this,
    );
    _snapController = AnimationController(
      duration: kMidiSnapDuration,
      vsync: this,
    )..addStatusListener(_handleSnapStatus);
    _snapAnimation = CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic,
    );

    // Set up derived animations
    _flyAnimation = CurvedAnimation(
      parent: _flyController,
      curve: Curves.easeInOutCubic,
    );
    _morphAnimation = CurvedAnimation(
      parent: _morphController,
      curve: Curves.easeInOutCubic,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    // Slight overshoot makes the pop-up feel "popped" without feeling bouncy.
    _dragPopAnimation = Tween<double>(begin: 1.0, end: kMidiDragPopScale)
        .animate(
      CurvedAnimation(parent: _dragPopController, curve: Curves.easeOutBack),
    );

    // Determine initial state based on isExpanded
    final initiallyExpanded = widget.isExpanded ?? false;
    if (initiallyExpanded) {
      _animationState = MidiPlayerAnimationState.expanded_player;
      _flyController.value = 1.0;
      _morphController.value = 1.0;
    } else {
      _animationState = MidiPlayerAnimationState.sidebar_circle;
      _flyController.value = 0.0;
      _morphController.value = 0.0;
      if (widget.isPlaying) {
        _bounceController.repeat(reverse: true);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use targeted accessors instead of MediaQuery.of(context) so
    // keyboard open/close (which changes viewInsets) does not
    // invalidate the cached layout of the MIDI player surface.
    final c = context;
    _screenWidth = MediaQuery.sizeOf(c).width;
    _screenHeight = MediaQuery.sizeOf(c).height;
    _bottomInset = MediaQuery.viewPaddingOf(c).bottom;
    _playerLeft = (_screenWidth * (1 - kMidiExpandedWidthRatio)) / 2;
    _playerWidth = _screenWidth * kMidiExpandedWidthRatio;
  }

  void _handleTap() {
    // Stop any in-flight snap so the tap starts from the visible position.
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
        expand();
        break;
      case MidiPlayerAnimationState.flying_to_sidebar:
        // While flying to sidebar, cancel and expand
        _flyController.stop();
        expand();
        break;
      case MidiPlayerAnimationState.expanded_player:
        collapse();
        break;
      case MidiPlayerAnimationState.flying_to_player:
        // Cancel fly, morph directly back to sidebar circle.
        _flyController.stop();
        _animationState = MidiPlayerAnimationState.collapsing_player;
        _morphController.reverse(from: _morphController.value).then((_) {
          _animationState = MidiPlayerAnimationState.sidebar_circle;
          if (widget.isPlaying) {
            _bounceController.repeat(reverse: true);
          }
        });
        break;
      case MidiPlayerAnimationState.expanding_player:
      case MidiPlayerAnimationState.collapsing_player:
        // During morph - ignore
        break;
    }
  }

  @override
  void dispose() {
    _tempoDebounce?.cancel();
    _transposeDebounce?.cancel();
    _flyController.dispose();
    _morphController.dispose();
    _bounceController.dispose();
    _dragPopController.dispose();
    _snapController
      ..removeStatusListener(_handleSnapStatus)
      ..dispose();
    _sidebarX.dispose();
    _sidebarY.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DraggableMidiControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle external isExpanded changes
    if (widget.isExpanded != null &&
        oldWidget.isExpanded != widget.isExpanded) {
      if (widget.isExpanded!) {
        expand();
      } else {
        collapse();
      }
    }

    // Handle playing state changes for bounce animation
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying &&
          _animationState == MidiPlayerAnimationState.sidebar_circle) {
        _bounceController.repeat(reverse: true);
      } else {
        _bounceController.stop();
        _bounceController.value = 0;
      }
    }
  }

  void expand() {
    if (_animationState != MidiPlayerAnimationState.sidebar_circle &&
        _animationState != MidiPlayerAnimationState.flying_to_sidebar) {
      return;
    }
    _animationState = MidiPlayerAnimationState.flying_to_player;
    _bounceController.stop();
    _bounceController.value = 0;
    _dragPopController.reverse();
    widget.onExpandedChanged?.call(true);

    // Phase 1: Fly to player position (from sidebar, where the controller
    // was reset to 0 at the end of the previous collapse).
    _flyController.forward(from: 0).then((_) {
      if (!mounted) return;
      _animationState = MidiPlayerAnimationState.expanding_player;
      // Phase 2: Morph into player
      _morphController.forward(from: _morphController.value).then((_) {
        if (!mounted) return;
        _animationState = MidiPlayerAnimationState.expanded_player;
      });
    });
  }

  void collapse() {
    if (_animationState != MidiPlayerAnimationState.expanded_player &&
        _animationState != MidiPlayerAnimationState.expanding_player) {
      return;
    }
    _animationState = MidiPlayerAnimationState.collapsing_player;
    widget.onExpandedChanged?.call(false);

    _morphController.reverse(from: _morphController.value).then((_) {
      if (!mounted) return;
      // Reset the fly value to 0 BEFORE changing state so the first
      // frame of flying_to_sidebar reads flyValue=0 → lerp gives
      // player position (no jump to the sidebar).
      _flyController.value = 0;
      _animationState = MidiPlayerAnimationState.flying_to_sidebar;
      _flyController.forward().then((_) {
        if (!mounted) return;
        _animationState = MidiPlayerAnimationState.sidebar_circle;
        // Reset fly to 0 so the next expand can forward(from: 0) and
        // produce the full fly animation from sidebar to player.
        _flyController.value = 0;
        if (widget.isPlaying) {
          _bounceController.repeat(reverse: true);
        }
      });
    });
  }

  // === Position Calculation Helpers ===

  double get _screenCenterX => _screenWidth / 2;

  /// Target snap position (0 = left, 1 = right) based on current X
  double get _targetSnapX {
    if (_screenWidth <= 0) return _sidebarX.value;
    final actualLeft = kMidiCircleMargin +
        (_sidebarX.value *
            (_screenWidth - kMidiCircleSize - kMidiCircleMargin * 2));
    final centerX = actualLeft + (kMidiCircleSize / 2);
    return centerX < _screenCenterX ? 0.0 : 1.0;
  }

  /// Circle position when collapsed (sidebar) - half-circle at edges
  Offset get _sidebarPosition =>
      _sidebarPositionAt(_sidebarX.value, _sidebarY.value);

  /// Resolves the sidebar offset for arbitrary normalised coordinates.  Used
  /// by both [_sidebarPosition] (current state) and the snap animation
  /// (interpolated coordinates) so both share the same edge-snapping logic.
  Offset _sidebarPositionAt(double x, double y) {
    final halfSize = kMidiCircleSize / 2;
    const peek = 8.0;
    final sliderLeft = x * (_screenWidth - kMidiCircleSize);

    final left = x <= 0.03
        ? -halfSize + peek
        : x >= 0.97
            ? _screenWidth - halfSize - peek
            : sliderLeft.clamp(peek, _screenWidth - kMidiCircleSize - peek);

    final maxBottom = _screenHeight * 0.75;
    final minBottom = kMidiCircleMargin + _bottomInset;
    final bottom = minBottom + (y * (maxBottom - minBottom));

    return Offset(left, bottom);
  }

  Offset get _playerPosition => Offset(_playerLeft, 0);

  /// Left offset of the 48px circle when it is centered at the player's
  /// horizontal centre (screenWidth / 2).  Used as the morph/fly anchor so
  /// the collapsing circle stays centred instead of shrinking toward the
  /// left edge of the expanded player.
  Offset get _circleAtPlayerCenter =>
      Offset(_screenCenterX - kMidiCircleSize / 2, 0);

  Size get _playerSize => Size(_playerWidth, kMidiExpandedTotalHeight);

  Size get _circleSize => const Size(kMidiCircleSize, kMidiCircleSize);

  Offset get _currentPosition {
    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
        return _effectiveSidebarPosition;
      case MidiPlayerAnimationState.flying_to_player:
        return Offset.lerp(
            _effectiveSidebarPosition, _playerPosition, _flyAnimation.value)!;
      case MidiPlayerAnimationState.flying_to_sidebar:
        return Offset.lerp(
            _circleAtPlayerCenter, _effectiveSidebarPosition, _flyAnimation.value)!;
      case MidiPlayerAnimationState.expanding_player:
      case MidiPlayerAnimationState.expanded_player:
        return _playerPosition;
      case MidiPlayerAnimationState.collapsing_player:
        // Hold the CENTRE constant during the morph: derive left from the
        // current morphed width so the shape stays centred as it shrinks
        // from the full player down to the 48px circle.  Anchoring the
        // left edge at _playerLeft instead caused the circle to collapse
        // toward the left side of the screen before flying to the sidebar.
        final w = _currentSize.width;
        return Offset(_screenCenterX - w / 2, 0);
    }
  }

  /// When a snap-to-edge animation is in flight, interpolate from the snap
  /// start coordinates to the target.  Otherwise return the current sidebar
  /// position.  This lets the morph surface move without setState on each
  /// tick — the AnimatedBuilder already drives the rebuild.
  Offset get _effectiveSidebarPosition {
    if (_snapController.isAnimating ||
        (_snapController.value > 0 && _snapController.value < 1)) {
      final t = _snapAnimation.value;
      return _sidebarPositionAt(
        _snapFromX + (_snapToX - _snapFromX) * t,
        _snapFromY + (_snapToY - _snapFromY) * t,
      );
    }
    return _sidebarPosition;
  }

  Size get _currentSize {
    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
      case MidiPlayerAnimationState.flying_to_sidebar:
        return _circleSize;
      case MidiPlayerAnimationState.flying_to_player:
        return Size.lerp(_circleSize, _playerSize, _flyAnimation.value)!;
      case MidiPlayerAnimationState.expanding_player:
      case MidiPlayerAnimationState.expanded_player:
        return _playerSize;
      case MidiPlayerAnimationState.collapsing_player:
        return Size.lerp(_circleSize, _playerSize, _morphAnimation.value)!;
    }
  }

  BorderRadius get _currentBorderRadius {
    const circleRadius = kMidiCircleSize / 2;
    const expandedRadius = BorderRadius.all(Radius.circular(16));

    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
      case MidiPlayerAnimationState.flying_to_sidebar:
      case MidiPlayerAnimationState.flying_to_player:
        return const BorderRadius.all(Radius.circular(circleRadius));
      case MidiPlayerAnimationState.expanding_player:
        return BorderRadius.lerp(
          const BorderRadius.all(Radius.circular(circleRadius)),
          expandedRadius,
          _morphAnimation.value,
        )!;
      case MidiPlayerAnimationState.expanded_player:
        return expandedRadius;
      case MidiPlayerAnimationState.collapsing_player:
        // Morph 1.0 → 0.0 maps to expanded (16) → circle (24).  We must
        // pass them in that order so the corners go from rounded to
        // fully round as the panel shrinks; the previous ordering
        // produced the inverse (24 → 16) which looked like a flicker.
        return BorderRadius.lerp(
          expandedRadius,
          const BorderRadius.all(Radius.circular(circleRadius)),
          1 - _morphAnimation.value,
        )!;
    }
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _showInstrumentMenu(BuildContext context) async {
    // Kept for compatibility with the existing API; the surface itself renders
    // no instrument button in the rebuilt layout.  When instrument wiring is
    // re-introduced, restore the popup here.
  }

  void _adjustTempo(double newTempo) {
    _tempoDebounce?.cancel();
    _tempoDebounce = Timer(const Duration(milliseconds: 300), () {
      widget.onTempo(newTempo);
    });
    setState(() {});
  }

  void _adjustTranspose(int newTranspose) {
    _transposeDebounce?.cancel();
    _transposeDebounce = Timer(const Duration(milliseconds: 300), () {
      widget.onTranspose(_normalizeTranspose(newTranspose));
    });
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

    showDialog<void>(
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

    showDialog<void>(
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

    showModalBottomSheet<void>(
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // ValueListenableBuilder for the sidebar position.  Rebuilds only
        // the Positioned + GestureDetector subtree when the user drags,
        // keeping the drag feeling smooth even when the rest of the
        // widget tree is non-trivial.
        ValueListenableBuilder<double>(
          valueListenable: _sidebarX,
          builder: (context, sidebarX, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _sidebarY,
              builder: (context, sidebarY, _) {
                return AnimatedBuilder(
                  animation: Listenable.merge([
                    _flyController,
                    _morphController,
                    _bounceController,
                    _dragPopController,
                    _snapController,
                  ]),
                  builder: (context, _) {
            final position = _currentPosition;
            final size = _currentSize;
            final borderRadius = _currentBorderRadius;
                    final dragScale = _dragPopAnimation.value;
                    final bounceScale =
                        _animationState ==
                                MidiPlayerAnimationState.sidebar_circle
                            ? (widget.isPlaying
                                ? 0.95 +
                                    (_bounceAnimation.value * 0.1)
                                : 1.0)
                            : 1.0;
                    final showHeader = _animationState ==
                            MidiPlayerAnimationState.expanding_player ||
                        _animationState ==
                            MidiPlayerAnimationState.expanded_player;

                    return Positioned(
                      key: const ValueKey('midi-positioned'),
                      left: position.dx,
                      bottom: position.dy,
                      child: GestureDetector(
                        onTap: _handleTap,
                        onPanStart: _handlePanStart,
                        onPanUpdate: _handlePanUpdate,
                        onPanEnd: _handlePanEnd,
                        behavior: HitTestBehavior.opaque,
                        child: RepaintBoundary(
                          child: Transform.scale(
                            scale: dragScale * bounceScale,
                            child: _AnimatedMorphSurface(
                              size: size,
                              borderRadius: borderRadius,
                              colors: colors,
                              showHeader: showHeader,
                              headerBuilder: (_) => _buildHeader(colors),
                              controlsBuilder: (ctx) =>
                                  _buildExpandedControls(ctx, colors),
                              circleBuilder: (_) =>
                                  _buildCircleContent(colors),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _handlePanStart(DragStartDetails _) {
    if (_animationState != MidiPlayerAnimationState.sidebar_circle &&
        _animationState != MidiPlayerAnimationState.flying_to_sidebar) {
      return;
    }
    _isDragging = true;
    _flyController.stop();
    _flyController.value = 0;
    _bounceController.stop();
    // Cancel any in-flight snap so the drag starts from the visible point.
    if (_snapController.isAnimating) _snapController.stop();
    // Pop-up: smoothly scales the circle while the user is holding it.
    _dragPopController.forward(from: _dragPopController.value);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_animationState == MidiPlayerAnimationState.expanded_player) {
      if (details.delta.dy < -12) collapse();
      return;
    }
    if (_isDragging) {
      _updateDragPosition(details.delta);
    }
  }

  void _handlePanEnd(DragEndDetails _) {
    if (!_isDragging) return;
    _isDragging = false;
    // Release pop-up (snaps back to normal size).
    _dragPopController.reverse();
    _snapToEdge();
  }

  void _updateDragPosition(Offset delta) {
    if (_screenWidth <= 0 || _screenHeight <= 0) return;
    final dx = delta.dx /
        (_screenWidth - kMidiCircleSize - kMidiCircleMargin * 2);
    final dy = delta.dy / (_screenHeight * 0.75 - kMidiCircleMargin);

    _sidebarX.value = (_sidebarX.value + dx).clamp(0.0, 1.0);
    _sidebarY.value = (_sidebarY.value + dy).clamp(0.0, 1.0);
  }

  void _handleSnapStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Commit the snap target to the persistent coordinates so subsequent
      // animations (expand/collapse) start from the correct snap point.
      _sidebarX.value = _snapToX;
      _sidebarY.value = _snapToY;
    }
  }

  /// Animates [_sidebarX] to the snap target (closest horizontal edge)
  /// while preserving [_sidebarY] so the circle stays where the user
  /// released it vertically.
  void _snapToEdge() {
    if (_screenWidth <= 0) return;
    final targetX = _targetSnapX;
    if (targetX == _sidebarX.value) return;

    _snapFromX = _sidebarX.value;
    _snapFromY = _sidebarY.value;
    _snapToX = targetX;
    _snapToY = _sidebarY.value; // preserve the user's release Y

    // Reuse a single controller; cancelling mid-animation is fine because
    // `forward(from: 0)` restarts cleanly.
    _snapController
      ..stop()
      ..value = 0
      ..forward();
  }

  Widget _buildCircleContent(ColorScheme colors) {
    return Center(
      child: Icon(
        Icons.queue_music_rounded,
        size: 22,
        color: colors.onPrimary,
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return GestureDetector(
      onTap: () {
        if (_animationState == MidiPlayerAnimationState.expanded_player) {
          collapse();
        }
      },
      child: SizedBox(
        width: double.infinity,
        height: kMidiExpandedHeaderHeight,
        child: Padding(
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
      ),
    );
  }

  /// Builds only the control panel (without header)
  /// Used for the part that appears below the morphed header
  Widget _buildExpandedControls(BuildContext context, ColorScheme colors) {
    return Container(
      key: const ValueKey('midi-expanded'),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
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
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: ColoredBox(
          color: colors.surfaceContainerLowest.withValues(alpha: 0.92),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTopRow(context, colors),
                const SizedBox(height: 6),
                _buildBottomRow(context, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context, ColorScheme colors) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: FilledButton(
            onPressed: widget.isLoading ? null : widget.onPlayPause,
            style: FilledButton.styleFrom(
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: colors.primary,
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                    ),
                  )
                : Icon(
                    widget.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: colors.onPrimary,
                    size: 20,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MidiSeekSlider(
            position: widget.position,
            duration: widget.duration,
            onSeek: widget.onSeek,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${_formatTime(widget.position)} / ${_formatTime(widget.duration)}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                letterSpacing: 0.1,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomRow(BuildContext context, ColorScheme colors) {
    final chordInfo = (widget.runningFamilyChord?.trim().isNotEmpty ?? false)
        ? widget.runningFamilyChord!.trim()
        : widget.currentKey;
    const boxHeight = 32.0;

    return SizedBox(
      height: boxHeight,
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: _buildTransposeControl(context, colors, boxHeight),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 2,
            child: _buildKeyControl(context, colors, chordInfo, boxHeight),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 3,
            child: _buildTempoControl(context, colors, boxHeight),
          ),
          _buildIconActions(colors),
        ],
      ),
    );
  }

  Widget _buildTransposeControl(
    BuildContext context,
    ColorScheme colors,
    double boxHeight,
  ) {
    return _Pill(
      height: boxHeight,
      colors: colors,
      children: [
        _CompactIconButton(
          onPressed: () => _adjustTranspose(widget.transposeStep - 1),
          icon: Icons.remove_rounded,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showTransposeEditDialog(context),
            child: Container(
              key: const ValueKey('midi-transpose-field'),
              alignment: Alignment.center,
              child: Text(
                '${widget.transposeStep}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        _CompactIconButton(
          onPressed: () => _adjustTranspose(widget.transposeStep + 1),
          icon: Icons.add_rounded,
        ),
      ],
    );
  }

  Widget _buildKeyControl(
    BuildContext context,
    ColorScheme colors,
    String chordInfo,
    double boxHeight,
  ) {
    return GestureDetector(
      onTap: widget.availableKeys.isEmpty
          ? null
          : () => _showKeySelector(context),
      child: _Pill(
        height: boxHeight,
        colors: colors,
        children: [
          Icon(Icons.key_rounded, size: 16, color: colors.onSurfaceVariant),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              chordInfo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTempoControl(
    BuildContext context,
    ColorScheme colors,
    double boxHeight,
  ) {
    return _Pill(
      height: boxHeight,
      colors: colors,
      children: [
        _CompactIconButton(
          onPressed: () => _adjustTempo((widget.tempoBpm - 1).clamp(30, 300)),
          icon: Icons.remove_rounded,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _showTempoEditDialog(context),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '${widget.tempoBpm.round()}',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ),
        _CompactIconButton(
          onPressed: () => _adjustTempo((widget.tempoBpm + 1).clamp(30, 300)),
          icon: Icons.add_rounded,
        ),
      ],
    );
  }

  Widget _buildIconActions(ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          key: _instrumentButtonKey,
          width: 28,
          height: 28,
          child: InkResponse(
            onTap: () => _showInstrumentMenu(context),
            radius: 16,
            child: Icon(
              Icons.piano_rounded,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: 28,
          height: 28,
          child: InkResponse(
            onTap: widget.onLoopModeCycle,
            radius: 16,
            child: Tooltip(
              message: midiLoopModeTooltip(widget.autoNextMode),
              child: Icon(
                midiLoopModeIcon(widget.autoNextMode),
                size: 18,
                color: midiLoopModeActive(widget.autoNextMode)
                    ? colors.primary
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The morphing surface that interpolates between the sidebar circle
/// and the expanded player.  It is responsible only for layout/paint
/// changes driven by the animation (size, border radius) — the static
/// content (header, controls, circle icon) is built once per `showHeader`
/// transition, never on every animation tick.
class _AnimatedMorphSurface extends StatelessWidget {
  const _AnimatedMorphSurface({
    required this.size,
    required this.borderRadius,
    required this.colors,
    required this.showHeader,
    required this.headerBuilder,
    required this.controlsBuilder,
    required this.circleBuilder,
  });

  final Size size;
  final BorderRadius borderRadius;
  final ColorScheme colors;
  final bool showHeader;
  final Widget Function(BuildContext) headerBuilder;
  final Widget Function(BuildContext) controlsBuilder;
  final Widget Function(BuildContext) circleBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.primary,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 12,
                offset: Offset(-3, 5),
              ),
            ],
          ),
          child: _MorphContent(
            showHeader: showHeader,
            headerBuilder: headerBuilder,
            controlsBuilder: controlsBuilder,
            circleBuilder: circleBuilder,
          ),
        ),
      ),
    );
  }
}

/// Holds the last-built content tree so the heavy controls subtree
/// is not rebuilt on every animation frame.  The subtree is only
/// rebuilt when `showHeader` actually flips, which happens once per
/// expand/collapse rather than ~26 times per animation.
class _MorphContent extends StatefulWidget {
  const _MorphContent({
    required this.showHeader,
    required this.headerBuilder,
    required this.controlsBuilder,
    required this.circleBuilder,
  });

  final bool showHeader;
  final Widget Function(BuildContext) headerBuilder;
  final Widget Function(BuildContext) controlsBuilder;
  final Widget Function(BuildContext) circleBuilder;

  @override
  State<_MorphContent> createState() => _MorphContentState();
}

class _MorphContentState extends State<_MorphContent> {
  late Widget _content = _buildFor(widget.showHeader);

  @override
  void didUpdateWidget(covariant _MorphContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showHeader != widget.showHeader) {
      _content = _buildFor(widget.showHeader);
    }
  }

  Widget _buildFor(bool showHeader) {
    if (!showHeader) {
      return Material(
        color: Colors.transparent,
        child: widget.circleBuilder(context),
      );
    }
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: kMidiExpandedHeaderHeight,
            child: widget.headerBuilder(context),
          ),
          SizedBox(
            height: kMidiExpandedControlsHeight,
            child: widget.controlsBuilder(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _content;
}

/// Common 28×28 compact tap target used throughout the controls row.
class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 16,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Icon(icon, size: 18),
      ),
    );
  }
}

/// Pill-shaped surface used for transpose/key/tempo controls.
class _Pill extends StatelessWidget {
  const _Pill({
    required this.colors,
    required this.children,
    required this.height,
  });

  final ColorScheme colors;
  final List<Widget> children;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
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

  // Cached theme — avoids re-creating SliderThemeData on every tick.
  SliderThemeData? _sliderTheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sliderTheme = SliderTheme.of(context).copyWith(
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      trackHeight: 6,
    );
  }

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
    final sliderValue = widget.duration > 0
        ? value.clamp(0.0, widget.duration)
        : 0.0;

    final theme = _sliderTheme;
    final slider = Slider(
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
    );

    return theme == null ? slider : SliderTheme(data: theme, child: slider);
  }
}
