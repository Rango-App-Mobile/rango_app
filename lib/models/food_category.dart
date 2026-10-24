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

    /// Line under the title on the card, e.g. "Coxinha, pastel, pizza".
    String? examples,

    /// Name of the Figma Food Theme mode: tomato, mustard, lilac, lime,
    /// pistachio, sky, plum, copper, cocoa or bubblegum. A String so the
    /// model stays pure Dart; the View resolves it with
    /// `FoodTheme.values.byName`.
    String? foodTheme,

    /// Name of the dish photo bundled in `assets/images/food/` (without the
    /// `.jpg`), e.g. "pizza". Null draws the Food Card placeholder. A String
    /// for the same reason as [foodTheme]: the View builds the image.
    String? photo,
  }) = _FoodCategory;

  factory FoodCategory.fromJson(Map<String, dynamic> json) =>
      _$FoodCategoryFromJson(json);
}
