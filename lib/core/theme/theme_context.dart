import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_text_styles.dart';
import 'package:rango_app/core/theme/food_colors.dart';

/// Short access to the Rango tokens: `context.colors.textSecondary`,
/// `context.textStyles.heading`, `context.foodColors.background`.
extension RangoThemeContext on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  AppTextStyles get textStyles =>
      Theme.of(this).extension<AppTextStyles>() ?? AppTextStyles.standard;

  FoodColors get foodColors =>
      Theme.of(this).extension<FoodColors>() ?? FoodColors.fallback;
}
