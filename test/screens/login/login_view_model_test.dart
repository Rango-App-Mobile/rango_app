import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_account_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/auth_form_state.dart';
import 'package:rango_app/screens/login/login_view_model.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _account = AppUser(uid: 'u1', isAnonymous: false, name: 'Ana');

class _Throwing extends FakeAccountRepository {
  @override
  Future<bool> hasAcceptedTerms(String uid) async =>
      throw const NetworkFailure();
}

ProviderContainer _container(
  AuthRepository repository, [
  AccountRepository? accounts,
]) {
  final defaultAccounts = FakeAccountRepository();
  unawaited(defaultAccounts.acceptTerms('u1'));
  // Listening keeps the autoDispose ViewModel alive between reads.
  return ProviderContainer.test(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      accountRepositoryProvider.overrideWithValue(
        accounts ?? defaultAccounts,
      ),
    ],
  )..listen(loginViewModelProvider, (_, _) {});
}

void main() {
  late _MockAuthRepository repository;
  late ProviderContainer container;

  LoginViewModel viewModel() => container.read(loginViewModelProvider.notifier);
  AuthFormState state() => container.read(loginViewModelProvider);

  setUp(() {
    repository = _MockAuthRepository();
    container = _container(repository);
  });

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final (provider, signIn, continueWith) in [
    (
      'Google',
      (AuthRepository r) => r.signInWithGoogle(),
      (LoginViewModel v) => v.continueWithGoogle(),
    ),
    (
      'Apple',
      (AuthRepository r) => r.signInWithApple(),
      (LoginViewModel v) => v.continueWithApple(),
    ),
  ]) {
    test('$provider is done after signing in', () async {
      when(() => signIn(repository)).thenAnswer((_) async => _account);

      await continueWith(viewModel());

      expect(state(), const AuthFormState(done: true));
    });

    test('closing the $provider sheet goes back to the form', () async {
      when(() => signIn(repository)).thenAnswer((_) async => null);

      await continueWith(viewModel());

      expect(state(), const AuthFormState());
    });

    test('$provider without network shows the alert', () async {
      when(() => signIn(repository)).thenThrow(const NetworkFailure());

      await continueWith(viewModel());

      expect(state().alert, contains('Sem conexão'));
      expect(state().done, isFalse);
    });

    test('a failure from $provider never lands under a field', () async {
      when(
        () => signIn(repository),
      ).thenThrow(const InvalidCredentialsFailure());

      await continueWith(viewModel());

      expect(
        state(),
        const AuthFormState(alert: 'Algo deu errado. Tente de novo.'),
      );
    });

    test('$provider with an account under another method says so', () async {
      when(
        () => signIn(repository),
      ).thenThrow(const AccountExistsWithOtherMethodFailure());

      await continueWith(viewModel());

      expect(
        state().alert,
        'Este e-mail já tem conta com outro jeito de entrar. '
        'Use o mesmo de antes.',
      );
    });

    test('$provider ignores a second tap while signing in', () async {
      final pending = Completer<AppUser?>();
      when(() => signIn(repository)).thenAnswer((_) => pending.future);

      final first = continueWith(viewModel());
      expect(state().submitting, isTrue);
      await continueWith(viewModel());
      pending.complete(_account);
      await first;

      verify(() => signIn(repository)).called(1);
      expect(state().done, isTrue);
    });
  }

  test('an account that did not accept the terms needs them', () async {
    when(() => repository.signInWithGoogle()).thenAnswer((_) async => _account);
    container = _container(repository, FakeAccountRepository());

    await viewModel().continueWithGoogle();

    expect(state(), const AuthFormState(needsTerms: true));
  });

  test('a failed terms check counts as not accepted', () async {
    when(() => repository.signInWithApple()).thenAnswer((_) async => _account);
    container = _container(repository, _Throwing());

    await viewModel().continueWithApple();

    expect(state(), const AuthFormState(needsTerms: true));
  });

  test('e-mail sign-in is done when accepted, needs terms otherwise', () async {
    when(
      () => repository.signIn(email: 'a@b.c', password: 'x'),
    ).thenAnswer((_) async => _account);

    await viewModel().submit(email: 'a@b.c', password: 'x');
    expect(state(), const AuthFormState(done: true));

    container = _container(repository, FakeAccountRepository());
    await viewModel().submit(email: 'a@b.c', password: 'x');
    expect(state(), const AuthFormState(needsTerms: true));
  });

  test('offers Apple only on iOS', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(viewModel().offersApple, isTrue);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(viewModel().offersApple, isFalse);
  });

  test('works with the fake repository', () async {
    final accounts = FakeAccountRepository();
    await accounts.acceptTerms(FakeAuthRepository.user.uid);
    container = _container(FakeAuthRepository(), accounts);

    await viewModel().continueWithGoogle();

    expect(state().done, isTrue);
  });
}
