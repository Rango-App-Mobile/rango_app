import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/theme/food_theme.dart';
import 'package:rango_app/core/widgets/empty_state.dart';
import 'package:rango_app/core/widgets/page_header.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);

void main() {
  const state = EmptyState(
    icon: Icons.search_off,
    title: 'Nada por aqui',
    message: 'Tente de novo',
  );

  testWidgets('renders icon, title and message', (tester) async {
    await tester.pumpWidget(_wrap(state));

    expect(find.byIcon(Icons.search_off), findsOneWidget);
    expect(find.text('Nada por aqui'), findsOneWidget);
    expect(find.text('Tente de novo'), findsOneWidget);
  });

  testWidgets('badge is a 96x96 mustard circle', (tester) async {
    await tester.pumpWidget(_wrap(state));

    final badge = find.ancestor(
      of: find.byIcon(Icons.search_off),
      matching: find.byType(Container),
    );
    expect(tester.getSize(badge.first), const Size(96, 96));
    final decoration =
        tester.widget<Container>(badge.first).decoration! as BoxDecoration;
    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, FoodTheme.mustard.background);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.search_off)).color,
      FoodTheme.mustard.foreground,
    );
  });

  testWidgets('uses a medium Page Header', (tester) async {
    await tester.pumpWidget(_wrap(state));

    final header = tester.widget<PageHeader>(find.byType(PageHeader));
    expect(header.size, PageHeaderSize.medium);
  });
}
