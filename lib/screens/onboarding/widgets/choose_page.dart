import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/theme/theme_context.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/screens/onboarding/widgets/clock_builder.dart';
import 'package:rango_app/screens/onboarding/widgets/onboarding_page_frame.dart';

/// Page 1: the first choice, Salgado or Doce. The cards slide in, a simulated
/// tap picks Salgado and Doce steps back (Figma "Onboarding 1").
class ChoosePage extends StatelessWidget {
  const ChoosePage({required this.clock, super.key});

  final AnimationController clock;

  static const seconds = 4.4;
  static const _art = Size(354, 420);
  static const _cardWidth = 262.0;
  static const _tapPoint = Offset(162, 158);
  static const _ringSize = 64.0;
  static const _dotSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return OnboardingPageFrame(
      title: 'Doce ou salgado?',
      subtitle:
          'Comece pelo que está com mais vontade. É só o ponto de partida: '
          'o resto a gente afunila.',
      artSize: _art,
      art: ClockBuilder(
        clock: clock,
        seconds: seconds,
        builder: (context, t) {
          final colors = context.colors;
          final aIn = seg(t, .35, 1.15, Curves.easeOutBack);
          final bIn = seg(t, .55, 1.35, Curves.easeOutBack);
          final press = t < 1.95
              ? lerp(1, .96, seg(t, 1.7, 1.95))
              : lerp(.96, 1.06, seg(t, 1.95, 2.25, Curves.easeOutBack));
          final bAway = seg(t, 2, 2.6);
          final dotScale = t < 1.6
              ? lerp(.4, 1, seg(t, 1.4, 1.6))
              : t < 1.95
              ? lerp(1, .7, seg(t, 1.6, 1.95))
              : lerp(.7, 1, seg(t, 1.95, 2.25));
          final dotOpacity = seg(t, 1.4, 1.6) * (1 - seg(t, 2.7, 2.95));
          final ring = seg(t, 1.9, 2.7);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 20,
                left: 0,
                child: Opacity(
                  opacity: seg(t, .35, .55),
                  child: Transform.translate(
                    offset: Offset(lerp(-260, 0, aIn), 0),
                    child: Transform.rotate(
                      angle: lerp(-.17, 3 * math.pi / 180, aIn),
                      child: Transform.scale(
                        scale: press,
                        child: SizedBox(
                          width: _cardWidth,
                          child: FoodCard(
                            title: 'Salgado',
                            subtitle: 'Coxinha, pastel, pizza',
                            size: FoodCardSize.medium,
                            foodTheme: FoodTheme.tomato,
                            photo: foodPhoto('salgado'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 188,
                right: 0,
                child: Opacity(
                  opacity: seg(t, .55, .75),
                  child: Transform.translate(
                    offset: Offset(lerp(260, 0, bIn), lerp(0, 28, bAway)),
                    child: Transform.rotate(
                      angle: lerp(.17, -3 * math.pi / 180, bIn),
                      child: Transform.scale(
                        scale: lerp(1, .94, bAway),
                        // Dimmed with a cream veil, not opacity: the card
                        // overlaps Salgado and must not show it through.
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            colors.bgCanvas.withValues(
                              alpha: .6 * seg(t, 2, 2.5),
                            ),
                            BlendMode.srcATop,
                          ),
                          child: SizedBox(
                            width: _cardWidth,
                            child: FoodCard(
                              title: 'Doce',
                              subtitle: 'Brigadeiro, açaí, bolo',
                              size: FoodCardSize.medium,
                              foodTheme: FoodTheme.bubblegum,
                              photo: foodPhoto('brigadeiro'),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _tapPoint.dx - _ringSize / 2,
                top: _tapPoint.dy - _ringSize / 2,
                child: Opacity(
                  opacity: t < 1.9 ? 0 : .9 * (1 - ring),
                  child: Transform.scale(
                    scale: lerp(.45, 2.1, ring),
                    child: Container(
                      width: _ringSize,
                      height: _ringSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.textPrimary,
                          width: AppRadius.stroke * 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _tapPoint.dx - _dotSize / 2,
                top: _tapPoint.dy - _dotSize / 2,
                child: Opacity(
                  opacity: dotOpacity * .85,
                  child: Transform.scale(
                    scale: dotScale,
                    child: Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
