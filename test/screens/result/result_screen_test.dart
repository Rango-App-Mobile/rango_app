import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_category_repository.dart';
import 'package:rango_app/screens/result/result_screen.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  List<String> pathIds = const ['savory', 'pasta', 'spaghetti'],
  Size size = const Size(402, 874),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: '/result',
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
      GoRoute(
        path: '/result',
        builder: (_, _) => ResultScreen(pathIds: pathIds),
      ),
      GoRoute(
        path: '/restaurants',
        builder: (_, state) =>
            Text('RESTAURANTS ${state.uri.queryParameters['category']}'),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(FakeCategoryRepository()),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the match card, header and both buttons', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Macarrão'), findsOneWidget);
    expect(find.text('Salgado, massa, macarrão'), findsOneWidget);
    expect(find.text('3 escolhas'), findsOneWidget);
    expect(find.text('Deu match!'), findsOneWidget);
    expect(find.text('Agora é só escolher onde.'), findsOneWidget);
    expect(
      find.text('Vamos buscar restaurantes que servem macarrão perto de você.'),
      findsOneWidget,
    );
    expect(find.text('Ver restaurantes perto'), findsOneWidget);
    expect(find.text('Recomeçar'), findsOneWidget);
  });

  testWidgets('"Ver restaurantes perto" opens restaurants for the category', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.ensureVisible(find.text('Ver restaurantes perto'));
    await tester.tap(find.text('Ver restaurantes perto'));
    await tester.pumpAndSettle();

    expect(find.text('RESTAURANTS spaghetti'), findsOneWidget);
  });

  testWidgets('"Recomeçar" goes home', (tester) async {
    await pumpScreen(tester);

    await tester.ensureVisible(find.text('Recomeçar'));
    await tester.tap(find.text('Recomeçar'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Voltar goes home', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.bySemanticsLabel('Voltar'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('system back goes home', (tester) async {
    await pumpScreen(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('an unknown id shows the error state with a way home', (
    tester,
  ) async {
    await pumpScreen(tester, pathIds: const ['savory', 'nope']);

    expect(find.text('Não deu para mostrar o resultado.'), findsOneWidget);
    expect(find.bySemanticsLabel('Voltar'), findsOneWidget);

    await tester.ensureVisible(find.text('Recomeçar'));
    await tester.tap(find.text('Recomeçar'));
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('does not overflow at 375x667', (tester) async {
    await pumpScreen(tester, size: const Size(375, 667));

    expect(tester.takeException(), isNull);
  });
}
