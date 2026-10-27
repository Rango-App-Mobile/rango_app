import 'dart:math';

/// A [Random] that makes `List.shuffle` keep the order, so a duel follows the
/// seed order and tests know which foods are on screen.
class InOrderRandom implements Random {
  @override
  int nextInt(int max) => max - 1;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}
