import 'package:flutter/widgets.dart';

/// Progress of [t] between [from] and [to] (seconds), 0 before and 1 after,
/// shaped by [curve]. The Figma keyframes are written in seconds, so the
/// widgets read the same numbers.
double seg(
  double t,
  double from,
  double to, [
  Curve curve = Curves.easeOut,
]) => curve.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

double lerp(double a, double b, double v) => a + (b - a) * v;

/// Rebuilds with the current time in seconds of a page animation. The [clock]
/// is shared with the progress bar, so both loop together.
class ClockBuilder extends StatelessWidget {
  const ClockBuilder({
    required this.clock,
    required this.seconds,
    required this.builder,
    super.key,
  });

  final AnimationController clock;

  /// Length of the page timeline in the Figma frame.
  final double seconds;

  final Widget Function(BuildContext context, double t) builder;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: clock,
    builder: (context, _) => builder(context, clock.value * seconds),
  );
}
