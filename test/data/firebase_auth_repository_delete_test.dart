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

class _MockUserMetadata extends Mock implements UserMetadata {}

final _now = DateTime(2026, 11, 14, 12);

void main() {
  late _MockFirebaseAuth auth;
  late _MockUser user;
  late FirebaseAuthRepository repository;
  String? silentToken;
  var googleSignOuts = 0;
  var deleted = false;

  setUpAll(() {
    registerFallbackValue(GoogleAuthProvider.credential(idToken: 'x'));
    registerFallbackValue(AppleAuthProvider());
  });

  /// An account linked to [providers] whose last sign-in was [ago].
  void signedIn(List<String> providers, {required Duration ago}) {
    final infos = [for (final id in providers) _MockUserInfo()..stubId(id)];
    when(() => user.providerData).thenReturn(infos);
    final metadata = _MockUserMetadata();
    when(() => metadata.lastSignInTime).thenReturn(_now.subtract(ago));
    when(() => user.metadata).thenReturn(metadata);
  }

  setUp(() {
    deleted = false;
    googleSignOuts = 0;
    silentToken = 'silent-google-token';
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
      googleIdToken: () async => fail('deleting never opens the Google picker'),
      googleSilentIdToken: () async => silentToken,
      googleSignOut: () async => googleSignOuts++,
      now: () => _now,
    );
  });

  group('refreshLoginSilently', () {
    for (final provider in ['apple.com', 'google.com', 'password']) {
      test('a recent $provider login needs nothing', () async {
        signedIn([provider], ago: const Duration(minutes: 1));

        expect(await repository.refreshLoginSilently(), isTrue);
        verifyNever(() => user.reauthenticateWithCredential(any()));
        verifyNever(() => user.reauthenticateWithProvider(any()));
      });
    }

    test('an old Google login is refreshed without any UI', () async {
      signedIn(['apple.com', 'google.com'], ago: const Duration(days: 3));
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => _MockUserCredential());

      expect(await repository.refreshLoginSilently(), isTrue);
      verify(() => user.reauthenticateWithCredential(any())).called(1);
    });

    test('an old Google login without a silent token is not enough', () async {
      signedIn(['google.com'], ago: const Duration(days: 3));
      silentToken = null;

      expect(await repository.refreshLoginSilently(), isFalse);
    });

    for (final provider in ['apple.com', 'password']) {
      test('an old $provider login is not enough, and asks nothing', () async {
        signedIn([provider], ago: const Duration(days: 3));

        expect(await repository.refreshLoginSilently(), isFalse);
        verifyNever(() => user.reauthenticateWithCredential(any()));
        verifyNever(() => user.reauthenticateWithProvider(any()));
      });
    }
  });

  group('deleteAccount', () {
    test('deletes the user, leaves Google and starts a new guest', () async {
      final guest = _MockUser();
      when(() => guest.uid).thenReturn('guest');
      when(() => guest.isAnonymous).thenReturn(true);
      when(() => guest.emailVerified).thenReturn(false);
      when(() => guest.providerData).thenReturn([]);
      final credential = _MockUserCredential();
      when(() => credential.user).thenReturn(guest);
      when(auth.signInAnonymously).thenAnswer((_) async => credential);
      signedIn(['google.com'], ago: Duration.zero);

      final result = await repository.deleteAccount();

      expect(result.isAnonymous, isTrue);
      expect(googleSignOuts, 1);
      verifyInOrder([() => user.delete(), auth.signInAnonymously]);
    });

    test('a refused deletion is a Failure and keeps the account', () async {
      signedIn(['apple.com'], ago: Duration.zero);
      when(
        () => user.delete(),
      ).thenThrow(FirebaseAuthException(code: 'requires-recent-login'));

      await expectLater(
        repository.deleteAccount(),
        throwsA(isA<RequiresRecentLoginFailure>()),
      );
      verifyNever(auth.signInAnonymously);
    });
  });
}
