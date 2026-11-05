import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/widgets/progressive_blur.dart';

const _bandKey = Key('progressive-blur-band');
const _height = 120.0;

Future<void> pump(WidgetTester tester, ProgressiveBlurEdge edge) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            key: const Key('box'),
            height: _height,
            child: ProgressiveBlur(edge: edge),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('top: every band starts at the top, each shorter than the last', (
    tester,
  ) async {
    await pump(tester, ProgressiveBlurEdge.top);
    final box = tester.getRect(find.byKey(const Key('box')));
    final elements = find.byKey(_bandKey).evaluate().toList();

    expect(elements.length, greaterThan(1));
    var previous = double.infinity;
    for (final element in elements) {
      final band = element.renderObject! as RenderBox;
      expect(band.localToGlobal(Offset.zero).dy, box.top);
      expect(band.size.height, lessThan(previous));
      previous = band.size.height;
    }
    expect((elements.first.renderObject! as RenderBox).size.height, _height);
  });

  testWidgets('bottom: every band ends at the bottom, each shorter than the '
      'last', (tester) async {
    await pump(tester, ProgressiveBlurEdge.bottom);
    final box = tester.getRect(find.byKey(const Key('box')));
    final elements = find.byKey(_bandKey).evaluate().toList();

    var previous = double.infinity;
    for (final element in elements) {
      final band = element.renderObject! as RenderBox;
      expect(
        band.localToGlobal(Offset.zero).dy + band.size.height,
        box.bottom,
      );
      expect(band.size.height, lessThan(previous));
      previous = band.size.height;
    }
  });

  for (final (edge, from) in [
    (ProgressiveBlurEdge.top, Alignment.topCenter),
    (ProgressiveBlurEdge.bottom, Alignment.bottomCenter),
  ]) {
    testWidgets('${edge.name}: the canvas tint fades away from the edge', (
      tester,
    ) async {
      await pump(tester, edge);

      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(ProgressiveBlur),
          matching: find.byType(DecoratedBox),
        ),
      );
      final gradient =
          (box.decoration as BoxDecoration).gradient! as LinearGradient;
      expect(gradient.begin, from);
      expect(gradient.colors.first.a, greaterThan(0));
      expect(gradient.colors.last.a, 0);
      expect(
        gradient.colors.last.withValues(alpha: 1),
        AppColors.light.bgCanvas,
      );
    });
  }

  testWidgets('taps pass through it', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => taps++,
                ),
              ),
              const Positioned.fill(
                child: ProgressiveBlur(edge: ProgressiveBlurEdge.bottom),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ProgressiveBlur));

    expect(taps, 1);
  });
}
