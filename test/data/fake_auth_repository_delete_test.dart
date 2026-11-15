import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/fake_auth_repository.dart';

Future<FakeAuthRepository> _withAccount() async {
  final repository = FakeAuthRepository();
  await repository.signUp(
    name: 'Joana',
    email: 'joana@email.com',
    password: '12345678',
  );
  return repository;
}

void main() {
  test('deleting the account forgets it and returns a new guest', () async {
    final repository = await _withAccount();

    expect(await repository.reauthenticate(password: '12345678'), isTrue);
    final guest = await repository.deleteAccount();

    expect(guest.isAnonymous, isTrue);
    await expectLater(
      repository.signIn(email: 'joana@email.com', password: '12345678'),
      throwsA(isA<InvalidCredentialsFailure>()),
    );
  });

  test('reauthenticating with a wrong password fails', () async {
    final repository = await _withAccount();

    await expectLater(
      repository.reauthenticate(password: 'wrong'),
      throwsA(isA<InvalidCredentialsFailure>()),
    );
  });
}
