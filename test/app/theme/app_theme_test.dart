import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_text_styles.dart';
import 'package:rango_app/core/theme/food_colors.dart';

void main() {
  final theme = AppTheme.light;

  test('paints screens with color/bg/canvas', () {
    expect(theme.scaffoldBackgroundColor, AppColors.light.bgCanvas);
  });

  test('exposes the Rango tokens as theme extensions', () {
    expect(theme.extension<AppColors>(), AppColors.light);
    expect(theme.extension<AppTextStyles>(), AppTextStyles.standard);
    expect(theme.extension<FoodColors>(), isNotNull);
  });

  test('defaults Material text to Aleo Body in color/text/primary', () {
    final body = theme.textTheme.bodyMedium;
    expect(body?.fontFamily, AppTextStyles.aleo);
    expect(body?.fontSize, 16);
    expect(body?.color, AppColors.light.textPrimary);
  });

  test('bundles every font family the text styles use', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json'))
            as List<Object?>;
    final families = manifest
        .map((entry) => (entry as Map<String, Object?>?)?['family'])
        .toSet();

    expect(
      families,
      containsAll([
        AppTextStyles.aleo,
        AppTextStyles.bowlbyOne,
        AppTextStyles.lobster,
      ]),
    );
  });
}
