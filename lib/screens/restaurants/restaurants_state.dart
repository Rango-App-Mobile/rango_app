import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rango_app/models/geo_point.dart';
import 'package:rango_app/models/restaurant.dart';

part 'restaurants_state.freezed.dart';

/// Where the map screen is in its journey; the View draws from it.
enum RestaurantsStatus {
  locating,
  searching,
  ready,
  empty,
  locationDenied,
  locationDeniedForever,
  locationServiceOff,
  error,
}

@freezed
abstract class RestaurantsState with _$RestaurantsState {
  const factory RestaurantsState({
    required RestaurantsStatus status,
    @Default('') String foodLabel,
    String? foodTheme,

    /// Category photo asset name, the preview fallback when the place has none.
    String? foodPhoto,
    GeoPoint? origin,
    @Default([]) List<Restaurant> restaurants,
    String? selectedId,

    /// Photo URL of the selected restaurant, once fetched.
    String? photoUri,
    String? errorMessage,
  }) = _RestaurantsState;

  const RestaurantsState._();

  Restaurant? get selected {
    for (final restaurant in restaurants) {
      if (restaurant.placeId == selectedId) return restaurant;
    }
    return null;
  }
}
