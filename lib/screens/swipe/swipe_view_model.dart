import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/like_game.dart';
import 'package:rango_app/models/like_state.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';

final swipeViewModelProvider =
    AsyncNotifierProvider<SwipeViewModel, SwipeState>(SwipeViewModel.new);

/// Shuffles the deck of cards. Tests override it to keep the seed order.
final deckRandomProvider = Provider<Random>((ref) => Random());

class SwipeViewModel extends AsyncNotifier<SwipeState> {
  late CategoryTree _tree;
  late LikeGame _game;

  @override
  Future<SwipeState> build() async {
    final categories = await ref.watch(categoryRepositoryProvider).fetchAll();
    _tree = CategoryTree(categories);
    return _initialState();
  }

  /// Picks Salgado or Doce at the root and deals that group's cards.
  void choose(FoodCategory group) {
    final current = state.requireValue;
    if (current.game != null || !current.options.contains(group)) return;

    _game = LikeGame(
      _tree.childrenOf(group),
      random: ref.read(deckRandomProvider),
    );
    state = AsyncData(
      current.copyWith(
        current: group,
        options: const [],
        history: [...current.history, group],
        game: _game.start(),
      ),
    );
  }

  /// Swipe right (or the heart button) on the card on top.
  // Closures, not tear-offs: `_game` is unset until the user picks a group.
  void like() => _swipe((game) => _game.like(game));

  /// Swipe left (or the X button) on the card on top.
  void pass() => _swipe((game) => _game.pass(game));

  void reset() => state = AsyncData(_initialState());

  void _swipe(LikeState Function(LikeState) apply) {
    final current = state.requireValue;
    final game = current.game;
    if (game == null || game.isOver) return;

    final next = apply(game);
    state = AsyncData(
      current.copyWith(
        history: [...current.history, game.current],
        game: next,
        result: next.winner,
      ),
    );
  }

  SwipeState _initialState() =>
      SwipeState(current: _tree.root, options: _tree.childrenOf(_tree.root));
}
