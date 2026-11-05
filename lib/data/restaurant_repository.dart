import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/fake_restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';

abstract interface class RestaurantRepository {
  /// Places within `RestaurantRanking.searchRadiusMeters` of [near] that match
  /// [keyword], ranked by `RestaurantRanking.rank` (nearest first). Throws
  /// `NetworkFailure` or `UnexpectedFailure`.
  Future<List<Restaurant>> search({
    required String keyword,
    required GeoPoint near,
  });

  /// The national phone number of the chosen place, or null. Fetched only for
  /// the restaurant the person picked.
  Future<String?> fetchPhone(String placeId);

  /// A short-lived photo URL (no key in it) for a Places photo resource name,
  /// or null. Never throws: a photo never breaks the screen.
  Future<String?> fetchPhotoUri(String photoName);
}

/// Fictional restaurants until the team's own Firestore data arrives.
final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => FakeRestaurantRepository(),
);
