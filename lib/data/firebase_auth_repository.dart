import 'package:firebase_auth/firebase_auth.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<AppUser> ensureSignedIn() {
    // Firebase Auth keeps the user on the device; signing in again would
    // create a new uid on every launch.
    final current = _auth.currentUser;
    if (current != null) return Future.value(_toAppUser(current));

    return _guard(() async => _user(await _auth.signInAnonymously()));
  }

  // `userChanges` (not `authStateChanges`) also fires when the name changes.
  @override
  Stream<AppUser> watchUser() => _auth
      .userChanges()
      .where((user) => user != null)
      .map((user) => _toAppUser(user!));

  @override
  Future<AppUser> signIn({required String email, required String password}) =>
      _guard(
        () async => _user(
          await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ),
      );

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) => _guard(() async {
    // Linking keeps the guest's uid; creating would start a new user.
    final guest = _auth.currentUser;
    final credential = guest != null && guest.isAnonymous
        ? await guest.linkWithCredential(
            EmailAuthProvider.credential(email: email, password: password),
          )
        : await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
    final user = credential.user;
    if (user == null) throw const UnexpectedFailure();
    await user.updateDisplayName(name);
    await user.reload();
    return _toAppUser(_auth.currentUser ?? user).copyWith(name: name);
  });

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') return;
      throw _toFailure(error);
    }
  }

  @override
  Future<AppUser> signOut() async {
    await _auth.signOut();
    return ensureSignedIn();
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on FirebaseAuthException catch (error) {
      throw _toFailure(error);
    }
  }

  AppUser _user(UserCredential credential) {
    final user = credential.user;
    if (user == null) throw const UnexpectedFailure();
    return _toAppUser(user);
  }

  Failure _toFailure(FirebaseAuthException error) => switch (error.code) {
    'network-request-failed' => const NetworkFailure(),
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' ||
    'user-disabled' => const InvalidCredentialsFailure(),
    'email-already-in-use' ||
    'credential-already-in-use' => const EmailInUseFailure(),
    'invalid-email' => const InvalidEmailFailure(),
    'weak-password' => const WeakPasswordFailure(),
    _ => const UnexpectedFailure(),
  };

  AppUser _toAppUser(User user) => AppUser(
    uid: user.uid,
    isAnonymous: user.isAnonymous,
    name: user.displayName,
    email: user.email,
    photoUrl: user.photoURL,
  );
}
