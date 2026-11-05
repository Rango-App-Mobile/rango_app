import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_shadows.dart';

/// The fake liquid glass of a round button: blurs what is behind it and casts
/// `Elevation/Card` around it. Fill and border stay with the [child], usually
/// a `Material` with `color/glass/*`, so its ink stays above them.
class GlassCircle extends StatelessWidget {
  const GlassCircle({required this.child, super.key});

  final Widget child;

  /// Figma background blur of radius 12: Flutter's sigma is half the radius.
  static const _blurSigma = 6.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _OuterShadowPainter(),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: child,
        ),
      ),
    );
  }
}

/// Draws the shadow only outside the circle. A `BoxDecoration` shadow also
/// paints under the shape, where it would dirty the translucent fill.
class _OuterShadowPainter extends CustomPainter {
  const _OuterShadowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final circle = Rect.fromLTWH(0, 0, size.width, size.height);
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(circle.inflate(size.longestSide * 2))
      ..addOval(circle);

    canvas
      ..save()
      ..clipPath(outside);
    for (final shadow in AppShadows.card) {
      canvas.drawOval(
        circle.shift(shadow.offset).inflate(shadow.spreadRadius),
        shadow.toPaint(),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter oldDelegate) => false;
}
