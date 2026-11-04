import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/geo_point.dart';

part 'restaurant.freezed.dart';

/// A nearby place that serves the chosen food, coming from Google Places.
/// [distanceMeters] is relative to the person's position at search time.
@freezed
abstract class Restaurant with _$Restaurant {
  const factory Restaurant({
    required String placeId,
    required String name,
    required GeoPoint location,

    /// Places `primaryTypeDisplayName`, e.g. "Restaurante italiano".
    String? cuisine,
    String? address,
    double? rating,

    /// Places photo resource name, e.g. `places/X/photos/Y`.
    String? photoName,

    /// Filled by `RestaurantRanking.rank`; 0 until then.
    @Default(0) double distanceMeters,
  }) = _Restaurant;
}
