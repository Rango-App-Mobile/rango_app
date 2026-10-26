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

    test('gives each group its whole food list', () {
      final [savory, sweet] = tree.childrenOf(tree.root);

      expect(tree.childrenOf(savory), hasLength(16));
      expect(tree.childrenOf(sweet), hasLength(16));
    });

    test('treats a node without children as a leaf', () {
      const pizza = FoodCategory(
        id: 'pizza',
        label: 'Pizza',
        parentId: 'savory',
      );
      expect(tree.isLeaf(pizza), isTrue);
    });

    test('rejects a root with a number of children other than two', () {
      expect(
        () => CategoryTree(const [
          FoodCategory(id: 'root', label: 'Root'),
          FoodCategory(id: 'only', label: 'Only child', parentId: 'root'),
        ]),
        throwsArgumentError,
      );
    });

    test('accepts a group with more than two foods', () {
      expect(
        () => CategoryTree(const [
          FoodCategory(id: 'root', label: 'Root'),
          FoodCategory(id: 'savory', label: 'Salgado', parentId: 'root'),
          FoodCategory(id: 'sweet', label: 'Doce', parentId: 'root'),
          FoodCategory(id: 'pizza', label: 'Pizza', parentId: 'savory'),
          FoodCategory(id: 'sushi', label: 'Sushi', parentId: 'savory'),
          FoodCategory(id: 'pastel', label: 'Pastel', parentId: 'savory'),
        ]),
        returnsNormally,
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
