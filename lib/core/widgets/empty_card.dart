import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma "Empty Card": reserved spot for the first Food Card when a
/// collection is empty. Dashed border over `bg/muted`, card radius.
class EmptyCard extends StatelessWidget {
  const EmptyCard({
    required this.label,
    this.height = defaultHeight,
    super.key,
  });

  /// Height in Figma.
  static const double defaultHeight = 392;
  static const double _borderWidth = 2;

  final String label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          fill: colors.bgMuted,
          border: colors.iconMuted,
          radius: AppRadius.card,
          strokeWidth: _borderWidth,
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textStyles.cardTitleMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.fill,
    required this.border,
    required this.radius,
    required this.strokeWidth,
  });

  static const double _dash = 8;
  static const double _gap = 6;

  final Color fill;
  final Color border;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = fill);

    final path = Path()..addRRect(rrect.deflate(strokeWidth / 2));
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashed.addPath(
          metric.extractPath(distance, distance + _dash),
          Offset.zero,
        );
        distance += _dash + _gap;
      }
    }
    canvas.drawPath(
      dashed,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.border != border ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth;
}
