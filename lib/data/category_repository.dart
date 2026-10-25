import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/food_category.dart';

abstract interface class CategoryRepository {
  Future<List<FoodCategory>> fetchAll();
}

/// Swapped for the Firestore implementation in the Sprint 2 story.
/// Tests override this provider; nobody instantiates a repository directly.
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => LocalCategoryRepository(),
);
