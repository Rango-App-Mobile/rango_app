import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/app_colors.dart';
import 'package:rango_app/core/theme/app_radius.dart';
import 'package:rango_app/core/theme/app_shadows.dart';
import 'package:rango_app/core/widgets/rango_tab_bar.dart';

Future<void> pump(
  WidgetTester tester, {
  int currentIndex = 0,
  ValueChanged<int>? onSelected,
  bool disableAnimations = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: disableAnimations),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: RangoTabBar(
            currentIndex: currentIndex,
            onSelected: onSelected ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  const colors = AppColors.light;

  testWidgets('shows both labels and icons', (tester) async {
    await pump(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Histórico'), findsOneWidget);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    expect(find.byIcon(Icons.history), findsOneWidget);
  });

  testWidgets('tapping an item calls onSelected with its index', (
    tester,
  ) async {
    final taps = <int>[];
    await pump(tester, onSelected: taps.add);
    await tester.tap(find.text('Histórico'));
    await tester.tap(find.text('Home'));
    expect(taps, [1, 0]);
  });

  testWidgets('each item is at least 92x52', (tester) async {
    await pump(tester);
    for (final label in ['Home', 'Histórico']) {
      final size = tester.getSize(
        find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
      );
      expect(size.width, greaterThanOrEqualTo(92));
      expect(size.height, greaterThanOrEqualTo(52));
    }
  });

  testWidgets('exposes selected state and position in semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester);
    final home = tester.getSemantics(find.bySemanticsLabel('Home, aba 1 de 2'));
    final history = tester.getSemantics(
      find.bySemanticsLabel('Histórico, aba 2 de 2'),
    );
    expect(home.flagsCollection.isSelected, Tristate.isTrue);
    expect(history.flagsCollection.isSelected, Tristate.isFalse);
    expect(home.flagsCollection.isButton, isTrue);
    handle.dispose();
  });

  testWidgets('container uses inverse fill and floating shadow', (
    tester,
  ) async {
    await pump(tester);
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(RangoTabBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, colors.bgInverse);
    expect(decoration.boxShadow, AppShadows.floating);
    expect(decoration.borderRadius, BorderRadius.circular(AppRadius.pill));
  });

  testWidgets('active item uses default ink, inactive uses inverse ink', (
    tester,
  ) async {
    await pump(tester);
    final home = tester.widget<Icon>(find.byIcon(Icons.home_outlined));
    final history = tester.widget<Icon>(find.byIcon(Icons.history));
    expect(home.color, colors.iconDefault);
    expect(history.color, colors.iconInverse);
  });

  testWidgets('switching tabs does not animate when animations are disabled', (
    tester,
  ) async {
    await pump(tester, disableAnimations: true);
    await pump(tester, currentIndex: 1, disableAnimations: true);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('switching tabs animates the pill otherwise', (tester) async {
    await pump(tester);
    await pump(tester, currentIndex: 1);
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
  });
}
