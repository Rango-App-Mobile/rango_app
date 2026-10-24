import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/core/widgets/rango_sticker.dart';
import 'package:rango_app/models/food_category.dart';

/// Tilted hero [FoodCard] of the winning food type with the "Deu match!"
/// sticker on its top-right corner.
class MatchCard extends StatelessWidget {
  const MatchCard({
    required this.result,
    required this.pathLabel,
    required this.choiceCount,
    super.key,
  });

  final FoodCategory result;
  final String pathLabel;
  final int choiceCount;

  static const double _cardAngle = -3 * math.pi / 180;
  static const double _stickerAngle = 8 * math.pi / 180;
  static const _stickerWidth = 120.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Transform.rotate(
          angle: _cardAngle,
          child: FoodCard(
            title: result.label,
            subtitle: pathLabel,
            chipLabel: '$choiceCount escolhas',
            foodTheme: _resolveFoodTheme(result.foodTheme),
            photo: foodPhoto(result.photo),
          ),
        ),
        Positioned(
          top: -AppSpace.lg,
          right: -AppSpace.xs,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: _stickerAngle,
              child: const SizedBox(
                width: _stickerWidth,
                child: FittedBox(
                  child: RangoSticker(
                    label: 'Deu match!',
                    color: RangoStickerColor.lime,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A missing or unknown theme name falls back to tomato.
FoodTheme _resolveFoodTheme(String? name) {
  for (final theme in FoodTheme.values) {
    if (theme.name == name) return theme;
  }
  return FoodTheme.tomato;
}
