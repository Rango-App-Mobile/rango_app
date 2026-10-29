import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_ranking.dart';

const _origin = GeoPoint(lat: 0, lng: 0);

// One degree of latitude is ~111194.9 m, so place it meters / 111194.9 north.
Restaurant _at(String name, double meters) => Restaurant(
  placeId: name,
  name: name,
  location: GeoPoint(lat: meters / 111194.9266, lng: 0),
);

void main() {
  group('RestaurantRanking', () {
    test('drops places farther than 3000 m', () {
      final ranked = RestaurantRanking.rank([
        _at('near', 1000),
        _at('far', 3100),
      ], _origin);
      expect(ranked.map((r) => r.name), ['near']);
    });

    test('keeps a place right at the 3000 m limit', () {
      final ranked = RestaurantRanking.rank([_at('edge', 2999.999)], _origin);
      expect(ranked, hasLength(1));
      expect(ranked.single.distanceMeters, closeTo(3000, 0.01));
    });

    test('sorts nearest first and breaks ties by name', () {
      final ranked = RestaurantRanking.rank([
        _at('c', 2000),
        _at('b', 500),
        _at('a', 500),
      ], _origin);
      expect(ranked.map((r) => r.name), ['a', 'b', 'c']);
    });

    test('fills distanceMeters from the origin', () {
      final ranked = RestaurantRanking.rank([_at('x', 1500)], _origin);
      expect(ranked.single.distanceMeters, closeTo(1500, 0.5));
    });

    test('caps the list at 20 results', () {
      final places = [for (var i = 0; i < 30; i++) _at('p$i', 10.0 + i)];
      final ranked = RestaurantRanking.rank(places, _origin);
      expect(ranked, hasLength(RestaurantRanking.maxResults));
      expect(ranked.first.name, 'p0');
    });

    test('returns an unmodifiable list', () {
      final ranked = RestaurantRanking.rank([_at('x', 10)], _origin);
      expect(() => ranked.add(_at('y', 20)), throwsUnsupportedError);
    });
  });
}
