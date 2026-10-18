import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/firebase_auth_repository.dart';
import 'package:rango_app/models/app_user.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

void main() {
  late _MockFirebaseAuth auth;
  late FirebaseAuthRepository repository;

  _MockUser user(String uid) {
    final user = _MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.isAnonymous).thenReturn(true);
    return user;
  }

  setUp(() {
    auth = _MockFirebaseAuth();
    repository = FirebaseAuthRepository(auth);
  });

  test('signs in anonymously when there is no current user', () async {
    final newUser = user('new-uid');
    final credential = _MockUserCredential();
    when(() => credential.user).thenReturn(newUser);
    when(() => auth.currentUser).thenReturn(null);
    when(auth.signInAnonymously).thenAnswer((_) async => credential);

    final result = await repository.ensureSignedIn();

    expect(result, const AppUser(uid: 'new-uid', isAnonymous: true));
    verify(auth.signInAnonymously).called(1);
  });

  test('reuses the current user without signing in again', () async {
    final existing = user('existing-uid');
    when(() => auth.currentUser).thenReturn(existing);

    final result = await repository.ensureSignedIn();

    expect(result.uid, 'existing-uid');
    verifyNever(auth.signInAnonymously);
  });

  test('maps network-request-failed to NetworkFailure', () async {
    when(() => auth.currentUser).thenReturn(null);
    when(auth.signInAnonymously).thenThrow(
      FirebaseAuthException(code: 'network-request-failed'),
    );

    expect(repository.ensureSignedIn(), throwsA(isA<NetworkFailure>()));
  });

  test('maps other auth errors to UnexpectedFailure', () async {
    when(() => auth.currentUser).thenReturn(null);
    when(auth.signInAnonymously).thenThrow(
      FirebaseAuthException(code: 'operation-not-allowed'),
    );

    expect(repository.ensureSignedIn(), throwsA(isA<UnexpectedFailure>()));
  });

  test('treats a sign-in without user as UnexpectedFailure', () async {
    final credential = _MockUserCredential();
    when(() => credential.user).thenReturn(null);
    when(() => auth.currentUser).thenReturn(null);
    when(auth.signInAnonymously).thenAnswer((_) async => credential);

    expect(repository.ensureSignedIn(), throwsA(isA<UnexpectedFailure>()));
  });
}
