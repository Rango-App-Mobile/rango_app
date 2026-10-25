import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/models/duel_game.dart';
import 'package:rango_app/models/food_category.dart';

const foods = [
  FoodCategory(id: 'burger', label: 'Hambúrguer'),
  FoodCategory(id: 'pizza', label: 'Pizza'),
  FoodCategory(id: 'sushi', label: 'Sushi'),
  FoodCategory(id: 'pastel', label: 'Pastel'),
];

void main() {
  group('DuelGame', () {
    test('starts with two different foods and no points', () {
      final state = DuelGame(foods).start();

      expect(state.champion, isNot(state.challenger));
      expect(state.streak, 0);
      expect(state.isOver, isFalse);
    });

    test('three wins in a row end the duel', () {
      final game = DuelGame(foods);
      var state = game.start();
      final favorite = state.champion;

      for (var i = 0; i < 3; i++) {
        state = game.choose(state, favorite);
      }

      expect(state.winner, favorite);
      expect(state.isOver, isTrue);
    });

    test('the first duel already counts as one point', () {
      final game = DuelGame(foods);
      var state = game.start();

      state = game.choose(state, state.challenger);

      expect(state.streak, 1);
    });

    test('beating the champion takes the throne with one point', () {
      final game = DuelGame(foods);
      var state = game.start();
      state = game.choose(state, state.champion);
      state = game.choose(state, state.champion);

      final rival = state.challenger;
      state = game.choose(state, rival);

      expect(state.champion, rival);
      expect(state.streak, 1);
    });

    test('a dethroned champion only returns after the list repeats', () {
      final game = DuelGame(foods);
      var state = game.start();
      final dethroned = state.champion;

      state = game.choose(state, state.challenger);

      expect(state.challenger, isNot(dethroned));
      expect(state.queue, isNot(contains(dethroned)));
    });

    test('the list repeats when the queue runs out', () {
      final game = DuelGame(foods);
      var state = game.start();

      for (var i = 0; i < 20; i++) {
        state = game.choose(state, state.challenger);
      }

      expect(state.isOver, isFalse);
      expect(state.challenger, isNot(state.champion));
    });

    test('ignores a food that is not in the current duel', () {
      final game = DuelGame(foods);
      final state = game.start();
      final outsider = state.queue.first;

      expect(game.choose(state, outsider), state);
    });

    test('ignores picks after the duel is over', () {
      final game = DuelGame(foods);
      var state = game.start();
      final favorite = state.champion;
      for (var i = 0; i < 3; i++) {
        state = game.choose(state, favorite);
      }

      expect(game.choose(state, state.challenger), state);
    });

    test('a duel needs at least two foods', () {
      expect(() => DuelGame([foods.first]), throwsArgumentError);
    });
  });
}
