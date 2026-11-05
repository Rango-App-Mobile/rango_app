import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/widgets/glass_circle.dart';

void main() {
  testWidgets('blurs what is behind it, clipped to a circle', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: GlassCircle(child: SizedBox.square(dimension: 48)),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(ClipOval),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
  });

  testWidgets('takes the size of its child', (tester) async {
    await tester.pumpWidget(
      const Center(
        child: GlassCircle(child: SizedBox.square(dimension: 48)),
      ),
    );

    expect(tester.getSize(find.byType(GlassCircle)), const Size.square(48));
  });
}
