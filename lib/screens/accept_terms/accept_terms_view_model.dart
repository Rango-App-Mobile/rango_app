import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/screens/accept_terms/accept_terms_state.dart';

final NotifierProvider<AcceptTermsViewModel, AcceptTermsState>
acceptTermsViewModelProvider =
    NotifierProvider.autoDispose<AcceptTermsViewModel, AcceptTermsState>(
      AcceptTermsViewModel.new,
    );

/// After a sign-in: asks for the name (when missing) and the terms.
class AcceptTermsViewModel extends Notifier<AcceptTermsState> {
  String? _uid;
  String _currentName = '';

  @override
  AcceptTermsState build() {
    unawaited(_load());
    return const AcceptTermsState();
  }

  Future<void> _load() async {
    try {
      final user = await ref.read(authRepositoryProvider).ensureSignedIn();
      _uid = user.uid;
      _currentName = user.name?.trim() ?? '';
      if (ref.mounted) {
        state = state.copyWith(
          initialName: _currentName.isEmpty ? null : _currentName,
        );
      }
    } on Failure {
      // The name field stays empty; submitting reports the failure.
    }
  }

  void termsAccepted({required bool accepted}) {
    if (state.submitting) return;
    state = state.copyWith(termsAccepted: accepted, termsError: null);
  }

  /// Editing the name clears the errors of the last attempt.
  void edited() {
    if (state.submitting) return;
    state = state.copyWith(nameError: null, alert: null);
  }

  Future<void> submit(String name) async {
    if (state.submitting) return;
    final person = name.trim();
    final invalid = state.copyWith(
      nameError: person.isEmpty ? 'Digite seu nome.' : null,
      termsError: state.termsAccepted
          ? null
          : 'Aceite os termos para continuar.',
      alert: null,
    );
    if (invalid.nameError != null || invalid.termsError != null) {
      state = invalid;
      return;
    }

    state = state.copyWith(submitting: true, alert: null);
    try {
      final auth = ref.read(authRepositoryProvider);
      final uid = _uid ?? (await auth.ensureSignedIn()).uid;
      if (person != _currentName) {
        await auth.updateName(person);
        _currentName = person;
      }
      await ref.read(accountRepositoryProvider).acceptTerms(uid);
      if (ref.mounted) state = state.copyWith(submitting: false, done: true);
    } on Failure catch (failure) {
      if (ref.mounted) {
        state = state.copyWith(
          submitting: false,
          alert: failure is NetworkFailure
              ? 'Sem conexão. Confira sua internet e tente de novo.'
              : 'Algo deu errado. Tente de novo.',
        );
      }
    }
  }

  /// "Agora não" or back: the account is left and the person is a guest again.
  Future<void> decline() async {
    if (state.submitting) return;
    state = state.copyWith(submitting: true, alert: null);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (ref.mounted) state = state.copyWith(submitting: false, done: true);
    } on Failure {
      if (ref.mounted) {
        state = state.copyWith(
          submitting: false,
          alert: 'Algo deu errado. Tente de novo.',
        );
      }
    }
  }
}
