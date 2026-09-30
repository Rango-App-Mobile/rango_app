import 'package:rango_app/models/food_category.dart';

/// Immutable view over the flat category list. Holds the convergence rule:
/// every non-leaf node has exactly two children (a binary choice).
class CategoryTree {
  CategoryTree(List<FoodCategory> categories)
    : _byParent = _groupByParent(categories) {
    final roots = _byParent[null] ?? const [];
    if (roots.length != 1) {
      throw ArgumentError(
        'Tree must have exactly one root, got ${roots.length}',
      );
    }
    root = roots.single;
    for (final entry in _byParent.entries) {
      if (entry.key != null && entry.value.length != 2) {
        throw ArgumentError('Node ${entry.key} must have exactly 2 children');
      }
    }
  }

  late final FoodCategory root;
  final Map<String?, List<FoodCategory>> _byParent;

  List<FoodCategory> childrenOf(FoodCategory node) =>
      _byParent[node.id] ?? const [];

  bool isLeaf(FoodCategory node) => childrenOf(node).isEmpty;

  static Map<String?, List<FoodCategory>> _groupByParent(
    List<FoodCategory> categories,
  ) {
    final map = <String?, List<FoodCategory>>{};
    for (final category in categories) {
      map.putIfAbsent(category.parentId, () => []).add(category);
    }
    return map;
  }
}
