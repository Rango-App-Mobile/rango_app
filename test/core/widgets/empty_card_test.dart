import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/widgets/empty_card.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('renders the label', (tester) async {
    await tester.pumpWidget(
      _wrap(const EmptyCard(label: 'Seu primeiro rango')),
    );

    expect(find.text('Seu primeiro rango'), findsOneWidget);
  });

  testWidgets('has the Figma default height of 392', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyCard(label: 'x')));

    expect(tester.getSize(find.byType(EmptyCard)).height, 392);
    expect(EmptyCard.defaultHeight, 392);
  });

  testWidgets('accepts a custom height', (tester) async {
    await tester.pumpWidget(_wrap(const EmptyCard(label: 'x', height: 200)));

    expect(tester.getSize(find.byType(EmptyCard)).height, 200);
  });

  testWidgets('fills bgMuted and draws a dashed iconMuted border', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const EmptyCard(label: 'x')));

    final painted = find.descendant(
      of: find.byType(EmptyCard),
      matching: find.byType(CustomPaint),
    );
    expect(
      tester.renderObject(painted.first),
      paints
        ..rrect(color: AppColors.light.bgMuted)
        ..path(color: AppColors.light.iconMuted, strokeWidth: 2),
    );
  });
}
