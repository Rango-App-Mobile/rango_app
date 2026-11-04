import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/restaurant.dart';

part 'restaurant_contact_args.freezed.dart';

/// What the map hands to the contact screen (06) through the route's `extra`:
/// the chosen restaurant plus what the map already knows about it, so the
/// contact screen does not search again.
@freezed
abstract class RestaurantContactArgs with _$RestaurantContactArgs {
  const factory RestaurantContactArgs({
    required Restaurant restaurant,

    /// `FoodCategory.foodTheme` of the chosen food, for the photo placeholder.
    String? foodTheme,

    /// Photo URL the map already fetched for the selected pin, if any.
    String? photoUri,
  }) = _RestaurantContactArgs;
}
