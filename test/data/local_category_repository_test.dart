import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/category_tree.dart';

void main() {
  test('uses the local repository as the default data source', () {
    final container = ProviderContainer.test();

    expect(
      container.read(categoryRepositoryProvider),
      isA<LocalCategoryRepository>(),
    );
  });

  test('provides both groups with 16 food choices each', () async {
    final categories = await LocalCategoryRepository().fetchAll();
    final tree = CategoryTree(categories);
    final [savory, sweet] = tree.childrenOf(tree.root);

    expect(categories, hasLength(35));
    expect(tree.root.id, 'root');
    expect([savory.id, sweet.id], ['savory', 'sweet']);
    expect(tree.childrenOf(savory), hasLength(16));
    expect(tree.childrenOf(sweet), hasLength(16));
  });

  test('provides Places and card metadata for every food choice', () async {
    final categories = await LocalCategoryRepository().fetchAll();
    final foods = categories.where(
      (category) => category.parentId != null && category.parentId != 'root',
    );

    expect(foods, hasLength(32));
    expect(
      foods.every(
        (food) =>
            food.placesKeyword?.isNotEmpty == true &&
            food.examples?.isNotEmpty == true &&
            food.foodTheme?.isNotEmpty == true &&
            food.photo?.isNotEmpty == true,
      ),
      isTrue,
    );
  });
}
