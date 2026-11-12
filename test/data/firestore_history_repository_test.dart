// The Firestore SDK types are sealed; mocking them is the only way to test.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/firestore_history_repository.dart';
import 'package:rango_app/models/history_entry.dart';
import 'package:rango_app/models/order_channel.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockQueryDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

_MockQueryDoc _doc(String id, Map<String, dynamic> data) {
  final doc = _MockQueryDoc();
  when(() => doc.id).thenReturn(id);
  when(doc.data).thenReturn(data);
  return doc;
}

final _decidedAt = DateTime(2026, 11, 12, 20, 30);

Map<String, dynamic> _valid({String channel = 'delivery'}) => {
  'foodId': 'pizza',
  'restaurantId': 'p1',
  'restaurantName': 'Bella Napoli',
  'cuisine': 'Pizzaria',
  'channel': channel,
  'decidedAt': Timestamp.fromDate(_decidedAt),
};

void main() {
  late _MockFirestore firestore;
  late _MockCollection sessions;
  late _MockQuery query;
  late FirestoreHistoryRepository repository;

  setUpAll(() => registerFallbackValue(const GetOptions()));

  setUp(() {
    firestore = _MockFirestore();
    final users = _MockCollection();
    final userDoc = _MockDoc();
    sessions = _MockCollection();
    query = _MockQuery();
    when(() => firestore.collection('users')).thenReturn(users);
    when(() => users.doc('u1')).thenReturn(userDoc);
    when(() => userDoc.collection('sessions')).thenReturn(sessions);
    when(
      () => sessions.orderBy('decidedAt', descending: true),
    ).thenReturn(query);
    when(() => query.limit(100)).thenReturn(query);
    repository = FirestoreHistoryRepository(
      firestore,
      timeout: const Duration(milliseconds: 50),
    );
  });

  void stubDocs(List<_MockQueryDoc> docs) {
    final snapshot = _MockQuerySnapshot();
    when(() => snapshot.docs).thenReturn(docs);
    when(() => query.get(any())).thenAnswer((_) async => snapshot);
  }

  group('fetchAll', () {
    test('reads the newest 100 of users/{uid}/sessions', () async {
      stubDocs([]);
      await repository.fetchAll('u1');
      verify(() => sessions.orderBy('decidedAt', descending: true)).called(1);
      verify(() => query.limit(100)).called(1);
    });

    test('maps every field', () async {
      stubDocs([_doc('s1', _valid(channel: 'call'))]);
      expect(await repository.fetchAll('u1'), [
        HistoryEntry(
          id: 's1',
          foodId: 'pizza',
          restaurantId: 'p1',
          restaurantName: 'Bella Napoli',
          cuisine: 'Pizzaria',
          channel: OrderChannel.call,
          decidedAt: _decidedAt,
        ),
      ]);
    });

    test('skips malformed documents', () async {
      stubDocs([
        _doc('ok', _valid()),
        _doc('no-food', {..._valid()}..remove('foodId')),
        _doc('bad-channel', _valid(channel: 'pigeon')),
        _doc('no-date', {..._valid(), 'decidedAt': null}),
      ]);
      final entries = await repository.fetchAll('u1');
      expect(entries.map((entry) => entry.id), ['ok']);
    });

    test('unavailable becomes NetworkFailure', () async {
      when(() => query.get(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );
      await expectLater(
        repository.fetchAll('u1'),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('other Firebase errors become UnexpectedFailure', () async {
      when(() => query.get(any())).thenThrow(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      );
      await expectLater(
        repository.fetchAll('u1'),
        throwsA(isA<UnexpectedFailure>()),
      );
    });

    test('a timeout becomes NetworkFailure', () async {
      final never = Completer<QuerySnapshot<Map<String, dynamic>>>();
      when(() => query.get(any())).thenAnswer((_) => never.future);
      await expectLater(
        repository.fetchAll('u1'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });

  group('save', () {
    final entry = HistoryEntry(
      id: '',
      foodId: 'pizza',
      restaurantId: 'p1',
      restaurantName: 'Bella Napoli',
      cuisine: 'Pizzaria',
      channel: OrderChannel.delivery,
      decidedAt: _decidedAt,
    );

    test('adds the decision with a server timestamp', () async {
      when(() => sessions.add(any())).thenAnswer((_) async => _MockDoc());
      await repository.save('u1', entry);
      final data =
          verify(() => sessions.add(captureAny())).captured.single
              as Map<String, dynamic>;
      expect(data, {
        'foodId': 'pizza',
        'restaurantId': 'p1',
        'restaurantName': 'Bella Napoli',
        'cuisine': 'Pizzaria',
        'channel': 'delivery',
        'decidedAt': FieldValue.serverTimestamp(),
      });
    });

    test('does not wait for the server', () async {
      final never = Completer<DocumentReference<Map<String, dynamic>>>();
      when(() => sessions.add(any())).thenAnswer((_) => never.future);
      await repository.save('u1', entry);
    });

    test('a failed write is swallowed', () async {
      when(() => sessions.add(any())).thenAnswer(
        (_) async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      );
      await repository.save('u1', entry);
      await Future<void>.delayed(Duration.zero);
    });
  });
}
