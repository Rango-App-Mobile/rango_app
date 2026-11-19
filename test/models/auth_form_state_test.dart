import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/models/auth_form_state.dart';

void main() {
  test('puts each failure next to what caused it', () {
    expect(
      AuthFormState.failed(const InvalidCredentialsFailure()).passwordError,
      'E-mail ou senha incorretos.',
    );
    expect(
      AuthFormState.failed(const WeakPasswordFailure()).passwordError,
      isNotNull,
    );
    expect(
      AuthFormState.failed(const EmailInUseFailure()).emailError,
      'Esse e-mail já tem conta. Entre nele ou use outro.',
    );
    expect(
      AuthFormState.failed(const InvalidEmailFailure()).emailError,
      isNotNull,
    );
    expect(
      AuthFormState.failed(const NetworkFailure()).alert,
      'Sem conexão. Confira sua internet e tente de novo.',
    );
    expect(
      AuthFormState.failed(const UnexpectedFailure()).alert,
      'Algo deu errado. Tente de novo.',
    );
  });

  test('recognises an e-mail by its shape', () {
    expect(AuthFormState.isEmail('joana@email.com'), isTrue);
    for (final wrong in [
      '',
      'joana',
      'joana@',
      'joana@email',
      'jo ana@e.com',
    ]) {
      expect(AuthFormState.isEmail(wrong), isFalse, reason: wrong);
    }
  });
}
