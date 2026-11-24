import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/core/widgets/food_photo.dart';
import 'package:rango_app/core/widgets/rango_sticker.dart';
import 'package:rango_app/screens/onboarding/widgets/clock_builder.dart';
import 'package:rango_app/screens/onboarding/widgets/onboarding_page_frame.dart';
import 'package:rango_app/screens/swipe/widgets/like_meter.dart';
import 'package:rango_app/screens/swipe/widgets/swipe_button.dart';

/// One card of the demo deck and what the person does with it.
class _Swipe {
  const _Swipe(this.title, this.photo, {required this.like});

  final String title;
  final String photo;
  final bool like;
}

/// Page 2: like or pass, one food at a time. The demo shows every state: a
/// like, a pass, then two more likes that fill the Like Meter and end in the
/// match (Figma "Onboarding 2", rule R2). Like the real swipe cards, the food
/// cards carry only the name, no description line.
class SwipePage extends StatelessWidget {
  const SwipePage({required this.clock, super.key});

  final AnimationController clock;

  static const seconds = 9.4;
  static const _art = Size(354, 500);
  static const _cardWidth = 255.0;
  static const _deckTop = 52.0;
  static const _confettiCenter = Offset(177, 236);

  static const _swipes = [
    _Swipe('Macarrão', 'macarrao', like: true),
    _Swipe('Pizza', 'pizza', like: false),
    _Swipe('Macarrão', 'macarrao', like: true),
    _Swipe('Macarrão', 'macarrao', like: true),
  ];

  /// When each swipe starts, in seconds.
  static const _starts = [1.7, 3.2, 4.7, 6.2];

  /// A swipe takes 0.8 s: drag (0.3) and throw (0.5).
  static const _swipeLength = .8;
  static const _matchAt = 7.2;

  static const List<FoodTheme> _confettiColors = [
    FoodTheme.tomato,
    FoodTheme.mustard,
    FoodTheme.lime,
    FoodTheme.bubblegum,
    FoodTheme.sky,
  ];

  /// 0..1..0 envelope of a stamp ("Curti!" or "Passo!") between [start] and
  /// [end] seconds, plus its scale.
  static (double opacity, double scale) _stamp(
    double t,
    double start,
    double end,
  ) {
    final opacity = seg(t, start, start + .1) * (1 - seg(t, end, end + .1));
    final scale = t < start + .25
        ? lerp(.5, 1.15, seg(t, start, start + .25))
        : lerp(1.15, 1, seg(t, start + .25, start + .4));
    return (opacity, scale);
  }

  /// The Like Meter pops each time a heart fills.
  static double _pop(double t, double at) => t < at + .15
      ? lerp(1, 1.15, seg(t, at, at + .15))
      : lerp(1.15, 1, seg(t, at + .15, at + .4));

  static double _pulse(double t, double start) => t < start + .2
      ? lerp(1, 1.25, seg(t, start, start + .2))
      : lerp(1.25, 1, seg(t, start + .2, start + .5));

  /// Cards are drawn from the last to the first, so each sits under the one
  /// before it.
  Widget _card(double t, int k) {
    final swipe = _swipes[k];
    final start = _starts[k];
    final direction = swipe.like ? 1.0 : -1.0;
    final drag = seg(t, start, start + .3);
    final fling = seg(t, start + .3, start + _swipeLength, Curves.easeIn);
    final dx = t < start + .3 ? lerp(0, 60, drag) : lerp(60, 380, fling);
    final angle = t < start + .3 ? lerp(0, .1, drag) : lerp(.1, .38, fling);

    // Waiting behind (smaller, lower) until the card before it is thrown.
    final promote = k == 0
        ? 1.0
        : seg(
            t,
            _starts[k - 1] + .3,
            _starts[k - 1] + .9,
            Curves.easeOutBack,
          );
    final appear = switch (k) {
      0 => seg(t, .55, .75),
      1 => seg(t, .4, .6),
      _ => seg(t, _starts[k - 2] + .3, _starts[k - 2] + .6),
    };
    final rise = switch (k) {
      0 => lerp(100, 0, seg(t, .55, 1.3, Curves.easeOutBack)),
      1 => lerp(70, 0, seg(t, .4, 1.1, Curves.easeOutBack)),
      _ => 0.0,
    };

    return Positioned(
      top: _deckTop,
      left: (354 - _cardWidth) / 2,
      child: Opacity(
        opacity: appear * (1 - seg(t, start + .5, start + _swipeLength)),
        child: Transform.translate(
          offset: Offset(dx * direction, rise + 22 * (1 - promote)),
          child: Transform.rotate(
            angle: angle * direction,
            child: Transform.scale(
              scale: lerp(.91, 1, promote),
              child: SizedBox(
                width: _cardWidth,
                child: FoodCard(
                  title: swipe.title,
                  foodTheme: FoodTheme.mustard,
                  photo: foodPhoto(swipe.photo),
                  photoHeight: 260,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPageFrame(
      title: 'Curta ou passe',
      subtitle:
          'Uma comida por vez: arraste pra direita pra curtir, pra esquerda '
          'pra passar. Três curtidas na mesma comida dão match.',
      artSize: _art,
      art: ClockBuilder(
        clock: clock,
        seconds: seconds,
        builder: (context, t) {
          var likes = 0;
          var likeStamp = (0.0, 1.0);
          var passStamp = (0.0, 1.0);
          var likePulse = 1.0;
          var passPulse = 1.0;
          var meterPop = 1.0;
          for (var k = 0; k < _swipes.length; k++) {
            final start = _starts[k];
            final stamp = _stamp(t, start + .05, start + .9);
            final pulse = _pulse(t, start + .1);
            if (_swipes[k].like) {
              if (t >= start + _swipeLength) likes++;
              meterPop = math.max(meterPop, _pop(t, start + _swipeLength));
              if (stamp.$1 > likeStamp.$1) likeStamp = stamp;
              likePulse = math.max(likePulse, pulse);
            } else {
              if (stamp.$1 > passStamp.$1) passStamp = stamp;
              passPulse = math.max(passPulse, pulse);
            }
          }
          final matchScale = t < _matchAt + .4
              ? lerp(.3, 1.15, seg(t, _matchAt, _matchAt + .4))
              : lerp(1.15, 1, seg(t, _matchAt + .4, _matchAt + .6));

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Opacity(
                    opacity: seg(t, .6, .9),
                    child: Transform.scale(
                      scale: meterPop,
                      child: LikeMeter(likes: likes, total: 3),
                    ),
                  ),
                ),
              ),
              for (var k = _swipes.length - 1; k >= 0; k--) _card(t, k),
              Positioned(
                top: _deckTop + 10,
                left: (354 - _cardWidth) / 2 - 14,
                child: Opacity(
                  opacity: likeStamp.$1,
                  child: Transform.scale(
                    scale: likeStamp.$2,
                    child: Transform.rotate(
                      angle: -.17,
                      child: const RangoSticker(
                        label: 'Curti!',
                        color: RangoStickerColor.lime,
                        size: Size(117, 70),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _deckTop + 10,
                right: (354 - _cardWidth) / 2 - 14,
                child: Opacity(
                  opacity: passStamp.$1,
                  child: Transform.scale(
                    scale: passStamp.$2,
                    child: Transform.rotate(
                      angle: .17,
                      child: const RangoSticker(
                        label: 'Passo!',
                        color: RangoStickerColor.bubblegum,
                        size: Size(117, 70),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: seg(t, .9, 1.2),
                  child: Transform.scale(
                    scale: .72,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 24,
                      children: [
                        Transform.scale(
                          scale: passPulse,
                          child: SwipeButton(
                            action: SwipeAction.pass,
                            foodLabel: 'Macarrão',
                            onPressed: () {},
                          ),
                        ),
                        Transform.scale(
                          scale: likePulse,
                          child: SwipeButton(
                            action: SwipeAction.like,
                            foodLabel: 'Macarrão',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: _confettiCenter.dy - 45,
                left: _confettiCenter.dx - 74,
                child: Opacity(
                  opacity: seg(t, _matchAt, _matchAt + .1),
                  child: Transform.scale(
                    scale: matchScale,
                    child: Transform.rotate(
                      angle: lerp(
                        .44,
                        .14,
                        seg(t, _matchAt, _matchAt + .5, Curves.easeOutBack),
                      ),
                      child: const RangoSticker(
                        label: 'Deu match!',
                        size: Size(148, 90),
                      ),
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < 12; i++) _confetti(t, i),
            ],
          );
        },
      ),
    );
  }

  Widget _confetti(double t, int i) {
    final start = _matchAt + .05 + (i % 3) * .04;
    final spread = seg(t, start, start + .9);
    final angle = i / 12 * 2 * math.pi + .3;
    final distance = 130.0 + (i % 4) * 28;
    final size = 8.0 + (i % 3) * 3;
    return Positioned(
      left: _confettiCenter.dx - size / 2 + math.cos(angle) * distance * spread,
      top:
          _confettiCenter.dy -
          size / 2 +
          (math.sin(angle) * distance + 30) * spread,
      child: Opacity(
        opacity:
            seg(t, start, start + .05) * (1 - seg(t, start + .6, start + 1)),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _confettiColors[i % _confettiColors.length].background,
          ),
        ),
      ),
    );
  }
}
