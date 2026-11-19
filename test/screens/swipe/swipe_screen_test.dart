import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/avatar_button.dart';
import 'package:rango_app/core/widgets/food_card.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/category_tree.dart';
import 'package:rango_app/models/food_category.dart';
import 'package:rango_app/models/like_state.dart';
import 'package:rango_app/screens/profile/profile_sheet.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';
import 'package:rango_app/screens/swipe/widgets/food_card_deck.dart';

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
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        deckRandomProvider.overrideWithValue(InOrderRandom()),
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

/// The card on top: the like button names its food.
Finder onTop(String label) => find.bySemanticsLabel('Curtir $label');

FoodCategory food(String id) =>
    LocalCategoryRepository.seed.firstWhere((c) => c.id == id);

LikeState game(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(SwipeScreen).last),
  );
  final game = container.read(swipeViewModelProvider).requireValue.game;
  if (game == null) throw StateError('No game on screen');
  return game;
}

Future<void> openSavory(WidgetTester tester) async {
  await tester.tap(find.text('Salgado'));
  await tester.pumpAndSettle();
}

/// Taps "Passar" until [label] is the card on top.
Future<void> passUntil(WidgetTester tester, String label) async {
  for (var i = 0; i < 40; i++) {
    if (find.bySemanticsLabel('Curtir $label').evaluate().isNotEmpty) return;
    await tester.tap(find.bySemanticsLabel(RegExp('^Passar ')));
    await tester.pumpAndSettle();
  }
  fail('$label never came back on top');
}

/// Likes Macarrão whenever it is on top and passes everything else.
Future<void> likeSpaghettiUntilMatch(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    if (find.textContaining('RESULT').evaluate().isNotEmpty) return;
    await passUntil(tester, 'Macarrão');
    await tester.tap(find.bySemanticsLabel('Curtir Macarrão'));
    await tester.pumpAndSettle();
  }
  fail('no match');
}

void main() {
  testWidgets('the avatar opens the Profile Sheet', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(AvatarButton));
    await tester.pumpAndSettle();

    expect(find.byType(ProfileSheet), findsOneWidget);
  });

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
    expect(find.text('Rango'), findsNothing);
    expect(find.bySemanticsLabel('Abrir perfil'), findsOneWidget);
    expect(voltar, findsNothing);
  });

  testWidgets('tapping a group opens the single card with Voltar only', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Salgado'));
    await tester.pumpAndSettle();

    expect(onTop('Macarrão'), findsOneWidget);
    expect(cardTitled('Macarrão'), findsOneWidget);
    // Only the meter, the deck and the buttons: no question above the card
    // and no line of examples under the food name.
    expect(find.textContaining('Curte'), findsNothing);
    expect(find.text('Espaguete, penne, fettuccine'), findsNothing);
    expect(find.bySemanticsLabel('0 de 3 curtidas'), findsOneWidget);
    expect(find.bySemanticsLabel('Passar Macarrão'), findsOneWidget);
    expect(find.bySemanticsLabel('Curtir Macarrão'), findsOneWidget);
    expect(voltar, findsOneWidget);
    expect(find.bySemanticsLabel('Abrir perfil'), findsNothing);
  });

  testWidgets('the like meter sits centered above the deck', (tester) async {
    await pumpScreen(tester);
    await openSavory(tester);

    final meter = tester.getCenter(find.bySemanticsLabel('0 de 3 curtidas'));
    final card = tester.getRect(cardTitled('Macarrão'));
    expect(meter.dx, closeTo(card.center.dx, 1));
    expect(meter.dy, lessThan(card.top));
  });

  testWidgets('the card is as big as the Figma card on a 402 phone', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openSavory(tester);

    final card = tester.getRect(cardTitled('Macarrão'));
    expect(card.width, closeTo(FoodCardDeck.cardWidth, 1));
    expect(card.height, closeTo(FoodCardDeck.cardHeight, 2));
  });

  testWidgets('on a small phone the card shrinks to fit with the buttons', (
    tester,
  ) async {
    await pumpScreen(tester, size: const Size(375, 667));
    await openSavory(tester);

    final card = tester.getRect(cardTitled('Macarrão'));
    final like = tester.getRect(find.bySemanticsLabel('Curtir Macarrão'));
    expect(card.bottom, lessThan(like.top));
    expect(like.bottom, lessThanOrEqualTo(667));
  });

  testWidgets('the next card peeks out under the one on top', (tester) async {
    await pumpScreen(tester);
    await openSavory(tester);

    expect(cardTitled('Pizza'), findsOneWidget);
    expect(
      tester.getBottomLeft(cardTitled('Pizza')).dy,
      greaterThan(tester.getBottomLeft(cardTitled('Macarrão')).dy),
    );
  });

  testWidgets('dragging a root card far enough chooses it', (tester) async {
    await pumpScreen(tester);

    await tester.drag(find.text('Doce'), const Offset(150, 0));
    await tester.pumpAndSettle();

    expect(onTop('Sorvete'), findsOneWidget);
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
    await openSavory(tester);
    await tester.tap(find.bySemanticsLabel('Curtir Macarrão'));
    await tester.pumpAndSettle();

    await tester.tap(voltar);
    await tester.pumpAndSettle();

    expect(find.textContaining('Bora decidir'), findsOneWidget);
    expect(find.text('Salgado'), findsOneWidget);
    expect(find.text('Doce'), findsOneWidget);
    expect(voltar, findsNothing);

    // The session really restarted: Doce deals its own cards.
    await tester.tap(find.text('Doce'));
    await tester.pumpAndSettle();
    expect(onTop('Sorvete'), findsOneWidget);
  });

  testWidgets('system back leaves the flow like Voltar', (tester) async {
    await pumpScreen(tester);
    await openSavory(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.textContaining('Bora decidir'), findsOneWidget);
    expect(voltar, findsNothing);
  });

  testWidgets('the heart button likes the card and shows the next one', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openSavory(tester);

    await tester.tap(find.bySemanticsLabel('Curtir Macarrão'));
    await tester.pumpAndSettle();

    expect(onTop('Pizza'), findsOneWidget);
    expect(game(tester).likesOf(food('spaghetti')), 1);
    expect(game(tester).passedIds, isEmpty);
  });

  testWidgets('the X button passes the card and shows the next one', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openSavory(tester);

    await tester.tap(find.bySemanticsLabel('Passar Macarrão'));
    await tester.pumpAndSettle();

    expect(onTop('Pizza'), findsOneWidget);
    expect(game(tester).likesOf(food('spaghetti')), 0);
    expect(game(tester).passedIds, {'spaghetti'});
  });

  testWidgets('dragging the card right likes it, left passes it', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openSavory(tester);

    await tester.drag(find.text('Macarrão'), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(onTop('Pizza'), findsOneWidget);
    expect(game(tester).likesOf(food('spaghetti')), 1);

    await tester.drag(find.text('Pizza'), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(onTop('Hambúrguer'), findsOneWidget);
    expect(game(tester).passedIds, {'pizza'});
  });

  testWidgets('a short drag on the card snaps back without swiping', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openSavory(tester);
    final before = tester.getCenter(cardTitled('Macarrão'));

    await tester.drag(find.text('Macarrão'), const Offset(40, 0));
    await tester.pumpAndSettle();

    expect(onTop('Macarrão'), findsOneWidget);
    expect(tester.getCenter(cardTitled('Macarrão')), before);
  });

  testWidgets('the sticker says what letting go will do', (tester) async {
    await pumpScreen(tester);
    await openSavory(tester);
    expect(find.text('Curti!'), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(cardTitled('Macarrão')),
    );
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(40, 0));
    await tester.pump();
    expect(find.text('Curti!'), findsOneWidget);

    await gesture.moveBy(const Offset(-160, 0));
    await tester.pump();
    expect(find.text('Curti!'), findsNothing);
    expect(find.text('Passo!'), findsOneWidget);

    await gesture.cancel();
    await tester.pumpAndSettle();
  });

  testWidgets('the meter shows the likes of the food on top', (tester) async {
    await pumpScreen(tester);
    await openSavory(tester);
    await tester.tap(find.bySemanticsLabel('Curtir Macarrão'));
    await tester.pumpAndSettle();

    await passUntil(tester, 'Macarrão');

    expect(find.bySemanticsLabel('1 de 3 curtidas'), findsOneWidget);
  });

  testWidgets('three likes on one food open the result with every swipe', (
    tester,
  ) async {
    await pumpScreen(tester);
    await openSavory(tester);

    await likeSpaghettiUntilMatch(tester);

    final savory = CategoryTree(
      LocalCategoryRepository.seed,
    ).childrenOf(food('savory'));
    final passed = savory.skip(1).map((c) => c.id);
    expect(
      find.text(
        'RESULT ${[
          'savory',
          'spaghetti',
          ...passed,
          'spaghetti',
          'spaghetti',
        ].join(',')}',
      ),
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

  testWidgets('with reduced motion a swipe takes effect at once', (
    tester,
  ) async {
    await pumpScreen(tester, disableAnimations: true);
    await openSavory(tester);

    await tester.drag(find.text('Macarrão'), const Offset(200, 0));
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
    expect(onTop('Pizza'), findsOneWidget);
  });

  testWidgets('fits a small phone without overflow', (tester) async {
    await pumpScreen(tester, size: const Size(375, 667));
    expect(tester.takeException(), isNull);

    await openSavory(tester);
    expect(tester.takeException(), isNull);
    expect(
      tester.getBottomLeft(find.bySemanticsLabel('Curtir Macarrão')).dy,
      lessThanOrEqualTo(667),
    );

    await likeSpaghettiUntilMatch(tester);
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
