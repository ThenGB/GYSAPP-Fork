import '../../../components/components.dart';
// ignore_for_file: constant_identifier_names
// Enum values use snake_case for readability (e.g., sidebar_circle, flying_to_player)
import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/midi_engine_service.dart';
import '../cubit/song_playlist.dart';

// Animation timing
const Duration kMidiAnimationFlyDuration = Duration(milliseconds: 240);
const Duration kMidiAnimationMorphDuration = Duration(milliseconds: 240);
const Duration kMidiSnapDuration = Duration(milliseconds: 260);
const Duration kMidiDragPopDuration = Duration(milliseconds: 180);

const double kMidiOverlayHorizontalMargin = 16;
const double kMidiOverlayBottomOffset = 0;
// The dashboard dock now owns real scaffold space, so the player only needs
// a small breathing gap from the bottom edge of the content viewport.
const double kMidiNavBarReserve = 12;
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

/// Sidebar button width: taller than a circle — a long pill whose ends are
/// half-circles (radius = height/2 = 24) so it reads as a docked tab.
const double kMidiSidebarWidth = 64.0;
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

/// A single General MIDI instrument entry shown in the instrument picker.
class MidiInstrumentOption {
  const MidiInstrumentOption(this.program, this.label);
  final int program;
  final String label;
}

/// Curated subset of the General MIDI instrument list grouped by family.
/// Includes the patches most commonly used for congregational song
/// accompaniment so the picker stays short and easy to scan.
const List<MidiInstrumentFamily> kMidiInstrumentFamilies = [
  MidiInstrumentFamily('Default', [
    MidiInstrumentOption(-1, 'Default (Acoustic Grand Piano)'),
  ]),
  MidiInstrumentFamily('Piano', [
    MidiInstrumentOption(0, 'Acoustic Grand Piano'),
    MidiInstrumentOption(1, 'Bright Acoustic Piano'),
    MidiInstrumentOption(2, 'Electric Grand Piano'),
    MidiInstrumentOption(4, 'Electric Piano 1'),
    MidiInstrumentOption(5, 'Electric Piano 2'),
    MidiInstrumentOption(6, 'Harpsichord'),
  ]),
  MidiInstrumentFamily('Organ', [
    MidiInstrumentOption(16, 'Drawbar Organ'),
    MidiInstrumentOption(19, 'Church Organ'),
    MidiInstrumentOption(20, 'Reed Organ'),
  ]),
  MidiInstrumentFamily('Guitar', [
    MidiInstrumentOption(24, 'Nylon Guitar'),
    MidiInstrumentOption(25, 'Steel Guitar'),
    MidiInstrumentOption(26, 'Jazz Guitar'),
    MidiInstrumentOption(27, 'Clean Electric'),
    MidiInstrumentOption(28, 'Muted Electric'),
    MidiInstrumentOption(29, 'Overdriven'),
    MidiInstrumentOption(30, 'Distortion'),
  ]),
  MidiInstrumentFamily('Bass', [
    MidiInstrumentOption(32, 'Acoustic Bass'),
    MidiInstrumentOption(33, 'Fingered Bass'),
    MidiInstrumentOption(34, 'Picked Bass'),
    MidiInstrumentOption(36, 'Slap Bass 1'),
    MidiInstrumentOption(39, 'Synth Bass 1'),
  ]),
  MidiInstrumentFamily('Strings', [
    MidiInstrumentOption(40, 'Violin'),
    MidiInstrumentOption(41, 'Viola'),
    MidiInstrumentOption(42, 'Cello'),
    MidiInstrumentOption(46, 'Orchestral Harp'),
    MidiInstrumentOption(48, 'String Ensemble'),
  ]),
  MidiInstrumentFamily('Brass', [
    MidiInstrumentOption(56, 'Trumpet'),
    MidiInstrumentOption(57, 'Trombone'),
    MidiInstrumentOption(58, 'Tuba'),
    MidiInstrumentOption(60, 'French Horn'),
    MidiInstrumentOption(61, 'Brass Section'),
  ]),
  MidiInstrumentFamily('Reed / Sax', [
    MidiInstrumentOption(65, 'Alto Sax'),
    MidiInstrumentOption(66, 'Tenor Sax'),
    MidiInstrumentOption(67, 'Baritone Sax'),
    MidiInstrumentOption(68, 'Oboe'),
    MidiInstrumentOption(71, 'Clarinet'),
  ]),
  MidiInstrumentFamily('Flute', [
    MidiInstrumentOption(72, 'Piccolo'),
    MidiInstrumentOption(73, 'Flute'),
    MidiInstrumentOption(74, 'Recorder'),
    MidiInstrumentOption(75, 'Pan Flute'),
  ]),
  MidiInstrumentFamily('Synth', [
    MidiInstrumentOption(80, 'Square Lead'),
    MidiInstrumentOption(81, 'Sawtooth Lead'),
    MidiInstrumentOption(88, 'New Age Pad'),
    MidiInstrumentOption(89, 'Warm Pad'),
    MidiInstrumentOption(90, 'Polysynth Pad'),
    MidiInstrumentOption(91, 'Choir Pad'),
  ]),
];

class MidiInstrumentFamily {
  const MidiInstrumentFamily(this.label, this.options);
  final String label;
  final List<MidiInstrumentOption> options;
}

String midiInstrumentLabel(int? program) {
  if (program == null || program < 0) {
    return 'Default (Acoustic Grand Piano)';
  }
  for (final family in kMidiInstrumentFamilies) {
    for (final option in family.options) {
      if (option.program == program) return option.label;
    }
  }
  return 'Program $program';
}

/// Fixed-bottom MIDI control panel styled to match the Stitch reference.
class DraggableMidiControls extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final double position;
  final double duration;

  /// Optional MIDI playback state stream.  When provided, the widget
  /// subscribes internally and drives the seek slider from a
  /// [ValueListenable] so position ticks (every 250 ms during playback)
  /// do NOT trigger a full widget rebuild.  Only the seek slider and
  /// its position label rebuild; the rest of the player stays put.
  final Stream<MidiPlaybackState>? stateStream;

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

  /// Currently selected MIDI instrument program (null = default / GM patch 0).
  final int? midiInstrument;

  /// Called when the user picks an instrument from the popup.  Pass `null`
  /// to reset to the default instrument.
  final ValueChanged<int?>? onMidiInstrument;

  /// When provided the panel's expand/collapse state is controlled externally
  /// (e.g. by the Dashboard which needs the height for layout calculations).
  final bool? isExpanded;
  final ValueChanged<bool>? onExpandedChanged;

  /// Optional prev/next song callbacks; shown in the expanded panel when set.
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;

  /// Chord viewer control: toggle chord overlay visibility from the panel.
  final bool showChord;
  final bool chordToggleEnabled;
  final VoidCallback? onToggleChord;

  /// Accidental mode (sharp ♯ / flat ♭) for transposed chord display —
  /// mirror of gyschordweb's transpose accidental switch.
  final String chordAccidentalMode;
  final VoidCallback? onToggleAccidental;

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
    this.stateStream,
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
    this.midiInstrument,
    this.onMidiInstrument,
    this.isExpanded,
    this.onExpandedChanged,
    this.onPreviousSong,
    this.onNextSong,
    this.showChord = false,
    this.chordToggleEnabled = true,
    this.onToggleChord,
    this.chordAccidentalMode = ChordService.accidentalSharp,
    this.onToggleAccidental,
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

  // === Position / Duration streaming ===
  //
  // The MIDI engine pushes a new MidiPlaybackState every 250 ms while
  // playing.  Forwarding that stream to the parent as a widget prop would
  // force a full DraggableMidiControls rebuild 4 times per second.  Instead
  // we subscribe internally and publish only the fields that drive the
  // seek slider / time label — the rest of the player does not see the
  // ticks.  didUpdateWidget still re-syncs the notifiers when the parent
  // hands us a new initial value (e.g. after a song change).
  final ValueNotifier<double> _positionNotifier = ValueNotifier<double>(0);
  final ValueNotifier<double> _durationNotifier = ValueNotifier<double>(0);
  StreamSubscription<MidiPlaybackState>? _stateSub;

  // === Animation State Machine ===
  MidiPlayerAnimationState _animationState =
      MidiPlayerAnimationState.expanded_player;

  // Position tracking for snap zones.  ValueNotifiers so drag updates
  // only rebuild the position-dependent parts of the widget tree (via
  // ValueListenableBuilder) instead of triggering a full State rebuild
  // on every pointer event.  This is what keeps the drag feeling smooth.
  final ValueNotifier<double> _sidebarX = ValueNotifier<double>(
    1.0,
  ); // 0 = left, 1 = right edge
  final ValueNotifier<double> _sidebarY = ValueNotifier<double>(
    0.5,
  ); // 0 = top, 1 = bottom (normalised)

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

  /// Monotonic counter bumped every time the parent rebuilds for a
  /// reason that affects the controls' content (state change, theme
  /// change, MediaQuery change).  _MorphContent reads this to know
  /// when to invalidate its cached subtree so that the closures
  /// (`headerBuilder`, `controlsBuilder`, `circleBuilder`) capture the
  /// latest state.
  ///
  /// Animation frames do NOT bump this counter: the parent itself
  /// is not rebuilt during animation (only the AnimatedBuilder's
  /// `builder` callback fires), so the cached content survives the
  /// ~14 frame rebuilds that happen during a 240 ms expand/collapse
  /// animation.
  int _contentVersion = 0;

  // Drag state
  bool _isDragging = false;
  double _snapFromX = 0;
  double _snapFromY = 0;
  double _snapToX = 0;
  double _snapToY = 0;

  // Debounce timers
  // (No local debounce anymore — the cubit coalesces the actual engine
  // update, and the displayed value comes from the parent rebuild
  // triggered by the cubit emit, so the visible number updates on the
  // next frame without any per-press setState or timer.)

  @override
  void initState() {
    super.initState();

    // Seed the notifiers with the initial values and start listening to
    // the engine's state stream.  Subsequent ticks update the notifiers
    // (cheap; the seek slider is the only listener) without rebuilding
    // the rest of the player.
    _positionNotifier.value = widget.position;
    _durationNotifier.value = widget.duration;
    final stream = widget.stateStream;
    if (stream != null) {
      _stateSub = stream.listen(_onMidiPlaybackState);
    }

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
      // Slight overshoot so the pill "clicks" into the dock edge instead
      // of easing to a dead stop.
      curve: Curves.easeOutBack,
    );

    // Set up derived animations
    _flyAnimation = CurvedAnimation(
      parent: _flyController,
      // Ease-out departure: the circle leaves quickly and decelerates into
      // its landing, which reads far smoother than a symmetric ease-in-out.
      curve: Curves.easeOutCubic,
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
          CurvedAnimation(
            parent: _dragPopController,
            curve: Curves.easeOutBack,
          ),
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

  void _onMidiPlaybackState(MidiPlaybackState s) {
    // Only republish when the value actually changes.  ValueNotifier
    // de-duplicates equal values, but the early-return saves the
    // round-trip through the listener chain.
    if (_positionNotifier.value != s.position) {
      _positionNotifier.value = s.position;
    }
    if (_durationNotifier.value != s.duration) {
      _durationNotifier.value = s.duration;
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
    // Theme/MediaQuery change — cached content may now reference
    // stale colors, so invalidate it.
    _contentVersion++;
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
    _stateSub?.cancel();
    _flyController.dispose();
    _morphController.dispose();
    _bounceController.dispose();
    _dragPopController.dispose();
    _snapController
      ..removeStatusListener(_handleSnapStatus)
      ..dispose();
    _sidebarX.dispose();
    _sidebarY.dispose();
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DraggableMidiControls oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Resubscribe if the stream identity changed.  Listen handles null
    // gracefully so this is safe even when the parent doesn't supply a
    // stream (e.g. widget tests).
    if (!identical(oldWidget.stateStream, widget.stateStream)) {
      _stateSub?.cancel();
      final stream = widget.stateStream;
      _stateSub = stream?.listen(_onMidiPlaybackState);
    }

    // Sync the notifiers when the parent hands us new initial values.
    // We only override the notifier when its current value still matches
    // the previous prop — if the stream has already pushed a fresher
    // value, leave it alone so we don't fight the live feed.
    if (oldWidget.position != widget.position &&
        _positionNotifier.value == oldWidget.position) {
      _positionNotifier.value = widget.position;
    }
    if (oldWidget.duration != widget.duration &&
        _durationNotifier.value == oldWidget.duration) {
      _durationNotifier.value = widget.duration;
    }

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

    // State changed at the parent level — invalidate the cached
    // _MorphContent subtree so the closures capture the new state.
    // Animation frames do not call this method, so the cache still
    // survives morph/fly transitions.
    _contentVersion++;
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

    // Phase 1: Fly to player position. The morph starts just before
    // landing (overlap) so the circle grows while still in transit —
    // one continuous motion instead of two sequential phases.
    _flyController.forward(from: 0);
    Future<void>.delayed(
      kMidiAnimationFlyDuration - const Duration(milliseconds: 60),
      () {
        if (!mounted ||
            _animationState != MidiPlayerAnimationState.flying_to_player) {
          return;
        }
        _animationState = MidiPlayerAnimationState.expanding_player;
        _morphController.forward(from: _morphController.value).then((_) {
          if (!mounted ||
              _animationState != MidiPlayerAnimationState.expanding_player) {
            return;
          }
          _animationState = MidiPlayerAnimationState.expanded_player;
        });
      },
    );
  }

  void collapse() {
    if (_animationState != MidiPlayerAnimationState.expanded_player &&
        _animationState != MidiPlayerAnimationState.expanding_player) {
      return;
    }
    // Three gentle phases instead of a rough parallel motion:
    //   1. Content swaps to the circle icon instantly (no squashing).
    //   2. The surface shrinks in place at the player slot (never dipping
    //      toward the nav bar — the slot sits above the dock).
    //   3. The circle glides to the sidebar button with an ease-out.
    _animationState = MidiPlayerAnimationState.collapsing_player;
    widget.onExpandedChanged?.call(false);

    _morphController.reverse(from: _morphController.value).then((_) {
      if (!mounted ||
          _animationState != MidiPlayerAnimationState.collapsing_player) {
        return;
      }
      _animationState = MidiPlayerAnimationState.flying_to_sidebar;
      _flyController.value = 0;
      _flyController.forward().then((_) {
        if (!mounted) return;
        _animationState = MidiPlayerAnimationState.sidebar_circle;
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
    final actualLeft =
        kMidiCircleMargin +
        (_sidebarX.value *
            (_screenWidth - kMidiSidebarWidth - kMidiCircleMargin * 2));
    final centerX = actualLeft + (kMidiSidebarWidth / 2);
    return centerX < _screenCenterX ? 0.0 : 1.0;
  }

  /// Circle position when collapsed (sidebar) - half-circle at edges
  Offset get _sidebarPosition =>
      _sidebarPositionAt(_sidebarX.value, _sidebarY.value);

  /// Resolves the sidebar offset for arbitrary normalised coordinates.  Used
  /// by both [_sidebarPosition] (current state) and the snap animation
  /// (interpolated coordinates) so both share the same edge-snapping logic.
  Offset _sidebarPositionAt(double x, double y) {
    final halfWidth = kMidiSidebarWidth / 2;
    const peek = 8.0;
    final sliderLeft = x * (_screenWidth - kMidiSidebarWidth);

    final left = x <= 0.03
        ? -halfWidth + peek
        : x >= 0.97
        ? _screenWidth - halfWidth - peek
        : sliderLeft
            .clamp(peek, _screenWidth - kMidiSidebarWidth - peek)
            .toDouble();

    final maxBottom = _screenHeight * 0.75;
    final minBottom = kMidiCircleMargin + _bottomInset + kMidiNavBarReserve;
    final bottom = minBottom + (y * (maxBottom - minBottom));

    return Offset(left, bottom);
  }

  Offset get _playerPosition => Offset(_playerLeft, kMidiNavBarReserve);

  Size get _playerSize => Size(_playerWidth, kMidiExpandedTotalHeight);

  /// Sidebar button: a long pill (half-circle ends, 64×48) so it reads as
  /// a docked tab rather than a plain circle.
  Size get _sidebarSize => const Size(kMidiSidebarWidth, kMidiCircleSize);

  Offset get _currentPosition {
    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
        return _effectiveSidebarPosition;
      case MidiPlayerAnimationState.flying_to_player:
        return Offset.lerp(
          _effectiveSidebarPosition,
          _playerPosition,
          _flyAnimation.value,
        )!;
      case MidiPlayerAnimationState.flying_to_sidebar:
        // Depart from the player slot itself and travel straight to the
        // sidebar button while shrinking — one continuous motion, never
        // dipping toward the nav bar.
        return Offset.lerp(
          _playerPosition,
          _effectiveSidebarPosition,
          _flyAnimation.value,
        )!;
      case MidiPlayerAnimationState.expanding_player:
      case MidiPlayerAnimationState.expanded_player:
        return _playerPosition;
      case MidiPlayerAnimationState.collapsing_player:
        // Tap-cancel during expand: morph back at the player slot (nav-bar
        // reserve, never under the dock).
        return _playerPosition;
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
        return _sidebarSize;
      case MidiPlayerAnimationState.flying_to_sidebar:
        // Morph already finished before the fly — the pill is small.
        return _sidebarSize;
      case MidiPlayerAnimationState.flying_to_player:
        // Keep the pill shape while in transit; only the position moves.
        // The shape morphs exclusively at the player slot, which reads as a
        // clean "fly then bloom" instead of a blob growing mid-flight.
        return _sidebarSize;
      case MidiPlayerAnimationState.expanding_player:
        // Bloom: the surface grows from pill to full player as it lands
        // (morph 0→1). Without this, the size jumped to the full player
        // instantly — a hard "pop" instead of an animated maximize.
        return Size.lerp(_sidebarSize, _playerSize, _morphAnimation.value)!;
      case MidiPlayerAnimationState.expanded_player:
        return _playerSize;
      case MidiPlayerAnimationState.collapsing_player:
        return Size.lerp(_sidebarSize, _playerSize, _morphAnimation.value)!;
    }
  }

  BorderRadius get _currentBorderRadius {
    // Half-circle pill ends: radius = height / 2 (24).
    const pillRadius = kMidiCircleSize / 2;
    const expandedRadius = BorderRadius.all(Radius.circular(16));

    switch (_animationState) {
      case MidiPlayerAnimationState.sidebar_circle:
      case MidiPlayerAnimationState.flying_to_sidebar:
      case MidiPlayerAnimationState.flying_to_player:
        return const BorderRadius.all(Radius.circular(pillRadius));
      case MidiPlayerAnimationState.expanding_player:
        return BorderRadius.lerp(
          const BorderRadius.all(Radius.circular(pillRadius)),
          expandedRadius,
          _morphAnimation.value,
        )!;
      case MidiPlayerAnimationState.expanded_player:
        return expandedRadius;
      case MidiPlayerAnimationState.collapsing_player:
        // Morph 1.0 → 0.0 maps to expanded (16) → pill (24).  We must
        // pass them in that order so the corners go from rounded to
        // fully round as the panel shrinks; the previous ordering
        // produced the inverse (24 → 16) which looked like a flicker.
        return BorderRadius.lerp(
          expandedRadius,
          const BorderRadius.all(Radius.circular(pillRadius)),
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
    final onSelected = widget.onMidiInstrument;
    if (onSelected == null) return;

    // Matches the key-selector style: a bottom sheet grouped by family
    // with a flat, scrollable list of options.  Touch-friendly on
    // phones and easier to scan than the previous popup menu.
    final picked = await showModalBottomSheet<int?>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  'Pilih Instrumen',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: kMidiInstrumentFamilies.length,
                  itemBuilder: (context, fi) {
                    final family = kMidiInstrumentFamilies[fi];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                          child: Text(
                            family.label.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        for (final option in family.options)
                          ListTile(
                            dense: true,
                            title: Text(option.label),
                            trailing: widget.midiInstrument == option.program
                                ? Icon(
                                    Icons.check_rounded,
                                    color: colors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(
                              sheetContext,
                            ).pop(option.program == -1 ? null : option.program),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      onSelected(picked);
    }
  }

  void _adjustTempo(double newTempo) {
    // Forward immediately.  The cubit's own 250 ms debounce coalesces
    // the actual engine update for rapid +/- presses, so a local
    // debounce here would only delay the displayed value (and the
    // setState that previously guarded it was a no-op — the visible
    // number comes from widget.tempoBpm, which the parent provides).
    widget.onTempo(newTempo);
  }

  void _adjustTranspose(int newTranspose) {
    // See _adjustTempo for rationale on no local debounce.
    widget.onTranspose(_normalizeTranspose(newTranspose));
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
        title: Text('edit_transpose_title'.tr()),
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
            child: Text('Batal'.tr()),
          ),
          TextButton(
            onPressed: () {
              final transpose = int.tryParse(controller.text);
              if (transpose != null) {
                widget.onTranspose(_normalizeTranspose(transpose));
              }
              Navigator.pop(context);
            },
            child: Text('Simpan'.tr()),
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
        title: Text('edit_tempo_title'.tr()),
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
              widget.onTempo(tempo.clamp(30, 300).toDouble());
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'.tr()),
          ),
          TextButton(
            onPressed: () {
              final tempo = double.tryParse(controller.text);
              if (tempo != null) {
                widget.onTempo(tempo.clamp(30, 300).toDouble());
              }
              Navigator.pop(context);
            },
            child: Text('Simpan'.tr()),
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
                              ? 0.95 + (_bounceAnimation.value * 0.1)
                              : 1.0)
                        : 1.0;
                    final showHeader =
                        _animationState ==
                            MidiPlayerAnimationState.expanding_player ||
                        _animationState ==
                            MidiPlayerAnimationState.expanded_player;

                    final canInteractWithDock =
                        _animationState ==
                            MidiPlayerAnimationState.sidebar_circle ||
                        _animationState ==
                            MidiPlayerAnimationState.flying_to_sidebar;
                    return Positioned(
                      key: const ValueKey('midi-positioned'),
                      left: position.dx,
                      bottom: position.dy,
                      child: GestureDetector(
                        onTap: canInteractWithDock ? _handleTap : null,
                        onPanStart: canInteractWithDock
                            ? _handlePanStart
                            : null,
                        onPanUpdate: canInteractWithDock
                            ? _handlePanUpdate
                            : null,
                        onPanEnd: canInteractWithDock ? _handlePanEnd : null,
                        behavior: HitTestBehavior.opaque,
                        child: RepaintBoundary(
                          child: Transform.scale(
                            scale: dragScale * bounceScale,
                            child: _AnimatedMorphSurface(
                              size: size,
                              fullSize: _playerSize,
                              borderRadius: borderRadius,
                              colors: colors,
                              showHeader: showHeader,
                              contentVersion: _contentVersion,
                              headerBuilder: (_) => _buildHeader(colors),
                              controlsBuilder: (ctx) =>
                                  _buildExpandedControls(ctx, colors),
                              circleBuilder: (_) => _buildCircleContent(colors),
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

  void _handlePanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;
    // Release pop-up: reverse so the circle settles back down smoothly.
    _dragPopController.reverse();
    // Velocity-based fling if the user flicked toward an edge.
    final velocityX = details.velocity.pixelsPerSecond.dx;
    if (velocityX.abs() > 200 && _screenWidth > 0) {
      final targetX = velocityX > 0 ? 1.0 : 0.0;
      _snapFromX = _sidebarX.value;
      _snapFromY = _sidebarY.value;
      _snapToX = targetX;
      _snapToY = _sidebarY.value;
      _snapController
        ..stop()
        ..value = 0
        ..forward();
    } else {
      _snapToEdge();
    }
  }

  void _updateDragPosition(Offset delta) {
    if (_screenWidth <= 0 || _screenHeight <= 0) return;
    final dx =
        delta.dx / (_screenWidth - kMidiSidebarWidth - kMidiCircleMargin * 2);
    // Negate dy because Positioned.bottom measures from the bottom of the
    // parent, while drag deltas use screen coordinates (y grows downward).
    // Without negation, dragging up moves the circle down (inverted).
    final dy = -delta.dy / (_screenHeight * 0.75 - kMidiCircleMargin);

    _sidebarX.value = (_sidebarX.value + dx).clamp(0.0, 1.0).toDouble();
    _sidebarY.value = (_sidebarY.value + dy).clamp(0.0, 1.0).toDouble();
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
    // ExcludeSemantics: the icon subtree swaps between play-arrow and the
    // equalizer when playback toggles, and the equalizer rebuilds every
    // frame — both push orphan a11y-tree updates (AXTree spam).  The
    // whole pill is decorative; the expanded player carries the controls.
    return ExcludeSemantics(child: _buildCircleIcon(colors));
  }

  Widget _buildCircleIcon(ColorScheme colors) {
    // Live status icon: an animated 3-bar equalizer while playing (the
    // bars ride the existing pulse controller at staggered phases) and a
    // play arrow when paused — the user always knows the true state.
    if (widget.isPlaying) {
      return AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, _) {
          final t = _bounceAnimation.value;
          double bar(double phase) {
            final p = (t + phase) % 1.0;
            // 0.35 → 1.0 → 0.35 sine wave.
            return 0.35 + 0.65 * (0.5 - 0.5 * math.cos(p * 2 * math.pi));
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _eqBar(heightFactor: bar(0.0), colors: colors),
              const SizedBox(width: 3),
              _eqBar(heightFactor: bar(0.33), colors: colors),
              const SizedBox(width: 3),
              _eqBar(heightFactor: bar(0.66), colors: colors),
            ],
          );
        },
      );
    }
    return Center(
      child: Icon(Icons.play_arrow_rounded, size: 26, color: colors.onPrimary),
    );
  }

  Widget _eqBar({required double heightFactor, required ColorScheme colors}) {
    return Container(
      width: 3.5,
      height: 10 + 14 * heightFactor,
      decoration: BoxDecoration(
        color: colors.onPrimary,
        borderRadius: BorderRadius.circular(2),
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
              // Now-playing mark: icon tucked in a soft tinted disc.
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.onPrimary.withValues(alpha: 0.18),
                ),
                child: Icon(
                  Icons.music_note_rounded,
                  size: 13,
                  color: colors.onPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.nowPlayingTitle.trim().isEmpty
                      ? 'Now Playing'
                      : widget.nowPlayingTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontSize: context.appFontSize(11),
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.expand_more, size: 20, color: colors.onPrimary),
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
        _AnimatedPlayButton(
          isLoading: widget.isLoading,
          isPlaying: widget.isPlaying,
          onPressed: widget.onPlayPause,
          colors: colors,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MidiSeekSlider(
            position: _positionNotifier,
            duration: _durationNotifier,
            isPlaying: widget.isPlaying,
            onSeek: widget.onSeek,
          ),
        ),
        const SizedBox(width: 6),
        // Subscribe to both notifiers so only the time text rebuilds on
        // a position tick; the play/pause button and seek slider
        // subscription live in their own builders.
        ValueListenableBuilder<double>(
          valueListenable: _positionNotifier,
          builder: (context, position, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _durationNotifier,
              builder: (context, duration, _) {
                // ExcludeSemantics: the clock text changes many times per
                // second while playing; each change pushes an a11y-tree
                // update (AXTree spam on Windows).  The time is
                // decorative — the seek bar conveys the same info.
                return ExcludeSemantics(
                  child: Text(
                    '${_formatTime(position)} / ${_formatTime(duration)}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.1,
                    ),
                  ),
                );
              },
            );
          },
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
    final isFlat = widget.chordAccidentalMode == ChordService.accidentalFlat;
    return _Pill(
      height: boxHeight,
      colors: colors,
      children: [
        _AnimatedIconButton(
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
        _AnimatedIconButton(
          onPressed: () => _adjustTranspose(widget.transposeStep + 1),
          icon: Icons.add_rounded,
        ),
        // The single ♯ / ♭ control for the song page. It shares SongCubit
        // state with both PDF and text renderers, matching gyschordweb.
        Tooltip(
          message: isFlat
              ? 'Gunakan notasi sharp (♯)'
              : 'Gunakan notasi mol (♭)',
          child: Semantics(
            button: true,
            selected: isFlat,
            label: isFlat ? 'Notasi mol' : 'Notasi sharp',
            child: GestureDetector(
              key: const ValueKey('midi-accidental-toggle'),
              behavior: HitTestBehavior.opaque,
              onTap: widget.onToggleAccidental,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: 28,
                margin: const EdgeInsets.symmetric(vertical: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isFlat
                      ? colors.primaryContainer.withValues(alpha: 0.84)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Text(
                    isFlat ? '♭' : '♯',
                    key: ValueKey(isFlat),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isFlat
                          ? colors.onPrimaryContainer
                          : colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
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
          // Use Flexible (not Expanded) so the icon+text group sizes to
          // its content.  The pill's MainAxisAlignment.center then
          // centres the whole group instead of pinning the text to the
          // trailing edge of an Expanded that consumed all remaining
          // width.
          Flexible(
            child: Text(
              chordInfo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              textAlign: TextAlign.center,
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
        _AnimatedIconButton(
          onPressed: () =>
              _adjustTempo((widget.tempoBpm - 1).clamp(30, 300).toDouble()),
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
        _AnimatedIconButton(
          onPressed: () =>
              _adjustTempo((widget.tempoBpm + 1).clamp(30, 300).toDouble()),
          icon: Icons.add_rounded,
        ),
      ],
    );
  }

  Widget _buildIconActions(ColorScheme colors) {
    final hasInstrument = widget.midiInstrument != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.onToggleChord != null && widget.chordToggleEnabled)
          _AnimatedIconButton(
            onPressed: widget.onToggleChord,
            icon: widget.showChord
                ? Icons.music_note_rounded
                : Icons.music_off_rounded,
            color: widget.showChord ? colors.primary : colors.onSurfaceVariant,
            tooltip: widget.showChord ? 'Sembunyikan chord' : 'Tampilkan chord',
          ),
        _AnimatedIconButton(
          key: _instrumentButtonKey,
          onPressed: () => _showInstrumentMenu(context),
          icon: Icons.piano_rounded,
          color: hasInstrument ? colors.primary : colors.onSurfaceVariant,
          tooltip: widget.onMidiInstrument == null
              ? 'Instrumen'
              : 'Instrumen: ${midiInstrumentLabel(widget.midiInstrument)}',
        ),
        _AnimatedIconButton(
          onPressed: widget.onLoopModeCycle,
          icon: midiLoopModeIcon(widget.autoNextMode),
          color: midiLoopModeActive(widget.autoNextMode)
              ? colors.primary
              : colors.onSurfaceVariant,
          tooltip: midiLoopModeTooltip(widget.autoNextMode),
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
    required this.fullSize,
    required this.borderRadius,
    required this.colors,
    required this.showHeader,
    required this.contentVersion,
    required this.headerBuilder,
    required this.controlsBuilder,
    required this.circleBuilder,
  });

  final Size size;

  /// Full player size. The expanded content is laid out at this size and
  /// clipped by the surface's ClipRRect while the surface grows/shrinks,
  /// so the bloom animation never runs the flex layout at intermediate
  /// (too-small) sizes (no RenderFlex overflow).
  final Size fullSize;
  final BorderRadius borderRadius;
  final ColorScheme colors;
  final bool showHeader;
  final int contentVersion;
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
            // Modern depth: a soft diagonal gradient instead of a flat
            // primary fill, with a hairline highlight border and a gentle
            // floating shadow.
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: 0.97),
                colors.primaryContainer.withValues(alpha: 0.92),
              ],
            ),
            border: Border.all(
              color: colors.onPrimary.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: _MorphContent(
            showHeader: showHeader,
            fullSize: fullSize,
            contentVersion: contentVersion,
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
/// is not rebuilt on every animation frame.  The subtree is rebuilt
/// when either:
///   1. `showHeader` flips (expand ↔ collapse), or
///   2. the parent bumps `contentVersion` (state change, theme change,
///      MediaQuery change) — the closures we cached were capturing
///      the parent's previous state, so we must rebuild to pick up
///      the new closures.
///
/// Animation frames do not bump `contentVersion` (the parent itself
/// is not rebuilt during animation), so the cache survives the
/// ~14 frame rebuilds that happen during a 240 ms expand/collapse
/// animation.
class _MorphContent extends StatefulWidget {
  const _MorphContent({
    required this.showHeader,
    required this.fullSize,
    required this.contentVersion,
    required this.headerBuilder,
    required this.controlsBuilder,
    required this.circleBuilder,
  });

  final bool showHeader;
  final Size fullSize;
  final int contentVersion;
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
    if (oldWidget.showHeader != widget.showHeader ||
        oldWidget.contentVersion != widget.contentVersion) {
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
      // Lay the expanded content out at the full player size and clip it
      // to the current surface: while the surface blooms from pill to
      // player the controls stay at their final layout (no flex overflow
      // at intermediate sizes) and are progressively revealed.  bottomLeft
      // keeps the content anchored to the fixed bottom-left corner of the
      // player slot, so the bloom reads as the player rising from the dock.
      child: OverflowBox(
        alignment: Alignment.bottomLeft,
        maxWidth: widget.fullSize.width,
        maxHeight: widget.fullSize.height,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _content;
}

/// Primary play/pause button with a press animation and a soft glow when
/// playing.  The scale dips on press and the icon cross-fades between
/// play/pause states.
class _AnimatedPlayButton extends StatefulWidget {
  const _AnimatedPlayButton({
    required this.isLoading,
    required this.isPlaying,
    required this.onPressed,
    required this.colors,
  });

  final bool isLoading;
  final bool isPlaying;
  final VoidCallback? onPressed;
  final ColorScheme colors;

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.82 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
      child: InkResponse(
        onTap: widget.onPressed,
        onTapDown: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        radius: 20,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.colors.primary,
            boxShadow: widget.isPlaying
                ? [
                    BoxShadow(
                      color: widget.colors.primary.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(widget.colors.onPrimary),
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    widget.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    key: ValueKey(widget.isPlaying),
                    color: widget.colors.onPrimary,
                    size: 20,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Common 28×28 compact tap target used throughout the controls row.
/// Compact icon button with a subtle press animation: the icon dips down
/// while pressed and springs back with a soft ease-out.  Shared by every
/// small control in the MIDI player (transpose, tempo, chord, instrument,
/// loop) so the whole panel feels alive and consistent.
class _AnimatedIconButton extends StatefulWidget {
  const _AnimatedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final Color? color;
  final String? tooltip;

  @override
  State<_AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<_AnimatedIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedScale(
      scale: _pressed ? 0.8 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: _pressed ? Curves.easeOutCubic : Curves.easeOutBack,
      child: InkResponse(
        onTap: widget.onPressed,
        onTapDown: widget.onPressed == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        radius: 16,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(widget.icon, size: 18, color: widget.color),
        ),
      ),
    );
    if (widget.tooltip == null) return button;
    // tap-only trigger: on desktop the default hover trigger mounts and
    // unmounts the tooltip overlay on every mouse pass, which pushes
    // orphan accessibility-tree updates and spams
    // "Failed to update ui::AXTree" from accessibility_bridge.cc.
    return Tooltip(
      message: widget.tooltip!,
      triggerMode: TooltipTriggerMode.tap,
      child: button,
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
        borderRadius: context.appRadius(8),
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
/// position updates from the audio engine.  It subscribes to position
/// and duration via [ValueListenable] so the parent does not need to
/// rebuild this widget on every position tick.
class _MidiSeekSlider extends StatefulWidget {
  const _MidiSeekSlider({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.onSeek,
  });

  final ValueListenable<double> position;
  final ValueListenable<double> duration;
  final bool isPlaying;
  final ValueChanged<double> onSeek;

  @override
  State<_MidiSeekSlider> createState() => _MidiSeekSliderState();
}

class _MidiSeekSliderState extends State<_MidiSeekSlider>
    with SingleTickerProviderStateMixin {
  double? _dragSeekValue;
  double? _pendingSeekValue;

  // Gentle "breathing" while playing: the active track swells and fades
  // instead of sitting static.  Paused, the pulse parks at 1.0 (full).
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
  late final Animation<double> _pulse = Tween<double>(
    begin: 0.65,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    if (widget.isPlaying) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_MidiSeekSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    }
    final pending = _pendingSeekValue;
    if (pending != null &&
        (widget.duration.value <= 0 ||
            (widget.position.value - pending).abs() <= 0.35)) {
      _pendingSeekValue = null;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.position,
      builder: (context, position, _) {
        return ValueListenableBuilder<double>(
          valueListenable: widget.duration,
          builder: (context, duration, _) {
            return _buildSlider(context, position, duration);
          },
        );
      },
    );
  }

  Widget _buildSlider(BuildContext context, double position, double duration) {
    final value = _dragSeekValue ?? _pendingSeekValue ?? position;
    final sliderValue = duration > 0
        ? value.clamp(0.0, duration).toDouble()
        : 0.0;

    final slider = Slider(
      value: sliderValue,
      max: duration > 0 ? duration : 1,
      onChanged: duration > 0
          ? (value) {
              setState(() => _dragSeekValue = value);
            }
          : null,
      onChangeEnd: duration > 0
          ? (value) {
              setState(() {
                _dragSeekValue = null;
                _pendingSeekValue = value;
              });
              widget.onSeek(value);
            }
          : null,
    );

    // ExcludeSemantics: the slider's value changes every frame while
    // playing, which pushes an accessibility tree update per frame on
    // Windows and spams "Failed to update ui::AXTree" from
    // accessibility_bridge.cc.  Gestures still work — only the a11y node
    // is dropped.
    return ExcludeSemantics(
      // The pulse drives a rebuild per frame while playing, so the
      // theme is rebuilt here (cheap) rather than cached.
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final colors = Theme.of(context).colorScheme;
          final pulse = _pulse.value;
          // Accent palette: the seekbar follows the theme accent
          // (primary), and stays visible on the light controls card
          // (onPrimary was white-on-white there).
          final theme = SliderTheme.of(context).copyWith(
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 5.5 + 0.5 * pulse,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            trackHeight: 5,
            thumbColor: colors.primary,
            activeTrackColor: colors.primary.withValues(alpha: pulse),
            inactiveTrackColor: colors.primary.withValues(alpha: 0.22),
            overlayColor: colors.primary.withValues(alpha: 0.12),
          );
          return SliderTheme(data: theme, child: slider);
        },
      ),
    );
  }
}
