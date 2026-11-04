import 'package:rango_app/data/restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';
import 'package:rango_app/models/restaurant_ranking.dart';

/// In-memory restaurants around the given position, no network. Used while
/// there is no Google key.
class FakeRestaurantRepository implements RestaurantRepository {
  // (name, cuisine, rating, dLat, dLng) in degrees; 0.01 deg is about 1.1 km.
  static const List<(String, String, double?, double, double)> _seed = [
    ('Cantina da Nona', 'Restaurante italiano', 4.6, 0.002, 0.001),
    ('Bistrô do Centro', 'Bistrô', 4.3, -0.004, 0.003),
    ('Casa da Esquina', 'Restaurante', 4.1, 0.006, -0.002),
    ('Forno e Lenha', 'Pizzaria', 4.7, -0.008, -0.004),
    ('Sabor de Casa', 'Restaurante', null, 0.010, 0.006),
    ('Mesa Viva', 'Restaurante', 3.9, -0.012, 0.010),
    ('Empório do Chef', 'Restaurante', 4.4, 0.016, -0.012),
    // Beyond 3 km: the ranking must cut it.
    ('Recanto Distante', 'Restaurante', 4.8, 0.040, 0.040),
  ];

  @override
  Future<List<Restaurant>> search({
    required String keyword,
    required GeoPoint near,
  }) async {
    final places = [
      for (final (i, seed) in _seed.indexed)
        Restaurant(
          placeId: 'fake-$i',
          name: seed.$1,
          cuisine: seed.$2,
          rating: seed.$3,
          address: 'Rua Exemplo, ${100 + i * 10} - Centro',
          location: GeoPoint(lat: near.lat + seed.$4, lng: near.lng + seed.$5),
        ),
    ];
    return RestaurantRanking.rank(places, near);
  }

  /// Even-numbered fake ids (`fake-0`, `fake-2`...) have a phone; the others
  /// have none, so the "no phone" state can be exercised.
  @override
  Future<String?> fetchPhone(String placeId) async {
    final index = int.tryParse(placeId.replaceFirst('fake-', ''));
    if (index == null || index.isOdd) return null;
    return '(51) 3333-${index.toString().padLeft(4, '0')}';
  }

  @override
  Future<String?> fetchPhotoUri(String photoName) async => null;
}
