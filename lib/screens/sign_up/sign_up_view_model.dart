import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
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
}
