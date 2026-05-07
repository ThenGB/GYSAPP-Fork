import 'package:flutter/material.dart';

/// Draggable floating panel for MIDI playback controls.
/// Includes play/pause, seek, transpose, tempo, and instrument controls.
class DraggableMidiControls extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final double position;
  final double duration;
  final int transposeStep;
  final double tempoBpm;
  final int? midiInstrument;
  final String soundFont;
  final List<String> availableSoundFonts;
  final List<List<dynamic>> availableInstruments;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;
  final ValueChanged<int> onTranspose;
  final ValueChanged<double> onTempo;
  final ValueChanged<int?> onInstrument;
  final ValueChanged<String> onSoundFont;

  const DraggableMidiControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.transposeStep,
    required this.tempoBpm,
    this.midiInstrument,
    this.soundFont = 'GeneralUser-GS.sf2',
    this.availableSoundFonts = const ['GeneralUser-GS.sf2', 'TimGM6mb.sf2'],
    this.availableInstruments = const [],
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
    required this.onTranspose,
    required this.onTempo,
    required this.onInstrument,
    required this.onSoundFont,
  });

  @override
  State<DraggableMidiControls> createState() => _DraggableMidiControlsState();
}

class _DraggableMidiControlsState extends State<DraggableMidiControls> {
  bool _expanded = false;
  Offset _position = const Offset(20, 100);

  String _instrumentLabel(int? program) {
    if (program == null) return 'Default';
    final match = widget.availableInstruments.cast<List<dynamic>>().firstWhere(
      (e) => (e[0] as num).toInt() == program,
      orElse: () => <dynamic>[],
    );
    return match.isEmpty ? 'Prog $program' : '${match[1]} (${match[0]})';
  }

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final panelWidth = _panelWidth(screenSize.width);
    final panelHeight = _expanded ? 360.0 : 56.0;
    final safePosition = _clampPosition(
      _position,
      screenSize,
      padding,
      panelWidth,
      panelHeight,
    );
    if (safePosition != _position) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _position = safePosition);
      });
    }

    return Positioned(
      left: safePosition.dx,
      top: safePosition.dy,
      child: _buildPanel(theme, screenSize, padding, panelWidth, panelHeight),
    );
  }

  double _panelWidth(double screenWidth) {
    if (!_expanded) return 56;
    return (screenWidth - 24).clamp(284.0, 360.0).toDouble();
  }

  Offset _clampPosition(
    Offset position,
    Size screenSize,
    EdgeInsets padding,
    double panelWidth,
    double panelHeight,
  ) {
    final minX = 8.0;
    final minY = padding.top + 8;
    final maxX =
        (screenSize.width - panelWidth - 8).clamp(minX, double.infinity);
    final maxY = (screenSize.height - panelHeight - padding.bottom - 8)
        .clamp(minY, double.infinity);
    return Offset(
      position.dx.clamp(minX, maxX).toDouble(),
      position.dy.clamp(minY, maxY).toDouble(),
    );
  }

  void _movePanel(
    DragUpdateDetails details,
    Size screenSize,
    EdgeInsets padding,
    double panelWidth,
    double panelHeight,
  ) {
    setState(() {
      _position = _clampPosition(
        _position + details.delta,
        screenSize,
        padding,
        panelWidth,
        panelHeight,
      );
    });
  }

  Widget _buildPanel(
    ThemeData theme,
    Size screenSize,
    EdgeInsets padding,
    double panelWidth,
    double panelHeight,
  ) {
    return Container(
      width: panelWidth,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _expanded
          ? _buildExpandedContent(
              theme,
              screenSize,
              padding,
              panelWidth,
              panelHeight,
            )
          : GestureDetector(
              onPanUpdate: (details) => _movePanel(
                details,
                screenSize,
                padding,
                panelWidth,
                panelHeight,
              ),
              child: _buildCollapsedButton(theme),
            ),
    );
  }

  Widget _buildCollapsedButton(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _expanded = true),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            widget.isPlaying ? Icons.music_note : Icons.music_off,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(
    ThemeData theme,
    Size screenSize,
    EdgeInsets padding,
    double panelWidth,
    double panelHeight,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button and drag handle
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => _movePanel(
              details,
              screenSize,
              padding,
              panelWidth,
              panelHeight,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.drag_handle,
                  size: 18,
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'MIDI',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () => setState(() => _expanded = false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Play/Pause/Stop inline with seekbar (single row)
          Row(
            children: [
              IconButton(
                tooltip: 'Stop',
                icon: const Icon(Icons.stop_rounded, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: widget.onStop,
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: IconButton(
                  tooltip: widget.isPlaying ? 'Pause' : 'Play',
                  padding: EdgeInsets.zero,
                  icon: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          widget.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 24,
                        ),
                  onPressed: widget.isLoading ? null : widget.onPlayPause,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 36,
                child: Text(
                  _formatTime(widget.position),
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Slider(
                  value: widget.duration > 0
                      ? widget.position.clamp(0, widget.duration)
                      : 0,
                  max: widget.duration > 0 ? widget.duration : 1,
                  onChanged: widget.duration > 0 ? widget.onSeek : null,
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  _formatTime(widget.duration),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),

          // Transpose control
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const Icon(Icons.music_note, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Transpose',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  onPressed: () => widget.onTranspose(widget.transposeStep - 1),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${widget.transposeStep > 0 ? '+' : ''}${widget.transposeStep}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 34,
                    height: 34,
                  ),
                  onPressed: () => widget.onTranspose(widget.transposeStep + 1),
                ),
              ],
            ),
          ),
          // Instrument control
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const Icon(Icons.piano, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Instrument',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  height: 32,
                  child: PopupMenuButton<int?>(
                    initialValue: widget.midiInstrument,
                    onSelected: widget.onInstrument,
                    itemBuilder: (context) => [
                      const PopupMenuItem<int?>(
                        value: null,
                        child: Text('Default'),
                      ),
                      ...widget.availableInstruments.map(
                        (entry) => PopupMenuItem<int?>(
                          value: (entry[0] as num).toInt(),
                          child: Text('${entry[1]} (${entry[0]})'),
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _instrumentLabel(widget.midiInstrument),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // SoundFont control
          SizedBox(
            height: 40,
            child: Row(
              children: [
                const Icon(Icons.library_music, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SoundFont',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                SizedBox(
                  height: 32,
                  child: PopupMenuButton<String>(
                    initialValue: widget.soundFont,
                    onSelected: widget.onSoundFont,
                    itemBuilder: (context) => widget.availableSoundFonts
                        .map(
                          (fileName) => PopupMenuItem<String>(
                            value: fileName,
                            child: Text(fileName),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 142),
                            child: Text(
                              widget.soundFont,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 16,
                            color: theme.colorScheme.outline,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tempo control
          Row(
            children: [
              const Icon(Icons.speed, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tempo',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 64,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${widget.tempoBpm.toInt()} BPM',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: widget.tempoBpm,
            min: 30,
            max: 220,
            divisions: 190,
            onChanged: widget.onTempo,
          ),
        ],
      ),
    );
  }
}
