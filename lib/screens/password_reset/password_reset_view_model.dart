import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/auth_form_state.dart';

final NotifierProvider<PasswordResetViewModel, AuthFormState>
passwordResetViewModelProvider =
    NotifierProvider.autoDispose<PasswordResetViewModel, AuthFormState>(
      PasswordResetViewModel.new,
    );

class PasswordResetViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  /// Editing the field clears the error of the last attempt.
  void edited() {
    if (!state.submitting) state = const AuthFormState();
  }

  /// Also resends: once the link was sent, `done` stays true whatever
  /// happens next.
  Future<void> submit(String email) async {
    if (state.submitting) return;
    final address = email.trim();
    if (!AuthFormState.isEmail(address)) {
      state = const AuthFormState(emailError: 'Confira o e-mail.');
      return;
    }

    final sent = state.done;
    state = AuthFormState(submitting: true, done: sent);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(address);
      if (ref.mounted) state = const AuthFormState(done: true);
    } on Failure catch (failure) {
      if (ref.mounted) {
        state = AuthFormState.failed(failure).copyWith(done: sent);
      }
    }
  }
}
