import 'dart:math';

import 'package:rango_app/models/duel_state.dart';
import 'package:rango_app/models/food_category.dart';

/// Winner-stays duel over a list of foods. The picked food keeps (or takes)
/// the throne; [winsToFinish] wins in a row end the duel. When the queue runs
/// out, the list is reshuffled and repeats, without the current champion.
class DuelGame {
  DuelGame(List<FoodCategory> pool, {this.winsToFinish = 3, Random? random})
    : _pool = List.unmodifiable(pool),
      _random = random ?? Random() {
    if (pool.length < 2) {
      throw ArgumentError('A duel needs at least 2 foods, got ${pool.length}');
    }
  }

  final List<FoodCategory> _pool;
  final int winsToFinish;
  final Random _random;

  DuelState start() {
    final deck = _shuffled(_pool);
    return DuelState(
      champion: deck[0],
      challenger: deck[1],
      queue: deck.sublist(2),
    );
  }

  DuelState choose(DuelState state, FoodCategory picked) {
    if (state.isOver) return state;
    if (picked != state.champion && picked != state.challenger) return state;
    final defend = picked == state.champion;
    final streak = defend ? state.streak + 1 : 1;

    if (streak >= winsToFinish) {
      return state.copyWith(champion: picked, streak: streak, winner: picked);
    }

    var queue = state.queue;
    if (queue.isEmpty) {
      queue = _shuffled(_pool.where((food) => food != picked).toList());
    }

    return state.copyWith(
      champion: picked,
      challenger: queue.first,
      queue: queue.sublist(1),
      streak: streak,
    );
  }

  List<FoodCategory> _shuffled(List<FoodCategory> foods) =>
      [...foods]..shuffle(_random);
}
