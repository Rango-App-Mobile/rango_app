import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';
import 'package:rango_app/models/auth_form_state.dart';

final NotifierProvider<LoginViewModel, AuthFormState> loginViewModelProvider =
    NotifierProvider.autoDispose<LoginViewModel, AuthFormState>(
      LoginViewModel.new,
    );

class LoginViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  /// Editing a field clears the errors of the last attempt.
  void edited() {
    if (!state.submitting) state = const AuthFormState();
  }

  Future<void> submit({required String email, required String password}) async {
    if (state.submitting) return;
    final address = email.trim();
    if (address.isEmpty || password.isEmpty) {
      state = AuthFormState(
        emailError: address.isEmpty ? 'Digite seu e-mail.' : null,
        passwordError: password.isEmpty ? 'Digite sua senha.' : null,
      );
      return;
    }

    state = const AuthFormState(submitting: true);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email: address, password: password);
      await _finish(user);
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
      if (user == null) {
        if (ref.mounted) state = const AuthFormState();
      } else {
        await _finish(user);
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
        );
      }
    }
  }

  /// Every account must have accepted the terms. A failed check counts as not
  /// accepted: the acceptance screen retries the write.
  Future<void> _finish(AppUser user) async {
    var accepted = false;
    try {
      accepted = await ref
          .read(accountRepositoryProvider)
          .hasAcceptedTerms(user.uid);
    } on Failure {
      // Treated as not accepted; see above.
    }
    if (ref.mounted) {
      state = AuthFormState(done: accepted, needsTerms: !accepted);
    }
  }
}
