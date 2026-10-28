import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/duel_game.dart';
import 'package:rango_app/models/duel_state.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';

final swipeViewModelProvider =
    AsyncNotifierProvider<SwipeViewModel, SwipeState>(SwipeViewModel.new);

/// Shuffles the duel queue. Tests override it to keep the seed order.
final duelRandomProvider = Provider<Random>((ref) => Random());

class SwipeViewModel extends AsyncNotifier<SwipeState> {
  late CategoryTree _tree;
  late DuelGame _game;

  @override
  Future<SwipeState> build() async {
    final categories = await ref.watch(categoryRepositoryProvider).fetchAll();
    _tree = CategoryTree(categories);
    return _initialState();
  }

  void choose(FoodCategory option) {
    final current = state.requireValue;
    if (current.hasConverged || !current.options.contains(option)) return;

    final duel = switch (current.duel) {
      null => _startDuel(option),
      final duel => _game.choose(duel, option),
    };

    state = AsyncData(
      current.copyWith(
        current: current.duel == null ? option : current.current,
        options: duel.isOver ? const [] : [duel.champion, duel.challenger],
        history: [...current.history, option],
        duel: duel,
        result: duel.winner,
      ),
    );
  }

  void reset() => state = AsyncData(_initialState());

  DuelState _startDuel(FoodCategory group) {
    _game = DuelGame(
      _tree.childrenOf(group),
      random: ref.read(duelRandomProvider),
    );
    return _game.start();
  }

  SwipeState _initialState() =>
      SwipeState(current: _tree.root, options: _tree.childrenOf(_tree.root));
}
