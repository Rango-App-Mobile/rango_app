import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/core/widgets/rango_button.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/screens/sign_up/sign_up_screen.dart';

import '../../helpers/auth_form.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Future<void> _pump(WidgetTester tester, AuthRepository repository) =>
    pumpAuthScreen(
      tester,
      route: '/signup',
      repository: repository,
      screens: {'/signup': (_) => const SignUpScreen()},
    );

Future<void> _fill(
  WidgetTester tester, {
  String name = 'Joana',
  String email = 'joana@email.com',
  String password = '12345678',
}) async {
  await typeIn(tester, 'Nome', name);
  await typeIn(tester, 'E-mail', email);
  await typeIn(tester, 'Senha', password);
}

void main() {
  testWidgets('fits the screen', (tester) async {
    await _pump(tester, FakeAuthRepository());

    expect(tester.takeException(), isNull);
    expect(
      tester
          .getBottomLeft(
            find.widgetWithText(RangoButton, 'Já tem conta? Entrar'),
          )
          .dy,
      lessThanOrEqualTo(874),
    );
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
}
