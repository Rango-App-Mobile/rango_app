import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/firebase_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

/// Every method throws a `Failure` when it cannot do its job.
abstract interface class AuthRepository {
  /// Returns the signed-in user, creating an anonymous one when there is
  /// none.
  Future<AppUser> ensureSignedIn();

  /// The current user, then every change to it: sign-in, sign-out and
  /// profile updates.
  Stream<AppUser> watchUser();

  Future<AppUser> signIn({required String email, required String password});

  /// Turns the current guest into an account, keeping its uid.
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Succeeds even when the e-mail has no account, so it cannot be used to
  /// find out who is registered.
  Future<void> sendPasswordReset(String email);

  /// Opens the Google account picker and signs in to the chosen account,
  /// keeping the guest's uid when the account is new. Null when the person
  /// closes the picker.
  Future<AppUser?> signInWithGoogle();

  /// The same as [signInWithGoogle], with Apple (iOS only).
  Future<AppUser?> signInWithApple();

  /// Sends the confirmation link to the current user's e-mail again.
  Future<void> resendVerification();

  /// Refreshes the current user from the server (the e-mail may have been
  /// confirmed in the mail app, which Firebase does not announce).
  Future<void> reload();

  /// Leaves the account and goes back to a guest session.
  Future<AppUser> signOut();
}

/// Tests override this provider with `FakeAuthRepository` or a mock: the
/// default talks to the real Firebase Auth.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

/// The signed-in user, following every change to it.
final currentUserProvider = StreamProvider<AppUser>(
  (ref) => ref.watch(authRepositoryProvider).watchUser(),
);
