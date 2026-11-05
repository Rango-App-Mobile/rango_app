import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';

void main() {
  test('uses the local repository as the default data source', () {
    final container = ProviderContainer.test();

    expect(
      container.read(categoryRepositoryProvider),
      isA<LocalCategoryRepository>(),
    );
  });

  test('fetches all 35 categories from the repository', () async {
    final categories = await LocalCategoryRepository().fetchAll();

    expect(categories, hasLength(35));
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
