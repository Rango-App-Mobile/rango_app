import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/widgets/rango_sticker.dart';

/// The card on top of the deck: drag right to like, left to pass. Past the
/// threshold it flies off and then reports; short of it, it snaps back.
///
/// While it moves, a sticker ("Curti!" or "Passo!") fades in to say what
/// letting go will do. The buttons under the deck are the alternative to the
/// drag, so a tap on the card does nothing.
class SwipeableFoodCard extends StatefulWidget {
  const SwipeableFoodCard({
    required this.onLike,
    required this.onPass,
    required this.child,
    super.key,
  });

  final VoidCallback onLike;
  final VoidCallback onPass;
  final Widget child;

  /// Fraction of the card width the card must travel to count as a swipe.
  static const distanceThreshold = 0.3;

  /// Horizontal fling speed (logical px/s) that counts as a swipe.
  static const velocityThreshold = 800.0;

  static const _settleDuration = Duration(milliseconds: 200);

  /// Extra tilt, in radians, when the card is dragged one full width.
  static const _dragTilt = 0.35;

  /// How far, in card widths, the card travels when it flies off.
  static const _flyOffDistance = 1.5;

  /// Figma `Sticker / carimbo` on the 02 Card único screens.
  static const _stickerSize = Size.square(136);
  static const double _stickerAngle = 14 * math.pi / 180;

  /// The card grows into place when it comes up from the back of the deck.
  static const _entranceScale = 0.94;

  @override
  State<SwipeableFoodCard> createState() => _SwipeableFoodCardState();
}

class _SwipeableFoodCardState extends State<SwipeableFoodCard>
    with TickerProviderStateMixin {
  late final AnimationController _settle;
  late final AnimationController _entrance;
  double _dx = 0;
  double _from = 0;
  double _to = 0;
  double _width = 1;

  /// What to report once the fly-off ends; null while snapping back.
  VoidCallback? _onFlownOff;

  @override
  void initState() {
    super.initState();
    _settle =
        AnimationController(
            vsync: this,
            duration: SwipeableFoodCard._settleDuration,
          )
          ..addListener(() {
            final eased = Curves.easeOutCubic.transform(_settle.value);
            setState(() => _dx = _from + (_to - _from) * eased);
          })
          ..addStatusListener((status) {
            if (status != AnimationStatus.completed) return;
            final report = _onFlownOff;
            _onFlownOff = null;
            report?.call();
          });
    _entrance = AnimationController(
      vsync: this,
      duration: SwipeableFoodCard._settleDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entrance.isAnimating || _entrance.value == 1) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      // Fire and forget: nothing waits for the entrance to end.
      _entrance.forward().ignore();
    }
  }

  @override
  void dispose() {
    _settle.dispose();
    _entrance.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _onDragStart(DragStartDetails details) {
    if (_onFlownOff != null) return;
    _settle.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_onFlownOff != null) return;
    setState(() => _dx += details.delta.dx);
  }

  void _onDragEnd(DragEndDetails details) {
    if (_onFlownOff != null) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final far = _dx.abs() / _width > SwipeableFoodCard.distanceThreshold;
    final fast = velocity.abs() > SwipeableFoodCard.velocityThreshold;
    if (far || fast) {
      final right = far ? _dx > 0 : velocity > 0;
      _flyOff(right ? widget.onLike : widget.onPass, right ? 1 : -1);
    } else {
      _animateTo(0);
    }
  }

  void _flyOff(VoidCallback report, int direction) {
    if (_reduceMotion) {
      report();
      return;
    }
    _onFlownOff = report;
    _animateTo(direction * _width * SwipeableFoodCard._flyOffDistance);
  }

  void _animateTo(double target) {
    if (_reduceMotion) {
      setState(() => _dx = target);
      return;
    }
    _from = _dx;
    _to = target;
    // Fire and forget: the listeners move the card and report the end.
    _settle.forward(from: 0).ignore();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _width = math.max(constraints.maxWidth, 1);
        final angle = _dx / _width * SwipeableFoodCard._dragTilt;
        final progress = (_dx / (_width * SwipeableFoodCard.distanceThreshold))
            .clamp(
              -1.0,
              1.0,
            );

        final card = Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (progress != 0)
              IgnorePointer(
                child: Opacity(
                  opacity: progress.abs(),
                  child: Transform.rotate(
                    angle: progress > 0
                        ? -SwipeableFoodCard._stickerAngle
                        : SwipeableFoodCard._stickerAngle,
                    child: RangoSticker(
                      label: progress > 0 ? 'Curti!' : 'Passo!',
                      color: progress > 0
                          ? RangoStickerColor.lime
                          : RangoStickerColor.bubblegum,
                      size: SwipeableFoodCard._stickerSize,
                    ),
                  ),
                ),
              ),
          ],
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: ScaleTransition(
            scale:
                Tween<double>(
                  begin: SwipeableFoodCard._entranceScale,
                  end: 1,
                ).animate(
                  CurvedAnimation(
                    parent: _entrance,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: Transform.translate(
              offset: Offset(_dx, 0),
              child: Transform.rotate(angle: angle, child: card),
            ),
          ),
        );
      },
    );
  }
}
