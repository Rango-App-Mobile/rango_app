import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/rango_sticker.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/widgets/draggable_food_card.dart';
import 'package:rango_app/screens/swipe/widgets/resolve_food_theme.dart';

/// The two overlapping option cards of a swipe level, with the "ou" sticker
/// where they meet. Enters with a fade and slide each time it is created, so
/// the parent keys it by the current level.
class SwipeChoiceCards extends StatefulWidget {
  const SwipeChoiceCards({
    required this.first,
    required this.second,
    required this.onChosen,
    super.key,
  });

  final FoodCategory first;
  final FoodCategory second;
  final ValueChanged<FoodCategory> onChosen;

  /// Figma medium Food Card width on the 402 frame.
  static const cardWidth = 292.0;

  /// How much card B covers the bottom of card A. Figma-only offset.
  static const _overlap = 40.0;

  /// Resting tilts, from the Figma level 2 screen (+2 / -2), widened a little
  /// so the pair reads as a stack at any level.
  static const double _firstAngle = 3 * math.pi / 180;
  static const double _secondAngle = -3 * math.pi / 180;

  static const _stickerWidth = 80.0;
  static const double _stickerAngle = 12 * math.pi / 180;

  static const _entranceDuration = Duration(milliseconds: 250);
  static const _entranceSlide = 24.0;

  @override
  State<SwipeChoiceCards> createState() => _SwipeChoiceCardsState();
}

class _SwipeChoiceCardsState extends State<SwipeChoiceCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;
  late final Animation<double> _curved;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: SwipeChoiceCards._entranceDuration,
    );
    _curved = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
    } else {
      // Fire and forget: nothing waits for the entrance to end.
      unawaited(_entrance.forward());
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _card(FoodCategory option, double angle) {
    return SizedBox(
      width: SwipeChoiceCards.cardWidth,
      child: DraggableFoodCard(
        semanticLabel: 'Escolher ${option.label}',
        baseAngle: angle,
        onChosen: () => widget.onChosen(option),
        child: FoodCard(
          title: option.label,
          subtitle: option.examples,
          size: FoodCardSize.medium,
          foodTheme: resolveFoodTheme(option.foodTheme),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Card B is moved up instead of laid out overlapping; the extra space it
    // leaves under itself works as the bottom margin of the pair.
    final pair = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _card(widget.first, SwipeChoiceCards._firstAngle),
        ),
        Transform.translate(
          offset: const Offset(0, -SwipeChoiceCards._overlap),
          child: Align(
            alignment: Alignment.centerRight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _card(widget.second, SwipeChoiceCards._secondAngle),
                // Decorative: a pointer on it would steal taps from the cards.
                Positioned(
                  left: -SwipeChoiceCards._stickerWidth / 2,
                  top: -SwipeChoiceCards._stickerWidth / 4,
                  child: IgnorePointer(
                    child: Transform.rotate(
                      angle: SwipeChoiceCards._stickerAngle,
                      child: const SizedBox(
                        width: SwipeChoiceCards._stickerWidth,
                        child: FittedBox(
                          child: RangoSticker(label: 'ou'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return FadeTransition(
      opacity: _curved,
      child: AnimatedBuilder(
        animation: _curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(
            0,
            (1 - _curved.value) * SwipeChoiceCards._entranceSlide,
          ),
          child: child,
        ),
        child: pair,
      ),
    );
  }
}
