import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_state.dart';

final swipeViewModelProvider =
    AsyncNotifierProvider<SwipeViewModel, SwipeState>(SwipeViewModel.new);

class SwipeViewModel extends AsyncNotifier<SwipeState> {
  late CategoryTree _tree;

  @override
  Future<SwipeState> build() async {
    final categories = await ref.watch(categoryRepositoryProvider).fetchAll();
    _tree = CategoryTree(categories);
    return _initialState();
  }

  void choose(FoodCategory option) {
    final current = state.requireValue;
    if (current.hasConverged || !current.options.contains(option)) return;

    final history = [...current.history, option];
    state = AsyncData(
      _tree.isLeaf(option)
          ? current.copyWith(
              history: history,
              options: const [],
              result: option,
            )
          : current.copyWith(
              current: option,
              options: _tree.childrenOf(option),
              history: history,
            ),
    );
  }

  void reset() => state = AsyncData(_initialState());

  SwipeState _initialState() =>
      SwipeState(current: _tree.root, options: _tree.childrenOf(_tree.root));
}
