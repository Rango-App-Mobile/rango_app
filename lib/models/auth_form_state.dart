import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/core/error/failure.dart';

part 'auth_form_state.freezed.dart';

/// State shared by the account forms (sign in, sign up, password reset): one
/// error per field, an alert for the whole form and whether it is done.
@freezed
abstract class AuthFormState with _$AuthFormState {
  const factory AuthFormState({
    @Default(false) bool submitting,
    @Default(false) bool done,
    String? nameError,
    String? emailError,
    String? passwordError,

    /// An error that is not about one field: no network, or unexpected.
    String? alert,
  }) = _AuthFormState;

  /// The form after [failure], with the message next to what caused it.
  factory AuthFormState.failed(Failure failure) => switch (failure) {
    InvalidCredentialsFailure() ||
    WeakPasswordFailure() => AuthFormState(passwordError: failure.message),
    EmailInUseFailure() ||
    InvalidEmailFailure() => AuthFormState(emailError: failure.message),
    NetworkFailure() => const AuthFormState(
      alert: 'Sem conexão. Confira sua internet e tente de novo.',
    ),
    _ => const AuthFormState(alert: 'Algo deu errado. Tente de novo.'),
  };

  static const minPasswordLength = 8;

  static bool isEmail(String value) => _email.hasMatch(value);

  static final _email = RegExp(r'^\S+@\S+\.\S+$');
}
