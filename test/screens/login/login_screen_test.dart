import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/screens/login/login_screen.dart';

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
  testWidgets('fits the screen, with Apple and Google still disabled', (
    tester,
  ) async {
    await _pump(tester, FakeAuthRepository());

    expect(tester.takeException(), isNull);
    for (final label in ['Continuar com a Apple', 'Continuar com o Google']) {
      final button = tester.widget<RangoButton>(
        find.widgetWithText(RangoButton, label),
      );
      expect(button.onPressed, isNull, reason: label);
    }
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
  });

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

    // Sign up replaced the login: back leaves the flow.
    await goBack(tester);
    expect(find.text('HOME'), findsOneWidget);
  });
}
