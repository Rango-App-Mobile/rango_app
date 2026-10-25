import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/firebase_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

abstract interface class AuthRepository {
  /// Returns the signed-in user, creating an anonymous one when there is
  /// none. Throws a `Failure` when it cannot.
  Future<AppUser> ensureSignedIn();
}

/// Tests override this provider with `FakeAuthRepository` or a mock: the
/// default talks to the real Firebase Auth.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);
