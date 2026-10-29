import 'dart:typed_data';
import 'dart:ui' as ui;

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
  void paint(Canvas canvas, Size size) => paintMapPinShape(canvas, size, fill);

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => oldDelegate.fill != fill;
}

/// Paints the drop and its tip shadow inside [size], tip centred
/// [MapPin.tipInset] above the bottom. Shared by the widget and the PNG
/// rendering used for Google markers, so both look the same.
void paintMapPinShape(Canvas canvas, Size size, Color fill) {
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

/// Paints a pin (and its balloon, when [balloon] is given) to PNG bytes for a
/// Google Maps marker. The image is symmetric around the pin, so a marker
/// anchored at `(0.5, 1)` puts the tip on the point.
Future<Uint8List> renderMapPinPng({
  required Color fill,
  required Color glyph,
  required bool selected,
  required double pixelRatio,
  String? balloon,
}) async {
  final pinSize = selected ? MapPin.selectedSize : MapPin.defaultSize;

  TextPainter? balloonText;
  var balloonWidth = 0.0;
  const balloonHeight = 26.0;
  const balloonGap = 4.0;
  if (balloon != null) {
    balloonText = TextPainter(
      text: TextSpan(
        text: balloon,
        style: const TextStyle(
          fontFamily: 'Aleo',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppPrimitives.cream,
        ),
      ),
      maxLines: 1,
      ellipsis: '…',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 220);
    balloonWidth = balloonText.width + AppSpace.sm * 2;
  }

  final width = balloonWidth > pinSize.width ? balloonWidth : pinSize.width;
  final extraTop = balloon == null ? 0.0 : balloonHeight + balloonGap;
  final size = Size(width, pinSize.height + extraTop);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(pixelRatio);

  if (balloonText != null) {
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        (width - balloonWidth) / 2,
        0,
        balloonWidth,
        balloonHeight,
      ),
      const Radius.circular(balloonHeight / 2),
    );
    canvas.drawRRect(pill, Paint()..color = AppPrimitives.ink700);
    balloonText.paint(
      canvas,
      Offset(pill.left + AppSpace.sm, (balloonHeight - balloonText.height) / 2),
    );
  }

  canvas
    ..save()
    ..translate((width - pinSize.width) / 2, extraTop);
  paintMapPinShape(canvas, pinSize, fill);

  final glyphSize = pinSize.width * 0.45;
  const icon = Icons.restaurant;
  final glyphPainter = TextPainter(
    text: TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: glyphSize,
        color: glyph,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final headCenterY = pinSize.width / 2;
  glyphPainter.paint(
    canvas,
    Offset(
      (pinSize.width - glyphPainter.width) / 2,
      headCenterY - glyphPainter.height / 2,
    ),
  );
  canvas.restore();

  final image = await recorder.endRecording().toImage(
    (size.width * pixelRatio).ceil(),
    (size.height * pixelRatio).ceil(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  if (data == null) throw StateError('Could not encode the map pin');
  return data.buffer.asUint8List();
}
