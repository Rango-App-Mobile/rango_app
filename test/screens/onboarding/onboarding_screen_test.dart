import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/data/fake_onboarding_repository.dart';
import 'package:rango_app/data/onboarding_repository.dart';
import 'package:rango_app/screens/onboarding/onboarding_screen.dart';
import 'package:rango_app/screens/swipe/widgets/like_meter.dart';

Future<GoRouter> _pump(
  WidgetTester tester,
  FakeOnboardingRepository repository, {
  bool reduceMotion = true,
  String start = '/onboarding',
}) async {
  tester.view
    ..physicalSize = const Size(402, 874)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: reduceMotion);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final router = GoRouter(
    initialLocation: start,
    routes: [
      GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [onboardingRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  // The loop never settles, so without reduced motion just let it start.
  await (reduceMotion ? tester.pumpAndSettle() : tester.pump());
  return router;
}

void main() {
  testWidgets('opens on the first page with Pular and Próximo', (tester) async {
    await _pump(tester, FakeOnboardingRepository(seen: false));

    expect(find.text('Doce ou salgado?'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('Próximo'), findsOneWidget);
    expect(find.text('Começar'), findsNothing);
  });

  testWidgets('Próximo walks the three pages; the last one hides Pular', (
    tester,
  ) async {
    await _pump(tester, FakeOnboardingRepository(seen: false));

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Curta ou passe'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    expect(find.text('Rango de Porto Alegre'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
    // Kept in the tree so the progress bar does not jump, but out of reach.
    expect(find.text('Pular').hitTestable(), findsNothing);
  });

  testWidgets('page 2 ends on the match with a full Like Meter', (
    tester,
  ) async {
    await _pump(tester, FakeOnboardingRepository(seen: false));
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();

    // Reduced motion parks the demo at its end state.
    expect(find.text('Deu match!'), findsOneWidget);
    expect(tester.widget<LikeMeter>(find.byType(LikeMeter)).likes, 3);
    // The food cards carry only the name: no description line.
    expect(find.text('Espaguete, talharim, nhoque'), findsNothing);
  });

  testWidgets('swiping the pages also moves them', (tester) async {
    await _pump(tester, FakeOnboardingRepository(seen: false));

    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(find.text('Curta ou passe'), findsOneWidget);
  });

  testWidgets('Começar on the first open marks it seen and goes home', (
    tester,
  ) async {
    final repository = FakeOnboardingRepository(seen: false);
    await _pump(tester, repository);
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Próximo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(repository.hasSeen, isTrue);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Pular marks it seen and goes home', (tester) async {
    final repository = FakeOnboardingRepository(seen: false);
    await _pump(tester, repository);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(repository.hasSeen, isTrue);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('reopened from the Profile it goes back instead of home', (
    tester,
  ) async {
    final router = await _pump(
      tester,
      FakeOnboardingRepository(),
      start: '/home',
    );
    unawaited(router.push('/onboarding'));
    await tester.pumpAndSettle();
    expect(find.text('Doce ou salgado?'), findsOneWidget);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('Doce ou salgado?'), findsNothing);
  });

  testWidgets('animates and loops without reduced motion', (tester) async {
    await _pump(
      tester,
      FakeOnboardingRepository(seen: false),
      reduceMotion: false,
    );

    // Mid-loop of page 1 and past a full loop: no exception, still on screen.
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.text('Salgado'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3000));
    expect(find.text('Doce ou salgado?'), findsOneWidget);

    await tester.tap(find.text('Próximo'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 5000));
    expect(find.text('Curta ou passe'), findsOneWidget);
  });
}
