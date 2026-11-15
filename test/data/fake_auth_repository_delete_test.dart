import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/fake_auth_repository.dart';

void main() {
  test('deleting the account forgets it and returns a new guest', () async {
    final repository = FakeAuthRepository();
    await repository.signUp(
      name: 'Joana',
      email: 'joana@email.com',
      password: '12345678',
    );

    expect(await repository.refreshLoginSilently(), isTrue);
    final guest = await repository.deleteAccount();

    expect(guest.isAnonymous, isTrue);
    await expectLater(
      repository.signIn(email: 'joana@email.com', password: '12345678'),
      throwsA(isA<InvalidCredentialsFailure>()),
    );
  });
}
