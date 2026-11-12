import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/core/widgets/inline_alert.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/screens/password_reset/password_reset_screen.dart';

import '../../helpers/auth_form.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Future<void> _pump(
  WidgetTester tester,
  AuthRepository repository, {
  String? email,
}) => pumpAuthScreen(
  tester,
  route: '/password-reset',
  repository: repository,
  screens: {
    '/password-reset': (_) => PasswordResetScreen(initialEmail: email),
  },
);

void main() {
  late _MockAuthRepository repository;

  setUp(() {
    repository = _MockAuthRepository();
    when(() => repository.sendPasswordReset(any())).thenAnswer((_) async {});
  });

  testWidgets('starts with the e-mail typed in the login', (tester) async {
    await _pump(tester, repository, email: 'joana@email.com');

    expect(find.text('joana@email.com'), findsOneWidget);
  });

  testWidgets('an invalid e-mail is not sent', (tester) async {
    await _pump(tester, repository);

    await typeIn(tester, 'E-mail', 'joana');
    await tapButton(tester, 'Enviar link');

    expect(find.text('Confira o e-mail.'), findsOneWidget);
    verifyNever(() => repository.sendPasswordReset(any()));
  });

  testWidgets('sends the link, confirms and can send again', (tester) async {
    await _pump(tester, repository);

    await typeIn(tester, 'E-mail', ' joana@email.com ');
    await tapButton(tester, 'Enviar link');

    expect(find.text('Confira seu e-mail'), findsOneWidget);
    expect(find.textContaining('joana@email.com'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);

    await tapButton(tester, 'Reenviar e-mail');
    expect(find.text('Confira seu e-mail'), findsOneWidget);
    verify(() => repository.sendPasswordReset('joana@email.com')).called(2);

    await tapButton(tester, 'Voltar para entrar');
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('without network shows the alert and stays on the form', (
    tester,
  ) async {
    when(
      () => repository.sendPasswordReset(any()),
    ).thenThrow(const NetworkFailure());
    await _pump(tester, repository);

    await typeIn(tester, 'E-mail', 'joana@email.com');
    await tapButton(tester, 'Enviar link');

    expect(find.byType(InlineAlert), findsOneWidget);
    expect(find.text('Recuperar senha'), findsOneWidget);
  });
}
