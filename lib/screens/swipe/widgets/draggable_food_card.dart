import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A tilted card that follows the finger horizontally and calls [onChosen]
/// when it is released far enough (or fast enough). Otherwise it snaps back.
///
/// The drag is horizontal only so the page can still scroll vertically on
/// small phones. A tap is the accessible alternative and also calls [onChosen].
class DraggableFoodCard extends StatefulWidget {
  const DraggableFoodCard({
    required this.semanticLabel,
    required this.baseAngle,
    required this.onChosen,
    required this.child,
    super.key,
  });

  /// Spoken label of the card, e.g. "Escolher Salgado".
  final String semanticLabel;

  /// Resting tilt in radians.
  final double baseAngle;

  final VoidCallback onChosen;
  final Widget child;

  /// Fraction of the card width the card must travel to count as a choice.
  static const distanceThreshold = 0.35;

  /// Horizontal fling speed (logical px/s) that counts as a choice.
  static const velocityThreshold = 800.0;

  static const _snapBackDuration = Duration(milliseconds: 200);

  /// Extra tilt, in radians, when the card is dragged one full width.
  static const _dragTilt = 0.35;

  @override
  State<DraggableFoodCard> createState() => _DraggableFoodCardState();
}

class _DraggableFoodCardState extends State<DraggableFoodCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapBack;
  double _dx = 0;
  double _releasedFrom = 0;
  double _width = 1;

  @override
  void initState() {
    super.initState();
    _snapBack =
        AnimationController(
          vsync: this,
          duration: DraggableFoodCard._snapBackDuration,
        )..addListener(() {
          final eased = Curves.easeOutCubic.transform(_snapBack.value);
          setState(() => _dx = _releasedFrom * (1 - eased));
        });
  }

  @override
  void dispose() {
    _snapBack.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) => _snapBack.stop();

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() => _dx += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    final travelled = _dx.abs() / _width;
    final fast =
        details.velocity.pixelsPerSecond.dx.abs() >
        DraggableFoodCard.velocityThreshold;
    if (travelled > DraggableFoodCard.distanceThreshold || fast) {
      widget.onChosen();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      setState(() => _dx = 0);
      return;
    }
    _releasedFrom = _dx;
    // Fire and forget: the listener updates the offset frame by frame.
    _snapBack.forward(from: 0).ignore();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = math.max(constraints.maxWidth, 1);
        final angle =
            widget.baseAngle + _dx / _width * DraggableFoodCard._dragTilt;
        return Semantics(
          button: true,
          label: widget.semanticLabel,
          excludeSemantics: true,
          onTap: widget.onChosen,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onChosen,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(_dx, 0),
              child: Transform.rotate(angle: angle, child: widget.child),
            ),
          ),
        );
      },
    );
  }
}
