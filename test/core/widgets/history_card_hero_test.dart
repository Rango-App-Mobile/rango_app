import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/widgets/history_card_hero.dart';

void main() {
  // The pile shows the shorter card; the detail, the taller one.
  const pile = Rect.fromLTWH(24, 400, 354, 470);
  const detail = Rect.fromLTWH(24, 140, 354, 700);

  group('leaving the pile', () {
    final tween = PullOutRectTween(begin: pile, end: detail);

    test('starts and ends on the cards', () {
      expect(tween.lerp(0), pile);
      expect(tween.lerp(1), detail);
    });

    test('first slides straight up out of the pile', () {
      final pulled = tween.lerp(PullOutRectTween.pullShare);

      expect(pulled?.left, pile.left);
      expect(pulled?.size, pile.size);
      expect(pulled?.top, pile.top - PullOutRectTween.pullDistance);
    });

    test('only then grows into the detail', () {
      final early = tween.lerp(PullOutRectTween.pullShare / 2);
      final late = tween.lerp(0.8);

      expect(early?.height, pile.height);
      expect(late?.height, greaterThan(pile.height));
    });
  });

  group('back to the pile', () {
    final tween = PullOutRectTween(begin: detail, end: pile);

    test('starts and ends on the cards', () {
      expect(tween.lerp(0), detail);
      expect(tween.lerp(1), pile);
    });

    test('reaches the spot above the pile before sliding in', () {
      final above = tween.lerp(1 - PullOutRectTween.pullShare);

      expect(above?.top, pile.top - PullOutRectTween.pullDistance);
      expect(above?.size, pile.size);
    });
  });
}
