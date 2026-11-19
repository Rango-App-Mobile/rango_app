// The Firestore SDK types are sealed; mocking them is the only way to test.
// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/account_repository.dart';
import 'package:rango_app/data/firestore_account_repository.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockQueryDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class _MockBatch extends Mock implements WriteBatch {}

void main() {
  late _MockFirestore firestore;
  late _MockCollection sessions;
  late _MockDoc userDoc;
  late FirestoreAccountRepository repository;

  setUpAll(() {
    registerFallbackValue(SetOptions(merge: true));
    registerFallbackValue(_MockDoc());
  });

  setUp(() {
    firestore = _MockFirestore();
    final users = _MockCollection();
    userDoc = _MockDoc();
    sessions = _MockCollection();
    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.collection('sessions')).thenReturn(sessions);
    repository = FirestoreAccountRepository(firestore);
  });

  void stubUser(Map<String, dynamic>? data) {
    final snapshot = _MockSnapshot();
    when(() => snapshot.exists).thenReturn(data != null);
    when(snapshot.data).thenReturn(data);
    when(userDoc.get).thenAnswer((_) async => snapshot);
  }

  group('hasAcceptedTerms', () {
    test('is false when the document does not exist', () async {
      stubUser(null);
      expect(await repository.hasAcceptedTerms('u1'), isFalse);
    });

    test('is false for an older terms version', () async {
      stubUser({'termsVersion': currentTermsVersion - 1});
      expect(await repository.hasAcceptedTerms('u1'), isFalse);
    });

    test('is true for the current version', () async {
      stubUser({'termsVersion': currentTermsVersion});
      expect(await repository.hasAcceptedTerms('u1'), isTrue);
    });
  });

  test('acceptTerms merges the version and a server timestamp', () async {
    when(() => userDoc.set(any(), any())).thenAnswer((_) async {});

    await repository.acceptTerms('u1');

    final captured = verify(
      () => userDoc.set(captureAny(), captureAny()),
    ).captured;
    final data = captured[0] as Map<String, dynamic>;
    expect(data['termsVersion'], currentTermsVersion);
    expect(data['termsAcceptedAt'], isA<FieldValue>());
    expect((captured[1] as SetOptions).merge, isTrue);
  });

  test(
    'deleteData removes sessions in batches of 500, then the user',
    () async {
      final docs = <_MockQueryDoc>[];
      for (var i = 0; i < 1200; i++) {
        final doc = _MockQueryDoc();
        when(() => doc.reference).thenReturn(_MockDoc());
        docs.add(doc);
      }
      final snapshot = _MockQuerySnapshot();
      when(() => snapshot.docs).thenReturn(docs);
      when(sessions.get).thenAnswer((_) async => snapshot);
      final batches = <_MockBatch>[];
      when(firestore.batch).thenAnswer((_) {
        final batch = _MockBatch();
        when(batch.commit).thenAnswer((_) async {});
        batches.add(batch);
        return batch;
      });
      when(userDoc.delete).thenAnswer((_) async {});

      await repository.deleteData('u1');

      expect(batches, hasLength(3));
      verify(() => batches[0].delete(any())).called(500);
      verify(() => batches[2].delete(any())).called(200);
      for (final batch in batches) {
        verify(batch.commit).called(1);
      }
      verify(userDoc.delete).called(1);
    },
  );

  test('unavailable becomes NetworkFailure', () async {
    when(userDoc.get).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
    );
    await expectLater(
      repository.hasAcceptedTerms('u1'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('other Firebase errors become UnexpectedFailure', () async {
    when(userDoc.get).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
    );
    await expectLater(
      repository.hasAcceptedTerms('u1'),
      throwsA(isA<UnexpectedFailure>()),
    );
  });
}
