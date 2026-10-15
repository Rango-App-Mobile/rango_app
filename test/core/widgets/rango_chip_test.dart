import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/widgets/rango_chip.dart';

Future<void> pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

ShapeDecoration chipDecoration(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .descendant(
          of: find.byType(RangoChip),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return box.decoration as ShapeDecoration;
}

Color? labelColor(WidgetTester tester) =>
    tester.widget<Text>(find.text('A')).style?.color;

void main() {
  const colors = AppColors.light;

  testWidgets('renders the label', (tester) async {
    await pump(tester, const RangoChip(label: 'Doce'));
    expect(find.text('Doce'), findsOneWidget);
  });

  testWidgets('outline has a 1px strong border and no fill', (tester) async {
    await pump(tester, const RangoChip(label: 'A'));
    final decoration = chipDecoration(tester);
    expect(decoration.color, Colors.transparent);
    final side = (decoration.shape as StadiumBorder).side;
    expect(side.color, colors.borderStrong);
    expect(side.width, 1);
    expect(labelColor(tester), colors.textPrimary);
  });

  testWidgets('solid uses inverse fill and text', (tester) async {
    await pump(
      tester,
      const RangoChip(label: 'A', style: RangoChipStyle.solid),
    );
    expect(chipDecoration(tester).color, colors.bgInverse);
    expect(labelColor(tester), colors.textInverse);
  });

  testWidgets('soft uses muted fill', (tester) async {
    await pump(tester, const RangoChip(label: 'A', style: RangoChipStyle.soft));
    expect(chipDecoration(tester).color, colors.bgMuted);
    expect(labelColor(tester), colors.textPrimary);
  });

  testWidgets('shows the icon only when given', (tester) async {
    await pump(tester, const RangoChip(label: 'A'));
    expect(find.byType(Icon), findsNothing);
    await pump(tester, const RangoChip(label: 'A', icon: Icons.star));
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
