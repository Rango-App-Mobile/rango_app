import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/firebase_options.dart';
import 'package:rango_app/models/app_user.dart';

class FirebaseAuthRepository implements AuthRepository {
  /// [googleIdToken] opens the Google account picker and returns the ID token
  /// of the chosen account, or null when the person closes it.
  /// [googleSilentIdToken] does the same without any UI, or returns null.
  /// [googleSignOut] forgets that account. All default to `google_sign_in`;
  /// tests pass their own, so they run without the plugin. [now] is the
  /// clock, for tests.
  FirebaseAuthRepository(
    this._auth, {
    Future<String?> Function()? googleIdToken,
    Future<String?> Function()? googleSilentIdToken,
    Future<void> Function()? googleSignOut,
    DateTime Function()? now,
  }) : _googleIdToken = googleIdToken ?? _pluginGoogleIdToken,
       _googleSilentIdToken = googleSilentIdToken ?? _pluginGoogleSilentIdToken,
       _googleSignOut = googleSignOut ?? _pluginGoogleSignOut,
       _now = now ?? DateTime.now;

  final FirebaseAuth _auth;
  final Future<String?> Function() _googleIdToken;
  final Future<String?> Function() _googleSilentIdToken;
  final Future<void> Function() _googleSignOut;
  final DateTime Function() _now;

  /// Firebase refuses to delete an account after about five minutes without
  /// a login; a margin keeps the check on the safe side.
  static const _recentLogin = Duration(minutes: 4);

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
    await _refreshToken(user);
    await user.updateDisplayName(name);
    try {
      await user.sendEmailVerification();
    } on Object catch (_) {
      // The account exists already; the Profile Sheet offers "Reenviar".
    }
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
  Future<AppUser?> signInWithGoogle() => _social(() async {
    final idToken = await _googleIdToken();
    if (idToken == null) return null;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _linkOrSignIn(
      link: (guest) => guest.linkWithCredential(credential),
      signIn: () => _auth.signInWithCredential(credential),
    );
  });

  @override
  Future<AppUser?> signInWithApple() => _social(() {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    return _linkOrSignIn(
      link: (guest) => guest.linkWithProvider(provider),
      signIn: () => _auth.signInWithProvider(provider),
    );
  });

  @override
  Future<void> resendVerification() => _guard(() async {
    await _auth.currentUser?.sendEmailVerification();
  });

  @override
  Future<void> reload() => _guard(() async {
    await _auth.currentUser?.reload();
  });

  @override
  Future<void> updateName(String name) => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const UnexpectedFailure();
    await user.updateDisplayName(name);
    await user.reload();
  });

  @override
  Future<AppUser> signOut() async {
    try {
      // So the next "Continuar com o Google" shows the account picker again.
      await _googleSignOut();
    } on Object catch (_) {
      // Best effort: the Firebase sign-out below is what matters.
    }
    await _auth.signOut();
    return ensureSignedIn();
  }

  @override
  Future<bool> refreshLoginSilently() => _guard(() async {
    final user = _auth.currentUser;
    if (user == null) throw const UnexpectedFailure();
    final last = user.metadata.lastSignInTime;
    if (last != null && _now().difference(last) < _recentLogin) return true;
    // Only Google can refresh a login without showing anything; Apple and
    // the password always ask the person.
    if (!user.providerData.any((i) => i.providerId == 'google.com')) {
      return false;
    }
    final idToken = await _googleSilentIdToken();
    if (idToken == null) return false;
    await user.reauthenticateWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return true;
  });

  @override
  Future<AppUser> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw const UnexpectedFailure();
    // ponytail: the Apple token is not revoked; that needs a code from the
    // Apple sheet, and deleting must not open it. Revoke from a server
    // (Cloud Functions) if App Review asks for it.
    await _guard(user.delete);
    try {
      await _googleSignOut();
    } on Object catch (_) {
      // Best effort, as in `signOut`: the account is already gone.
    }
    return ensureSignedIn();
  }

  /// A guest links the account, keeping its uid. When the account already
  /// exists the guest is dropped and the person signs in to it instead: a
  /// guest has nothing saved (rule R1), so nothing is lost.
  Future<AppUser> _linkOrSignIn({
    required Future<UserCredential> Function(User guest) link,
    required Future<UserCredential> Function() signIn,
  }) async {
    final guest = _auth.currentUser;
    if (guest == null || !guest.isAnonymous) return _user(await signIn());
    try {
      final credential = await link(guest);
      final user = credential.user;
      if (user != null) await _refreshToken(user);
      return _user(credential);
    } on FirebaseAuthException catch (error) {
      if (!_accountExists.contains(error.code)) rethrow;
      // Reusing the credential Firebase hands back avoids opening the
      // Apple sheet a second time.
      final credential = error.credential;
      return _user(
        credential == null
            ? await signIn()
            : await _auth.signInWithCredential(credential),
      );
    }
  }

  /// After linking, the ID token still says `anonymous`, and the Firestore
  /// rules deny anonymous users: force a new one. A failure here must not fail
  /// the login, the token is refreshed on its own within the hour.
  Future<void> _refreshToken(User user) async {
    try {
      await user.getIdToken(true);
    } on Object catch (_) {
      // Best effort; see above.
    }
  }

  static const _accountExists = {
    'credential-already-in-use',
    'email-already-in-use',
    'account-exists-with-different-credential',
  };

  /// Closing the Google or Apple sheet is not an error: it returns null.
  Future<AppUser?> _social(Future<AppUser?> Function() body) =>
      _guard(() async {
        try {
          return await body();
        } on FirebaseAuthException catch (error) {
          if (_cancelled.contains(error.code)) return null;
          rethrow;
        }
      });

  static const _cancelled = {
    'canceled',
    'web-context-canceled',
    'web-context-cancelled',
  };

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
    'user-mismatch' ||
    'user-not-found' ||
    'user-disabled' => const InvalidCredentialsFailure(),
    'email-already-in-use' ||
    'credential-already-in-use' => const EmailInUseFailure(),
    'requires-recent-login' => const RequiresRecentLoginFailure(),
    'invalid-email' => const InvalidEmailFailure(),
    'weak-password' => const WeakPasswordFailure(),
    'account-exists-with-different-credential' =>
      const AccountExistsWithOtherMethodFailure(),
    _ => const UnexpectedFailure(),
  };

  /// Apple and Google keep the name on the provider, not always on the user.
  String? _nameOf(User user) {
    if (user.displayName?.isNotEmpty ?? false) return user.displayName;
    for (final info in user.providerData) {
      if (info.displayName?.isNotEmpty ?? false) return info.displayName;
    }
    return null;
  }

  AppUser _toAppUser(User user) => AppUser(
    uid: user.uid,
    isAnonymous: user.isAnonymous,
    name: _nameOf(user),
    email: user.email,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
    usesPassword: user.providerData.any((i) => i.providerId == 'password'),
  );
}

// `initialize` must run once, before anything else in `google_sign_in`.
Future<void>? _googleReady;

Future<void> _initializeGoogle() =>
    _googleReady ??= GoogleSignIn.instance.initialize(
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? DefaultFirebaseOptions.googleIosClientId
          : null,
      serverClientId: DefaultFirebaseOptions.googleWebClientId,
    );

Future<String?> _pluginGoogleIdToken() async {
  try {
    await _initializeGoogle();
    final account = await GoogleSignIn.instance.authenticate();
    return account.authentication.idToken;
  } on Exception catch (error) {
    if (error is GoogleSignInException &&
        error.code == GoogleSignInExceptionCode.canceled) {
      return null;
    }
    // A misconfigured client id lands here, too: see `docs/auth.md`.
    throw const UnexpectedFailure();
  }
}

Future<String?> _pluginGoogleSilentIdToken() async {
  try {
    await _initializeGoogle();
    final account = await GoogleSignIn.instance
        .attemptLightweightAuthentication();
    return account?.authentication.idToken;
  } on Exception {
    // No silent login available: the caller asks for a new sign-in.
    return null;
  }
}

Future<void> _pluginGoogleSignOut() async {
  await _initializeGoogle();
  await GoogleSignIn.instance.signOut();
}
