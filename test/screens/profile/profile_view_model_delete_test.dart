import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/screens/profile/profile_view_model.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockAccountRepository extends Mock implements AccountRepository {}

const _account = AppUser(
  uid: 'u1',
  isAnonymous: false,
  name: 'Joana',
  email: 'joana@email.com',
);

void main() {
  late _MockAuthRepository auth;
  late _MockAccountRepository accounts;
  late ProviderContainer container;

  setUp(() async {
    auth = _MockAuthRepository();
    accounts = _MockAccountRepository();
    when(auth.reload).thenAnswer((_) async {});
    when(auth.watchUser).thenAnswer((_) => Stream.value(_account));
    when(auth.ensureSignedIn).thenAnswer((_) async => _account);
    when(auth.refreshLoginSilently).thenAnswer((_) async => true);
    when(() => accounts.deleteData(any())).thenAnswer((_) async {});
    when(auth.deleteAccount).thenAnswer((_) async => FakeAuthRepository.user);
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        accountRepositoryProvider.overrideWithValue(accounts),
      ],
    );
    addTearDown(container.dispose);
    container.listen(profileViewModelProvider, (_, _) {});
    await container.read(profileViewModelProvider.future);
  });

  ProfileViewModel viewModel() =>
      container.read(profileViewModelProvider.notifier);

  test('deletes the data, then the account, without asking anything', () async {
    expect(await viewModel().deleteAccount(), isNull);

    verifyInOrder([
      auth.refreshLoginSilently,
      () => accounts.deleteData('u1'),
      auth.deleteAccount,
    ]);
  });

  test('an old login that cannot be refreshed deletes nothing', () async {
    when(auth.refreshLoginSilently).thenAnswer((_) async => false);

    expect(
      await viewModel().deleteAccount(),
      const RequiresRecentLoginFailure().message,
    );
    verifyNever(() => accounts.deleteData(any()));
    verifyNever(auth.deleteAccount);
  });

  test('a network failure while deleting the data keeps the account', () async {
    when(() => accounts.deleteData(any())).thenThrow(const NetworkFailure());

    expect(await viewModel().deleteAccount(), 'Sem conexão.');
    verifyNever(auth.deleteAccount);
  });

  test('any other failure shows the generic message', () async {
    when(auth.deleteAccount).thenThrow(const UnexpectedFailure());

    expect(
      await viewModel().deleteAccount(),
      'Não foi possível excluir sua conta. Tente de novo.',
    );
  });
}
