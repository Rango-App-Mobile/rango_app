import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/data/category_repository.dart';
import 'package:rango_app/data/history_repository.dart';
import 'package:rango_app/models/profile_stats.dart';
import 'package:rango_app/screens/profile/profile_state.dart';

/// Riverpod's automatic retry is off: the session was already created behind
/// the startup gate, so a failure here has nothing to wait for.
final profileViewModelProvider =
    StreamNotifierProvider<ProfileViewModel, ProfileState>(
      ProfileViewModel.new,
      retry: (_, _) => null,
    );

/// Reuses the history and menu already owned by the app; opening the profile
/// does not add a Firestore query or expand the 100-entry history window.
final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final entriesFuture = ref.watch(historyEntriesProvider.future);
  final categoriesFuture = ref.watch(categoriesProvider.future);
  final entries = await entriesFuture;
  final categories = await categoriesFuture;
  return ProfileStats.fromHistory(entries: entries, categories: categories);
}, retry: (_, _) => null);

/// Follows the user, so the sheet changes by itself after sign-in and
/// sign-out.
class ProfileViewModel extends StreamNotifier<ProfileState> {
  @override
  Stream<ProfileState> build() {
    final repository = ref.watch(authRepositoryProvider);
    // Firebase does not announce an e-mail confirmed in the mail app, so ask
    // for a fresh user when the sheet opens. Best effort.
    unawaited(_refresh(repository));
    return repository.watchUser().map(ProfileState.fromUser);
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

  /// Reloads the data providers used by the statistics panel.
  void retryStatistics() {
    ref
      ..invalidate(historyEntriesProvider)
      ..invalidate(categoriesProvider);
  }

  /// Deletes the account and its data without asking anything. Null when it
  /// is gone; otherwise why it stayed, ready to show.
  ///
  /// The order matters: Firestore only lets the account itself delete its
  /// data, so the data goes before the account, and only once Firebase will
  /// accept deleting the account.
  Future<String?> deleteAccount() async {
    final auth = ref.read(authRepositoryProvider);
    final accounts = ref.read(accountRepositoryProvider);
    try {
      final user = await auth.ensureSignedIn();
      if (!await auth.refreshLoginSilently()) {
        return const RequiresRecentLoginFailure().message;
      }
      await accounts.deleteData(user.uid);
      await auth.deleteAccount();
      return null;
    } on Failure catch (failure) {
      return switch (failure) {
        NetworkFailure() || RequiresRecentLoginFailure() => failure.message,
        _ => 'Não foi possível excluir sua conta. Tente de novo.',
      };
    }
  }

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
