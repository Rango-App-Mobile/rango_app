import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_space.dart';
import 'package:rango_app/core/theme/resolve_food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/widgets/swipeable_food_card.dart';

/// The single-card stack: the food on top, swipeable, and the edge of the
/// next one peeking out under it, like a pile of cards.
class FoodCardDeck extends StatelessWidget {
  const FoodCardDeck({
    required this.current,
    required this.next,
    required this.swipeCount,
    required this.onLike,
    required this.onPass,
    super.key,
  });

  final FoodCategory current;
  final FoodCategory? next;

  /// How many cards were swiped so far. Keys the card on top, so each new
  /// card is a fresh widget (even when the same food comes back on top).
  final int swipeCount;

  final VoidCallback onLike;
  final VoidCallback onPass;

  /// Figma Hero Food Card on the "02 Card único" screens: 354 x 512, with a
  /// 408 photo. The deck keeps this proportion at any width.
  static const cardWidth = 354.0;
  static const cardHeight = 512.0;

  /// Below this the photo stops shrinking and the whole deck scales down.
  static const _minPhotoHeight = 200.0;

  /// How much of the next card shows under the one on top. Figma-only offset.
  static const peek = 12.0;

  /// The next card is drawn smaller, as if it were further back.
  static const _backScale = 0.92;

  /// Just the name and the photo, as in the Figma menu (Assets, "Cardápio").
  /// The name stays on one line (shrinking if long), so the header height
  /// is known and the photo takes the rest of the card.
  static Widget _card(FoodCategory food, double photoHeight) => FoodCard(
    title: food.label,
    titleMaxLines: 1,
    photoHeight: photoHeight,
    foodTheme: resolveFoodTheme(food.foodTheme),
    photo: foodPhoto(food.photo),
    photoLabel: 'Foto: ${food.label.toLowerCase()}',
  );

  @override
  Widget build(BuildContext context) {
    final next = this.next;
    return LayoutBuilder(
      builder: (context, constraints) {
        // As big as the Figma card allows at this width, but no taller than
        // the room between the meter and the buttons.
        final width = constraints.maxWidth;
        final byProportion = width * cardHeight / cardWidth;
        final height = constraints.hasBoundedHeight
            ? math.min(byProportion, constraints.maxHeight - peek)
            : byProportion;
        // Hero card without a subtitle: padding, the one-line title and the
        // gap above the photo; the photo takes the rest.
        final title = context.textStyles.cardTitleLarge;
        final titleLine = (title.fontSize ?? 0) * (title.height ?? 1);
        final header = 2 * AppSpace.md + titleLine + AppSpace.sm;
        final photoHeight = math.max(height - header, _minPhotoHeight);

        // Safety net: if the card still does not fit (a very small phone, a
        // large system font), the whole deck scales down instead of
        // overflowing.
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.only(bottom: peek),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (next != null)
                      Positioned.fill(
                        top: peek,
                        bottom: -peek,
                        child: ExcludeSemantics(
                          child: IgnorePointer(
                            child: Transform.scale(
                              scale: _backScale,
                              alignment: Alignment.bottomCenter,
                              child: OverflowBox(
                                alignment: Alignment.bottomCenter,
                                maxHeight: double.infinity,
                                child: _card(next, photoHeight),
                              ),
                            ),
                          ),
                        ),
                      ),
                    SwipeableFoodCard(
                      key: ValueKey(swipeCount),
                      onLike: onLike,
                      onPass: onPass,
                      child: _card(current, photoHeight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
