import 'dart:async';

import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

/// In-memory accounts: what is created here lives until the app closes.
class FakeAuthRepository implements AuthRepository {
  static const user = AppUser(uid: 'fake-uid', isAnonymous: true);

  final _accounts = <String, ({String name, String password})>{};
  final _changes = StreamController<AppUser>.broadcast();
  AppUser _current = user;

  @override
  Future<AppUser> ensureSignedIn() async => _current;

  @override
  Stream<AppUser> watchUser() => Stream.multi((listener) {
    // Subscribes before returning, so no change is lost after the first event.
    listener.add(_current);
    final subscription = _changes.stream.listen(listener.add);
    listener.onCancel = subscription.cancel;
  });

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw const InvalidCredentialsFailure();
    }
    return _set(_account(name: account.name, email: email, usesPassword: true));
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_accounts.containsKey(email)) throw const EmailInUseFailure();
    _accounts[email] = (name: name, password: password);
    return _set(_account(name: name, email: email, usesPassword: true));
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  /// Always picks the same sample account, so the app without Firebase can
  /// show the flow.
  @override
  Future<AppUser?> signInWithGoogle() async =>
      _set(_account(name: 'Ana Souza', email: 'ana.souza@gmail.com'));

  @override
  Future<AppUser?> signInWithApple() async =>
      _set(_account(name: 'Ana Souza', email: 'ana.souza@icloud.com'));

  @override
  Future<void> resendVerification() async {}

  @override
  Future<void> reload() async {}

  @override
  Future<void> updateName(String name) async =>
      _set(_current.copyWith(name: name));

  @override
  Future<AppUser> signOut() async => _set(user);

  @override
  Future<bool> refreshLoginSilently() async => true;

  @override
  Future<AppUser> deleteAccount() async {
    _accounts.remove(_current.email);
    return _set(user);
  }

  AppUser _account({
    required String name,
    required String email,
    bool usesPassword = false,
  }) => AppUser(
    uid: user.uid,
    isAnonymous: false,
    name: name,
    email: email,
    // Social accounts arrive verified; a fresh password account does not.
    emailVerified: !usesPassword,
    usesPassword: usesPassword,
  );

  AppUser _set(AppUser next) {
    _current = next;
    _changes.add(next);
    return next;
  }
}
