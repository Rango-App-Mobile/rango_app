import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/theme/app_text_styles.dart';

void main() {
  final styles = AppTextStyles.standard;

  test('matches the Figma family, weight and size of each style', () {
    final expected = <String, (TextStyle, String, FontWeight, double)>{
      'Brand/Logo': (styles.brandLogo, 'Lobster', FontWeight.w400, 40),
      'Display/Large': (styles.displayLarge, 'BowlbyOne', FontWeight.w400, 40),
      'Card Title/Small': (
        styles.cardTitleSmall,
        'BowlbyOne',
        FontWeight.w400,
        18,
      ),
      'Heading': (styles.heading, 'Aleo', FontWeight.w700, 20),
      'Body Strong': (styles.bodyStrong, 'Aleo', FontWeight.w600, 16),
      'Tab': (styles.tab, 'Aleo', FontWeight.w600, 10),
    };
    for (final MapEntry(key: name, value: (style, family, weight, size))
        in expected.entries) {
      expect(style.fontFamily, family, reason: name);
      expect(style.fontWeight, weight, reason: name);
      expect(style.fontSize, size, reason: name);
    }
  });

  test('converts the Figma pixel line height into a multiplier', () {
    double pixels(TextStyle style) =>
        (style.fontSize ?? 0) * (style.height ?? 0);
    expect(pixels(styles.body), 24);
    expect(pixels(styles.displayLarge), 44);
  });

  test('converts the Figma percent tracking into pixels', () {
    expect(styles.displayLarge.letterSpacing, closeTo(-0.4, 1e-9));
    expect(styles.chip.letterSpacing, closeTo(0.11, 1e-9));
    expect(styles.body.letterSpacing, 0);
  });

  test('leaves color to the place the text is drawn', () {
    expect(styles.body.color, isNull);
  });
}
