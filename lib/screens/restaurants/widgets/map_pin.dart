import 'package:flutter/material.dart';
import 'package:rango_app/core/format/restaurant_format.dart';
import 'package:rango_app/core/theme/app_primitives.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/food_theme_scope.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';

/// Figma `Map Pin`: a drop filled with the Food Theme color, a fork-and-knife
/// glyph and a small shadow under the tip. Selected is larger and shows a
/// balloon with the name and rating above it.
///
/// The widget is [defaultSize] or [selectedSize]; the balloon overflows above
/// it. The tip of the drop is [tipInset] above the bottom edge.
class MapPin extends StatelessWidget {
  const MapPin({
    required this.name,
    required this.foodTheme,
    this.rating,
    this.distanceMeters,
    this.selected = false,
    this.onTap,
    super.key,
  });

  static const defaultSize = Size(44, 57);
  static const selectedSize = Size(56, 73);

  /// Distance from the bottom edge to the tip (room for the shadow).
  static const tipInset = 3.0;

  final String name;

  /// `FoodCategory.foodTheme` name; resolved here.
  final String? foodTheme;
  final double? rating;
  final double? distanceMeters;
  final bool selected;
  final VoidCallback? onTap;

  /// `Nome ★ 4,7`, or just the name without a rating.
  static String balloonText(String name, double? rating) =>
      rating == null ? name : '$name ★ ${formatRating(rating)}';

  String get _spoken {
    final rating = this.rating;
    final distance = distanceMeters;
    return [
      name,
      if (rating != null) 'nota ${formatRating(rating)}',
      if (distance != null) 'a ${formatDistance(distance)}',
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final size = selected ? selectedSize : defaultSize;
    return FoodThemeScope(
      theme: resolveFoodTheme(foodTheme),
      child: Builder(
        builder: (context) {
          final colors = context.colors;
          final food = context.foodColors;
          return Semantics(
            button: true,
            selected: selected,
            label: _spoken,
            excludeSemantics: true,
            onTap: onTap,
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: SizedBox.fromSize(
                size: size,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PinPainter(fill: food.background),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: size.width / 2 - size.width * 0.45 / 2,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.restaurant,
                              size: size.width * 0.45,
                              color: food.foreground,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        bottom: size.height + AppSpace.xxs,
                        left: -200,
                        right: -200,
                        child: Center(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.bgInverse,
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpace.sm,
                                vertical: AppSpace.xxs,
                              ),
                              child: Text(
                                balloonText(name, rating),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textStyles.label.copyWith(
                                  color: colors.textInverse,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  const _PinPainter({required this.fill});

  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final tipY = size.height - MapPin.tipInset;
    final centerX = size.width / 2;
    final radius = size.width / 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centerX, tipY),
        width: size.width * 0.32,
        height: MapPin.tipInset * 2,
      ),
      Paint()..color = AppPrimitives.ink900.withValues(alpha: 0.25),
    );

    final head = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(centerX, radius), radius: radius),
      );
    final tail = Path()
      ..moveTo(centerX - radius * 0.82, radius * 1.55)
      ..lineTo(centerX, tipY)
      ..lineTo(centerX + radius * 0.82, radius * 1.55)
      ..close();
    final drop = Path.combine(PathOperation.union, head, tail);
    canvas.drawPath(drop, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => oldDelegate.fill != fill;
}
