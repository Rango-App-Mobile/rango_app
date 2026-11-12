import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/fake_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/auth_form_state.dart';
import 'package:rango_app/screens/login/login_view_model.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _account = AppUser(uid: 'u1', isAnonymous: false, name: 'Ana');

ProviderContainer _container(AuthRepository repository) {
  // Listening keeps the autoDispose ViewModel alive between reads.
  return ProviderContainer.test(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
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

  test('offers Apple only on iOS', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    expect(viewModel().offersApple, isTrue);

    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(viewModel().offersApple, isFalse);
  });

  test('works with the fake repository', () async {
    container = _container(FakeAuthRepository());

    await viewModel().continueWithGoogle();

    expect(state().done, isTrue);
  });
}
