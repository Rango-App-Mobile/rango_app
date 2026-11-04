import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/screens/history_detail/history_detail_screen.dart';

Future<void> _pump(
  WidgetTester tester, {
  String id = 'h9',
  Size size = const Size(402, 874),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        historyRepositoryProvider.overrideWithValue(FakeHistoryRepository()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/history',
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, _) => TextButton(
                onPressed: () => context.push('/history/$id'),
                child: const Text('HISTORY'),
              ),
            ),
            GoRoute(
              path: '/history/:id',
              builder: (_, state) =>
                  HistoryDetailScreen(entryId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: '/restaurants',
              builder: (_, state) => Text(
                'RESTAURANTS ${state.uri.queryParameters['category']}',
              ),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('HISTORY'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the food, when, the way there and the restaurant', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Macarrão'), findsWidgets);
    expect(find.text('1 nov, 12:30'), findsOneWidget);
    expect(find.text('O caminho até aqui'), findsOneWidget);
    expect(find.text('Salgado'), findsOneWidget);
    expect(find.text('Onde você pediu'), findsOneWidget);
    expect(find.text('Cantina da Nona'), findsOneWidget);
    expect(find.text('Italiana · Moinhos de Vento'), findsOneWidget);
    expect(find.text('Pedido!'), findsNothing);
  });

  testWidgets('both buttons lead to the restaurants of that food', (
    tester,
  ) async {
    await _pump(tester);

    await tester.ensureVisible(find.text('Pedir de novo'));
    await tester.tap(find.text('Pedir de novo'));
    await tester.pumpAndSettle();
    expect(find.text('RESTAURANTS spaghetti'), findsOneWidget);
  });

  testWidgets('Voltar returns to the history', (tester) async {
    await _pump(tester);

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('HISTORY'), findsOneWidget);
  });

  testWidgets('an unknown decision says so, with Voltar', (tester) async {
    await _pump(tester, id: 'nope');

    expect(find.text('Não encontramos esse rango.'), findsOneWidget);
    expect(find.bySemanticsLabel('Voltar'), findsOneWidget);
  });

  testWidgets('does not overflow at 375x667', (tester) async {
    await _pump(tester, size: const Size(375, 667));

    expect(tester.takeException(), isNull);
  });
}
