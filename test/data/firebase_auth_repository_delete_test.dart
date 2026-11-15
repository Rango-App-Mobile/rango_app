import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/firebase_auth_repository.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUser extends Mock implements User {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUserInfo extends Mock implements UserInfo {
  void stubId(String id) => when(() => providerId).thenReturn(id);
}

class _MockIdTokenResult extends Mock implements IdTokenResult {}

class _MockAdditionalUserInfo extends Mock implements AdditionalUserInfo {}

void main() {
  late _MockFirebaseAuth auth;
  late _MockUser user;
  late FirebaseAuthRepository repository;
  String? googleIdToken;
  var googleSignOuts = 0;
  var deleted = false;

  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider.credential(idToken: 'x'));
    registerFallbackValue(AppleAuthProvider());
  });

  /// [providerId] is how this session signed in (the token's
  /// `sign_in_provider`, unless [session] says otherwise); [alsoLinked] are
  /// other providers on the same account.
  void signedInWith(
    String providerId, {
    List<String> alsoLinked = const [],
    String? session = '',
  }) {
    final infos = [
      for (final id in [providerId, ...alsoLinked]) _MockUserInfo()..stubId(id),
    ];
    when(() => user.providerData).thenReturn(infos);
    final token = _MockIdTokenResult();
    when(
      () => token.signInProvider,
    ).thenReturn(session == '' ? providerId : session);
    when(user.getIdTokenResult).thenAnswer((_) async => token);
  }

  setUp(() {
    deleted = false;
    googleSignOuts = 0;
    googleIdToken = 'google-id-token';
    auth = _MockFirebaseAuth();
    user = _MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => user.isAnonymous).thenReturn(false);
    when(() => user.email).thenReturn('joana@email.com');
    when(() => user.emailVerified).thenReturn(true);
    when(() => user.delete()).thenAnswer((_) async => deleted = true);
    when(() => auth.currentUser).thenAnswer((_) => deleted ? null : user);
    repository = FirebaseAuthRepository(
      auth,
      googleIdToken: () async => googleIdToken,
      googleSignOut: () async => googleSignOuts++,
    );
  });

  group('reauthenticate', () {
    test('a password account reauthenticates with the password', () async {
      signedInWith('password');
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      expect(await repository.reauthenticate(password: '12345678'), isTrue);
      verify(() => user.reauthenticateWithCredential(any())).called(1);
    });

    test('a password account without a password is invalid', () {
      signedInWith('password');

      expect(
        repository.reauthenticate(),
        throwsA(isA<InvalidCredentialsFailure>()),
      );
    });

    test('a Google account reauthenticates with a new ID token', () async {
      signedInWith('google.com');
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      expect(await repository.reauthenticate(), isTrue);
      verify(() => user.reauthenticateWithCredential(any())).called(1);
    });

    test('closing the Google picker returns false', () async {
      signedInWith('google.com');
      googleIdToken = null;

      expect(await repository.reauthenticate(), isFalse);
      verifyNever(() => user.reauthenticateWithCredential(any()));
    });

    test('an Apple account reauthenticates with the Apple provider', () async {
      signedInWith('apple.com');
      when(
        () => user.reauthenticateWithProvider(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      expect(await repository.reauthenticate(), isTrue);
      verify(() => user.reauthenticateWithProvider(any())).called(1);
    });

    test(
      'an account with Google and Apple uses the one it signed in with',
      () async {
        signedInWith('apple.com', alsoLinked: ['google.com', 'password']);
        when(
          () => user.reauthenticateWithProvider(any()),
        ).thenAnswer((_) async => _MockUserCredential());

        expect(await repository.reauthenticate(password: 'x'), isTrue);
        verify(() => user.reauthenticateWithProvider(any())).called(1);
        verifyNever(() => user.reauthenticateWithCredential(any()));
      },
    );

    test('without the session provider it prefers Apple over Google', () async {
      signedInWith('google.com', alsoLinked: ['apple.com'], session: null);
      when(
        () => user.reauthenticateWithProvider(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      expect(await repository.reauthenticate(), isTrue);
      verify(() => user.reauthenticateWithProvider(any())).called(1);
    });

    for (final code in ['canceled', 'web-context-canceled']) {
      test('closing the Apple sheet ($code) returns false', () async {
        signedInWith('apple.com');
        when(
          () => user.reauthenticateWithProvider(any()),
        ).thenThrow(FirebaseAuthException(code: code));

        expect(await repository.reauthenticate(), isFalse);
      });
    }

    test('maps wrong password, mismatch, recent login and network', () async {
      signedInWith('password');
      final expected = {
        'wrong-password': isA<InvalidCredentialsFailure>(),
        'user-mismatch': isA<InvalidCredentialsFailure>(),
        'requires-recent-login': isA<RequiresRecentLoginFailure>(),
        'network-request-failed': isA<NetworkFailure>(),
      };
      for (final MapEntry(:key, :value) in expected.entries) {
        when(
          () => user.reauthenticateWithCredential(any()),
        ).thenThrow(FirebaseAuthException(code: key));
        await expectLater(
          repository.reauthenticate(password: 'x'),
          throwsA(value),
          reason: key,
        );
      }
    });
  });

  group('deleteAccount', () {
    test('deletes the user, then returns a new guest', () async {
      final guest = _MockUser();
      when(() => guest.uid).thenReturn('guest');
      when(() => guest.isAnonymous).thenReturn(true);
      when(() => guest.emailVerified).thenReturn(false);
      when(() => guest.providerData).thenReturn([]);
      final credential = _MockUserCredential();
      when(() => credential.user).thenReturn(guest);
      when(auth.signInAnonymously).thenAnswer((_) async => credential);
      signedInWith('google.com');

      final result = await repository.deleteAccount();

      expect(result.isAnonymous, isTrue);
      expect(googleSignOuts, 1);
      verifyInOrder([() => user.delete(), auth.signInAnonymously]);
    });

    test(
      'revokes the Apple token with the code from reauthentication',
      () async {
        signedInWith('apple.com');
        final info = _MockAdditionalUserInfo();
        when(() => info.authorizationCode).thenReturn('apple-code');
        final credential = _MockUserCredential();
        when(() => credential.additionalUserInfo).thenReturn(info);
        when(
          () => user.reauthenticateWithProvider(any()),
        ).thenAnswer((_) async => credential);
        when(
          () => auth.revokeTokenWithAuthorizationCode('apple-code'),
        ).thenAnswer((_) async {});
        final anonymous = _MockUserCredential();
        final guest = _MockUser();
        when(() => guest.uid).thenReturn('guest');
        when(() => guest.isAnonymous).thenReturn(true);
        when(() => guest.emailVerified).thenReturn(false);
        when(() => guest.providerData).thenReturn([]);
        when(() => anonymous.user).thenReturn(guest);
        when(auth.signInAnonymously).thenAnswer((_) async => anonymous);

        await repository.reauthenticate();
        await repository.deleteAccount();

        verifyInOrder([
          () => auth.revokeTokenWithAuthorizationCode('apple-code'),
          () => user.delete(),
        ]);
      },
    );

    test('a failed Apple revocation does not block the deletion', () async {
      signedInWith('apple.com');
      final info = _MockAdditionalUserInfo();
      when(() => info.authorizationCode).thenReturn('apple-code');
      final credential = _MockUserCredential();
      when(() => credential.additionalUserInfo).thenReturn(info);
      when(
        () => user.reauthenticateWithProvider(any()),
      ).thenAnswer((_) async => credential);
      when(
        () => auth.revokeTokenWithAuthorizationCode(any()),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      final anonymous = _MockUserCredential();
      final guest = _MockUser();
      when(() => guest.uid).thenReturn('guest');
      when(() => guest.isAnonymous).thenReturn(true);
      when(() => guest.emailVerified).thenReturn(false);
      when(() => guest.providerData).thenReturn([]);
      when(() => anonymous.user).thenReturn(guest);
      when(auth.signInAnonymously).thenAnswer((_) async => anonymous);

      await repository.reauthenticate();
      await repository.deleteAccount();

      verify(() => user.delete()).called(1);
    });

    test('a failed deletion is a Failure and keeps the account', () {
      signedInWith('google.com');
      when(
        () => user.delete(),
      ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));

      expect(
        repository.deleteAccount(),
        throwsA(isA<RequiresRecentLoginFailure>()),
      );
      verifyNever(auth.signInAnonymously);
    });
  });
}
