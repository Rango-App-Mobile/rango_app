import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/data/fake_restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant_ranking.dart';

void main() {
  const near = GeoPoint(lat: -30.0277, lng: -51.2287);
  final repository = FakeRestaurantRepository();

  test('search ranks nearest first, all within 3 km', () async {
    final result = await repository.search(keyword: 'massa', near: near);

    expect(result, isNotEmpty);
    expect(
      result.map((r) => r.distanceMeters),
      everyElement(lessThanOrEqualTo(RestaurantRanking.searchRadiusMeters)),
    );
    final distances = result.map((r) => r.distanceMeters).toList();
    expect(distances, [...distances]..sort());
  });

  test('search cuts the place beyond 3 km', () async {
    final result = await repository.search(keyword: 'massa', near: near);

    expect(result.map((r) => r.name), isNot(contains('Recanto Distante')));
  });

  test('search is deterministic', () async {
    final a = await repository.search(keyword: 'massa', near: near);
    final b = await repository.search(keyword: 'massa', near: near);

    expect(a, b);
  });

  test('fetchPhone returns a number for even ids and null for odd', () async {
    expect(await repository.fetchPhone('fake-0'), '(51) 3333-0000');
    expect(await repository.fetchPhone('fake-1'), isNull);
    expect(await repository.fetchPhone('other'), isNull);
  });

  test('fetchPhotoUri returns null', () async {
    expect(await repository.fetchPhotoUri('places/x/photos/y'), isNull);
  });
}
