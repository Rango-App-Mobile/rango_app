import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/profile/profile_state.dart';
import 'package:rango_app/screens/profile/profile_view_model.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

Future<ProfileState> _load(AppUser user) {
  final repository = _MockAuthRepository();
  when(repository.ensureSignedIn).thenAnswer((_) async => user);
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container.read(profileViewModelProvider.future);
}

void main() {
  test('an anonymous user is a guest named Visitante', () async {
    final state = await _load(FakeAuthRepository.user);

    expect(state.isGuest, isTrue);
    expect(state.name, 'Visitante');
    expect(state.subtitle, 'Sessão anônima neste aparelho');
    expect(state.photoUrl, isNull);
  });

  test('a user with an account shows name, e-mail and photo', () async {
    final state = await _load(
      const AppUser(
        uid: 'u1',
        isAnonymous: false,
        name: 'Joana',
        email: 'joana@email.com',
        photoUrl: 'https://example.com/joana.png',
      ),
    );

    expect(state.isGuest, isFalse);
    expect(state.name, 'Joana');
    expect(state.subtitle, 'joana@email.com');
    expect(state.photoUrl, 'https://example.com/joana.png');
  });

  test('without a name, the e-mail takes the name and leaves the '
      'subtitle empty', () async {
    final state = await _load(
      const AppUser(uid: 'u1', isAnonymous: false, email: 'joana@email.com'),
    );

    expect(state.name, 'joana@email.com');
    expect(state.subtitle, isNull);
  });

  test('without name and e-mail, falls back to a generic name', () async {
    final state = await _load(const AppUser(uid: 'u1', isAnonymous: false));

    expect(state.name, 'Sua conta');
    expect(state.subtitle, isNull);
  });

  test('a blank name counts as no name', () async {
    final state = await _load(
      const AppUser(
        uid: 'u1',
        isAnonymous: false,
        name: '  ',
        email: 'joana@email.com',
      ),
    );

    expect(state.name, 'joana@email.com');
  });

  test('stays in error without retrying when the session fails', () async {
    final repository = _MockAuthRepository();
    when(repository.ensureSignedIn).thenThrow(const NetworkFailure());
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(profileViewModelProvider, (_, _) {});
    addTearDown(subscription.close);

    await expectLater(
      container.read(profileViewModelProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    verify(repository.ensureSignedIn).called(1);
  });
}
