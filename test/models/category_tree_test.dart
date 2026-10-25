import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/food_category.dart';

void main() {
  group('CategoryTree', () {
    final tree = CategoryTree(LocalCategoryRepository.seed);

    test('exposes the single root and its two children', () {
      expect(tree.root.id, 'root');
      expect(tree.childrenOf(tree.root).map((c) => c.id), ['savory', 'sweet']);
    });

    test('treats a node without children as a leaf', () {
      const pizza = FoodCategory(
        id: 'pizza',
        label: 'Pizza',
        parentId: 'pasta',
      );
      expect(tree.isLeaf(pizza), isTrue);
    });

    test('rejects a node with a number of children other than two', () {
      expect(
        () => CategoryTree(const [
          FoodCategory(id: 'root', label: 'Root'),
          FoodCategory(id: 'only', label: 'Only child', parentId: 'root'),
        ]),
        throwsArgumentError,
      );
    });

    test('round-trips through JSON', () {
      const category = FoodCategory(
        id: 'cake',
        label: 'Bolo',
        parentId: 'sweet',
      );
      expect(FoodCategory.fromJson(category.toJson()), category);
    });
  });
}
