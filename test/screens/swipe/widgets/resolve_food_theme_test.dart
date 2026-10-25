import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/screens/swipe/widgets/resolve_food_theme.dart';

void main() {
  test('resolves a known theme name', () {
    expect(resolveFoodTheme('plum'), FoodTheme.plum);
  });

  test('falls back to tomato for null or unknown names', () {
    expect(resolveFoodTheme(null), FoodTheme.tomato);
    expect(resolveFoodTheme('neon'), FoodTheme.tomato);
  });
}
