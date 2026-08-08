import 'package:flutter/material.dart';

/// Detects horizontal swipes with a distance + velocity threshold so that
/// vertical scrolling or tiny horizontal jitters do not trigger navigation.
///
/// Mirrors the behaviour of the app's other paged views (Bible chapter
/// navigation, PDF page turns): a swipe must travel at least [minDistance]
/// pixels and end with a horizontal velocity above [minVelocity] to count.
class SwipeDetectorWidget extends StatefulWidget {
  final Widget child;
  final Function onSwipeLeft;
  final Function onSwipeRight;

  /// Minimum horizontal travel (px) for a swipe to be accepted.
  final double minDistance;

  /// Minimum horizontal end velocity (px/s) for a swipe to be accepted.
  final double minVelocity;

  const SwipeDetectorWidget({
    super.key,
    required this.child,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.minDistance = 60,
    this.minVelocity = 250,
  });

  @override
  State<SwipeDetectorWidget> createState() => _SwipeDetectorWidgetState();
}

class _SwipeDetectorWidgetState extends State<SwipeDetectorWidget> {
  /// Accumulated horizontal drag distance while the gesture is active.
  double _accumulatedDx = 0;
  bool _horizontalGesture = false;

  void _track(DragUpdateDetails details) {
    _accumulatedDx += details.delta.dx;
    if (_accumulatedDx.abs() >= widget.minDistance) {
      _horizontalGesture = true;
    }
  }

  void _onSwipeEnd(DragEndDetails details) {
    final dx = _accumulatedDx;
    _accumulatedDx = 0;
    final gestureIsHorizontal = _horizontalGesture;
    _horizontalGesture = false;

    final velocity = details.velocity.pixelsPerSecond.dx;
    final movedFarEnough = dx.abs() >= widget.minDistance;
    final movedFastEnough = velocity.abs() >= widget.minVelocity;
    if (!movedFarEnough || !movedFastEnough || !gestureIsHorizontal) {
      return;
    }
    if (dx > 0) {
      widget.onSwipeRight();
    } else {
      widget.onSwipeLeft();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: _onSwipeEnd,
      onHorizontalDragUpdate: _track,
      child: widget.child,
    );
  }
}
