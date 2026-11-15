import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/auth_form_state.dart';

final NotifierProvider<SignUpViewModel, AuthFormState> signUpViewModelProvider =
    NotifierProvider.autoDispose<SignUpViewModel, AuthFormState>(
      SignUpViewModel.new,
    );

class SignUpViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  /// Editing a field clears the errors of the last attempt.
  void edited() {
    if (!state.submitting) state = const AuthFormState();
  }

  Future<void> submit({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.submitting) return;
    final person = name.trim();
    final address = email.trim();
    final invalid = AuthFormState(
      nameError: person.isEmpty ? 'Digite seu nome.' : null,
      emailError: AuthFormState.isEmail(address) ? null : 'Confira o e-mail.',
      passwordError: password.length < AuthFormState.minPasswordLength
          ? 'Pelo menos 8 caracteres.'
          : null,
    );
    if (invalid != const AuthFormState()) {
      state = invalid;
      return;
    }

    state = const AuthFormState(submitting: true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signUp(name: person, email: address, password: password);
      if (ref.mounted) state = const AuthFormState(done: true);
    } on Failure catch (failure) {
      if (ref.mounted) state = AuthFormState.failed(failure);
    }
  }

  /// Apple sign-in is offered only on iOS (`docs/contexto.md` §11).
  bool get offersApple => defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> continueWithGoogle() =>
      _continueWith(ref.read(authRepositoryProvider).signInWithGoogle);

  Future<void> continueWithApple() =>
      _continueWith(ref.read(authRepositoryProvider).signInWithApple);

  /// Closing the Google or Apple sheet just brings the form back.
  Future<void> _continueWith(Future<AppUser?> Function() signIn) async {
    if (state.submitting) return;
    state = const AuthFormState(submitting: true);
    try {
      final user = await signIn();
      if (ref.mounted) state = AuthFormState(done: user != null);
    } on Failure catch (failure) {
      // No field caused it, so only the network and a taken e-mail keep their
      // own message; the rest is a generic alert.
      if (ref.mounted) {
        state = AuthFormState.failed(
          failure is NetworkFailure ||
                  failure is AccountExistsWithOtherMethodFailure
              ? failure
              : const UnexpectedFailure(),
        );
      }
    }
  }
}
