import 'package:flutter/material.dart';

class SwipeDetectorWidget extends StatelessWidget {
  final Widget child;
  final Function onSwipeLeft;
  final Function onSwipeRight;

  const SwipeDetectorWidget({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: _onSwipeEnd,
      child: child,
    );
  }

  void _onSwipeEnd(DragEndDetails details) {
    if (details.velocity.pixelsPerSecond.dx > 0) {
      // Swiped to the right
      onSwipeRight();
    } else if (details.velocity.pixelsPerSecond.dx < 0) {
      // Swiped to the left
      onSwipeLeft();
    }
  }
}
