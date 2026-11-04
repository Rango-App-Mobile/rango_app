import 'dart:math';

import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/like_state.dart';

/// Single-card swipe over a list of foods: like or pass the card on top.
///
/// Likes add up per food and never reset; the first food to reach
/// [likesToMatch] likes wins. A passed food leaves the session. When a round
/// ends, the foods still in play are shuffled again; if every food was
/// passed, the whole list comes back.
class LikeGame {
  LikeGame(List<FoodCategory> pool, {this.likesToMatch = 3, Random? random})
    : _pool = List.unmodifiable(pool),
      _random = random ?? Random() {
    if (pool.length < 2) {
      throw ArgumentError('A game needs at least 2 foods, got ${pool.length}');
    }
  }

  final List<FoodCategory> _pool;
  final int likesToMatch;
  final Random _random;

  LikeState start() {
    final deck = _shuffled(_pool);
    return LikeState(
      current: deck.first,
      queue: deck.sublist(1),
      likesToMatch: likesToMatch,
    );
  }

  LikeState like(LikeState state) {
    if (state.isOver) return state;
    final food = state.current;
    final count = state.likesOf(food) + 1;
    final likes = {...state.likes, food.id: count};
    if (count >= state.likesToMatch) {
      return state.copyWith(likes: likes, winner: food);
    }
    return _advance(state.copyWith(likes: likes));
  }

  LikeState pass(LikeState state) {
    if (state.isOver) return state;
    final food = state.current;
    return _advance(
      state.copyWith(
        passedIds: {...state.passedIds, food.id},
        // The next round may already hold the passed food: take it out.
        queue: state.queue.where((other) => other != food).toList(),
      ),
    );
  }

  /// Puts the next card on top and deals a new round when this one is about
  /// to end, so there is always a card behind the one on top.
  LikeState _advance(LikeState state) {
    var passedIds = state.passedIds;
    var queue = state.queue;
    if (queue.isEmpty) {
      (queue, passedIds) = _newRound(passedIds, avoidFirst: state.current);
    }
    final current = queue.first;
    var rest = queue.sublist(1);
    if (rest.isEmpty) {
      (rest, passedIds) = _newRound(passedIds, avoidFirst: current);
    }
    return state.copyWith(
      current: current,
      queue: rest,
      passedIds: passedIds,
    );
  }

  /// Shuffles the foods still in play. [avoidFirst] is the card on screen
  /// right now: it should not come straight back as the next one.
  (List<FoodCategory>, Set<String>) _newRound(
    Set<String> passedIds, {
    required FoodCategory avoidFirst,
  }) {
    var passed = passedIds;
    var alive = _pool.where((food) => !passed.contains(food.id)).toList();
    if (alive.isEmpty) {
      passed = const {};
      alive = _pool;
    }
    final deck = _shuffled(alive);
    if (deck.length > 1 && deck.first == avoidFirst) {
      deck.add(deck.removeAt(0));
    }
    return (deck, passed);
  }

  List<FoodCategory> _shuffled(List<FoodCategory> foods) =>
      [...foods]..shuffle(_random);
}
