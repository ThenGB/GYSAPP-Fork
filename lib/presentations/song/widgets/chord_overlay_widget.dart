import 'package:flutter/material.dart';

import '../../../data/services/chord_service.dart';

/// Overlay widget that displays chord badges on top of PDF pages.
class ChordOverlayWidget extends StatelessWidget {
  final Map<int, List<ChordData>> chords;
  final int currentPage;
  final int transposeStep;

  const ChordOverlayWidget({
    super.key,
    required this.chords,
    required this.currentPage,
    this.transposeStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    final pageChords = chords[currentPage];
    if (pageChords == null || pageChords.isEmpty) {
      return const SizedBox.shrink();
    }

    // Apply transpose
    final displayChords = transposeStep != 0
        ? pageChords
              .map(
                (c) => ChordData(
                  noteIdx: c.noteIdx,
                  chord: ChordService.transposeChord(c.chord, transposeStep),
                  page: c.page,
                ),
              )
              .toList()
        : pageChords;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: displayChords.map((chord) {
            // Calculate position based on noteIdx (simplified positioning)
            // In a real implementation, this would need proper mapping to PDF coordinates
            final top = _calculateTopPosition(
              chord.noteIdx,
              constraints.maxHeight,
            );
            final left = _calculateLeftPosition(
              chord.noteIdx,
              constraints.maxWidth,
            );

            return Positioned(
              top: top,
              left: left,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  chord.chord,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  double _calculateTopPosition(int noteIdx, double maxHeight) {
    // Simplified: distribute chords vertically based on noteIdx
    // In production, this should map to actual note positions in the PDF
    final line = noteIdx ~/ 20;
    return (line * 30.0).clamp(20, maxHeight - 40);
  }

  double _calculateLeftPosition(int noteIdx, double maxWidth) {
    // Simplified: distribute chords horizontally
    final col = noteIdx % 5;
    return (col * (maxWidth / 5) + 20).clamp(20, maxWidth - 60);
  }
}
