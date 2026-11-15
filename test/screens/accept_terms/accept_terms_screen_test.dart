import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rango_app/app/theme/app_theme.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_account_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/screens/accept_terms/accept_terms_screen.dart';

import '../../helpers/auth_form.dart';

class _Slow extends FakeAccountRepository {
  final gate = Completer<void>();

  @override
  Future<void> acceptTerms(String uid) => gate.future;
}

Future<void> _pump(WidgetTester tester, AccountRepository accounts) async {
  final auth = FakeAuthRepository();
  await auth.signInWithGoogle();
  await pumpAuthScreen(
    tester,
    route: '/accept-terms',
    repository: auth,
    accounts: accounts,
    screens: {'/accept-terms': (_) => const AcceptTermsScreen()},
  );
}

void main() {
  testWidgets('renders the title and the prefilled name', (tester) async {
    await _pump(tester, FakeAccountRepository());

    expect(find.text('Quase lá'), findsOneWidget);
    expect(find.text('Ana Souza'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('without the switch it asks for the terms', (tester) async {
    await _pump(tester, FakeAccountRepository());

    await tapButton(tester, 'Continuar');

    expect(find.text('Aceite os termos para continuar.'), findsOneWidget);
    expect(find.byType(AcceptTermsScreen), findsOneWidget);
  });

  testWidgets('accepting records the terms and goes back', (tester) async {
    final accounts = FakeAccountRepository();
    await _pump(tester, accounts);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tapButton(tester, 'Continuar');

    expect(find.text('HOME'), findsOneWidget);
    expect(await accounts.hasAcceptedTerms('fake-uid'), isTrue);
  });

  testWidgets('shows the loading overlay while submitting', (tester) async {
    final accounts = _Slow();
    await _pump(tester, accounts);

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tester.tap(find.widgetWithText(RangoButton, 'Continuar'));
    await tester.pump();

    expect(find.byType(RangoLoadingView), findsOneWidget);
    accounts.gate.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('accepting closes the login left underneath', (tester) async {
    final auth = FakeAuthRepository();
    await auth.signInWithGoogle();
    final accounts = FakeAccountRepository();
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const Text('HOME')),
        GoRoute(path: '/login', builder: (_, _) => const Text('LOGIN')),
        GoRoute(
          path: '/accept-terms',
          builder: (_, _) => const AcceptTermsScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(auth),
          accountRepositoryProvider.overrideWithValue(accounts),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    unawaited(router.push<void>('/login'));
    await tester.pumpAndSettle();
    unawaited(router.push<void>('/accept-terms'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pump();
    await tapButton(tester, 'Continuar');

    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('LOGIN'), findsNothing);
  });

  testWidgets('Agora não signs out and goes back', (tester) async {
    await _pump(tester, FakeAccountRepository());

    await tapButton(tester, 'Agora não');

    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('scrolls on a small screen', (tester) async {
    await _pump(tester, FakeAccountRepository());
    tester.view.physicalSize = const Size(320, 300);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Agora não'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
