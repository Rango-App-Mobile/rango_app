import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_shadows.dart';

/// The flight of a Histórico card into its detail screen, as if it were
/// pulled out of the pile: it first slides up and out of the stack, tilting
/// a little and lifting (a stronger shadow), and only then travels and grows
/// into place on the detail screen. Going back it does the reverse and slides
/// into the pile again. Both ends wrap their card in this widget with the
/// same [entryId].
///
/// During the flight the two cards cross-fade inside the moving box, each at
/// its own natural height and clipped to the box, so neither layout is
/// squeezed while the box grows.
class HistoryCardHero extends StatelessWidget {
  const HistoryCardHero({
    required this.entryId,
    required this.child,
    super.key,
  });

  final String entryId;
  final Widget child;

  static Object tagFor(String entryId) => 'history-card-$entryId';

  /// Tilt, in radians, at the height of the pull.
  static const double _pullTilt = -3 * math.pi / 180;

  static Widget _shuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final from = (fromContext.widget as Hero).child;
    final to = (toContext.widget as Hero).child;
    Widget natural(Widget card) => ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        maxHeight: double.infinity,
        child: card,
      ),
    );
    // Texts in flight live in the overlay, outside any Material.
    return Material(
      type: MaterialType.transparency,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          // 0 at both ends, 1 in the middle of the flight.
          final lift = math.sin(math.pi * animation.value);
          return Transform.rotate(
            angle: _pullTilt * lift,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [
                  for (final shadow in AppShadows.floating)
                    shadow.copyWith(
                      color: shadow.color.withValues(
                        alpha: shadow.color.a * lift,
                      ),
                    ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: ReverseAnimation(animation),
              child: natural(from),
            ),
            FadeTransition(opacity: animation, child: natural(to)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagFor(entryId),
      createRectTween: (begin, end) => PullOutRectTween(begin: begin, end: end),
      flightShuttleBuilder: _shuttle,
      child: child,
    );
  }
}

/// The path of the card between the pile and the detail screen.
///
/// The pile end is the shorter card (the pile shows the Hero layout, the
/// detail the taller Expanded one). Leaving the pile, the card first slides
/// [pullDistance] up out of it during the first [pullShare] of the flight,
/// then travels to the other end. Coming back it reaches that same spot above
/// the pile first and slides down into it at the end.
class PullOutRectTween extends RectTween {
  PullOutRectTween({super.begin, super.end});

  static const pullDistance = 96.0;

  /// Share of the flight spent pulling. The Hero eases its progress with
  /// `fastOutSlowIn`, which runs ahead early on, so the pull gets more than
  /// half of it to last about a third of the real time.
  static const pullShare = 0.55;

  @override
  Rect? lerp(double t) {
    final begin = this.begin;
    final end = this.end;
    if (begin == null || end == null) return super.lerp(t);

    final leavingPile = begin.height <= end.height;
    final pile = leavingPile ? begin : end;
    final pulled = pile.translate(0, -pullDistance);

    if (leavingPile) {
      if (t < pullShare) {
        return Rect.lerp(
          begin,
          pulled,
          Curves.easeOut.transform(t / pullShare),
        );
      }
      final rest = (t - pullShare) / (1 - pullShare);
      return Rect.lerp(pulled, end, Curves.easeInOut.transform(rest));
    }

    const split = 1 - pullShare;
    if (t < split) {
      return Rect.lerp(begin, pulled, Curves.easeInOut.transform(t / split));
    }
    final rest = (t - split) / pullShare;
    return Rect.lerp(pulled, end, Curves.easeIn.transform(rest));
  }
}
