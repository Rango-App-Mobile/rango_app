import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/geo_point.dart';

part 'restaurant.freezed.dart';

/// A nearby place that serves the chosen food.
/// [distanceMeters] is relative to the person's position at search time.
@freezed
abstract class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String placeId,
    required String name,
    required GeoPoint location,

    /// Kind of place, e.g. "Restaurante italiano".
    String? cuisine,
    String? address,
    double? rating,

    /// Reference that `RestaurantRepository.fetchPhotoUri` resolves to a URL.
    String? photoName,

    /// Filled by `RestaurantRanking.rank`; 0 until then.
    @Default(0) double distanceMeters,
  }) = _Restaurant;
}
