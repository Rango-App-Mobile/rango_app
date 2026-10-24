import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/theme/app_primitives.dart';
import 'package:rango_app/core/theme/food_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  test('has the ten modes of the Figma Food Theme collection', () {
    expect(FoodTheme.values.map((t) => t.name), [
      'tomato',
      'mustard',
      'lilac',
      'lime',
      'pistachio',
      'sky',
      'plum',
      'copper',
      'cocoa',
      'bubblegum',
    ]);
  });

  test('uses cream ink only on the dark foods', () {
    final creamOn = FoodTheme.values
        .where((t) => t.foreground == AppPrimitives.cream)
        .map((t) => t.name);
    expect(creamOn, ['pistachio', 'plum', 'cocoa']);
  });

  for (final theme in FoodTheme.values) {
    test('${theme.name} text passes WCAG AA on its background', () {
      expect(
        _contrast(theme.background, theme.foreground),
        greaterThanOrEqualTo(4.5),
      );
    });
  }

  test('resolves a mode stored by name', () {
    expect(
      FoodTheme.values.byName('mustard').background,
      AppPrimitives.mustard,
    );
  });
}
