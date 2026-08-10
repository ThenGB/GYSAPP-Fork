import 'package:flutter/material.dart';

import '../../../data/services/chord_service.dart';
import '../../../data/services/midi_engine_service.dart';
import '../cubit/song_playlist.dart';
import 'draggable_midi_controls_base.dart' as base;

export 'draggable_midi_controls_base.dart' hide DraggableMidiControls;

/// Compatibility wrapper around the mature drag/morph MIDI player.
///
/// The base implementation already renders the accidental notation control
/// (♯/♭) inside the expanded transpose pill. This wrapper preserves the public
/// API while suppressing the Dashboard's legacy external attached chip for
/// uncontrolled callers, so users see exactly one accidental control.
class DraggableMidiControls extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final double position;
  final double duration;
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
  final int? midiInstrument;
  final ValueChanged<int?>? onMidiInstrument;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpandedChanged;
  final VoidCallback? onPreviousSong;
  final VoidCallback? onNextSong;
  final bool showChord;
  final bool chordToggleEnabled;
  final VoidCallback? onToggleChord;
  final String chordAccidentalMode;
  final VoidCallback? onToggleAccidental;
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
    this.leftMargin = base.kMidiOverlayHorizontalMargin,
    this.rightMargin = base.kMidiOverlayHorizontalMargin,
    this.bottomOffset = base.kMidiOverlayBottomOffset,
  });

  @override
  State<DraggableMidiControls> createState() => _DraggableMidiControlsState();
}

class _DraggableMidiControlsState extends State<DraggableMidiControls> {
  late bool _expanded = widget.isExpanded ?? true;

  @override
  void didUpdateWidget(covariant DraggableMidiControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controlled = widget.isExpanded;
    if (controlled != null && controlled != _expanded) {
      _expanded = controlled;
    }
  }

  void _handleExpandedChanged(bool expanded) {
    if (mounted && _expanded != expanded) {
      setState(() => _expanded = expanded);
    }

    // The only current uncontrolled caller used this callback to draw a
    // second floating accidental chip outside the MIDI surface. Keep that
    // legacy overlay suppressed now that the base player exposes ♯/♭ itself.
    // Controlled callers still receive the callback as part of the public API.
    if (widget.isExpanded != null) {
      widget.onExpandedChanged?.call(expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return base.DraggableMidiControls(
      key: const ValueKey('midi-base-player'),
      isPlaying: widget.isPlaying,
      isLoading: widget.isLoading,
      position: widget.position,
      duration: widget.duration,
      stateStream: widget.stateStream,
      transposeStep: widget.transposeStep,
      currentKey: widget.currentKey,
      availableKeys: widget.availableKeys,
      tempoBpm: widget.tempoBpm,
      autoNextMode: widget.autoNextMode,
      onPlayPause: widget.onPlayPause,
      onLoopModeCycle: widget.onLoopModeCycle,
      onSeek: widget.onSeek,
      onTranspose: widget.onTranspose,
      onKeySelected: widget.onKeySelected,
      onTempo: widget.onTempo,
      nowPlayingTitle: widget.nowPlayingTitle,
      runningFamilyChord: widget.runningFamilyChord,
      midiInstrument: widget.midiInstrument,
      onMidiInstrument: widget.onMidiInstrument,
      isExpanded: widget.isExpanded,
      onExpandedChanged: _handleExpandedChanged,
      onPreviousSong: widget.onPreviousSong,
      onNextSong: widget.onNextSong,
      showChord: widget.showChord,
      chordToggleEnabled: widget.chordToggleEnabled,
      onToggleChord: widget.onToggleChord,
      chordAccidentalMode: widget.chordAccidentalMode,
      onToggleAccidental: widget.onToggleAccidental,
      usePositioned: widget.usePositioned,
      leftMargin: widget.leftMargin,
      rightMargin: widget.rightMargin,
      bottomOffset: widget.bottomOffset,
    );
  }
}
