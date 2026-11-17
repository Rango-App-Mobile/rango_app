import 'package:freezed_annotation/freezed_annotation.dart';

part 'accept_terms_state.freezed.dart';

@freezed
abstract class AcceptTermsState with _$AcceptTermsState {
  const factory AcceptTermsState({
    /// The name the account already has, to prefill the field.
    String? initialName,
    @Default(false) bool termsAccepted,
    @Default(false) bool submitting,

    /// Accepted or declined: the View closes the screen.
    @Default(false) bool done,
    String? nameError,
    String? termsError,
    String? alert,
  }) = _AcceptTermsState;
}
