import 'package:flutter_test/flutter_test.dart';
import 'package:rango_app/core/format/restaurant_format.dart';

void main() {
  group('formatRating', () {
    test('uses one decimal and a comma', () {
      expect(formatRating(4.7), '4,7');
      expect(formatRating(5), '5,0');
      expect(formatRating(4.75), '4,8');
    });
  });

  group('formatDistance', () {
    test('uses whole meters below 1 km', () {
      expect(formatDistance(850), '850 m');
      expect(formatDistance(849.6), '850 m');
      expect(formatDistance(999), '999 m');
    });

    test('uses km with one decimal and a comma from 1 km', () {
      expect(formatDistance(1000), '1,0 km');
      expect(formatDistance(1234), '1,2 km');
      expect(formatDistance(12500), '12,5 km');
    });
  });
}
