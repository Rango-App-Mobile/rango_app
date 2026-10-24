import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Sticker` variants: `Color` property.
enum RangoStickerColor {
  mustard(FoodTheme.mustard),
  lime(FoodTheme.lime),
  bubblegum(FoodTheme.bubblegum);

  const RangoStickerColor(this.foodTheme);

  final FoodTheme foodTheme;
}

/// Celebratory starburst badge, Figma component `Sticker`. Rotation is the
/// caller's job (wrap the instance in `Transform.rotate`), as in Figma.
class RangoSticker extends StatelessWidget {
  const RangoSticker({
    required this.label,
    this.color = RangoStickerColor.mustard,
    super.key,
  });

  final String label;
  final RangoStickerColor color;

  static const _width = 212.0;
  static const _height = 128.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: CustomPaint(
        size: const Size(_width, _height),
        painter: StarburstPainter(
          fill: color.foodTheme.background,
          stroke: context.colors.borderStrong,
        ),
        child: SizedBox(
          width: _width,
          height: _height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.md),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: context.textStyles.cardTitleSmall.copyWith(
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the 14-point star of the Sticker stretched to an ellipse.
class StarburstPainter extends CustomPainter {
  const StarburstPainter({required this.fill, required this.stroke});

  final Color fill;
  final Color stroke;

  static const pointCount = 14;

  /// Figma STAR inner radius ratio.
  static const innerRatio = 0.86;

  @override
  void paint(Canvas canvas, Size size) {
    // Inset so the outline stays inside the box.
    final radiusX = size.width / 2 - AppRadius.stroke / 2;
    final radiusY = size.height / 2 - AppRadius.stroke / 2;
    final center = size.center(Offset.zero);

    final path = Path();
    const vertices = pointCount * 2;
    for (var i = 0; i < vertices; i++) {
      final ratio = i.isEven ? 1.0 : innerRatio;
      final angle = -math.pi / 2 + i * math.pi / pointCount;
      final point = Offset(
        center.dx + radiusX * ratio * math.cos(angle),
        center.dy + radiusY * ratio * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppRadius.stroke
          ..strokeJoin = StrokeJoin.round,
      );
  }

  @override
  bool shouldRepaint(StarburstPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.stroke != stroke;
}
