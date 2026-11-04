import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';

/// R4: only places within 3 km of the person, nearest first
/// (docs/contexto.md §7).
abstract final class RestaurantRanking {
  static const searchRadiusMeters = 3000;
  static const maxResults = 20;

  /// Fills each place's distance from [origin], drops those beyond
  /// [searchRadiusMeters], sorts nearest first (ties by name) and keeps at
  /// most [maxResults].
  static List<Restaurant> rank(Iterable<Restaurant> places, GeoPoint origin) {
    final ranked =
        [
              for (final place in places)
                place.copyWith(
                  distanceMeters: origin.distanceTo(place.location),
                ),
            ]
            .where((place) => place.distanceMeters <= searchRadiusMeters)
            .toList()
          ..sort((a, b) {
            final byDistance = a.distanceMeters.compareTo(b.distanceMeters);
            return byDistance != 0 ? byDistance : a.name.compareTo(b.name);
          });
    return List.unmodifiable(ranked.take(maxResults));
  }
}
