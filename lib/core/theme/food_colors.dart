import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/food_theme.dart';

/// `food-card/bg` and `food-card/on` for the current subtree. The Figma sets a
/// Food Theme mode on a card instance; here `FoodThemeScope` swaps this
/// extension, and everything inside the card follows.
@immutable
class FoodColors extends ThemeExtension<FoodColors> {
  const FoodColors({required this.background, required this.foreground});

  factory FoodColors.of(FoodTheme theme) =>
      FoodColors(background: theme.background, foreground: theme.foreground);

  /// Tomato is the first mode of the collection, as in Figma.
  static final fallback = FoodColors.of(FoodTheme.tomato);

  final Color background;
  final Color foreground;

  @override
  FoodColors copyWith({Color? background, Color? foreground}) {
    return FoodColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
    );
  }

  @override
  FoodColors lerp(FoodColors? other, double t) {
    if (other == null) return this;
    return FoodColors(
      background: Color.lerp(background, other.background, t) ?? background,
      foreground: Color.lerp(foreground, other.foreground, t) ?? foreground,
    );
  }
}
