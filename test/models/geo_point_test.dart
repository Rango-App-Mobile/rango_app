import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/models/geo_point.dart';

void main() {
  group('GeoPoint', () {
    test('has zero distance to itself', () {
      const point = GeoPoint(lat: -30.0346, lng: -51.2177);
      expect(point.distanceTo(point), 0);
    });

    test('measures one degree of latitude as about 111.19 km', () {
      const a = GeoPoint(lat: 0, lng: 0);
      const b = GeoPoint(lat: 1, lng: 0);
      expect(a.distanceTo(b), closeTo(111194.9, 5));
    });

    test('is symmetric for two Porto Alegre points about 1.2 km apart', () {
      const a = GeoPoint(lat: -30.0346, lng: -51.2177);
      const b = GeoPoint(lat: -30.0346, lng: -51.2050);
      // 0.0127 deg of longitude * cos(30.0346 deg) * 111194.9 m/deg.
      expect(a.distanceTo(b), closeTo(1223, 5));
      expect(b.distanceTo(a), closeTo(a.distanceTo(b), 1e-9));
    });
  });
}
