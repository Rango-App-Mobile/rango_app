import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/rango_sticker.dart';

Future<void> pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

StarburstPainter painter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(RangoSticker),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as StarburstPainter;
}

void main() {
  testWidgets('renders the label', (tester) async {
    await pump(tester, const RangoSticker(label: 'Deu match!'));
    expect(find.text('Deu match!'), findsOneWidget);
  });

  testWidgets('is 212x128', (tester) async {
    await pump(tester, const RangoSticker(label: 'Deu match!'));
    expect(tester.getSize(find.byType(RangoSticker)), const Size(212, 128));
  });

  testWidgets('each color uses its food theme background', (tester) async {
    const expected = {
      RangoStickerColor.mustard: FoodTheme.mustard,
      RangoStickerColor.lime: FoodTheme.lime,
      RangoStickerColor.bubblegum: FoodTheme.bubblegum,
    };
    for (final entry in expected.entries) {
      await pump(tester, RangoSticker(label: 'A', color: entry.key));
      expect(painter(tester).fill, entry.value.background);
    }
  });

  testWidgets('outline uses the strong border color', (tester) async {
    await pump(tester, const RangoSticker(label: 'A'));
    expect(painter(tester).stroke, AppColors.light.borderStrong);
  });
}
