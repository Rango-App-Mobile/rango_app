import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rango_app/data/firestore_restaurant_repository.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';

abstract interface class RestaurantRepository {
  /// Places within `RestaurantRanking.searchRadiusMeters` of [near] that serve
  /// the food [foodId] (a `FoodCategory.id`), ranked by
  /// `RestaurantRanking.rank` (nearest first). Throws `NetworkFailure` or
  /// `UnexpectedFailure`.
  Future<List<Restaurant>> search({
    required String foodId,
    required GeoPoint near,
  });

  /// The national phone number of the chosen place, or null. Fetched only for
  /// the restaurant the person picked.
  Future<String?> fetchPhone(String placeId);

  /// A short-lived photo URL (no key in it) for a Places photo resource name,
  /// or null. Never throws: a photo never breaks the screen.
  Future<String?> fetchPhotoUri(String photoName);
}

/// The team's restaurants in Firestore by default; `main.dart` swaps in the
/// fictional ones when Firebase is not configured, and tests override this
/// provider.
final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => FirestoreRestaurantRepository(FirebaseFirestore.instance),
);
