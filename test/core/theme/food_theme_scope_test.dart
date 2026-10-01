import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/food_colors.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/theme/food_theme_scope.dart';
import 'package:rango_app/core/theme/theme_context.dart';

void main() {
  testWidgets('swaps the food colors only inside the scope', (tester) async {
    late FoodColors outside;
    late FoodColors inside;
    late AppColors insideColors;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            outside = context.foodColors;
            return FoodThemeScope(
              theme: FoodTheme.plum,
              child: Builder(
                builder: (context) {
                  inside = context.foodColors;
                  insideColors = context.colors;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );

    expect(outside.background, FoodTheme.tomato.background);
    expect(inside.background, FoodTheme.plum.background);
    expect(inside.foreground, FoodTheme.plum.foreground);
    expect(insideColors, AppColors.light);
  });
}
