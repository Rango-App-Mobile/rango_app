// The Firestore SDK types are sealed; mocking them is the only way to test.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rango_app/core/error/failure.dart';
import 'package:rango_app/data/firestore_restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';

class _MockFirestore extends Mock implements firestore.FirebaseFirestore {}

class _MockCollection extends Mock
    implements firestore.CollectionReference<Map<String, dynamic>> {}

class _MockQuery extends Mock
    implements firestore.Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements firestore.QuerySnapshot<Map<String, dynamic>> {}

class _MockQueryDoc extends Mock
    implements firestore.QueryDocumentSnapshot<Map<String, dynamic>> {}

class _MockDoc extends Mock
    implements firestore.DocumentReference<Map<String, dynamic>> {}

class _MockDocSnapshot extends Mock
    implements firestore.DocumentSnapshot<Map<String, dynamic>> {}

const _near = GeoPoint(lat: -30.0277, lng: -51.2287);

/// A restaurant document as the sheet sync writes it, [dLat] degrees north of
/// [_near] (0.01 deg is about 1.1 km).
Map<String, dynamic> _place(
  String name, {
  double dLat = 0.001,
  bool active = true,
  Object? rating = 4.5,
}) => {
  'name': name,
  'location': firestore.GeoPoint(_near.lat + dLat, _near.lng),
  'foods': ['spaghetti'],
  'cuisine': 'Italiana',
  'address': 'Rua A, 1',
  'rating': rating,
  'phone': '(51) 3333-0000',
  'active': active,
};

void main() {
  late _MockFirestore db;
  late _MockCollection collection;
  late _MockQuery byFood;
  late _MockQuery limited;
  late FirestoreRestaurantRepository repository;

  void stubDocs(Map<String, Map<String, dynamic>> docs) {
    final queryDocs = <_MockQueryDoc>[];
    for (final MapEntry(:key, :value) in docs.entries) {
      final doc = _MockQueryDoc();
      when(() => doc.id).thenReturn(key);
      when(doc.data).thenReturn(value);
      queryDocs.add(doc);
    }
    final snapshot = _MockQuerySnapshot();
    when(() => snapshot.docs).thenReturn(queryDocs);
    when(limited.get).thenAnswer((_) async => snapshot);
  }

  setUp(() {
    db = _MockFirestore();
    collection = _MockCollection();
    byFood = _MockQuery();
    limited = _MockQuery();
    when(() => db.collection('restaurants')).thenReturn(collection);
    when(
      () => collection.where('foods', arrayContains: 'spaghetti'),
    ).thenReturn(byFood);
    when(() => byFood.limit(any())).thenReturn(limited);
    repository = FirestoreRestaurantRepository(
      db,
      timeout: const Duration(milliseconds: 50),
    );
  });

  group('search', () {
    test('asks Firestore only for places that serve the food', () async {
      stubDocs({});
      await repository.search(foodId: 'spaghetti', near: _near);
      verify(
        () => collection.where('foods', arrayContains: 'spaghetti'),
      ).called(1);
    });

    test('maps documents to restaurants, nearest first', () async {
      stubDocs({
        'far': _place('Longe', dLat: 0.02),
        'near': _place('Perto'),
      });

      final result = await repository.search(foodId: 'spaghetti', near: _near);

      expect(result.map((r) => r.placeId), ['near', 'far']);
      final first = result.first;
      expect(first.name, 'Perto');
      expect(first.cuisine, 'Italiana');
      expect(first.address, 'Rua A, 1');
      expect(first.rating, 4.5);
      expect(first.location.lat, closeTo(_near.lat + 0.001, 1e-9));
      expect(first.distanceMeters, greaterThan(0));
    });

    test('drops places beyond 3 km', () async {
      stubDocs({'far': _place('Longe', dLat: 0.05)});
      expect(
        await repository.search(foodId: 'spaghetti', near: _near),
        isEmpty,
      );
    });

    test('drops inactive places and those without name or position', () {
      stubDocs({
        'off': _place('Saiu', active: false),
        'unnamed': _place(' '),
        'nowhere': {..._place('Sem lugar'), 'location': null},
      });
      expect(
        repository.search(foodId: 'spaghetti', near: _near),
        completion(isEmpty),
      );
    });

    test('reads an integer rating and a null one', () async {
      stubDocs({'a': _place('A', rating: 4), 'b': _place('B', rating: null)});
      final result = await repository.search(foodId: 'spaghetti', near: _near);
      expect(
        {for (final r in result) r.placeId: r.rating},
        {'a': 4.0, 'b': null},
      );
    });

    test('unavailable Firestore becomes NetworkFailure', () {
      when(limited.get).thenThrow(
        firestore.FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unavailable',
        ),
      );
      expect(
        repository.search(foodId: 'spaghetti', near: _near),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('a timeout becomes NetworkFailure', () {
      when(limited.get).thenAnswer(
        (_) =>
            Completer<firestore.QuerySnapshot<Map<String, dynamic>>>().future,
      );
      expect(
        repository.search(foodId: 'spaghetti', near: _near),
        throwsA(isA<NetworkFailure>()),
      );
    });

    test('other Firebase errors become UnexpectedFailure', () {
      when(limited.get).thenThrow(
        firestore.FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
        ),
      );
      expect(
        repository.search(foodId: 'spaghetti', near: _near),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });

  group('fetchPhone', () {
    late _MockDoc doc;

    void stubPhone(Object? phone) {
      final snapshot = _MockDocSnapshot();
      when(snapshot.data).thenReturn({'phone': phone});
      when(doc.get).thenAnswer((_) async => snapshot);
    }

    setUp(() {
      doc = _MockDoc();
      when(() => collection.doc('p1')).thenReturn(doc);
    });

    test('reads the phone of the document', () async {
      stubPhone(' (51) 3333-0000 ');
      expect(await repository.fetchPhone('p1'), '(51) 3333-0000');
    });

    test('returns null when there is no phone', () async {
      stubPhone(null);
      expect(await repository.fetchPhone('p1'), isNull);
    });
  });

  test('fetchPhotoUri returns null', () async {
    expect(await repository.fetchPhotoUri('x'), isNull);
  });
}
