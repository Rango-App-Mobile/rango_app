import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/app/app.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/data/local_category_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/startup/startup_screen.dart';
import 'package:rango_app/screens/swipe/swipe_screen.dart';
import 'package:rango_app/screens/swipe/swipe_view_model.dart';

import '../helpers/in_order_random.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

final Finder homeTab = find.bySemanticsLabel('Home, aba 1 de 2');
final Finder historyTab = find.bySemanticsLabel('Histórico, aba 2 de 2');

Future<void> pumpApp(WidgetTester tester) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        categoryRepositoryProvider.overrideWithValue(LocalCategoryRepository()),
        duelRandomProvider.overrideWithValue(InOrderRandom()),
      ],
      child: const RangoApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the router only after the user is ready', (tester) async {
    final signIn = Completer<AppUser>();
    final repository = _MockAuthRepository();
    when(repository.ensureSignedIn).thenAnswer((_) => signIn.future);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          categoryRepositoryProvider.overrideWithValue(
            LocalCategoryRepository(),
          ),
        ],
        child: const RangoApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(StartupScreen), findsOneWidget);
    expect(find.byType(SwipeScreen), findsNothing);

    signIn.complete(FakeAuthRepository.user);
    await tester.pumpAndSettle();

    expect(find.byType(StartupScreen), findsNothing);
    expect(find.byType(SwipeScreen), findsOneWidget);
  });

  testWidgets('opens on Home with the Tab Bar', (tester) async {
    await pumpApp(tester);

    expect(find.textContaining('Bora decidir'), findsOneWidget);
    expect(homeTab, findsOneWidget);
    expect(historyTab, findsOneWidget);
  });

  testWidgets('switches between the Home and Histórico tabs', (tester) async {
    await pumpApp(tester);

    await tester.tap(historyTab);
    await tester.pumpAndSettle();

    expect(find.text('Seu histórico'), findsOneWidget);
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(historyTab).flagsCollection.isSelected,
      Tristate.isTrue,
    );
    expect(
      tester.getSemantics(homeTab).flagsCollection.isSelected,
      Tristate.isFalse,
    );
    handle.dispose();

    await tester.tap(homeTab);
    await tester.pumpAndSettle();

    expect(find.textContaining('Bora decidir'), findsOneWidget);
  });

  group('swipe flow', () {
    Future<void> reachResult(WidgetTester tester) async {
      await tester.tap(find.text('Salgado'));
      await tester.pumpAndSettle();
      expect(homeTab, findsNothing);

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('Macarrão'));
        await tester.pumpAndSettle();
      }
    }

    testWidgets('converges on a result and opens restaurants', (tester) async {
      await pumpApp(tester);

      await reachResult(tester);

      expect(find.text('Deu match!'), findsOneWidget);
      expect(find.text('Macarrão'), findsOneWidget);
      expect(homeTab, findsNothing);

      final seeRestaurants = find.text('Ver restaurantes perto');
      await tester.ensureVisible(seeRestaurants);
      await tester.pumpAndSettle();
      await tester.tap(seeRestaurants);
      await tester.pumpAndSettle();

      expect(find.text('Restaurantes em breve'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Voltar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bora decidir'), findsOneWidget);
      expect(homeTab, findsOneWidget);
    });

    testWidgets('Recomeçar on the result returns to Home level 1', (
      tester,
    ) async {
      await pumpApp(tester);
      await reachResult(tester);

      final restart = find.text('Recomeçar');
      await tester.ensureVisible(restart);
      await tester.pumpAndSettle();
      await tester.tap(restart);
      await tester.pumpAndSettle();

      expect(find.textContaining('Bora decidir'), findsOneWidget);
      expect(homeTab, findsOneWidget);
    });

    testWidgets('Voltar on a choice level returns to Home level 1', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.text('Salgado'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Voltar'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Bora decidir'), findsOneWidget);
      expect(homeTab, findsOneWidget);
    });
  });
}
