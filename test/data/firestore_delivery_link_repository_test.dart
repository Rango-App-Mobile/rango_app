// The Firestore SDK types are sealed; mocking them is the only way to test.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/data/firestore_delivery_link_repository.dart';
import 'package:rango_app/models/delivery_links.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class _MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late _MockFirestore firestore;
  late _MockCollection collection;
  late _MockDoc doc;
  late FirestoreDeliveryLinkRepository repository;

  void stubData(Map<String, dynamic>? data) {
    final snapshot = _MockSnapshot();
    when(snapshot.data).thenReturn(data);
    when(doc.get).thenAnswer((_) async => snapshot);
  }

  setUp(() {
    firestore = _MockFirestore();
    collection = _MockCollection();
    doc = _MockDoc();
    when(() => firestore.collection('restaurants')).thenReturn(collection);
    when(() => collection.doc('p1')).thenReturn(doc);
    repository = FirestoreDeliveryLinkRepository(
      firestore,
      timeout: const Duration(milliseconds: 50),
    );
  });

  test('reads restaurants/{placeId}', () async {
    stubData(null);
    await repository.linksFor('p1');
    verify(() => firestore.collection('restaurants')).called(1);
    verify(() => collection.doc('p1')).called(1);
  });

  test('parses ifood and others', () async {
    stubData({
      'deliveryLinks': {
        'ifood': 'https://ifood.com.br/a',
        'others': ['https://b.com', 'https://c.com'],
      },
    });
    expect(
      await repository.linksFor('p1'),
      const DeliveryLinks(
        ifood: 'https://ifood.com.br/a',
        others: ['https://b.com', 'https://c.com'],
      ),
    );
  });

  test('parses only others', () async {
    stubData({
      'deliveryLinks': {
        'others': ['https://b.com'],
      },
    });
    expect(
      await repository.linksFor('p1'),
      const DeliveryLinks(others: ['https://b.com']),
    );
  });

  test('ignores empty strings and non-string items', () async {
    stubData({
      'deliveryLinks': {
        'ifood': '',
        'others': ['', 42, null, 'https://b.com'],
      },
    });
    expect(
      await repository.linksFor('p1'),
      const DeliveryLinks(others: ['https://b.com']),
    );
  });

  test('returns null when everything is empty', () async {
    stubData({
      'deliveryLinks': {'ifood': '', 'others': <String>[]},
    });
    expect(await repository.linksFor('p1'), isNull);
  });

  test('returns null for a missing doc or field', () async {
    stubData(null);
    expect(await repository.linksFor('p1'), isNull);
    stubData({'name': 'x'});
    expect(await repository.linksFor('p1'), isNull);
  });

  test('returns null for malformed shapes', () async {
    stubData({'deliveryLinks': 'nope'});
    expect(await repository.linksFor('p1'), isNull);
    stubData({
      'deliveryLinks': {'ifood': 7, 'others': 'x'},
    });
    expect(await repository.linksFor('p1'), isNull);
  });

  test('returns null on FirebaseException', () async {
    when(doc.get).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
    );
    expect(await repository.linksFor('p1'), isNull);
  });

  test('returns null on timeout', () async {
    final never = Completer<DocumentSnapshot<Map<String, dynamic>>>();
    when(doc.get).thenAnswer((_) => never.future);
    expect(await repository.linksFor('p1'), isNull);
  });
}
