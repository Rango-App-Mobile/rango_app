import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/startup/startup_view_model.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  test('becomes ready with an anonymous user', () async {
    final container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );

    final user = await container.read(startupViewModelProvider.future);

    expect(user.isAnonymous, isTrue);
  });

  test('exposes NetworkFailure as error', () async {
    final repository = _MockAuthRepository();
    when(repository.ensureSignedIn).thenThrow(const NetworkFailure());
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    await expectLater(
      container.read(startupViewModelProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    expect(
      container.read(startupViewModelProvider).error,
      isA<NetworkFailure>(),
    );
  });

  test('retry recovers after a failure', () async {
    final repository = _MockAuthRepository();
    var calls = 0;
    when(repository.ensureSignedIn).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw const NetworkFailure();
      return const AppUser(uid: 'uid', isAnonymous: true);
    });
    final container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    final subscription = container.listen(startupViewModelProvider, (_, _) {});
    addTearDown(subscription.close);

    await expectLater(
      container.read(startupViewModelProvider.future),
      throwsA(isA<NetworkFailure>()),
    );

    container.read(startupViewModelProvider.notifier).retry();
    final user = await container.read(startupViewModelProvider.future);

    expect(user.uid, 'uid');
    expect(calls, 2);
  });
}
