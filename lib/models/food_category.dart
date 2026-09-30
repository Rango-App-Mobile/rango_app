import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_category.freezed.dart';
part 'food_category.g.dart';

/// One node of the choice tree. A node with no children is a food type
/// the app can search for on Google Places.
@freezed
abstract class FoodCategory with _$FoodCategory {
  const factory FoodCategory({
    required String id,
    required String label,
    String? parentId,
    String? placesKeyword,
  }) = _FoodCategory;

  factory FoodCategory.fromJson(Map<String, dynamic> json) =>
      _$FoodCategoryFromJson(json);
}
