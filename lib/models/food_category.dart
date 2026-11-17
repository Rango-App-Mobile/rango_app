import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_category.freezed.dart';
part 'food_category.g.dart';

/// One node of the choice tree. A node with no children is a food type;
/// restaurants list the [id]s of the foods they serve.
@freezed
abstract class FoodCategory with _$FoodCategory {
  const factory FoodCategory({
    required String id,
    required String label,
    String? parentId,

    /// Line under the title on the card, e.g. "Coxinha, pastel, pizza".
    String? examples,
    String? foodTheme,

    /// Name of the dish photo bundled in `assets/images/food/` (without the
    /// `.jpg`), e.g. "pizza". Null draws the Food Card placeholder. A String
    /// for the same reason as [foodTheme]: the View builds the image.
    String? photo,
  }) = _FoodCategory;

  factory FoodCategory.fromJson(Map<String, dynamic> json) =>
      _$FoodCategoryFromJson(json);
}
