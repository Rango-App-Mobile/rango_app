import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_sticker.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/widgets/resolve_food_theme.dart';

/// Minimal converged state: the winning food type, the path that led to it and
/// a way to start over. The full result screen is a later story.
class SwipeResult extends StatelessWidget {
  const SwipeResult({
    required this.result,
    required this.history,
    required this.onRestart,
    super.key,
  });

  final FoodCategory result;
  final List<FoodCategory> history;
  final VoidCallback onRestart;

  static const double _cardAngle = -3 * math.pi / 180;
  static const double _stickerAngle = 8 * math.pi / 180;
  static const _stickerWidth = 120.0;

  /// "Salgado, massa, macarrão": the first label as is, the rest lowercase.
  String get _path => [
    for (final (index, choice) in history.indexed)
      if (index == 0) choice.label else _lowerFirst(choice.label),
  ].join(', ');

  static String _lowerFirst(String text) =>
      text.isEmpty ? text : '${text[0].toLowerCase()}${text.substring(1)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpace.lg,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(
              angle: _cardAngle,
              child: FoodCard(
                title: result.label,
                subtitle: _path,
                chipLabel: '${history.length} escolhas',
                foodTheme: resolveFoodTheme(result.foodTheme),
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
        ),
        Align(
          child: RangoButton(
            label: 'Recomeçar',
            style: RangoButtonStyle.ghost,
            onPressed: onRestart,
          ),
        ),
      ],
    );
  }
}
