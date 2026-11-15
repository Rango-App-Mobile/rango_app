import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/screens/profile/profile_state.dart';

/// Riverpod's automatic retry is off: the session was already created behind
/// the startup gate, so a failure here has nothing to wait for.
final profileViewModelProvider =
    StreamNotifierProvider<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
      retry: (_, _) => null,
    );

/// Follows the user, so the sheet changes by itself after sign-in and
/// sign-out.
class ProfileViewModel extends StreamNotifier<ProfileState> {
  // Kept here, not only in the state: re-authenticating makes Firebase emit
  // the user again, and that emission must not end the "deleting" screen.
  bool _deleting = false;

  @override
  Stream<ProfileState> build() {
    final repository = ref.watch(authRepositoryProvider);
    // Firebase does not announce an e-mail confirmed in the mail app, so ask
    // for a fresh user when the sheet opens. Best effort.
    unawaited(_refresh(repository));
    return repository.watchUser().map(
      (user) => ProfileState.fromUser(user).copyWith(deleting: _deleting),
    );
  }

  Future<void> _refresh(AuthRepository repository) async {
    try {
      await repository.reload();
    } on Failure {
      // Stale data is fine; the next opening tries again.
    }
  }

  /// Whether the link was sent.
  Future<bool> resendVerification() async {
    try {
      await ref.read(authRepositoryProvider).resendVerification();
      return true;
    } on Failure {
      return false;
    }
  }

  /// Deletes the account and its data. True when it is gone; false when the
  /// person gave up on the re-login (nothing happens) or it failed, in which
  /// case [ProfileState.deleteError] says why and the account stays.
  ///
  /// The order matters: Firestore only lets the account itself delete its
  /// data, so the data goes before the account.
  Future<bool> deleteAccount({String? password}) async {
    final auth = ref.read(authRepositoryProvider);
    final accounts = ref.read(accountRepositoryProvider);
    final before = state.value ?? ProfileState.guest;
    _deleting = true;
    state = AsyncData(before.copyWith(deleting: true, deleteError: null));
    try {
      final user = await auth.ensureSignedIn();
      if (!await auth.reauthenticate(password: password)) {
        _set(before);
        return false;
      }
      await accounts.deleteData(user.uid);
      await auth.deleteAccount();
      _set(ProfileState.guest);
      return true;
    } on Failure catch (failure) {
      _set(before.copyWith(deleteError: _deleteMessage(failure)));
      return false;
    }
  }

  void _set(ProfileState next) {
    _deleting = false;
    if (ref.mounted) state = AsyncData(next);
  }

  String _deleteMessage(Failure failure) => switch (failure) {
    NetworkFailure() ||
    InvalidCredentialsFailure() ||
    RequiresRecentLoginFailure() => failure.message,
    _ => 'Não foi possível excluir sua conta. Tente de novo.',
  };

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on Failure {
      // The account is gone even if the new guest session could not be
      // created (offline); the startup gate creates it on the next launch.
      if (ref.mounted) state = const AsyncData(ProfileState.guest);
    }
  }
}
