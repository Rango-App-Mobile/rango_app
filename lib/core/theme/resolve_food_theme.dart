import 'package:rango_app/core/theme/food_theme.dart';

/// Turns the `foodTheme` name stored on a category into a [FoodTheme].
///
/// The model keeps a plain String to stay pure Dart, so the View resolves it
/// here. A missing or unknown name falls back to tomato instead of crashing on
/// bad data.
FoodTheme resolveFoodTheme(String? name) {
  if (name == null) return FoodTheme.tomato;
  for (final theme in FoodTheme.values) {
    if (theme.name == name) return theme;
  }
  return FoodTheme.tomato;
}
