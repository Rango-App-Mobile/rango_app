import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
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
      await ref
          .read(authRepositoryProvider)
          .signIn(email: address, password: password);
      if (ref.mounted) state = const AuthFormState(done: true);
    } on Failure catch (failure) {
      if (ref.mounted) state = AuthFormState.failed(failure);
    }
  }
}
