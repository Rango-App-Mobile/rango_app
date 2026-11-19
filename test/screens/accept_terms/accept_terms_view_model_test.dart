import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_account_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/screens/accept_terms/accept_terms_state.dart';
import 'package:rango_app/screens/accept_terms/accept_terms_view_model.dart';

class _Failing extends FakeAccountRepository {
  _Failing(this.failure);
  final Failure failure;

  @override
  Future<void> acceptTerms(String uid) async => throw failure;
}

void main() {
  late FakeAuthRepository auth;
  late FakeAccountRepository account;
  late ProviderContainer container;

  ProviderContainer build(AccountRepository accounts) => ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(auth),
      accountRepositoryProvider.overrideWithValue(accounts),
    ],
  )..listen(acceptTermsViewModelProvider, (_, _) {});

  AcceptTermsViewModel viewModel() =>
      container.read(acceptTermsViewModelProvider.notifier);
  AcceptTermsState state() => container.read(acceptTermsViewModelProvider);

  setUp(() async {
    auth = FakeAuthRepository();
    await auth.signInWithGoogle();
    account = FakeAccountRepository();
    container = build(account);
    await Future<void>.delayed(Duration.zero);
  });

  test('prefills the name of the current user', () {
    expect(state().initialName, 'Ana Souza');
  });

  test('asks for the name and the terms', () async {
    await viewModel().submit('  ');

    expect(state().nameError, 'Digite seu nome.');
    expect(state().termsError, 'Aceite os termos para continuar.');
    expect(state().done, isFalse);
  });

  test('keeps the name and records the terms', () async {
    viewModel().termsAccepted(accepted: true);
    await viewModel().submit('Ana Souza');

    expect(state().done, isTrue);
    expect(await account.hasAcceptedTerms('fake-uid'), isTrue);
  });

  test('a changed name is saved before the terms', () async {
    viewModel().termsAccepted(accepted: true);
    await viewModel().submit('Ana Maria');

    expect((await auth.ensureSignedIn()).name, 'Ana Maria');
    expect(state().done, isTrue);
  });

  test('declining signs out back to a guest', () async {
    await viewModel().decline();

    expect(state().done, isTrue);
    expect((await auth.ensureSignedIn()).isAnonymous, isTrue);
    expect(await account.hasAcceptedTerms('fake-uid'), isFalse);
  });

  test('no network shows the network alert and stays', () async {
    container = build(_Failing(const NetworkFailure()));
    viewModel().termsAccepted(accepted: true);
    await viewModel().submit('Ana');

    expect(state().alert, contains('Sem conexão'));
    expect(state().done, isFalse);
    expect(state().submitting, isFalse);
  });

  test('another failure shows the generic alert', () async {
    container = build(_Failing(const UnexpectedFailure()));
    viewModel().termsAccepted(accepted: true);
    await viewModel().submit('Ana');

    expect(state().alert, 'Algo deu errado. Tente de novo.');
  });
}
