import 'package:flutter/painting.dart';
import 'package:rango_app/core/theme/app_primitives.dart';

/// The modes of the Figma "Food Theme" collection. Each food has a background
/// and the ink that reads on it (`food/<name>/bg` and `food/<name>/on`); every
/// pair passes WCAG AA. Categories store the mode by name, so the model stays
/// pure Dart and `FoodTheme.values.byName` resolves it here.
enum FoodTheme {
  tomato(AppPrimitives.tomato, AppPrimitives.ink900),
  mustard(AppPrimitives.mustard, AppPrimitives.ink900),
  lilac(AppPrimitives.lilac, AppPrimitives.ink900),
  lime(AppPrimitives.lime, AppPrimitives.ink900),
  pistachio(AppPrimitives.pistachio, AppPrimitives.cream),
  sky(AppPrimitives.sky, AppPrimitives.ink900),
  plum(AppPrimitives.plum, AppPrimitives.cream),
  copper(AppPrimitives.copper, AppPrimitives.ink900),
  cocoa(AppPrimitives.cocoa, AppPrimitives.cream),
  bubblegum(AppPrimitives.bubblegum, AppPrimitives.ink900);

  const FoodTheme(this.background, this.foreground);

  final Color background;
  final Color foreground;
}
