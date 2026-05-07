import 'package:flutter/material.dart';

/// Draggable floating panel for MIDI playback controls.
/// Includes play/pause, seek, transpose, and tempo controls.
class DraggableMidiControls extends StatefulWidget {
  final bool isPlaying;
  final bool isLoading;
  final double position;
  final double duration;
  final int transposeStep;
  final double tempoBpm;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final ValueChanged<double> onSeek;
  final ValueChanged<int> onTranspose;
  final ValueChanged<double> onTempo;

  const DraggableMidiControls({
    super.key,
    required this.isPlaying,
    required this.isLoading,
    required this.position,
    required this.duration,
    required this.transposeStep,
    required this.tempoBpm,
    required this.onPlayPause,
    required this.onStop,
    required this.onSeek,
    required this.onTranspose,
    required this.onTempo,
  });

  @override
  State<DraggableMidiControls> createState() => _DraggableMidiControlsState();
}

class _DraggableMidiControlsState extends State<DraggableMidiControls> {
  bool _expanded = false;
  Offset _position = const Offset(20, 100);

  String _formatTime(double seconds) {
    final m = seconds ~/ 60;
    final s = (seconds % 60).toInt();
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: Material(
          color: Colors.transparent,
          child: _buildPanel(theme),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragEnd: (details) {
          setState(() {
            _position = details.offset;
          });
        },
        child: _buildPanel(theme),
      ),
    );
  }

  Widget _buildPanel(ThemeData theme) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final panelWidth =
        _expanded ? (screenWidth - 32).clamp(260.0, 340.0).toDouble() : 56.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
          ? _buildExpandedContent(theme)
          : _buildCollapsedButton(theme),
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

  Widget _buildExpandedContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            children: [
              Icon(Icons.drag_handle,
                  size: 16, color: theme.colorScheme.outline),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _expanded = false),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Play/Pause/Stop controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: widget.onStop,
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: widget.onPlayPause,
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(widget.isPlaying ? Icons.pause : Icons.play_arrow),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              SizedBox(
                width: 40,
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
                width: 40,
                child: Text(
                  _formatTime(widget.duration),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),

          // Transpose control
          Row(
            children: [
              const Icon(Icons.music_note, size: 16),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Transpose',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
                constraints: const BoxConstraints(),
                onPressed: () => widget.onTranspose(widget.transposeStep + 1),
              ),
            ],
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
