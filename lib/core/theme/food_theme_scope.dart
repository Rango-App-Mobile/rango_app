import 'package:flutter/material.dart';
import 'package:rango_app/core/theme/food_colors.dart';
import 'package:rango_app/core/theme/food_theme.dart';

/// Applies a Food Theme mode to its subtree, like switching the mode of the
/// Food Theme collection on a Figma instance.
class FoodThemeScope extends StatelessWidget {
  const FoodThemeScope({required this.theme, required this.child, super.key});

  final FoodTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final extensions = {...base.extensions}
      ..[FoodColors] = FoodColors.of(theme);
    return Theme(
      data: base.copyWith(extensions: extensions.values),
      child: child,
    );
  }
}
