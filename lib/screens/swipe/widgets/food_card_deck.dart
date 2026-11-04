import 'package:flutter/material.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/widgets/resolve_food_theme.dart';
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

  /// Figma Hero Food Card width on the 402 frame.
  static const cardWidth = 354.0;

  /// How much of the next card shows under the one on top. Figma-only offset.
  static const peek = 12.0;

  /// The next card is drawn smaller, as if it were further back.
  static const _backScale = 0.92;

  /// Just the name and the photo, as in the Figma menu (Assets, "Cardápio").
  static Widget _card(FoodCategory food) => FoodCard(
    title: food.label,
    foodTheme: resolveFoodTheme(food.foodTheme),
    photo: foodPhoto(food.photo),
    photoLabel: 'Foto: ${food.label.toLowerCase()}',
  );

  @override
  Widget build(BuildContext context) {
    final next = this.next;
    // Lay the deck out at the Figma width and scale it down to the room left
    // between the header and the buttons, so small phones never overflow.
    return FittedBox(
      child: SizedBox(
        width: cardWidth,
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
                          child: _card(next),
                        ),
                      ),
                    ),
                  ),
                ),
              SwipeableFoodCard(
                key: ValueKey(swipeCount),
                onLike: onLike,
                onPass: onPass,
                child: _card(current),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
