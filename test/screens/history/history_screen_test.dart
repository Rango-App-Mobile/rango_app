import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_history_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/screens/history/history_screen.dart';
import 'package:rango_app/screens/history/widgets/history_stack.dart';

class _MockHistoryRepository extends Mock implements HistoryRepository {}

Future<void> _pump(
  WidgetTester tester, {
  HistoryRepository? repository,
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
        historyRepositoryProvider.overrideWithValue(
          repository ?? FakeHistoryRepository(),
        ),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/history',
          routes: [
            GoRoute(
              path: '/history',
              builder: (_, _) => const HistoryScreen(),
            ),
            GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
            GoRoute(
              path: '/history/:id',
              builder: (_, state) =>
                  Text('DETAIL ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder cardTitled(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(FoodCard));

/// The cards actually drawn by the stack (not the invisible sizer).
Finder get drawnCards => find.descendant(
  of: find.byType(Positioned),
  matching: find.byType(FoodCard),
);

void main() {
  group('with decisions', () {
    testWidgets('shows the count and the newest card whole, in front', (
      tester,
    ) async {
      await _pump(tester);

      expect(find.text('Seu histórico'), findsOneWidget);
      expect(find.text('9 rangos decididos desde setembro.'), findsOneWidget);

      // The newest decision: Macarrão at Cantina da Nona, on 1 nov.
      final newest = cardTitled('Macarrão').last;
      expect(find.text('Cantina da Nona'), findsWidgets);
      expect(find.text('1 nov'), findsWidgets);
      final center = tester.getCenter(newest);
      expect(
        tester
            .hitTestOnBinding(center)
            .path
            .any(
              (entry) => entry.target == tester.renderObject(newest),
            ),
        isTrue,
      );
      expect(find.text('Seu primeiro rango'), findsNothing);
    });

    testWidgets('each newer card is drawn lower and on top of the older', (
      tester,
    ) async {
      await _pump(tester);
      // At the top of the list every card is out of the pile.
      await tester.drag(find.byType(HistoryStack), const Offset(0, 1200));
      await tester.pumpAndSettle();

      final pizza = tester.getTopLeft(cardTitled('Pizza').last).dy;
      final spaghetti = tester.getTopLeft(cardTitled('Macarrão').last).dy;
      expect(spaghetti, greaterThan(pizza));
      expect(spaghetti - pizza, closeTo(HistoryStack.stripHeight, 1));
    });

    testWidgets('older cards pile at the top instead of leaving the screen', (
      tester,
    ) async {
      await _pump(tester);

      final stackTop = tester.getTopLeft(find.byType(HistoryStack)).dy;
      for (final element in drawnCards.evaluate()) {
        final top = tester.getTopLeft(find.byWidget(element.widget)).dy;
        expect(top, greaterThanOrEqualTo(stackTop - 1));
      }
    });

    testWidgets('scrolling up brings the oldest decision down into view', (
      tester,
    ) async {
      await _pump(tester);

      await tester.drag(find.byType(HistoryStack), const Offset(0, 1200));
      await tester.pumpAndSettle();

      final stackTop = tester.getTopLeft(find.byType(HistoryStack)).dy;
      final acai = tester.getTopLeft(cardTitled('Açaí').last).dy;
      expect(acai, closeTo(stackTop + HistoryStack.pileTop, 1));

      // Scrolling back down piles them again, still on screen.
      await tester.drag(find.byType(HistoryStack), const Offset(0, -1200));
      await tester.pumpAndSettle();
      for (final element in drawnCards.evaluate()) {
        final top = tester.getTopLeft(find.byWidget(element.widget)).dy;
        expect(top, greaterThanOrEqualTo(stackTop - 1));
      }
    });

    testWidgets('cards in the pile get smaller the further back they are', (
      tester,
    ) async {
      await _pump(tester);

      // Drawn width over laid-out width: the scale of the pile.
      final scales = [
        for (final element in drawnCards.evaluate())
          (tester.getTopRight(find.byWidget(element.widget)).dx -
                  tester.getTopLeft(find.byWidget(element.widget)).dx) /
              tester.getSize(find.byWidget(element.widget)).width,
      ];
      expect(scales.first, lessThan(1));
      expect(scales.last, closeTo(1, 0.001));
      for (var i = 1; i < scales.length; i++) {
        expect(scales[i], greaterThanOrEqualTo(scales[i - 1]));
      }
    });

    testWidgets('titles stay on one line so the strip shows the date', (
      tester,
    ) async {
      await _pump(tester);

      for (final element in drawnCards.evaluate()) {
        expect((element.widget as FoodCard).titleMaxLines, 1);
      }
    });

    testWidgets('a long title shrinks to fit one line instead of wrapping', (
      tester,
    ) async {
      await _pump(tester);
      await tester.drag(find.byType(HistoryStack), const Offset(0, 1200));
      await tester.pumpAndSettle();

      final title = find.text('Cachorro-quente').last;
      final text = tester.widget<Text>(title);
      expect(text.maxLines, 1);
      expect(text.overflow, isNot(TextOverflow.ellipsis));

      final card = find.ancestor(of: title, matching: find.byType(FoodCard));
      final titleWidth =
          tester.getTopRight(title).dx - tester.getTopLeft(title).dx;
      expect(titleWidth, lessThan(tester.getSize(card.first).width));
      final titleHeight =
          tester.getBottomLeft(title).dy - tester.getTopLeft(title).dy;
      final pizzaTitle = find.text('Pizza').last;
      final oneLine =
          tester.getBottomLeft(pizzaTitle).dy -
          tester.getTopLeft(pizzaTitle).dy;
      expect(titleHeight, lessThanOrEqualTo(oneLine));
    });

    testWidgets('tapping a card opens that decision', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Cantina da Nona').last);
      await tester.pumpAndSettle();
      expect(find.text('DETAIL h9'), findsOneWidget);
    });

    testWidgets('tapping the visible strip of an older card opens it', (
      tester,
    ) async {
      await _pump(tester);
      await tester.drag(find.byType(HistoryStack), const Offset(0, 1200));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Norimon').last);
      await tester.pumpAndSettle();
      expect(find.text('DETAIL h6'), findsOneWidget);
    });

    testWidgets('does not overflow at 375x667', (tester) async {
      await _pump(tester, size: const Size(375, 667));

      expect(tester.takeException(), isNull);
    });
  });

  group('empty', () {
    final empty = FakeHistoryRepository(entries: const <HistoryEntry>[]);

    testWidgets('shows the empty state and the profile avatar', (
      tester,
    ) async {
      await _pump(tester, repository: empty);

      expect(find.text('Seu histórico'), findsOneWidget);
      expect(find.text('Seu primeiro rango'), findsOneWidget);
      expect(
        find.text(
          'Cada decisão aparece aqui, com a comida e o restaurante que você '
          'escolheu.',
        ),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Abrir perfil'), findsOneWidget);
      expect(find.bySemanticsLabel('Voltar'), findsNothing);
    });

    testWidgets('"Decidir meu rango" goes to home', (tester) async {
      await _pump(tester, repository: empty);

      await tester.ensureVisible(find.text('Decidir meu rango'));
      await tester.tap(find.text('Decidir meu rango'));
      await tester.pumpAndSettle();

      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('does not overflow at 375x667', (tester) async {
      await _pump(tester, repository: empty, size: const Size(375, 667));

      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('offers a way out when the history fails to load', (
    tester,
  ) async {
    final failing = _MockHistoryRepository();
    when(failing.fetchAll).thenThrow(Exception('offline'));
    await _pump(tester, repository: failing);

    expect(find.text('Não deu para carregar seu histórico.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });
}
