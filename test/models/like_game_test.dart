import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/like_game.dart';
import 'package:rango_app/models/like_state.dart';

import '../helpers/in_order_random.dart';

const burger = FoodCategory(id: 'burger', label: 'Hambúrguer');
const pizza = FoodCategory(id: 'pizza', label: 'Pizza');
const sushi = FoodCategory(id: 'sushi', label: 'Sushi');
const pastel = FoodCategory(id: 'pastel', label: 'Pastel');
const List<FoodCategory> foods = [burger, pizza, sushi, pastel];

/// Keeps the seed order on every shuffle, so tests know the next card.
LikeGame inOrder([List<FoodCategory> pool = foods]) =>
    LikeGame(pool, random: InOrderRandom());

LikeState likeUntilOver(LikeGame game, LikeState state) {
  var current = state;
  while (!current.isOver) {
    current = game.like(current);
  }
  return current;
}

void main() {
  group('LikeGame', () {
    test('starts with one card on top, the next behind and no likes', () {
      final state = inOrder().start();

      expect(state.current, burger);
      expect(state.next, pizza);
      expect(state.likesOf(burger), 0);
      expect(state.isOver, isFalse);
    });

    test('liking adds one like and shows the next card', () {
      final game = inOrder();
      final state = game.like(game.start());

      expect(state.likesOf(burger), 1);
      expect(state.current, pizza);
    });

    test('passing shows the next card without a like', () {
      final game = inOrder();
      final state = game.pass(game.start());

      expect(state.likesOf(burger), 0);
      expect(state.current, pizza);
    });

    test('likes add up across rounds and never reset', () {
      final game = inOrder();
      var state = game.like(game.start()); // burger 1
      state = game.pass(state); // pizza out
      state = game.like(state); // sushi 1
      state = game.like(state); // pastel 1, the deck repeats

      expect(state.current, burger);
      expect(state.likesOf(burger), 1);
      expect(state.likesOf(sushi), 1);
      expect(state.likesOf(pastel), 1);
    });

    test('the first food to reach three likes wins', () {
      final game = inOrder();
      final state = likeUntilOver(game, game.start());

      // Burger comes first in every round, so it gets there first.
      expect(state.winner, burger);
      expect(state.likesOf(burger), 3);
      expect(state.likesOf(pastel), 2);
      expect(state.isOver, isTrue);
    });

    test('a passed food never comes back while others are left', () {
      final game = inOrder();
      var state = game.pass(game.start()); // burger out
      final seen = <FoodCategory>[];
      for (var i = 0; i < 6; i++) {
        seen.add(state.current);
        state = game.like(state);
      }

      expect(seen, [pizza, sushi, pastel, pizza, sushi, pastel]);
    });

    test('the deck repeats with only the foods still in play', () {
      final game = inOrder();
      var state = game.pass(game.start()); // burger out
      state = game.like(state); // pizza 1
      state = game.pass(state); // sushi out
      state = game.like(state); // pastel 1, the deck repeats

      expect(state.current, pizza);
      expect(state.next, pastel);
      expect(state.passedIds, {'burger', 'sushi'});
    });

    test('passing every food brings the whole list back', () {
      final game = inOrder();
      var state = game.start();
      for (var i = 0; i < foods.length; i++) {
        state = game.pass(state);
      }

      expect(state.passedIds, isEmpty);
      expect(state.current, burger);
      expect({state.current, ...state.queue}, foods.toSet());
    });

    test('there is always a next card while the game is on', () {
      final game = inOrder();
      var state = game.start();
      for (var i = 0; i < 30 && !state.isOver; i++) {
        state = i.isEven ? game.pass(state) : game.like(state);
        if (!state.isOver) expect(state.next, isNotNull);
      }
    });

    test('ignores swipes after the game is over', () {
      final game = inOrder([burger, pizza]);
      final state = likeUntilOver(game, game.start());

      expect(game.like(state), state);
      expect(game.pass(state), state);
    });

    test('a game needs at least two foods', () {
      expect(() => LikeGame([burger]), throwsArgumentError);
    });
  });
}
