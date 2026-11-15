import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
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
    if (!state.submitting) {
      state = AuthFormState(termsAccepted: state.termsAccepted);
    }
  }

  void termsAccepted({required bool accepted}) {
    if (!state.submitting) state = AuthFormState(termsAccepted: accepted);
  }

  Future<void> submit({
    required String name,
    required String email,
    required String confirmEmail,
    required String password,
    required String confirmPassword,
  }) async {
    if (state.submitting) return;
    final accepted = state.termsAccepted;
    final person = name.trim();
    final address = email.trim();
    final blank = AuthFormState(termsAccepted: accepted);
    final invalid = blank.copyWith(
      nameError: person.isEmpty ? 'Digite seu nome.' : null,
      emailError: AuthFormState.isEmail(address) ? null : 'Confira o e-mail.',
      confirmEmailError: confirmEmail.trim() == address
          ? null
          : 'Os e-mails não são iguais.',
      passwordError: password.length < AuthFormState.minPasswordLength
          ? 'Pelo menos 8 caracteres.'
          : null,
      confirmPasswordError: confirmPassword == password
          ? null
          : 'As senhas não são iguais.',
      termsError: accepted ? null : 'Aceite os termos para criar a conta.',
    );
    if (invalid != blank) {
      state = invalid;
      return;
    }

    state = AuthFormState(submitting: true, termsAccepted: accepted);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(name: person, email: address, password: password);
      await _recordTerms(user.uid);
      if (ref.mounted) {
        state = AuthFormState(done: true, termsAccepted: accepted);
      }
    } on Failure catch (failure) {
      if (ref.mounted) {
        state = AuthFormState.failed(
          failure,
        ).copyWith(termsAccepted: accepted);
      }
    }
  }

  /// The account already exists, so a failure here must not look like a
  /// failed sign-up (a retry would say "e-mail in use").
  Future<void> _recordTerms(String uid) async {
    try {
      await ref.read(accountRepositoryProvider).acceptTerms(uid);
    } on Failure {
      // Dropped on purpose; see above.
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
    final accepted = state.termsAccepted;
    state = AuthFormState(submitting: true, termsAccepted: accepted);
    try {
      final user = await signIn();
      if (ref.mounted) {
        state = AuthFormState(done: user != null, termsAccepted: accepted);
      }
    } on Failure catch (failure) {
      // No field caused it, so only the network and a taken e-mail keep their
      // own message; the rest is a generic alert.
      if (ref.mounted) {
        state = AuthFormState.failed(
          failure is NetworkFailure ||
                  failure is AccountExistsWithOtherMethodFailure
              ? failure
              : const UnexpectedFailure(),
        ).copyWith(termsAccepted: accepted);
      }
    }
  }
}
