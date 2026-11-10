import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/fake_auth_repository.dart';

void main() {
  test('returns the same anonymous uid on repeated calls', () async {
    final repository = FakeAuthRepository();

    final first = await repository.ensureSignedIn();
    final second = await repository.ensureSignedIn();

    expect(first.isAnonymous, isTrue);
    expect(second.uid, first.uid);
  });

  test('an account can be created, left and entered again', () async {
    final repository = FakeAuthRepository();

    final created = await repository.signUp(
      name: 'Joana',
      email: 'joana@email.com',
      password: '12345678',
    );
    expect(created.isAnonymous, isFalse);
    expect(created.uid, FakeAuthRepository.user.uid);

    expect((await repository.signOut()).isAnonymous, isTrue);

    final back = await repository.signIn(
      email: 'joana@email.com',
      password: '12345678',
    );
    expect(back.name, 'Joana');
    expect((await repository.ensureSignedIn()).name, 'Joana');
  });

  test('rejects a wrong password and a repeated e-mail', () async {
    final repository = FakeAuthRepository();
    await repository.signUp(name: 'J', email: 'j@e.com', password: '12345678');

    expect(
      repository.signIn(email: 'j@e.com', password: 'wrong'),
      throwsA(isA<InvalidCredentialsFailure>()),
    );
    expect(
      repository.signUp(name: 'J', email: 'j@e.com', password: '12345678'),
      throwsA(isA<EmailInUseFailure>()),
    );
  });

  test('watchUser starts with the current user and follows changes', () async {
    final repository = FakeAuthRepository();
    final names = <String?>[];
    final subscription = repository.watchUser().listen(
      (u) => names.add(u.name),
    );
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    await repository.signUp(name: 'J', email: 'j@e.com', password: '12345678');
    await pumpEventQueue();

    expect(names, [null, 'J']);
  });
}
