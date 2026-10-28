import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

import '../../helpers/in_order_random.dart';

Future<void> pumpScreen(
  WidgetTester tester, {
  Size size = const Size(402, 874),
  bool disableAnimations = false,
  bool settle = true,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        duelRandomProvider.overrideWithValue(InOrderRandom()),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: child!,
        ),
        routerConfig: _router(),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

Finder cardTitled(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(FoodCard));

GoRouter _router() => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', builder: (_, _) => const SwipeScreen()),
    GoRoute(
      path: '/choose',
      builder: (_, _) => const SwipeScreen(mode: SwipeMode.flow),
    ),
    GoRoute(
      path: '/result',
      builder: (_, state) =>
          Text('RESULT ${state.uri.queryParameters['path']}'),
    ),
  ],
);

final Finder voltar = find.bySemanticsLabel('Voltar');

void main() {
  testWidgets('root shows the options, the Top Bar Principal, no Voltar', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Salgado'), findsOneWidget);
    expect(find.text('Doce'), findsOneWidget);
    expect(find.textContaining('Bora decidir'), findsOneWidget);
    expect(
      find.text('Toque ou arraste o card que deu mais vontade.'),
      findsOneWidget,
    );
    expect(find.text('ou'), findsOneWidget);
    expect(find.text('Rango'), findsOneWidget);
    expect(find.bySemanticsLabel('Abrir perfil'), findsOneWidget);
    expect(voltar, findsNothing);
  });

  testWidgets('tapping a card opens the flow screen with Voltar only', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();

    expect(find.text('Macarrão ou\npizza?'), findsOneWidget);
    expect(find.text('Macarrão'), findsOneWidget);
    expect(find.text('Pizza'), findsOneWidget);
    expect(voltar, findsOneWidget);
    expect(find.bySemanticsLabel('Abrir perfil'), findsNothing);
  });

  testWidgets('dragging a card far enough chooses it', (tester) async {
    await pumpScreen(tester);

    await tester.drag(find.text('Doce'), const Offset(150, 0));
    await tester.pumpAndSettle();

    expect(find.text('Sorvete'), findsOneWidget);
    expect(find.text('Bolo'), findsOneWidget);
  });

  testWidgets('a short drag snaps back without choosing', (tester) async {
    await pumpScreen(tester);
    final before = tester.getCenter(cardTitled('Salgado'));

    await tester.drag(find.text('Salgado'), const Offset(40, 0));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Salgado'), findsOneWidget);
    expect(find.text('Macarrão'), findsNothing);
    expect(tester.getCenter(cardTitled('Salgado')), before);
  });

  testWidgets('the card follows the finger while dragging', (tester) async {
    await pumpScreen(tester);
    final before = tester.getCenter(cardTitled('Salgado'));

    final gesture = await tester.startGesture(before);
    // The first move only gets past the drag slop; the second one is followed.
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();

    expect(tester.getCenter(cardTitled('Salgado')).dx, greaterThan(before.dx));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('a cancelled drag snaps back without choosing', (tester) async {
    await pumpScreen(tester);
    final before = tester.getCenter(cardTitled('Salgado'));

    final gesture = await tester.startGesture(before);
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();
    await gesture.cancel();
    await tester.pumpAndSettle();

    expect(find.text('Macarrão'), findsNothing);
    expect(tester.getCenter(cardTitled('Salgado')), before);
  });

  testWidgets('Voltar leaves the flow and resets the session', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Macarrão'));
    await tester.pumpAndSettle();

    await tester.tap(voltar);
    await tester.pumpAndSettle();

    expect(find.textContaining('Bora decidir'), findsOneWidget);
    expect(find.text('Salgado'), findsOneWidget);
    expect(find.text('Doce'), findsOneWidget);
    expect(voltar, findsNothing);

    // The session really restarted: Doce leads to its own level 2.
    await tester.tap(find.text('Doce'));
    await tester.pumpAndSettle();
    expect(find.text('Sorvete'), findsOneWidget);
  });

  testWidgets('system back leaves the flow like Voltar', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.textContaining('Bora decidir'), findsOneWidget);
    expect(voltar, findsNothing);
  });

  testWidgets('a duel round swaps the loser for the next challenger', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Macarrão'));
    await tester.pumpAndSettle();

    expect(find.text('Macarrão ou\nhambúrguer?'), findsOneWidget);
    expect(find.text('Pizza'), findsNothing);
    expect(find.text('Macarrão está ganhando com 1 vitória.'), findsOneWidget);
  });

  testWidgets('a dragged champion comes back for the next round', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();
    final before = tester.getCenter(cardTitled('Macarrão')).dx;

    await tester.drag(find.text('Macarrão'), const Offset(150, 0));
    await tester.pumpAndSettle();

    // Only the horizontal offset: the header above may change height.
    expect(find.text('Hambúrguer'), findsOneWidget);
    expect(tester.getCenter(cardTitled('Macarrão')).dx, before);
  });

  testWidgets('three wins in a row open the result with every choice', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Macarrão'));
      await tester.pumpAndSettle();
    }

    expect(
      find.text('RESULT savory,spaghetti,spaghetti,spaghetti'),
      findsOneWidget,
    );
  });

  testWidgets('with reduced motion the cards are visible after one pump', (
    tester,
  ) async {
    await pumpScreen(tester, disableAnimations: true, settle: false);
    await tester.pump();
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(FoodCard).first,
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    expect(find.text('Salgado'), findsOneWidget);
  });

  testWidgets('with animations the cards fade in', (tester) async {
    await pumpScreen(tester, settle: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byType(FoodCard).first,
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(fade.opacity.value, 1);
  });

  testWidgets('with reduced motion a short drag jumps straight back', (
    tester,
  ) async {
    await pumpScreen(tester, disableAnimations: true);
    final before = tester.getCenter(cardTitled('Salgado'));

    await tester.drag(find.text('Salgado'), const Offset(40, 0));
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getCenter(cardTitled('Salgado')), before);
  });

  testWidgets('fits a small phone without overflow, scrolling if needed', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(375, 667));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Macarrão'));
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
    expect(find.textContaining('RESULT'), findsOneWidget);
  });

  testWidgets('offers a way out when the options fail to load', (tester) async {
    tester.view
      ..physicalSize = const Size(402, 874)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = _FlakyRepository();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(theme: AppTheme.light, home: const SwipeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Não deu para carregar as opções.'), findsOneWidget);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Salgado'), findsOneWidget);
  });

  testWidgets('shows a progress indicator while loading', (tester) async {
    await pumpScreen(tester, settle: false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });
}

class _FlakyRepository extends LocalCategoryRepository {
  var _calls = 0;

  @override
  Future<List<FoodCategory>> fetchAll() async {
    _calls++;
    if (_calls == 1) throw Exception('offline');
    return super.fetchAll();
  }
}
