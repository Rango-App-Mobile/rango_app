import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/core/widgets/rango_text_field.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_account_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/sign_up/sign_up_screen.dart';

import '../../helpers/auth_form.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Future<void> _pump(
  WidgetTester tester,
  AuthRepository repository, {
  FakeAccountRepository? accounts,
}) => pumpAuthScreen(
  tester,
  route: '/signup',
  repository: repository,
  accounts: accounts,
  screens: {'/signup': (_) => const SignUpScreen()},
);

Future<void> _fill(
  WidgetTester tester, {
  String name = 'Joana',
  String email = 'joana@email.com',
  String password = '12345678',
  String? confirmEmail,
  String? confirmPassword,
  bool terms = true,
}) async {
  await typeIn(tester, 'Nome', name);
  await typeIn(tester, 'E-mail', email);
  await typeIn(tester, 'Confirmar e-mail', confirmEmail ?? email);
  await typeIn(tester, 'Senha', password);
  await typeIn(tester, 'Confirmar senha', confirmPassword ?? password);
  if (terms) {
    await tester.ensureVisible(find.byType(Switch));
    await tester.tap(find.byType(Switch));
    await tester.pump();
  }
}

void main() {
  testWidgets('fields come in order: name, e-mails, passwords, terms', (
    tester,
  ) async {
    await _pump(tester, FakeAuthRepository());

    double top(Finder finder) => tester.getTopLeft(finder).dy;
    final tops = [
      for (final label in [
        'Nome',
        'E-mail',
        'Confirmar e-mail',
        'Senha',
        'Confirmar senha',
      ])
        top(find.widgetWithText(RangoTextField, label)),
      top(find.byType(Switch)),
      top(find.widgetWithText(RangoButton, 'Criar conta')),
    ];
    expect(tops, [...tops]..sort());
  });

  testWidgets('different confirmations and missing terms are asked for', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    await _pump(tester, repository);

    await _fill(
      tester,
      confirmEmail: 'outro@email.com',
      confirmPassword: '87654321',
      terms: false,
    );
    await tapButton(tester, 'Criar conta');

    expect(find.text('Os e-mails não são iguais.'), findsOneWidget);
    expect(find.text('As senhas não são iguais.'), findsOneWidget);
    expect(find.text('Aceite os termos para criar a conta.'), findsOneWidget);
    verifyNever(
      () => repository.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('signing up records the terms for the new account', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    final accounts = FakeAccountRepository();
    await _pump(tester, repository, accounts: accounts);

    await _fill(tester);
    await tapButton(tester, 'Criar conta');

    final user = await repository.ensureSignedIn();
    expect(await accounts.hasAcceptedTerms(user.uid), isTrue);
  });

  testWidgets('a full-screen loading covers the form while submitting', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    final pending = Completer<AppUser>();
    when(
      () => repository.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);
    await _pump(tester, repository);

    await _fill(tester);
    // The spinner never settles, so pump instead of pumpAndSettle.
    await tester.tap(find.widgetWithText(RangoButton, 'Criar conta'));
    await tester.pump();

    expect(find.byType(RangoLoadingView), findsOneWidget);
    expect(find.text('Criando sua conta…'), findsOneWidget);

    pending.completeError(const UnexpectedFailure());
    await tester.pumpAndSettle();
    expect(find.byType(RangoLoadingView), findsNothing);
    expect(find.byType(InlineAlert), findsOneWidget);
  });

  testWidgets('scrolls to the last button on a small screen', (tester) async {
    await _pump(tester, FakeAuthRepository());

    // Five fields plus the terms are taller than the screen: the form must
    // scroll instead of overflowing.
    final last = find.widgetWithText(RangoButton, 'Já tem conta? Entrar');
    await tester.ensureVisible(last);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(tester.getBottomLeft(last).dy, lessThanOrEqualTo(874));
  });

  testWidgets('creating the account goes back to where the person was', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await _pump(tester, repository);

    await _fill(tester);
    await tapButton(tester, 'Criar conta');

    expect(find.text('HOME'), findsOneWidget);
    final user = await repository.ensureSignedIn();
    expect(user.isAnonymous, isFalse);
    expect(user.name, 'Joana');
  });

  testWidgets('checks name, e-mail and password before calling the server', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    await _pump(tester, repository);

    await _fill(tester, name: ' ', email: 'joana', password: '1234567');
    await tapButton(tester, 'Criar conta');

    expect(find.text('Digite seu nome.'), findsOneWidget);
    expect(find.text('Confira o e-mail.'), findsOneWidget);
    // The helper turns into the error, with the same words.
    expect(find.text('Pelo menos 8 caracteres.'), findsOneWidget);
    verifyNever(
      () => repository.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('an e-mail in use shows under the field, keeping the rest', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await repository.signUp(
      name: 'Joana',
      email: 'joana@email.com',
      password: '12345678',
    );
    await repository.signOut();
    await _pump(tester, repository);

    await _fill(tester);
    await tapButton(tester, 'Criar conta');

    expect(
      find.text('Esse e-mail já tem conta. Entre nele ou use outro.'),
      findsOneWidget,
    );
    expect(find.text('Joana'), findsOneWidget);
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('an unexpected error shows the alert', (tester) async {
    final repository = _MockAuthRepository();
    when(
      () => repository.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const UnexpectedFailure());
    await _pump(tester, repository);

    await _fill(tester);
    await tapButton(tester, 'Criar conta');

    expect(
      find.widgetWithText(InlineAlert, 'Algo deu errado. Tente de novo.'),
      findsOneWidget,
    );
  });

  testWidgets('Já tem conta? replaces this screen with the login', (
    tester,
  ) async {
    await _pump(tester, FakeAuthRepository());

    await tapButton(tester, 'Já tem conta? Entrar');
    expect(find.text('/login'), findsOneWidget);

    await goBack(tester);
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Google creates the account; Apple shows only on iOS', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await _pump(tester, repository);
    expect(find.text('Continuar com a Apple'), findsNothing);

    await tapText(tester, 'Continuar com o Google');

    expect(find.text('HOME'), findsOneWidget);
    expect((await repository.ensureSignedIn()).isAnonymous, isFalse);
  });

  testWidgets(
    'Apple on iOS creates the account',
    (tester) async {
      final repository = FakeAuthRepository();
      await _pump(tester, repository);

      await tapText(tester, 'Continuar com a Apple');

      expect(find.text('HOME'), findsOneWidget);
      expect((await repository.ensureSignedIn()).email, contains('icloud'));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
