import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/apple_sign_in_button.dart';
import 'package:rango_app/core/widgets/google_sign_in_button.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/core/widgets/rango_loading_view.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_account_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/login/login_screen.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../helpers/auth_form.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Future<FakeAuthRepository> _withJoana() async {
  final repository = FakeAuthRepository();
  await repository.signUp(
    name: 'Joana',
    email: 'joana@email.com',
    password: '12345678',
  );
  await repository.signOut();
  return repository;
}

Future<void> _pump(WidgetTester tester, AuthRepository repository) =>
    pumpAuthScreen(
      tester,
      route: '/login',
      repository: repository,
      screens: {'/login': (_) => const LoginScreen()},
    );

void main() {
  testWidgets('an account without the terms goes to the acceptance screen', (
    tester,
  ) async {
    final repository = await _withJoana();
    await pumpAuthScreen(
      tester,
      route: '/login',
      repository: repository,
      accounts: FakeAccountRepository(),
      screens: {'/login': (_) => const LoginScreen()},
    );

    await typeIn(tester, 'E-mail', 'joana@email.com');
    await typeIn(tester, 'Senha', '12345678');
    await tapButton(tester, 'Entrar');

    expect(find.text('/accept-terms'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Criar conta pushes the sign-up, and back returns to login', (
    tester,
  ) async {
    await _pump(tester, FakeAuthRepository());

    await tapButton(tester, 'Ainda não tem conta? Criar conta');
    expect(find.text('/signup'), findsOneWidget);

    await goBack(tester);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a full-screen loading covers the form while signing in', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    final pending = Completer<AppUser>();
    when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);
    await _pump(tester, repository);

    await typeIn(tester, 'E-mail', 'joana@email.com');
    await typeIn(tester, 'Senha', '12345678');
    await tester.tap(find.widgetWithText(RangoButton, 'Entrar'));
    await tester.pump();

    expect(find.byType(RangoLoadingView), findsOneWidget);
    expect(find.text('Entrando…'), findsOneWidget);

    pending.completeError(const UnexpectedFailure());
    await tester.pumpAndSettle();
    expect(find.byType(RangoLoadingView), findsNothing);
    expect(find.byType(InlineAlert), findsOneWidget);
  });

  testWidgets(
    'fits the screen on iOS, with Apple and Google',
    (tester) async {
      await _pump(tester, FakeAuthRepository());

      expect(tester.takeException(), isNull);
      expect(find.text('Continuar com a Apple'), findsOneWidget);
      expect(find.text('Continuar com o Google'), findsOneWidget);
      expect(
        tester
            .getBottomLeft(
              find.widgetWithText(
                RangoButton,
                'Ainda não tem conta? Criar conta',
              ),
            )
            .dy,
        lessThanOrEqualTo(874),
      );
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('Android has no Apple button', (tester) async {
    await _pump(tester, FakeAuthRepository());

    expect(find.text('Continuar com a Apple'), findsNothing);
    expect(find.text('Continuar com o Google'), findsOneWidget);
  });

  testWidgets('Google signs in and goes back to where the person was', (
    tester,
  ) async {
    final repository = FakeAuthRepository();
    await _pump(tester, repository);

    await tapText(tester, 'Continuar com o Google');

    expect(find.text('HOME'), findsOneWidget);
    expect((await repository.ensureSignedIn()).isAnonymous, isFalse);
  });

  testWidgets(
    'Apple on iOS calls the repository',
    (tester) async {
      final repository = _MockAuthRepository();
      when(repository.signInWithApple).thenAnswer((_) async => null);
      await _pump(tester, repository);

      await tapText(tester, 'Continuar com a Apple');

      // Closing the sheet keeps the person on the form.
      verify(repository.signInWithApple).called(1);
      expect(find.byType(LoginScreen), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('the social buttons are off while signing in', (tester) async {
    final repository = _MockAuthRepository();
    final pending = Completer<AppUser?>();
    when(repository.signInWithGoogle).thenAnswer((_) => pending.future);
    await _pump(tester, repository);

    await tapText(tester, 'Continuar com o Google', settle: false);

    final google = tester.widget<GoogleSignInButton>(
      find.byType(GoogleSignInButton),
    );
    expect(google.onPressed, isNull);
    final apple = tester.widget<AppleSignInButton>(
      find.byType(AppleSignInButton),
    );
    expect(apple.onPressed, isNull);
    pending.complete(null);
    await tester.pumpAndSettle();
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets(
    'Apple uses the official button',
    (tester) async {
      await _pump(tester, FakeAuthRepository());

      final button = tester.widget<SignInWithAppleButton>(
        find.byType(SignInWithAppleButton),
      );
      expect(button.style, SignInWithAppleButtonStyle.black);
      expect(button.text, 'Continuar com a Apple');
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets('signing in goes back to where the person was', (tester) async {
    final repository = await _withJoana();
    await _pump(tester, repository);

    await typeIn(tester, 'E-mail', ' joana@email.com ');
    await typeIn(tester, 'Senha', '12345678');
    await tapButton(tester, 'Entrar');

    expect(find.text('HOME'), findsOneWidget);
    expect((await repository.ensureSignedIn()).name, 'Joana');
  });

  testWidgets('a wrong password shows under the field and clears on edit', (
    tester,
  ) async {
    await _pump(tester, await _withJoana());

    await typeIn(tester, 'E-mail', 'joana@email.com');
    await typeIn(tester, 'Senha', 'wrong-one');
    await tapButton(tester, 'Entrar');

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);

    await typeIn(tester, 'Senha', 'wrong-on');
    await tester.pump();
    expect(find.text('E-mail ou senha incorretos.'), findsNothing);
  });

  testWidgets('empty fields are asked for without calling the server', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    await _pump(tester, repository);

    await tapButton(tester, 'Entrar');

    expect(find.text('Digite seu e-mail.'), findsOneWidget);
    expect(find.text('Digite sua senha.'), findsOneWidget);
    verifyNever(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('without network shows the alert and keeps what was typed', (
    tester,
  ) async {
    final repository = _MockAuthRepository();
    when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const NetworkFailure());
    await _pump(tester, repository);

    await typeIn(tester, 'E-mail', 'joana@email.com');
    await typeIn(tester, 'Senha', '12345678');
    await tapButton(tester, 'Entrar');

    expect(
      find.widgetWithText(
        InlineAlert,
        'Sem conexão. Confira sua internet e tente de novo.',
      ),
      findsOneWidget,
    );
    expect(find.text('joana@email.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the links open sign up and password reset', (tester) async {
    await _pump(tester, FakeAuthRepository());

    await typeIn(tester, 'E-mail', 'joana@email.com');
    await tapButton(tester, 'Esqueci minha senha');
    expect(find.text('/password-reset joana@email.com'), findsOneWidget);

    await goBack(tester);
    await tapButton(tester, 'Ainda não tem conta? Criar conta');
    expect(find.text('/signup'), findsOneWidget);
  });
}
