import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/food_category.dart';

abstract interface class CategoryRepository {
  Future<List<FoodCategory>> fetchAll();
}

/// The food list ships with the app (docs/contexto.md §8), so the local
/// repository is the real implementation. Tests override this provider;
/// nobody instantiates a repository directly.
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => LocalCategoryRepository(),
);

/// The menu, loaded once and kept: screens that need it at once (the
/// Histórico detail, drawn on the first frame of its card's flight) read it
/// already resolved.
final categoriesProvider = FutureProvider<List<FoodCategory>>(
  (ref) => ref.watch(categoryRepositoryProvider).fetchAll(),
);
