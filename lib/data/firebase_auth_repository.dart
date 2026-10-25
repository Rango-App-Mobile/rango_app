import 'package:firebase_auth/firebase_auth.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Future<AppUser> ensureSignedIn() async {
    // Firebase Auth keeps the anonymous user on the device; signing in again
    // would create a new uid on every launch.
    final current = _auth.currentUser;
    if (current != null) return _toAppUser(current);

    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) throw const UnexpectedFailure();
      return _toAppUser(user);
    } on FirebaseAuthException catch (error) {
      throw error.code == 'network-request-failed'
          ? const NetworkFailure()
          : const UnexpectedFailure();
    }
  }

  AppUser _toAppUser(User user) =>
      AppUser(uid: user.uid, isAnonymous: user.isAnonymous);
}
