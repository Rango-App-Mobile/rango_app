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

  test('brings the name, e-mail and photo of a user with an account', () async {
    final existing = _MockUser();
    when(() => existing.uid).thenReturn('account-uid');
    when(() => existing.isAnonymous).thenReturn(false);
    when(() => existing.displayName).thenReturn('Joana');
    when(() => existing.email).thenReturn('joana@email.com');
    when(() => existing.photoURL).thenReturn('https://example.com/joana.png');
    when(() => auth.currentUser).thenReturn(existing);

    final result = await repository.ensureSignedIn();

    expect(
      result,
      const AppUser(
        uid: 'account-uid',
        isAnonymous: false,
        name: 'Joana',
        email: 'joana@email.com',
        photoUrl: 'https://example.com/joana.png',
      ),
    );
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

  group('accounts', () {
    setUpAll(() {
      registerFallbackValue(
        EmailAuthProvider.credential(email: 'a@b.c', password: 'x'),
      );
    });

    _MockUser account() {
      final account = _MockUser();
      when(() => account.uid).thenReturn('guest-uid');
      when(() => account.isAnonymous).thenReturn(false);
      when(() => account.displayName).thenReturn('Joana');
      when(() => account.email).thenReturn('joana@email.com');
      when(() => account.photoURL).thenReturn(null);
      when(() => account.updateDisplayName(any())).thenAnswer((_) async {});
      when(account.reload).thenAnswer((_) async {});
      return account;
    }

    test(
      'signing up links the guest, keeping the uid, and saves the name',
      () async {
        final guest = user('guest-uid');
        final linked = account();
        final credential = _MockUserCredential();
        when(() => credential.user).thenReturn(linked);
        when(() => auth.currentUser).thenReturn(guest);
        when(() => guest.linkWithCredential(any())).thenAnswer((_) async {
          when(() => auth.currentUser).thenReturn(linked);
          return credential;
        });

        final result = await repository.signUp(
          name: 'Joana',
          email: 'joana@email.com',
          password: '12345678',
        );

        expect(result.uid, 'guest-uid');
        expect(result.isAnonymous, isFalse);
        expect(result.name, 'Joana');
        verify(() => linked.updateDisplayName('Joana')).called(1);
        verifyNever(
          () => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        );
      },
    );

    test('signing up with a used e-mail is EmailInUseFailure', () async {
      final guest = user('guest-uid');
      when(() => auth.currentUser).thenReturn(guest);
      when(
        () => guest.linkWithCredential(any()),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        repository.signUp(name: 'J', email: 'j@e.com', password: '12345678'),
        throwsA(isA<EmailInUseFailure>()),
      );
    });

    test('signs in with e-mail and password', () async {
      final signedIn = account();
      final credential = _MockUserCredential();
      when(() => credential.user).thenReturn(signedIn);
      when(
        () => auth.signInWithEmailAndPassword(
          email: 'joana@email.com',
          password: '12345678',
        ),
      ).thenAnswer((_) async => credential);

      final result = await repository.signIn(
        email: 'joana@email.com',
        password: '12345678',
      );

      expect(result.email, 'joana@email.com');
      expect(result.isAnonymous, isFalse);
    });

    for (final (code, matcher) in [
      ('invalid-credential', isA<InvalidCredentialsFailure>()),
      ('wrong-password', isA<InvalidCredentialsFailure>()),
      ('user-not-found', isA<InvalidCredentialsFailure>()),
      ('invalid-email', isA<InvalidEmailFailure>()),
      ('network-request-failed', isA<NetworkFailure>()),
      ('too-many-requests', isA<UnexpectedFailure>()),
    ]) {
      test('signing in maps $code', () {
        when(
          () => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(FirebaseAuthException(code: code));

        expect(
          repository.signIn(email: 'j@e.com', password: 'x'),
          throwsA(matcher),
        );
      });
    }

    test('a password reset for an unknown e-mail still succeeds', () async {
      when(
        () => auth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await expectLater(repository.sendPasswordReset('j@e.com'), completes);
    });

    test('a password reset without network is NetworkFailure', () {
      when(
        () => auth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      expect(
        repository.sendPasswordReset('j@e.com'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('signing out goes back to a new guest session', () async {
      final guest = user('new-guest');
      final credential = _MockUserCredential();
      when(() => credential.user).thenReturn(guest);
      when(auth.signOut).thenAnswer((_) async {});
      when(() => auth.currentUser).thenReturn(null);
      when(auth.signInAnonymously).thenAnswer((_) async => credential);

      final result = await repository.signOut();

      expect(result.isAnonymous, isTrue);
      verifyInOrder([auth.signOut, auth.signInAnonymously]);
    });

    test('watches the user, skipping the signed-out gap', () {
      final guest = user('guest-uid');
      when(
        auth.userChanges,
      ).thenAnswer((_) => Stream.fromIterable([guest, null, account()]));

      expect(
        repository.watchUser().map((user) => user.isAnonymous),
        emitsInOrder([true, false, emitsDone]),
      );
    });
  });
}
